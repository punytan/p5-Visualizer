package Visualizer::Types;
use sane;
use Time::Piece ();
use Mouse::Util::TypeConstraints;

enum 'Metrics::Resolution'
    => qw/ Y YM YMD YMDH /;

enum 'Metrics::Aggregator'
    => qw/ count sum average max min /;

subtype 'Metrics::DateTime'
    => as 'Str',
    => where { eval { Time::Piece::localtime->strptime($_, "%Y-%m-%d %T") } };

subtype 'Metrics::Name'
    => as 'Str'
    => where { defined $_ && length $_ };

subtype 'Metrics::Value'
    => as 'Int'
    => where { defined $_ && length $_ && /^[0-9]+$/ };

1;
__END__
