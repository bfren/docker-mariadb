# Docker Compose

## tl;dr

1. Create a `.env` file on your host machine and copy the contents from the default file in this folder.
2. **Change the values for the port / passwords / username.** (!)
3. Create a `docker-compose.yml` file on your host machine and copy the contents from one of the various `.yml` template files in this folder.  (Descriptions of each can be found below.)
4. Run the following: `docker-compose up`.  This will download the image, and run the database installation routine.

The `MARIADB_USERNAME` environment variable is important because the container will automatically create a database of that name when it starts for the first time.

Backups will be created automatically every 8 hours and stored in `./v/backup`.

## Contents

- [Environment Variables](#environment-variables)
- [Access from app](#access-from-app)
- [Access from host](#access-from-host)
- [Access from external](#access-from-external)
  - [Client configuration](#client-configuration)

## Environment Variables

The `.env` file is a convenient way of grouping and defining variables for use in your `docker-compose.yml` file.  The default file looks like this:

```bash
MARIADB_VERSION=10.9.2 # NB this is the MariaDB version, not the image version
MARIADB_PORT=3306 # you will access the database over this port
MARIADB_ROOT_PASSWORD=root_password
MARIADB_USERNAME=application_name # a database with this name will be created automatically
MARIADB_PASSWORD=another_password
```

## Access from app

**Suggested use: standard Docker deployment.**

This is the most common way to use a Docker database image: create one per app.  The file `access-from-app.yml` will help you here - simply add your app's service definition and off you go!

## Access from host

**Suggested use: local development machine.**

If you want a single database container that multiple apps can access, or that you can access directly from your container host OS, use `access-from-host.yml`.  This maps `MARIADB_PORT` from localhost to the database container.

This is how I have a test / dev server setup on my development machine.  I have also used this config while migrating native apps to their Docker alternatives.

## Access from external

**Suggested use: here be dragons!**

If you want to share a database server over a network - or, God forbid, the internet - you need `access-from-external.yml`.  This will map `MARIADB_PORT` to the **host** port (which means you need to allow access through your firewall / NAT).

You will notice that the template file includes `MARIADB_SSL_ENABLE=1` - this is strongly recommended if you are accessing a database over a network as it will ensure that traffic is secured.  Setting `MARIADB_SSL_ENABLE` to `1` will enable SSL support in your container, but you still have work to do on your client machine to make it work.

You will also notice that it has an additional volume mapped: `/ssl`.  The SSL keys and certificates will be automatically generated on startup, and added to this directory.  You will need to add these to your client machine / application to be able to access data over SSL.

### Client configuration

For example, if you copy the three files created by the container in the host `./v/ssl` directory to your client machine (say, into the client's `/etc/my.cnf.d/ssl` directory), you then need to do the following (this assumes you have installed the latest version of the MariaDB client on your client machine):

1. Create file `/etc/mysql/mariadb.conf.d/50-mysql-clients.cnf` (if it doesn't already exist).

2. Add the following to the `[mysql]` block:

    ```conf
    [mysql]
    ssl-ca=/etc/my.cnf.d/ssl/ca-cert.pem
    ssl-cert=/etc/my.cnf.d/ssl/client-cert.pem
    ssl-key=/etc/my.cnf.d/ssl/client-key.pem
    ```

3. Connect to your database server using the details in `.env`:

    ```bash
    $ mariadb -h 127.0.0.1 -u MARIADB_USERNAME -p
    Enter password: # enter your password
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 5
    Server version: 10.9.2-MariaDB-1:10.9.2+maria~deb11 mariadb.org binary distribution

    Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]>
    ```

4. Now enter `SHOW VARIABLES LIKE '%ssl%';` and you see something like this:

    ```bash
    MariaDB [(none)]> SHOW VARIABLES LIKE '%ssl%';
    +---------------------+-----------------------------------+
    | Variable_name       | Value                             |
    +---------------------+-----------------------------------+
    | have_openssl        | YES                               |
    | have_ssl            | YES                               |
    | ssl_ca              | /etc/my.cnf.d/ssl/ca-cert.pem     |
    | ssl_capath          |                                   |
    | ssl_cert            | /etc/my.cnf.d/ssl/server-cert.pem |
    | ssl_cipher          |                                   |
    | ssl_crl             |                                   |
    | ssl_crlpath         |                                   |
    | ssl_key             | /etc/my.cnf.d/ssl/server-key.pem  |
    | version_ssl_library | OpenSSL 1.1.1k  25 Mar 2021       |
    +---------------------+-----------------------------------+
    10 rows in set (0.006 sec)
    ```

If you do, that means you have connected to your new database server successfully via SSL!

If not, you need to make sure that you have entered the correct paths into `/etc/mysql/mariadb.conf.d/50-mysql-clients.cnf`.
