use sane;
use Test::Alpaca;
use Visualizer::Service::Metrics::Value;
use Visualizer::Service::Metrics::History;

my $guards = Test::Alpaca->setup(
    mysqld => {
        schema_class => 'Schema'
    }
);

sub dbh { Visualizer::Service::Metrics::Value->connect('DB_MASTER')->dbh }

my $guard = Test::Alpaca->init_database(
    DB_MASTER => {
        metrics => [
            { metrics_name => 'foo', owner_id => 1 }
        ],
    }
);

my @data = (
    [ 'foo', '2014-03-04 00:00:00', 100 ],
    [ 'foo', '2014-03-05 00:00:00', 100 ],
    [ 'foo', '2014-03-06 00:00:00', 100 ],
    [ 'foo', '2014-03-06 01:00:00', 100 ],
    [ 'foo', '2014-03-06 02:00:00', 100 ],
    [ 'foo', '2014-04-04 00:00:00', 100 ],
    [ 'foo', '2014-04-04 23:00:00', 100 ],
    [ 'foo', '2014-04-05 00:00:00', 100 ],
    [ 'foo', '2014-05-05 00:00:00', 100 ],
);

for (@data) {
    Visualizer::Service::Metrics::Value->create_hourly(
        name     => $_->[0],
        datetime => $_->[1],
        value    => $_->[2],
    );
}

test_cmp_deeply 'get_ymdh_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_ymdh_resolution(
            metrics_id => 1,
            year  => 2014,
            month => 3,
            day   => 6,
            hour  => 2,
            aggregator => 'sum',
        );
    },
    expect => [
        { datetime => '2014-03-06 02:00:00', sum => 100 }
    ];

test_cmp_deeply 'get_ymd_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_ymd_resolution(
            metrics_id => 1,
            year  => 2014,
            month => 3,
            day   => 6,
            aggregator => 'sum',
        );
    },
    expect => [
        { datetime => '2014-03-06 00:00:00', sum => 100 },
        { datetime => '2014-03-06 01:00:00', sum => 100 },
        { datetime => '2014-03-06 02:00:00', sum => 100 },
    ];

test_cmp_deeply 'get_ym_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_ym_resolution(
            metrics_id => 1,
            year       => 2014,
            month      => 3,
            aggregator => 'sum',
        );
    },
    expect => [
        { datetime => '2014-03-04', sum => 100 },
        { datetime => '2014-03-05', sum => 100 },
        { datetime => '2014-03-06', sum => 300 },
    ];

test_cmp_deeply 'get_y_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_y_resolution(
            metrics_id => 1,
            year       => 2014,
            aggregator => 'sum',
        );
    },
    expect => [
        { datetime => '2014-03-01', sum => 500 },
        { datetime => '2014-04-01', sum => 300 },
        { datetime => '2014-05-01', sum => 100 },
    ];

done_testing;

