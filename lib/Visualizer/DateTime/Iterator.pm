package Visualizer::DateTime::Iterator;
use sane;
use DateTime;
use DateTime::Duration;
use Time::Piece;

sub as_epoch { shift; gmtime->strptime(shift, "%Y-%m-%d %T")->epoch }

sub new {
    my ($class, $start, $end, $duration_args) = @_;

    my $current  = DateTime->from_epoch(epoch => $class->as_epoch($start));
    my $start_dt = DateTime->from_epoch(epoch => $class->as_epoch($start));
    my $end_dt   = DateTime->from_epoch(epoch => $class->as_epoch($end));
    my $duration = DateTime::Duration->new(%$duration_args);

    bless {
        start   => $start_dt,
        end     => $end_dt,
        current => $current,
        step_duration => $duration,
        is_initial => 1,
    }, $class;
}

sub next {
    my $self = shift;

    if ($self->{is_initial}) {
        $self->{is_initial} = undef;
        return $self->{current};
    } elsif ($self->{current} < $self->{end}) {
        $self->{current} += $self->{step_duration};
        return $self->{current};
    } else {
        return;
    }
}

1;
__END__
