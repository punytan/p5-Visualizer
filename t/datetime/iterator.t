use sane;
use Test::Alpaca;
use Visualizer::DateTime::Iterator;

my $start = '2014-02-26 00:00:00';
my $end   = '2014-03-02 00:00:00';

test_is_deeply "$start -> $end by hourly",
    run => sub {
        my $iter = Visualizer::DateTime::Iterator->new($start, $end, { hours => 1 });

        my @result;
        while (my $dt = $iter->next) {
            push @result, $dt->strftime('%Y-%m-%d %T');
        }

        return [ @result ];
    },
    expect => [
        (map { sprintf "2014-02-26 %02d:00:00", $_ } 0 .. 23),
        (map { sprintf "2014-02-27 %02d:00:00", $_ } 0 .. 23),
        (map { sprintf "2014-02-28 %02d:00:00", $_ } 0 .. 23),
        (map { sprintf "2014-03-01 %02d:00:00", $_ } 0 .. 23),
        '2014-03-02 00:00:00',
    ];

test_is_deeply "2003-01-01 00:00:00 -> 2005-01-01 00:00:00  by monthly",
    run => sub {
        my $iter = Visualizer::DateTime::Iterator->new(
            "2003-01-01 00:00:00",
            "2005-01-01 00:00:00",
            { months => 1 }
        );

        my @result;
        while (my $dt = $iter->next) {
            push @result, $dt->strftime('%Y-%m-%d %T');
        }

        return [ @result ];
    },
    expect => [
        (map { sprintf "2003-%02d-01 00:00:00", $_ } 1 .. 12),
        (map { sprintf "2004-%02d-01 00:00:00", $_ } 1 .. 12),
        "2005-01-01 00:00:00",
    ];

done_testing;

