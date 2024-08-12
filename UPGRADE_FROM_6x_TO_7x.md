# Upgrading from version 6.x to 7.x

There are a number of breaking changes from version 6 to 7.

## Environment Variables

| 6.x                                                                                                       | 7.x                                                                                                                                               | Example                                                                                                               |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Environment variables all began with 'MARIADB_'                                                           | Environment variables begin with 'BF_DB_'                                                                                                         | `MARIADB_BACKUP_COMPRESS_FILES=1` -> `BF_DB_BACKUP_COMPRESS_FILES=1`                                                  |
| Backup duration was configured by `MARIADB_BACKUP_KEEP_FOR_DAYS`                                          | Backup duration is now `BF_DB_BACKUP_KEEP_FOR` and uses the [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations) format        | `MARIADB_BACKUP_KEEP_FOR_DAYS=28` -> `BF_DB_BACKUP_KEEP_FOR=28day`                                                    |
| SSL certificate duration was configured by `MARIADB_SSL_DAYS`                                             | SSL certificate duration is now `BF_DB_SSL_EXPIRY` and uses the [Nu duration](https://www.nushell.sh/book/types_of_data.html#durations) format    | `MARIADB_SSL_DAYS=3650` -> `BF_DB_SSL_EXPIRY=3650day`                                                                 |
| `MARIADB_USERNAME` would be used as user, password and database name if they were not defined separately  | This is now done by `BF_DB_APPLICATION`<br/>*(`BF_DB_USERNAME`, `BF_DB_PASSWORD` and `BF_DB_DATABASE` can be used as overrides)*                  | `BF_DB_APPLICATION=foo`<br/>`BF_DB_PASSWORD=bar`<br/>results in a user 'foo' with password 'bar' and database 'foo'   |

## Volumes

| 6.x               | 7.x       |
| ----------------- | --------- |
| /var/lib/mysql    | /data     |
| /var/lib/backup   | /backup   |
