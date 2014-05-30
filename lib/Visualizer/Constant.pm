use Visualizer::Constant;
use sane;
use Constant::Exporter (
    EXPORT_OK => {
        map { ($_ => $_) } qw(
            ERROR_METRICS_NOT_FOUND
            ERROR_CREDENTIAL_NOT_FOUND
        )
    }
);

1;
__END__
