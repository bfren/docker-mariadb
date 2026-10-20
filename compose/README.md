# Docker Compose examples

Three ways to run [MariaDB](../README.md), depending on what needs to reach the database.

| File                       | Who can connect                                    | Use for                                 |
| -------------------------- | -------------------------------------------------- | --------------------------------------- |
| `access-from-app.yml`      | Containers on the `app` network only               | Most deployments - one database per app |
| `access-from-host.yml`     | Containers, and the host on `127.0.0.1:${PORT}`    | A development machine                   |
| `access-from-external.yml` | Containers, and any machine on `${PORT}`, with SSL | A database shared over a network        |

## Using them

1. Copy [`.env`](.env) next to your `docker-compose.yml` and **change the passwords** - keep `.env` out of version control.
2. Copy one of the `.yml` files to `docker-compose.yml`.
3. Run `docker compose up -d`.

On first start a database and user are created - named `APPLICATION` in the first two examples, or `DATABASE` and `USERNAME` in the third. Backups are saved in `./v/backup` every eight hours.

`VERSION` is the MariaDB version (see [Tags](../README.md#tags)), not the image version.

## Access from external

Only do this if you must - and never on the internet without a firewall. The port is open on every interface, so allow it through your firewall only from the machines that need it.

`BF_DB_SSL_ENABLE=1` makes the container generate a CA, server and client certificate in `./v/ssl` on first start. Clients need them to connect securely:

1. Copy `ca-cert.pem`, `client-cert.pem` and `client-key.pem` from `./v/ssl` to the client (they are only readable by UID 1000, so use `sudo` if needed), e.g. into `/home/you/.mariadb`.
2. Add them to the `[client]` section of the client's option file (e.g. `~/.my.cnf`) - use full paths:

    ```ini
    [client]
    ssl-ca=/home/you/.mariadb/ca-cert.pem
    ssl-cert=/home/you/.mariadb/client-cert.pem
    ssl-key=/home/you/.mariadb/client-key.pem
    ```

3. Connect with `mariadb --host=<server> --port=<PORT> --user=<USERNAME> --password`, then check the connection is encrypted:

    ```sql
    SHOW SESSION STATUS LIKE 'Ssl_cipher';
    ```

    A cipher name (e.g. `TLS_AES_256_GCM_SHA384`) means the connection uses SSL. An empty value means it doesn't - check the paths in your option file.

SSL is offered, not required, so clients without the certificates can still connect unencrypted. To require it, run `ALTER USER '<USERNAME>'@'%' REQUIRE SSL;` as root (`docker exec -it db db-root`).
