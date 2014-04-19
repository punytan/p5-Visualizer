package Visualizer::Types;
use sane;
use Time::Piece ();
use Scalar::Util 'looks_like_number';
use Mouse::Util::TypeConstraints;

enum 'Metrics::Resolution'
    => qw/ Y YM YMD YMDH /;

subtype 'Metrics::DateTime'
    => as 'Str',
    => where {
        defined $_ && length $_ && /^\d{4}-\d{2}-\d{2} \d{2}:00:00$/
        && eval { Time::Piece::localtime->strptime($_, "%Y-%m-%d %T") }
    };

subtype 'Metrics::Name'
    => as 'Str'
    => where { defined $_ && length $_ };

subtype 'Metrics::Value'
    => as 'Int'
    => where { looks_like_number $_ };

subtype 'Metrics::Year'
    => as 'Int',
    => where { looks_like_number $_ && $_ >= 0 };

subtype 'Metrics::Month'
    => as 'Int',
    => where { looks_like_number $_ && $_ >= 1 && $_ <= 12 };

subtype 'Metrics::Day'
    => as 'Int',
    => where { looks_like_number $_ && $_ >= 1 && $_ <= 31 };

subtype 'Metrics::Hour'
    => as 'Int',
    => where { looks_like_number $_ && $_ >= 0 && $_ <= 23 };

subtype 'Metrics::ID'
    => as 'Int',
    => where { looks_like_number $_ && $_ >= 1 };

1;
__END__
