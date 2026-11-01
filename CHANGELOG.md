# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [10.0.0] - Unreleased

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

[10.0.0]: https://github.com/bfren/docker-mariadb/compare/v9.0.3...v10.0.0
