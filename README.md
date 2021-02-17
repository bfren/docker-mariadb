# Docker MariaDB

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bencgreen/docker-mariadb) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bencgreen/docker-mariadb/build?label=github) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/bcgdesign/mariadb?label=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/bcgdesign/mariadb?label=pulls) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/bcgdesign/mariadb/latest?label=size)

[Docker Repository](https://hub.docker.com/r/bcgdesign/mariadb) - [bcg|design ecosystem](https://github.com/bencgreen/docker)

I've been using [webhippie](https://github.com/dockhippie/mariadb)'s MariaDB image for a while, but I wanted to manage backups in a different way, and use the latest version of [MariaDB](https://mariadb.org/).

So this was originally a fork of that, with a different backup script to store backups by date rather than index.  However it is now substantially different, using my own [Alpine](https://hub.docker.com/r/bcgdesign/alpine-s6) base image, with a clean install of the [S6 Overlay](https://github.com/just-containers/s6-overlay).

## Contents

* [Automatic Backups](#automatic-backups)
* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Authors / Licence / Copyright](#authors)

## Automatic Backups

Backups for every database (except `mysql`, `information_schema`, `performance_schema`, and `sys`) are stored:

* in the `/var/lib/backup` volume
* in subfolders by date and time (yyMMddhhmm)
* every eight hours

See [For Backups](#for-backups) for configuration variables.

## Ports

* 3306

## Volumes

| Volume              | Purpose                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------- |
| `/etc/mysql/conf.d` | Optional additional mariadb configuration.                                                        |
| `/var/lib/mysql`    | Data files.                                                                                       |
| `/var/lib/backup`   | Backup files (also used for export / import scripts - see [helper functions](#helper-functions)). |

## Environment Variables

### For Backups

| Variable                   | Values                       | Description                                              | Default |
| -------------------------- | ---------------------------- | -------------------------------------------------------- | ------- |
| `DB_BACKUP_COMPRESS_FILES` | 0 or 1                       | Whether or not to compress backup files (using gzip).    | 0       |
| `DB_BACKUP_KEEP_FOR_DAYS`  | 0: keep forever<br>Num: days | How many days to keep backups before auto-deleting them. | 14      |

### For SSL

| Variable                 | Values  | Description                                                            | Default          |
| ------------------------ | ------- | ---------------------------------------------------------------------- | ---------------- |
| `DB_SSL_ENABLE`          | 0 or 1  | Set to "1" to enable SSL support.                                      | 0                |
| `DB_SSL_DAYS`            | integer | The number of days before self-generated SSL certificates will expire. | 3650 (ten years) |
| `DB_SSL_CA_KEY_BITS`     | integer | The size in bits of the CA SSL private key.                            | 4096             |
| `DB_SSL_SERVER_KEY_BITS` | integer | The size in bits of the server SSL private key.                        | 4096             |
| `DB_SSL_CLIENT_KEY_BITS` | integer | The size in bits of the client SSL private key.                        | 4096             |

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

## Authors

* [Ben Green](https://github.com/bencgreen)

## License

> MIT

## Copyright

> Copyright (c) 2021 Ben Green <https://bcgdesign.com>
