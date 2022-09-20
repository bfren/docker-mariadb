FROM bfren/debian-s6:bullseye-1.1.0

ARG BF_IMAGE
ARG BF_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y --no-install-recommends ca-certificates
ADD https://mariadb.org/mariadb_release_signing_key.asc /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc

ENV \
    # set to "1" to compress backup sql files
    MARIADB_BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    MARIADB_BACKUP_KEEP_FOR_DAYS="28" \
    # set to "1" to enable SSL support
    MARIADB_SSL_ENABLE="0" \
    # the number of days before self-generated SSL certificates will expire
    MARIADB_SSL_DAYS="3650" \
    # the size in bits of the CA SSL private key
    MARIADB_SSL_CA_KEY_BITS="4096" \
    # the size in bits of the server SSL private key
    MARIADB_SSL_SERVER_KEY_BITS="4096" \
    # the size in bits of the client SSL private key
    MARIADB_SSL_CLIENT_KEY_BITS="4096" \
    # see https://mariadb.com/kb/en/server-system-variables/#character_set_server
    MARIADB_CHARACTER_SET="utf8" \
    # see https://mariadb.com/kb/en/server-system-variables/#collation_server
    MARIADB_COLLATION="utf8_general_ci" \
    # see https://mariadb.com/kb/en/server-system-variables/#log_warnings
    MARIADB_LOG_WARNINGS="3"

EXPOSE 3306

COPY ./overlay /
COPY ./10.5/overlay /

RUN bf-install

VOLUME [ "/var/lib/mysql", "/var/lib/backup", "/etc/my.cnf.d", "/ssl" ]
