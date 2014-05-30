package Visualizer::Web::Router;
use sane;

use Router::Lazy::DSL;

routes 'Visualizer::Web::Handler', sub {
    GET  '/metrics' => 'Metrics#list';
    GET  '/metrics/:metrics_id/:year'                     => 'API::Metrics#get';
    GET  '/metrics/:metrics_id/:year/:month'              => 'API::Metrics#get';
    GET  '/metrics/:metrics_id/:year/:month/:day'         => 'API::Metrics#get';
    GET  '/metrics/:metrics_id/:year/:month/:day/:hour'   => 'API::Metrics#get';
    POST '/metrics/:metrics_name/:year/:month/:day/:hour' => 'API::Metrics#create';
};

1;
__END__
