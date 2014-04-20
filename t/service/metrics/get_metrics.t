use sane;
use Test::Alpaca;
use Visualizer::Service::Metrics 'ERROR_METRICS_NOT_FOUND';

my $guards = Test::Alpaca->setup(
    mysqld => {
        schema_class => 'Schema'
    }
);

sub dbh { Visualizer::Service::Metrics->connect('DB_MASTER')->dbh }

subtest 'success' => sub {
    my $guard = Test::Alpaca->init_database(
        DB_MASTER => {
            metrics => [
                { metrics_name => 'foo', description => 'foo foo' },
                { metrics_name => 'bar', description => 'bar bar' },
            ],
        }
    );

    test_cmp_deeply 'should be created',
        sub {
            Visualizer::Service::Metrics->get_metrics();
        },
        [
            {
                metrics_id   => 1,
                metrics_name => 'foo',
                description  => 'foo foo',
                created_at => re(qr/\d+/),
                updated_at => re(qr/\d+/),
            },
            {
                metrics_id   => 2,
                metrics_name => 'bar',
                description  => 'bar bar',
                created_at => re(qr/\d+/),
                updated_at => re(qr/\d+/),
            }
        ];
};

done_testing;

