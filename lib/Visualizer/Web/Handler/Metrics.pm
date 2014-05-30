package Visualizer::Web::Handler::Metrics;
use sane;
use parent 'Visualizer::Web::Handler';
use Visualizer::Service::Metrics 'ERROR_METRICS_NOT_FOUND';

sub list {
    my ($self, $context) = @_;

    my $metrics = eval { Visualizer::Service::Metrics->get_metrics; };
    if (my $e = $@) {
        if (ref $e eq 'Visualizer::Service::Exception'){
            if ($e->{code} eq ERROR_METRICS_NOT_FOUND()) {
                $self->write_json({}, 404);
            }
        }
        $self->log(fatal => $e);
        $self->write_json({}, 500);
    }

    $self->write_json($metrics);
}

1;
__END__
