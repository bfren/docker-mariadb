# MariaDB

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-mariadb) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fmariadb) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fmariadb) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-mariadb/dev.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/mariadb) - [Quay.io](https://quay.io/repository/bfren/mariadb) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

[MariaDB](https://mariadb.org) server with the jobs around it built in: the database and user are created on first start, every database is backed up every eight hours, the data is upgraded automatically when you move to a newer MariaDB version, and SSL certificates can be generated for you.

There are two variants:

* **Debian** (the default) - built on [Debian + S6](https://github.com/bfren/docker-debian-s6) with MariaDB's own packages, so you can choose any supported MariaDB version.
* **Alpine** - built on [Alpine + S6](https://github.com/bfren/docker-alpine-s6) with Alpine's packages, so each Alpine release gives you one MariaDB version. Smaller, and also built for `linux/arm/v7`.

Upgrading from 6.x? Read [the upgrade guide](UPGRADE_FROM_6x_TO_7x.md) first - environment variables and volumes changed.

## Quickstart

`docker-compose.yml`:

```yaml
services:
  db:
    image: quay.io/bfren/mariadb:mariadb11.8-8.1
    restart: unless-stopped
    environment:
      - BF_DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - BF_DB_APPLICATION=myapp
      - BF_DB_PASSWORD=${DB_PASSWORD}
    volumes:
      - ./v/data:/data
      - ./v/backup:/backup
```

`.env` (keep it out of version control):

```sh
DB_ROOT_PASSWORD=change-me
DB_PASSWORD=change-me-too
```

Run `docker compose up -d`. On first start a database and user called `myapp` are created, and your app (in the same compose file) connects to `db:3306`. To open a MariaDB shell:

```sh
docker compose exec db db-user     # as myapp
docker compose exec db db-root     # as root
```

See [compose](compose) for examples that allow access from the host or other machines.

## Features

* 🐬 MariaDB 10.11 to 13.0 (Debian) or 10.6 to 11.8 (Alpine) - choose with the image tag
* 🚀 Root password, application database(s) and user created on first start
* 💾 Every database backed up every eight hours, optionally compressed, with old backups deleted automatically
* ♻️ Restore, export and import with one command
* ⬆️ Data upgraded automatically after moving to a newer MariaDB version
* 🔒 Optional SSL, with CA, server and client certificates generated for you
* 🧩 Add your own MariaDB configuration files
* 🩺 Health check that the application user can query the server
* 👤 MariaDB runs as `dbadm` (UID 1000), not root

## Tags

Images are published to Docker Hub (`bfren/mariadb`) and Quay.io (`quay.io/bfren/mariadb`). There is no `latest` tag - choose a MariaDB version.

| Tag                          | Example                | Use when                                        |
| ---------------------------- | ---------------------- | ----------------------------------------------- |
| `mariadbX.Y`                 | `mariadb11.8`          | You want the latest image for a MariaDB version |
| `mariadbX.Y-MAJOR`           | `mariadb11.8-8`        | You want updates, but not breaking changes      |
| `mariadbX.Y-MINOR`           | `mariadb11.8-8.1`      | You want fixes only - **recommended**           |
| `mariadbX.Y-VERSION`         | `mariadb11.8-8.1.22`   | You want to pin this image exactly              |
| `mariadbX.Y.Z`               | `mariadb11.8.9`        | You want an exact MariaDB release               |
| `mariadbX.Y.Z-VERSION`       | `mariadb11.8.9-8.1.22` | You want to pin both                            |
| any of the above + `-alpine` | `mariadb11.8-8-alpine` | You want the Alpine variant                     |

| Variant | MariaDB | Release  | Base                 | Platforms                                    | LTS   |
| ------- | ------- | -------- | -------------------- | -------------------------------------------- | ----- |
| Debian  | 13.0    | 13.0.2   | Debian 13 (trixie)   | `linux/amd64`, `linux/arm64`                 | No    |
| Debian  | 12.3    | 12.3.3   | Debian 13 (trixie)   | `linux/amd64`, `linux/arm64`                 | Yes   |
| Debian  | 11.8    | 11.8.9   | Debian 13 (trixie)   | `linux/amd64`, `linux/arm64`                 | Yes   |
| Debian  | 11.4    | 11.4.13  | Debian 12 (bookworm) | `linux/amd64`, `linux/arm64`                 | Yes   |
| Debian  | 10.11   | 10.11.19 | Debian 12 (bookworm) | `linux/amd64`, `linux/arm64`                 | Yes   |
| Alpine  | 11.8    | 11.8.8   | Alpine 3.24          | `linux/amd64`, `linux/arm/v7`, `linux/arm64` | Yes   |
| Alpine  | 11.4    | 11.4.12  | Alpine 3.23          | `linux/amd64`, `linux/arm/v7`, `linux/arm64` | Yes   |
| Alpine  | 10.11   | 10.11.18 | Alpine 3.20          | `linux/amd64`, `linux/arm/v7`, `linux/arm64` | Yes   |
| Alpine  | 10.6    | 10.6.16  | Alpine 3.17          | `linux/amd64`, `linux/arm/v7`, `linux/arm64` | Ended |

13.0 is a short-term release - use an LTS version for anything long-lived. See MariaDB's [release dates](https://mariadb.com/kb/en/mariadb-server-release-dates/) for support periods.

## Configuration

### Ports

| Port   | Purpose |
| ------ | ------- |
| `3306` | MariaDB |

You only need to publish it to reach the database from outside Docker - containers on the same network connect directly.

### Volumes

| Volume    | Purpose                                                                             |
| --------- | ----------------------------------------------------------------------------------- |
| `/data`   | The database files.                                                                 |
| `/backup` | Automatic backups, and the files used by `db-export`, `db-import` and `db-restore`. |
| `/ssl`    | Generated SSL certificates and keys (when `BF_DB_SSL_ENABLE=1`).                    |

Everything in the volumes is owned by `dbadm` (UID / GID 1000), and only readable by its owner. On the host, read the files as UID 1000 or with `sudo`.

### Environment Variables

**Database** - these are only used the first time the container starts (see [First start](#first-start)):

| Variable              | Values   | Description                                                                                     | Default |
| --------------------- | -------- | ----------------------------------------------------------------------------------------------- | ------- |
| `BF_DB_ROOT_PASSWORD` | string   | **Required.** Password for `root` (also used by backups, so keep it set).                       |         |
| `BF_DB_APPLICATION`   | string   | Default for `BF_DB_DATABASE`, `BF_DB_USERNAME` and `BF_DB_PASSWORD`.                            |         |
| `BF_DB_DATABASE`      | names    | Database(s) to create - separate several with spaces.                                           |         |
| `BF_DB_USERNAME`      | string   | Application user, given full access to those databases.                                         |         |
| `BF_DB_PASSWORD`      | string   | Application user's password (also used by the health check, so keep it set).                    |         |
| `BF_DB_SUPER_USER`    | `0`, `1` | Give the application user access to all databases and user management - **not** for production. | `0`     |

Set `BF_DB_APPLICATION`, or all three of `BF_DB_DATABASE`, `BF_DB_USERNAME` and `BF_DB_PASSWORD`. Using `BF_DB_APPLICATION` alone makes the password the same as the user name, so set `BF_DB_PASSWORD` too.

**Backups:**

| Variable                      | Values                                                                  | Description                             | Default |
| ----------------------------- | ----------------------------------------------------------------------- | --------------------------------------- | ------- |
| `BF_DB_BACKUP_COMPRESS_FILES` | `0`, `1`                                                                | Compress backup files with bzip2.       | `0`     |
| `BF_DB_BACKUP_KEEP_FOR`       | [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations) | How long to keep backups, e.g. `14day`. | `28day` |

**Server** - applied every time the container starts:

| Variable                        | Values   | Description                                                                                      | Default           |
| ------------------------------- | -------- | ------------------------------------------------------------------------------------------------ | ----------------- |
| `BF_DB_CHARACTER_SET`           | string   | [character_set_server](https://mariadb.com/kb/en/server-system-variables/#character_set_server). | `utf8`            |
| `BF_DB_COLLATION`               | string   | [collation_server](https://mariadb.com/kb/en/server-system-variables/#collation_server).         | `utf8_general_ci` |
| `BF_DB_LOG_WARNINGS`            | integer  | [log_warnings](https://mariadb.com/kb/en/server-system-variables/#log_warnings).                 | `3`               |
| `BF_DB_QUERY_CACHE_ENABLE`      | `0`, `1` | Enable the [query cache](https://mariadb.com/kb/en/query-cache/).                                | `0`               |
| `BF_DB_QUERY_CACHE_SIZE_BYTES`  | integer  | Total query cache size.                                                                          | `268435456`       |
| `BF_DB_QUERY_CACHE_LIMIT_BYTES` | integer  | Largest result cached per query.                                                                 | `1048576`         |

**SSL** - see [SSL](#ssl):

| Variable                    | Values                                                                  | Description                             | Default    |
| --------------------------- | ----------------------------------------------------------------------- | --------------------------------------- | ---------- |
| `BF_DB_SSL_ENABLE`          | `0`, `1`                                                                | Enable SSL.                             | `0`        |
| `BF_DB_SSL_EXPIRY`          | [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations) | Lifetime of the generated certificates. | `36500day` |
| `BF_DB_SSL_CA_KEY_BITS`     | integer                                                                 | Size of the CA private key.             | `4096`     |
| `BF_DB_SSL_SERVER_KEY_BITS` | integer                                                                 | Size of the server private key.         | `4096`     |
| `BF_DB_SSL_CLIENT_KEY_BITS` | integer                                                                 | Size of the client private key.         | `4096`     |

See [Debian + S6](https://github.com/bfren/docker-debian-s6#environment-variables) or [Alpine + S6](https://github.com/bfren/docker-alpine-s6#environment-variables) for `BF_DEBUG`, `BF_TZ` and the other base image variables. `BF_TZ` sets the time backups run.

## How It Works

On every start, `/etc/my.cnf` is generated from the server variables, SSL certificates are generated if needed, and the backup job is added to cron. Then MariaDB starts under S6, its error log is forwarded to `docker logs`, and the upgrade check runs.

### First start

If `/data` has not been initialised, MariaDB's system tables are installed and an initialisation script runs as the server starts:

* `root` is given `BF_DB_ROOT_PASSWORD` and can only connect from inside the container (`localhost`)
* each database in `BF_DB_DATABASE` is created, and the application user is given full access to it from `localhost` and any host (`%`)
* with `BF_DB_SUPER_USER=1`, the application user can also access every database and manage users
* the `test` database is removed

This only happens once. Changing these variables later does **not** change passwords, users or databases - see [I changed a password but can't log in](#i-changed-a-password-but-cant-log-in).

### Backups

At a random minute every eight hours (00:xx, 08:xx and 16:xx in `BF_TZ`), `db-backup` creates a folder in `/backup` named by date and time (`yyyyMMddHHmm`, e.g. `202610171608`) containing:

* `dump.sql` - every database, used by `db-restore`
* `<database>.sql` - each database on its own

`mysql`, `information_schema`, `performance_schema`, `sys` and `test` are not backed up individually. With `BF_DB_BACKUP_COMPRESS_FILES=1` the files are compressed with bzip2 (`.sql.bz2`). Backup folders older than `BF_DB_BACKUP_KEEP_FOR` are deleted - files in the root of `/backup` are left alone.

**Back up before moving to a newer MariaDB version** - run `db-backup`.

### Restore, export and import

* `db-restore <folder>` restores every database from a backup folder's `dump.sql` (or `dump.sql.bz2`), e.g. `db-restore 202610171608`. Each database in the dump is dropped and recreated - databases that are not in the dump are left alone.
* `db-export <database>` saves `/backup/<database>.sql`.
* `db-import <database>` runs `/backup/<database>.sql`. Files from `db-export` and the per-database backup files recreate the database themselves.

To move a database between containers, `db-export` in one, copy the file to the other's `/backup`, then `db-import`.

### SSL

With `BF_DB_SSL_ENABLE=1`, a CA, server and client certificate are generated in `/ssl` on first start (if `/ssl/server-cert.pem` doesn't exist) and MariaDB accepts TLS 1.2 and 1.3. Clients need `ca-cert.pem`, and `client-cert.pem` / `client-key.pem` if you use certificate authentication. SSL is offered, not required - to require it, add `REQUIRE SSL` to the user, or `require_secure_transport` in your own configuration. Delete the files in `/ssl` and restart to generate new ones.

### Upgrades

After MariaDB starts, the version that created `/data` is compared with the server's. If they differ, `mariadb-upgrade` runs once to update the system tables. It also runs every month, as a check. Downgrading is not supported - restore a backup instead.

### Custom configuration

`/etc/my.cnf` includes every file in `/etc/my.cnf.d`, so mount your own `*.cnf` files there (e.g. `innodb_buffer_pool_size`). Don't change `datadir`, the log file or SSL paths.

### Helper commands

Run these with `docker exec <container> <command>`.

| Command                 | Arguments | Description                                                            |
| ----------------------- | --------- | ---------------------------------------------------------------------- |
| `db-root`               |           | Open a MariaDB shell as `root` (add `-it` to `docker exec`).           |
| `db-user`               |           | Open a MariaDB shell as the application user (add `-it`).              |
| `db-backup`             |           | Back up now.                                                           |
| `db-restore`            | folder    | Restore every database from a backup folder.                           |
| `db-export`             | database  | Save a database to `/backup/<database>.sql`.                           |
| `db-import`             | database  | Run `/backup/<database>.sql`.                                          |
| `db-upgrade`            |           | Run `mariadb-upgrade` - normally not needed.                           |
| `db-enable-super-user`  |           | Give the application user access to all databases and user management. |
| `db-disable-super-user` |           | Recreate the application user with access only to `BF_DB_DATABASE`.    |

### Health check

The health check (inherited from the base image: every 30 seconds) connects as the application user and runs `SELECT 1`.

## Testing

```sh
./test.nu              # builds MariaDB 13.0 (Debian) and runs /test
./test.nu alpine3.24   # or any version directory
./test.nu --all        # every version, in parallel
./run.sh 11.8          # builds and opens a shell, with /data, /backup and /ssl in this directory
./test-upgrade.sh      # starts Alpine 3.17 (10.6), then Alpine 3.20 (10.11) on the same data
./generate.sh          # regenerates the Dockerfiles from Dockerfile-debian.esh and Dockerfile-alpine.esh
```

`/test` runs this image's tests alongside the base images' tests: the initialisation script, `my.cnf`, SSL certificate generation, version detection, and backup, restore, export and import (using stub `mariadb` executables, so no server is needed). Run it on both variants, e.g. `./test.nu 11.8` and `./test.nu alpine3.24`.

## Troubleshooting

### The container stops straight after starting

Check `docker logs <container>`. `BF_DB_ROOT_PASSWORD` must be set, and either `BF_DB_APPLICATION` or all of `BF_DB_DATABASE`, `BF_DB_USERNAME` and `BF_DB_PASSWORD`.

### I changed a password but can't log in

Passwords are only set on [first start](#first-start). Change them in SQL (`docker exec -it <container> db-root`, then `ALTER USER ... IDENTIFIED BY ...`), then update the environment variable to match - backups use `BF_DB_ROOT_PASSWORD` and the health check uses `BF_DB_PASSWORD`.

### I can't connect as root from outside the container

`root` can only connect from `localhost`. Use the application user, or `db-root` inside the container.

### The container is unhealthy

The application user couldn't run `SELECT 1`. Usually its password no longer matches `BF_DB_PASSWORD` - see above.

### MariaDB won't start after changing the image tag

Moving to an older MariaDB version is not supported. Go back to the previous tag, or restore a backup into an empty `/data`.

## FAQs

### Should I use Debian or Alpine?

Debian, unless you need `linux/arm/v7` or the smallest image. It has every supported MariaDB version, from MariaDB's own packages. Alpine's version is fixed by the Alpine release, so newer MariaDB versions arrive later.

### How do I add another database later?

As root (`db-root`): `CREATE DATABASE newdb;` then `GRANT ALL PRIVILEGES ON newdb.* TO 'myapp'@'%';`. Add it to `BF_DB_DATABASE` too, so `db-disable-super-user` keeps it.

### Can I use the official MariaDB image's variables, such as `MARIADB_ROOT_PASSWORD`?

No - this image only reads the `BF_DB_*` variables.

## Licence

> [MIT](https://mit.bfren.dev/2020)

## Copyright

> Copyright (c) 2020-2026 [bfren](https://bfren.dev) (unless otherwise stated)
