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
            credentials => [
                { token => 'foo', client_name => 'client', created_at => time, updated_at => time }
            ],
            metrics => [
                { metrics_name => 'foo', description => 1 }
            ],
        }
    );

    test_cmp_deeply 'should be created',
        sub {
            Visualizer::Service::Metrics::Value->create_hourly(
                name     => 'foo',
                datetime => '2014-03-04 00:00:00',
                value    => 100,
                token    => 'foo',
            );
            dbh->selectall_arrayref(
                "SELECT * FROM metrics_values",
                { Slice => {} }
            );
        },
        [
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
    test_exception 'should raise validation error if datetime is not rounded',
        sub {
            Visualizer::Service::Metrics::Value->create_hourly(
                name     => 'foo',
                datetime => '2014-03-04 20:40:42',
                value    => 200,
            );
        },
        sub {
            my $e = shift;
            isa_ok $e, 'Alpaca::Exception::ValidationError';
            like $e, qr/Invalid value for 'datetime'/;
        };
};

done_testing;

