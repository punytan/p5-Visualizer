package Visualizer::Service;
use sane;
use Visualizer::Types;
use parent 'Alpaca::Service';

__PACKAGE__->config->add(
    DB_MASTER => {
        dsn  => 'dbi:mysql:visualizer',
        user => undef, # TBD
        pass => undef,
        attr => {
            RaiseError => 1,
            AutoCommit => 0,
            PrintError => 1,
            ShowErrorStatement  => 1,
            AutoInactiveDestroy => 1,
            mysql_enable_utf8   => 1,
        }
    },
);

__PACKAGE__->config->add(
    DB_SLAVE => [
        {
            dsn  => 'dbi:mysql:visualizer',
            user => undef, # TBD
            pass => undef,
            attr => {
                RaiseError => 1,
                AutoCommit => 0,
                PrintError => 1,
                ShowErrorStatement  => 1,
                AutoInactiveDestroy => 1,
                mysql_enable_utf8   => 1,
            }
        }
    ]
);

1;
__END__
