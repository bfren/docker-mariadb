FROM ghcr.io/bfren/debian-s6:bookworm-3.1.2

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

EXPOSE 3306

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y apt-transport-https ca-certificates
ADD https://mariadb.org/mariadb_release_signing_key.pgp /etc/apt/keyrings/mariadb-keyring.pgp
RUN chmod 0444 /etc/apt/keyrings/mariadb-keyring.pgp

ENV \
    # set to "1" to give the application user permission to access all databases and manage users
    # should NOT be used in production, but is extremely useful for a dev server
    BF_DB_USER_SUPER=0 \
    # set to "1" to compress backup sql files
    BF_DB_BACKUP_COMPRESS_FILES=0 \
    # the period of time to keep backups before auto-deleting them (Nu duration)
    BF_DB_BACKUP_KEEP_FOR=28day \
    # set to "1" to enable SSL support
    BF_DB_SSL_ENABLE=0 \
    # the period of time before self-generated SSL certificates will expire (Nu duration)
    BF_DB_SSL_EXPIRY=36500day \
    # the size in bits of the CA SSL private key
    BF_DB_SSL_CA_KEY_BITS=4096 \
    # the size in bits of the server SSL private key
    BF_DB_SSL_SERVER_KEY_BITS=4096 \
    # the size in bits of the client SSL private key
    BF_DB_SSL_CLIENT_KEY_BITS=4096 \
    # see https://mariadb.com/kb/en/server-system-variables/#character_set_server
    BF_DB_CHARACTER_SET=utf8 \
    # see https://mariadb.com/kb/en/server-system-variables/#collation_server
    BF_DB_COLLATION=utf8_general_ci \
    # see https://mariadb.com/kb/en/server-system-variables/#log_warnings
    BF_DB_LOG_WARNINGS=3

COPY ./overlay /
COPY ./11.4/overlay /
RUN bf-install

VOLUME [ "/backup", "/data", "/ssl" ]
