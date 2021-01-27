# Docker MariaDB

![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/bcgdesign/mariadb/latest?label=latest) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/bencgreen/docker-mariadb/build?label=github) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/bcgdesign/mariadb?label=docker) ![Docker Pulls](https://img.shields.io/docker/pulls/bcgdesign/mariadb?label=pulls) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/bcgdesign/mariadb/latest?label=size)

[Docker Repository](https://hub.docker.com/r/bcgdesign/mariadb) - [bcg|design ecosystem](https://github.com/bencgreen/docker)

I've been using [webhippie](https://github.com/dockhippie/mariadb)'s MariaDB image for a while, but I wanted to manage backups in a different way, and use the latest version of [MariaDB](https://mariadb.org/).

So this was originally a fork of that, with a different backup script to store backups by date rather than index.  However it is now substantially different, using my own [Alpine](https://hub.docker.com/r/bcgdesign/alpine-s6) base image, with a clean install of the [S6 Overlay](https://github.com/just-containers/s6-overlay).

## Automatic Backups

Backups are stored:

* in the `/var/lib/backup` volume
* in subfolders by date and time (yyMMddhhmm)
* every eight hours

The following environment variables are available for the backups `BACKUP_COMPRESS_FILES` (0 or 1) and `BACKUP_KEEP_FOR_DAYS`.

## Ports

* 3306

## Volumes

* `/etc/mysql/conf.d` - optional additional configuration
* `/var/lib/mysql` - data files
* `/var/lib/backup` - backup files

## Environment Variables

### For Backups

| Variable                | Values                       | Description                                             | Default |
| ----------------------- | ---------------------------- | ------------------------------------------------------- | ------- |
| `BACKUP_COMPRESS_FILES` | 0: false<br>1: true          | Whether or not to compress backup files (using gzip)    | 0       |
| `BACKUP_KEEP_FOR_DAYS`  | 0: keep forever<br>Num: days | How many days to keep backups before auto-deleting them | 14      |

### For Database

| Variable                                    | Values                                | Description                                                                           | Default                                     |
| ------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------- |
| `MARIADB_ROOT_PASSWORD`                     | string                                | Password for root user                                                                | *None* - **required**                       |
| `MARIADB_USERNAME`                          | string                                | Application username - will be used as database name if `MARIADB_DATABASE` is not set | *None* - recommended                        |
| `MARIADB_PASSWORD`                          | string                                | Application password                                                                  | *None* - required if username is defined    |
| `MARIADB_DATABASE`                          | string                                | Database name(s) - multiple databases can be separated by a comma                     | *None*                                      |
| `MARIADB_BINLOG_FORMAT`                     |                                       |                                                                                       | mixed                                       |
| `MARIADB_CHARACTER_SET_SERVER`              |                                       |                                                                                       | utf8                                        |
| `MARIADB_COLLATION_SERVER`                  |                                       |                                                                                       | utf8_general_ci                             |
| `MARIADB_DEFAULT_CHARACTER_SET`             |                                       |                                                                                       | utf8                                        |
| `MARIADB_EXPIRE_LOGS_DAYS`                  |                                       | Set to 0 so logs never expire                                                         | 28                                          |
| `MARIADB_INNODB_BUFFER_POOL_SIZE`           |                                       |                                                                                       | 16M                                         |
| `MARIADB_INNODB_DATA_FILE_PATH`             |                                       |                                                                                       | ibdata1:10M:autoextend                      |
| `MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT`    |                                       |                                                                                       | 1                                           |
| `MARIADB_INNODB_LOCK_WAIT_TIMEOUT`          |                                       |                                                                                       | 50                                          |
| `MARIADB_INNODB_LOG_BUFFER_SIZE`            |                                       |                                                                                       | 8M                                          |
| `MARIADB_INNODB_LOG_FILE_SIZE`              |                                       |                                                                                       | 5M                                          |
| `MARIADB_INNODB_USE_NATIVE_AIO`             |                                       |                                                                                       | 1                                           |
| `MARIADB_KEY_BUFFER_SIZE`                   |                                       |                                                                                       | 16M                                         |
| `MARIADB_KEY_BUFFER_SIZE`                   |                                       |                                                                                       | 20M                                         |
| `MARIADB_LOG_BIN`                           |                                       | Set to 0 to disable binary logging                                                    | mysql-bin                                   |
| `MARIADB_MAX_ALLOWED_PACKET`                |                                       |                                                                                       | 16M                                         |
| `MARIADB_MAX_ALLOWED_PACKET`                |                                       |                                                                                       | 1M                                          |
| `MARIADB_MAX_CONNECTIONS`                   |                                       |                                                                                       | 151                                         |
| `MARIADB_MYISAM_SORT_BUFFER_SIZE`           |                                       |                                                                                       | 8M                                          |
| `MARIADB_NET_BUFFER_SIZE`                   |                                       |                                                                                       | 8K                                          |
| `MARIADB_READ_BUFFER`                       |                                       |                                                                                       | 2M                                          |
| `MARIADB_READ_BUFFER_SIZE`                  |                                       |                                                                                       | 256K                                        |
| `MARIADB_READ_RND_BUFFER_SIZE`              |                                       |                                                                                       | 512K                                        |
| `MARIADB_SERVER_ID`                         |                                       |                                                                                       | 1                                           |
| `MARIADB_SORT_BUFFER_SIZE`                  |                                       |                                                                                       | 20M                                         |
| `MARIADB_SORT_BUFFER_SIZE`                  |                                       |                                                                                       | 512K                                        |
| `MARIADB_TABLE_OPEN_CACHE`                  |                                       |                                                                                       | 64                                          |
| `MARIADB_WRITE_BUFFER`                      |                                       |                                                                                       | 2M                                          |

## Authors

* [Ben Green](https://github.com/bencgreen)
* [Thomas Boerger](https://github.com/tboerger)

## License

> MIT

## Copyright

> Copyright (c) 2021 Ben Green <https://bcgdesign.com>  
> Unless otherwise stated
