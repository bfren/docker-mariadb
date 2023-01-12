# Docker MariaDB

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-mariadb) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fmariadb) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fmariadb)<br/>
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-mariadb/dev-10_4?label=10.4) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-mariadb/dev-10_5?label=10.5) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bfren/docker-mariadb/dev-10_6?label=10.6)

[Docker Repository](https://hub.docker.com/r/bfren/mariadb) - [bfren ecosystem](https://github.com/bfren/docker)

[MariaDB](https://mariadb.org/) comes pre-installed (10.4, 10.5, or 10.6) with automatic backups built-in.

## Contents

* [Automatic Backups](#automatic-backups)
* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Licence / Copyright](#licence)

## Automatic Backups

Backups for every database (except `mysql`, `information_schema`, `performance_schema`, and `sys`) are stored:

* in the `/var/lib/backup` volume
* in subfolders by date and time (yyMMddhhmm)
* every eight hours

See [For Backups](#for-backups) for configuration variables.

## Ports

* 3306

## Volumes

| Volume            | Purpose                                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| `/etc/my.cnf.d`   | Optional additional mariadb configuration.                                                        |
| `/var/lib/mysql`  | Data files.                                                                                       |
| `/var/lib/backup` | Backup files (also used for export / import scripts - see [helper functions](#helper-functions)). |

## Environment Variables

### For Backups

| Variable                        | Values                       | Description                                              | Default |
| ------------------------------- | ---------------------------- | -------------------------------------------------------- | ------- |
| `MARIADB_BACKUP_COMPRESS_FILES` | 0 or 1                       | Whether or not to compress backup files (using gzip).    | 0       |
| `MARIADB_BACKUP_KEEP_FOR_DAYS`  | 0: keep forever<br>Num: days | How many days to keep backups before auto-deleting them. | 14      |

### For SSL

| Variable                      | Values  | Description                                                            | Default          |
| ----------------------------- | ------- | ---------------------------------------------------------------------- | ---------------- |
| `MARIADB_SSL_ENABLE`          | 0 or 1  | Set to "1" to enable SSL support.                                      | 0                |
| `MARIADB_SSL_DAYS`            | integer | The number of days before self-generated SSL certificates will expire. | 3650 (ten years) |
| `MARIADB_SSL_CA_KEY_BITS`     | integer | The size in bits of the CA SSL private key.                            | 4096             |
| `MARIADB_SSL_SERVER_KEY_BITS` | integer | The size in bits of the server SSL private key.                        | 4096             |
| `MARIADB_SSL_CLIENT_KEY_BITS` | integer | The size in bits of the client SSL private key.                        | 4096             |

### For Database

| Variable                | Values | Description                                                                                           | Default                                  |
| ----------------------- | ------ | ----------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `MARIADB_ROOT_PASSWORD` | string | Password for root user.                                                                               | *None* - **required**                    |
| `MARIADB_USERNAME`      | string | Application username - will be used as database name if `MARIADB_DATABASE` is not set.                | *None* - recommended                     |
| `MARIADB_PASSWORD`      | string | Application password.                                                                                 | *None* - required if username is defined |
| `MARIADB_DATABASE`      | string | Database name(s) - multiple databases can be separated by a comma.                                    | *None*                                   |
| `MARIADB_CHARACTER_SET` | string | Sets [character_set_server](https://mariadb.com/kb/en/server-system-variables/#character_set_server). | utf8                                     |
| `MARIADB_COLLATION`     | string | Sets [collation_server](https://mariadb.com/kb/en/server-system-variables/#collation_server).         | utf8_general_ci                          |
| `MARIADB_LOG_WARNINGS`  | string | Sets [log_warnings](https://mariadb.com/kb/en/server-system-variables/#log_warnings).                 | 2                                        |

## Helper Functions

| Function    | Purpose                                                                                 | Usage                                             |
| ----------- | --------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `db-backup` | Run backup manually.                                                                    | `docker exec <<CONTAINER>> db-backup`             |
| `db-export` | Dumps the specified database as a SQL file to the root of the `/var/lib/backup` volume. | `docker exec <<CONTAINER>> db-export <<DB_NAME>>` |
| `db-import` | Executes all files in the root of the `/var/lib/backup` volume.                         | `docker exec <<CONTAINER>> db-import`             |

## Licence

> [MIT](https://mit.bfren.dev/2020)

## Copyright

> Copyright (c) 2020-2023 [bfren](https://bfren.dev) (unless otherwise stated)
