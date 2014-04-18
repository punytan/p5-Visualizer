package Visualizer::Service::Metrics::History;
use sane;
use parent 'Visualizer::Service';
use Visualizer::DateTime::Iterator;
use DateTime;
use Constant::Exporter (
    EXPORT_OK => {
        map { ($_ => $_) } qw/ ERROR_METRICS_NOT_FOUND /
    }
);

__PACKAGE__->add_validator(
    get_y_resolution => {
        metrics_id => { isa => 'Metrics::ID' },
        year       => { isa => 'Metrics::Year'  },
        aggregator => {
            isa     => 'Metrics::Aggregator',
            default => 'sum',
        },
    }
);

sub get_y_resolution {
    my $class = shift;
    my $args  = $class->validate(get_y_resolution => @_);

    my $metrics = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my $aggregator = $args->{aggregator};
        my ($stmt, @bind) = $class->sql->select(
            metrics_values => [
                \'DATE_FORMAT(timestamp, "%Y-%m-01") AS datetime',
                \"$aggregator(value) AS $aggregator" # :p
            ],
            {
                metrics_id => $args->{metrics_id},
                year       => $args->{year},
            },
            {
                group_by => 'month'
            }
        );

        return $dbh->selectall_arrayref($stmt, { Slice => {} }, @bind);
    });

    return $metrics;
}

__PACKAGE__->add_validator(
    get_ym_resolution => {
        metrics_id => { isa => 'Metrics::ID' },
        year       => { isa => 'Metrics::Year'  },
        month      => { isa => 'Metrics::Month' },
        aggregator => {
            isa     => 'Metrics::Aggregator',
            default => 'sum',
        },
    }
);

sub get_ym_resolution {
    my $class = shift;
    my $args  = $class->validate(get_ym_resolution => @_);

    my $metrics = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my $aggregator = $args->{aggregator};
        my ($stmt, @bind) = $class->sql->select(
            metrics_values => [
                \'DATE_FORMAT(timestamp, "%Y-%m-%d") AS datetime',
                \"$aggregator(value) AS $aggregator" # :p
            ],
            {
                metrics_id => $args->{metrics_id},
                year       => $args->{year},
                month      => $args->{month},
            },
            {
                group_by => 'day'
            }
        );

        return $dbh->selectall_arrayref($stmt, { Slice => {} }, @bind);
    });

    return $metrics;
}

__PACKAGE__->add_validator(
    get_ymd_resolution => {
        metrics_id => { isa => 'Metrics::ID' },
        year       => { isa => 'Metrics::Year'  },
        month      => { isa => 'Metrics::Month' },
        day        => { isa => 'Metrics::Day'   },
        aggregator => {
            isa     => 'Metrics::Aggregator',
            default => 'sum',
        },
    }
);

sub get_ymd_resolution {
    my $class = shift;
    my $args  = $class->validate(get_ymd_resolution => @_);

    my $metrics = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my $aggregator = $args->{aggregator};
        my ($stmt, @bind) = $class->sql->select(
            metrics_values => [
                \'DATE_FORMAT(timestamp, "%Y-%m-%d %H:00:00") as datetime',
                \"$aggregator(value) AS $aggregator" # :p
            ],
            {
                metrics_id => $args->{metrics_id},
                year       => $args->{year},
                month      => $args->{month},
                day        => $args->{day},
            },
            {
                group_by => 'hour'
            }
        );

        return $dbh->selectall_arrayref($stmt, { Slice => {} }, @bind);
    });

    return $metrics;
}

__PACKAGE__->add_validator(
    get_ymdh_resolution => {
        metrics_id => { isa => 'Metrics::ID'  },
        year       => { isa => 'Metrics::Year'  },
        month      => { isa => 'Metrics::Month' },
        day        => { isa => 'Metrics::Day'   },
        hour       => { isa => 'Metrics::Hour'  },
        aggregator => {
            isa     => 'Metrics::Aggregator',
            default => 'sum',
        },
    }
);

sub get_ymdh_resolution {
    my $class = shift;
    my $args  = $class->validate(get_ymdh_resolution => @_);

    my $metrics = $class->connect('DB_SLAVE')->run(sub {
        my $dbh = shift;

        my $aggregator = $args->{aggregator};
        my ($stmt, @bind) = $class->sql->select(
            metrics_values => [
                \'DATE_FORMAT(timestamp, "%Y-%m-%d %H:00:00") as datetime',
                \"$aggregator(value) AS $aggregator" # :p
            ],
            {
                metrics_id => $args->{metrics_id},
                year       => $args->{year},
                month      => $args->{month},
                day        => $args->{day},
                hour       => $args->{hour},
            },
            {
                order_by => { datetime => 'ASC' }
            }
        );

        return $dbh->selectall_arrayref($stmt, { Slice => {} }, @bind);
    });

    return $metrics;
}

1;
__END__
