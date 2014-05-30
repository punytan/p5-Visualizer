package Schema;
use sane;
use parent 'Test::Alpaca::Schema';

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE credentials (
    token       VARCHAR(64)  NOT NULL,
    client_name VARCHAR(32)  NOT NULL,
    created_at  INT UNSIGNED NOT NULL,
    updated_at  INT UNSIGNED NOT NULL,
    PRIMARY KEY(`token`)
)
SQL

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE `metrics` (
  `metrics_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `metrics_name` varchar(64) NOT NULL,
  `description` varchar(128) NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`metrics_id`),
  UNIQUE (`metrics_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
SQL

__PACKAGE__->add(DB_MASTER => { test => <<SQL });
CREATE TABLE metrics_values (
    metrics_id  INT     UNSIGNED NOT NULL,
    timestamp   DATETIME         NOT NULL,
    value       BIGINT           NOT NULL,
    year        YEAR             NOT NULL,
    month       TINYINT UNSIGNED NOT NULL,
    day         TINYINT UNSIGNED NOT NULL,
    hour        TINYINT UNSIGNED NOT NULL,
    created_at  INT     UNSIGNED NOT NULL,
    updated_at  INT     UNSIGNED NOT NULL,
    PRIMARY KEY (`metrics_id`, `timestamp`),
    KEY iymdh (`metrics_id`, `year`, `month`, `day`, `hour`)
)
SQL

1;
__END__
