FROM ghcr.io/bfren/alpine-s6:alpine3.17-5.4.7

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

EXPOSE 3306

ENV \
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
COPY ./overlay-alpine /
COPY ./alpine3.17/overlay /
RUN bf-install


VOLUME [ "/backup", "/data", "/ssl" ]
