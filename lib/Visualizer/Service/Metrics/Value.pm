package Visualizer::Service::Metrics::Value;
use sane;
use parent 'Visualizer::Service';
use Constant::Exporter (
    EXPORT_OK => {
        map { ($_ => $_) } qw/ ERROR_METRICS_NOT_FOUND /
    }
);


__PACKAGE__->add_validator(
    create_hourly => {
        name     => { isa => 'Metrics::Name'     },
        datetime => { isa => 'Metrics::DateTime' },
        value    => { isa => 'Metrics::Value'    },
    }
);

sub create_hourly {
    my $class = shift;
    my $args  = $class->validate(create_hourly => @_);

    $class->connect('DB_MASTER')->txn(sub {
        my $dbh = shift;

        my $metrics = do {
            my ($stmt, @bind) = $class->sql->select(
                metrics => ['*'], {
                    metrics_name => $args->{name},
                }
            );
            $dbh->selectrow_hashref($stmt, undef, @bind);
        };

        unless ($metrics) {
            Visualizer::Exception->throw(ERROR_METRICS_NOT_FOUND);
        }

        my $now = time;
        my ($stmt, @bind) = $class->sql->insert(
            metrics_values => {
                metrics_id => $metrics->{metrics_id},
                timestamp  => $args->{datetime},
                value      => $args->{value},
                year       => \[ 'YEAR(?)',  $args->{datetime} ],
                month      => \[ 'MONTH(?)', $args->{datetime} ],
                day        => \[ 'DAY(?)',   $args->{datetime} ],
                hour       => \[ 'HOUR(?)',  $args->{datetime} ],
                created_at => $now,
                updated_at => $now,
            }, {
                update => {
                    value      => \'VALUES(valeu)',
                    updated_at => \'VALUES(updated_at)',
                }
            }
        );
        $dbh->do($stmt, undef, @bind);
    });

    return;
}

1;
__END__
