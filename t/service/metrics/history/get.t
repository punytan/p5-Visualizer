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
    [ 'foo', '2014-03-05 00:00:00', 200 ],
    [ 'foo', '2014-03-06 00:00:00', 300 ],
    [ 'foo', '2014-03-06 01:00:00', 400 ],
    [ 'foo', '2014-03-06 02:00:00', 500 ],
    [ 'foo', '2014-04-04 00:00:00', 600 ],
    [ 'foo', '2014-04-04 23:00:00', 700 ],
    [ 'foo', '2014-04-05 00:00:00', 800 ],
    [ 'foo', '2014-05-05 00:00:00', 900 ],
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
        );
    },
    expect => [
        { datetime => '2014-03-06 02:00:00', sum => 500, count => 1, max => 500, min => 500, avg => '500.0000' }
    ];

test_cmp_deeply 'get_ymd_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_ymd_resolution(
            metrics_id => 1,
            year  => 2014,
            month => 3,
            day   => 6,
        );
    },
    expect => [
        { datetime => '2014-03-06 00:00:00', sum => 300, count => 1, max => 300, min => 300, avg => '300.0000' },
        { datetime => '2014-03-06 01:00:00', sum => 400, count => 1, max => 400, min => 400, avg => '400.0000' },
        { datetime => '2014-03-06 02:00:00', sum => 500, count => 1, max => 500, min => 500, avg => '500.0000' },
    ];

test_cmp_deeply 'get_ym_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_ym_resolution(
            metrics_id => 1,
            year       => 2014,
            month      => 3,
        );
    },
    expect => [
        { datetime => '2014-03-04', sum => 100,  count => 1, max => 100, min => 100, avg => '100.0000' },
        { datetime => '2014-03-05', sum => 200,  count => 1, max => 200, min => 200, avg => '200.0000' },
        { datetime => '2014-03-06', sum => 1200, count => 3, max => 500, min => 300, avg => '400.0000' },
    ];

test_cmp_deeply 'get_y_resolution',
    run => sub {
        Visualizer::Service::Metrics::History->get_y_resolution(
            metrics_id => 1,
            year       => 2014,
        );
    },
    expect => [
        { datetime => '2014-03-01', sum => 1500, count => 5, max => 500, min => 100, avg => '300.0000' },
        { datetime => '2014-04-01', sum => 2100, count => 3, max => 800, min => 600, avg => '700.0000' },
        { datetime => '2014-05-01', sum => 900,  count => 1, max => 900, min => 900, avg => '900.0000' },
    ];

done_testing;

