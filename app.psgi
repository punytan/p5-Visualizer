use sane;
use Plack::Builder;
use Visualizer::Web;
use Visualizer::Web::Router;

my $web = Visualizer::Web->new(
    router => Visualizer::Web::Router::routes 'Visualizer::Web::Handler'
);

$web->load_controllers;

my $app = $web->wrap_default_middlewares(
    $web->raw_app, { Session => 0 }
);

builder {
    mount "/api" => $app;
    mount "/"    => builder {
        enable sub {
            my $app = shift;
            sub {
                my $env = shift;
                if ($env->{PATH_INFO} eq '/') {
                    return [ 302, [ Location => '/index.html' ], [] ];
                }
                return $app->($env);
            }
        };
        enable "Plack::Middleware::Static",
            path => qr{^/},
            root => './public/';
    };
};
