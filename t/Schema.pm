package Schema;
use parent 'Test::Alpaca::Schema';

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE owners (
    owner_id INT UNSIGNED NOT NULL,
    name     INT UNSIGNED NOT NULL
)
SQL

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE credentials (
    owner_id      INT UNSIGNED NOT NULL,
    client_id     VARCHAR(64)   NOT NULL,
    client_secret VARCHAR(64)  NOT NULL,
    expires_at    INT UNSIGNED NOT NULL,
    created_at    INT UNSIGNED NOT NULL,
    updated_at    INT UNSIGNED NOT NULL
)
SQL

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE metrics (
    metrics_id    INT UNSIGNED AUTO_INCREMENT,
    metrics_name  VARCHAR(64)  NOT NULL,
    owner_id      INT UNSIGNED NOT NULL,
    PRIMARY KEY (`metrics_id`)
)
SQL

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE metrics_values (
    metrics_id  INT UNSIGNED NOT NULL,
    resolution  ENUM('Y', 'YM', 'YMD', 'YMDH'),
    aggregator  ENUM('count', 'sum', 'average', 'max', 'min'),
    ts          DATETIME     NOT NULL,
    val         INT(20)      NOT NULL,
    created_at  INT UNSIGNED NOT NULL,
    updated_at  INT UNSIGNED NOT NULL,
    PRIMARY KEY (`metrics_id`, `resolution`, `aggregator`, `ts`)
)
SQL

1;
__END__
