use sane;
use Test::Alpaca;
use Visualizer::Service::Metrics::Value;

my $guards = Test::Alpaca->setup(
    mysqld => {
        schema_class => 'Schema'
    }
);

subtest 'success' => sub {
    my $guard = Test::Alpaca->init_database(
        DB_MASTER => {
            metrics => [
                {
                    metrics_name => 'foo',
                    owner_id => 1,
                }
            ],
        }
    );

    test_cmp_deeply 'should be created',
        run => sub {
            Visualizer::Service::Metrics::Value->create_hourly(
                name     => 'foo',
                datetime => '2014-03-04 00:00:00',
                value    => 100,
            );
            Visualizer::Service::Metrics::Value->connect('DB_MASTER')->dbh->selectall_arrayref(
                "SELECT * FROM metrics_values",
                { Slice => {} }
            );
        },
        expect => [
            {
                metrics_id => 1,
                resolution => 'YMDH',
                aggregator => 'count',
                ts         => '2014-03-04 00:00:00',
                val        => 100,
                created_at => re(qr/\d+/),
                updated_at => re(qr/\d+/),
            }
        ];

};

done_testing;

