# Docker MariaDB

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-mariadb) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fmariadb) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fmariadb) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-mariadb/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/mariadb) - [bfren ecosystem](https://github.com/bfren/docker)

[MariaDB](https://mariadb.org/) comes pre-installed (10.5, 10.6 LTS, 11.1, 11.2, 11.4 LTS and 11.5) with automatic backups built-in.

## Contents

* [Automatic Backups](#automatic-backups)
* [Ports](#ports)
* [Volumes](#volumes)
* [Environment Variables](#environment-variables)
* [Helper Functions](#helper-functions)
* [Licence / Copyright](#licence)

## Automatic Backups

Backups for every database (except `mysql`, `information_schema`, `performance_schema`, and `sys`) are stored:

* in the `/backup` volume
* in subfolders by date and time (yyMMddhhmm)
* every eight hours

See [For Backups](#for-backups) for configuration variables.

**It is strongly recommended that you run a backup before updating to a more recent version.**

## Ports

* 3306

## Volumes

| Volume    | Purpose                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------- |
| `/backup` | Backup files (also used for export / import scripts - see [helper functions](#helper-functions)). |
| `/data`   | Data files.                                                                                       |
| `/ssl`    | SSL certificates and files.                                                                       |

## Environment Variables

### For Backups

| Variable                          | Values                                                                    | Description                                                       | Default   |
| --------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------- | --------- |
| `BF_DB_BACKUP_COMPRESS_FILES`     | 0 or 1                                                                    | Whether or not to compress backup files (using gzip).             | 0         |
| `BF_DB_BACKUP_KEEP_FOR`           | [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations)   | The period of time to keep backups before auto-deleting them.     | 28day     |

### For SSL

| Variable                      | Values                                                                    | Description                                                               | Default   |
| ----------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------- | --------- |
| `BF_DB_SSL_ENABLE`            | 0 or 1                                                                    | Set to "1" to enable SSL support.                                         | 0         |
| `BF_DB_SSL_EXPIRY`            | [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations)   | The period of time before self-generated SSL certificates will expire.    | 36500day  |
| `BF_DB_SSL_CA_KEY_BITS`       | integer                                                                   | The size in bits of the CA SSL private key.                               | 4096      |
| `BF_DB_SSL_SERVER_KEY_BITS`   | integer                                                                   | The size in bits of the server SSL private key.                           | 4096      |
| `BF_DB_SSL_CLIENT_KEY_BITS`   | integer                                                                   | The size in bits of the client SSL private key.                           | 4096      |

### For Database

| Variable              | Values    | Description                                                                                                       | Default               |
| --------------------- | --------- | ----------------------------------------------------------------------------------------------------------------- | --------------------- |
| `BF_DB_ROOT_PASSWORD` | string    | Password for root user.                                                                                           | *None* - **required** |
| `BF_DB_APPLICATION`   | string    | Application name - will be used as `BF_DB_DATABASE`, `BF_DB_PASSWORD` and `BF_DB_USERNAME` if they are not set.   | *None*                |
| `BF_DB_DATABASE`      | string    | Database name(s) - multiple databases can be separated by a comma.                                                | *None*                |
| `BF_DB_USERNAME`      | string    | Application username - required if `BF_DB_APPLICATION` is not used.                                               | *None*                |
| `BF_DB_PASSWORD`      | string    | Application password - required if `BF_DB_APPLICATION` is not used.                                               | *None*                |
| `BF_DB_SUPER_USER`    | 0 or 1    | Grants the application user permission to **all** databases plus user management - **not** for production.        | 0                     |
| `BF_DB_CHARACTER_SET` | string    | Sets [character_set_server](https://mariadb.com/kb/en/server-system-variables/#character_set_server).             | utf8                  |
| `BF_DB_COLLATION`     | string    | Sets [collation_server](https://mariadb.com/kb/en/server-system-variables/#collation_server).                     | utf8_general_ci       |
| `BF_DB_LOG_WARNINGS`  | string    | Sets [log_warnings](https://mariadb.com/kb/en/server-system-variables/#log_warnings).                             | 2                     |

## Helper Functions

| Function      | Arguments         | Purpose                                                                               | Usage                                                 |
| ------------- | ----------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `db-backup`   | *None*            | Run backup manually.                                                                  | `docker exec <<CONTAINER>> db-backup`                 |
| `db-export`   | 1: Database name  | Dumps the specified database as a SQL file to the root of the `/backup` volume.       | `docker exec <<CONTAINER>> db-export <<DB_NAME>>`     |
| `db-import`   | 1: Database name  | Executes all files in the root of the `/backup` volume.                               | `docker exec <<CONTAINER>> db-import <<DB_NAME>>`     |
| `db-restore`  | 1: Backup set     | Deletes all files in `/data` volume, then restores from the specified backup dump.    | `docker exec <<CONTAINER>> db-restore 202107180500`   |
| `db-upgrade`  | *None*            | Run `mariadb-upgrade` manually - normally not necessary but performs various checks.  | `docker exec <<CONTAINER>> db-upgrade`                |

## Licence

> [MIT](https://mit.bfren.dev/2020)

## Copyright

> Copyright (c) 2020-2024 [bfren](https://bfren.dev) (unless otherwise stated)
