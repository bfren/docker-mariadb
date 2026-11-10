# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [10.0.2] - 2026-11-10

### Changed

- Base image updated to `bfren/debian-s6` 5.0.2, which updates Nushell to 0.117.0 (your own Nushell scripts may
  need changes) and keeps the container starting when `BF_TZ` cannot be set - see the
  [Debian + S6 changelog](https://github.com/bfren/docker-debian-s6/blob/main/CHANGELOG.md).
- `BF_DB_DATABASE` accepts commas as well as spaces between database names, as `bfren/postgresql` does.

### Fixed

- A password containing a single quote or backslash no longer stops MariaDB from starting - passwords, user names
  and database names are now escaped in the generated SQL, including in `db-disable-super-user`.

### Security

- The initialisation script `/tmp/init.sql` is deleted once the server is online. Before, MariaDB ran it on every
  start - granting super user access again after `db-disable-super-user`, and resetting passwords changed using
  SQL - and it left the passwords readable in `/tmp`.

## [10.0.1] - 2026-11-06

### Changed

- Base image updated to `bfren/debian-s6` 5.0.1, which rebuilds BusyBox, figlet and Nushell (Debian is unchanged) -
  see the
  [Debian + S6 changelog](https://github.com/bfren/docker-debian-s6/blob/main/CHANGELOG.md).

## [10.0.0] - 2026-11-05

### Changed

- **Breaking:** base image updated to `bfren/debian-s6` 5.0.0 - see the
  [Debian + S6 changelog](https://github.com/bfren/docker-debian-s6/blob/main/CHANGELOG.md).
  `bf env set` must now run as root.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.

### Fixed

- Backups are written straight to the file instead of being held in memory first, so large databases no longer need
  that much memory to back up.
- `db-export dump` is refused - `/backup/dump.sql` would be restored on the next start.

[10.0.2]: https://github.com/bfren/docker-mariadb/compare/v10.0.1...v10.0.2
[10.0.1]: https://github.com/bfren/docker-mariadb/compare/v10.0.0...v10.0.1
[10.0.0]: https://github.com/bfren/docker-mariadb/compare/v9.0.3...v10.0.0
