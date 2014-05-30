package Visualizer::Web::Handler::API::Metrics;
use sane;
use parent 'Visualizer::Web::Handler';
use Visualizer::Service::Metrics 'ERROR_METRICS_NOT_FOUND';
use Visualizer::Service::Metrics::Value;
use Visualizer::Service::Metrics::History;

sub get {
    my ($self, $context, $metrics_name, $year, $month, $day, $hour) = @_;

    my %params = (
        year  => $year,
        month => $month,
        day   => $day,
        hour  => $hour,
    );

    my @dispatch = qw(get_y_resolution get_ym_resolution get_ymd_resolution get_ymdh_resolution);
    my $length = scalar grep { defined } ($year, $month, $day, $hour);
    my $method = $dispatch[ $length - 1 ];

    my ($metrics, $values) = eval {
        my $metrics = Visualizer::Service::Metrics->get_metrics_metadata(
            name => $metrics_name
        );

        my $values = Visualizer::Service::Metrics::History->$method(
            metrics_id => $metrics->{metrics_id},
            map { ($_ => $params{$_}) x!! $params{$_} } keys %params
        );

        return $metrics, $values;
    };
    if (my $e = $@) {
        if (ref $e eq 'Alpaca::Exception::ValidationError') {
            $self->write_json({}, 400);
        } elsif (ref $e eq 'Visualizer::Service::Exception'){
            if ($e->{code} eq ERROR_METRICS_NOT_FOUND()) {
                $self->write_json({}, 404);
            }
        }
        $self->log(fatal => $e);
        $self->write_json({}, 500);
    }

    $self->write_json($values);
}

sub create {
    my ($self, $context, $metrics_name, $year, $month, $day, $hour) = @_;

    eval {
        Visualizer::Service::Metrics::Value->create_hourly(
            name     => $metrics_name,
            datetime => sprintf('%04d-%02d-%02d %02d:00:00'),
            value    => $context->request->body_parameters->get('value'),
            token    => $context->request->query_parameters->get('token'),
        );
    };
    if (my $e = $@) {
        if (ref $e eq 'Alpaca::Exception::ValidationError') {
            $self->write_json({}, 400);
        } elsif (ref $e eq 'Visualizer::Service::Exception') {
            if ($e->{code} eq ERROR_METRICS_NOT_FOUND()) {
                $self->write_json({}, 404);
            }
        }
        $self->log(fatal => $e);
        $self->write_json({}, 500);
    }

    $self->write_json({ success => \1 });
}

1;
__END__
