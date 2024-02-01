FROM bfren/debian-s6:bookworm-2.0.8

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 3306

COPY ./overlay /
COPY ./10.11/overlay /

ADD https://mariadb.org/mariadb_release_signing_key.pgp /etc/apt/keyrings/mariadb-keyring.pgp

ENV \
    # set to "1" to compress backup sql files
    BF_DB_BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    BF_DB_BACKUP_KEEP_FOR_DAYS="28" \
    # set to "1" to enable SSL support
    BF_DB_SSL_ENABLE="0" \
    # the number of days before self-generated SSL certificates will expire
    BF_DB_SSL_DAYS="3650" \
    # the size in bits of the CA SSL private key
    BF_DB_SSL_CA_KEY_BITS="4096" \
    # the size in bits of the server SSL private key
    BF_DB_SSL_SERVER_KEY_BITS="4096" \
    # the size in bits of the client SSL private key
    BF_DB_SSL_CLIENT_KEY_BITS="4096" \
    # see https://mariadb.com/kb/en/server-system-variables/#character_set_server
    BF_DB_CHARACTER_SET="utf8" \
    # see https://mariadb.com/kb/en/server-system-variables/#collation_server
    BF_DB_COLLATION="utf8_general_ci" \
    # see https://mariadb.com/kb/en/server-system-variables/#log_warnings
    BF_DB_LOG_WARNINGS="3"

RUN bf-install

VOLUME [ "/backup", "/data", "/ssl" ]
