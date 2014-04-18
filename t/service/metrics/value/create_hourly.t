use sane;
use Test::Alpaca;
use Visualizer::Service::Metrics::Value;

my $guards = Test::Alpaca->setup(
    mysqld => {
        schema_class => 'Schema'
    }
);

sub dbh { Visualizer::Service::Metrics::Value->connect('DB_MASTER')->dbh }

subtest 'success' => sub {
    my $guard = Test::Alpaca->init_database(
        DB_MASTER => {
            metrics => [
                { metrics_name => 'foo', owner_id => 1 }
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
            dbh->selectall_arrayref(
                "SELECT * FROM metrics_values",
                { Slice => {} }
            );
        },
        expect => [
            {
                metrics_id => 1,
                timestamp  => '2014-03-04 00:00:00',
                value      => 100,
                year       => 2014,
                month      => 3,
                day        => 4,
                hour       => 0,
                created_at => re(qr/\d+/),
                updated_at => re(qr/\d+/),
            }
        ];
};

subtest 'fail' => sub {
    test_is_deeply 'should raise validation error if datetime is not rounded',
        run => sub {
            Visualizer::Service::Metrics::Value->create_hourly(
                name     => 'foo',
                datetime => '2014-03-04 20:40:42',
                value    => 200,
            );
        },
        exception => sub {
            my $e = shift;
            isa_ok $e, 'Alpaca::Exception::ValidationError';
            like $e, qr/Invalid value for 'datetime'/;
        };
};

done_testing;

