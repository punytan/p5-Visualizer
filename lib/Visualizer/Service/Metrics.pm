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

    my $metrics = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my ($stmt, @bind) = $class->sql->select(
            metrics => ['*'], {
                metrics_name => $args->{name},
            }
        );

        if (my $metrics = $dbh->selectrow_hashref($stmt, undef, @bind)) {
            return $metrics;
        } else {
            $class->throw(ERROR_METRICS_NOT_FOUND());
        }
    });

    return $metrics;
}

sub get_metrics {
    my $class = shift;

    my $all = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my ($stmt, @bind) = $class->sql->select(
            metrics => ['*'],
            { },
            { order_by => { metrics_id => 'ASC' } }
        );

        $dbh->selectall_arrayref($stmt, { Slice => {} }, @bind);
    });

    return $all;
}

1;
__END__

