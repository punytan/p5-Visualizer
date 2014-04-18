package Visualizer::Service::Metrics;
use sane;
use parent 'Visualizer::Service';
use Visualizer::Constant 'ERROR_METRICS_NOT_FOUND';

__PACKAGE__->add_validator(
    get_metrics_metadata => {
        name => { isa => 'Metrics::Name' },
    }
);

sub get_metrics_metadata {
    my $class = shift;
    my $args  = $class->validate(get_metrics_metadata => @_);

    my $metrics = $class->connect('DB_SLAVE')->txn(sub {
        my $dbh = shift;

        my ($stmt, @bind) = $class->sql->select(
            metrics => ['*'], {
                metrics_name => $args->{name},
            }
        );

        if (my $metrics = $dbh->selectrow_hashref($stmt, undef, @bind)) {
            return $metrics;
        } else {
            Visualizer::Exception->throw(ERROR_METRICS_NOT_FOUND);
        }
    });

    return $metrics;
}

1;
__END__

