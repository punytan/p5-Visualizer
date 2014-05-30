package Visualizer::Web::Handler;
use sane;
use parent 'Aqua::Handler';
use Data::Dumper;

sub log {
    shift; warn Dumper [ @_ ];
}

1;
__END__
