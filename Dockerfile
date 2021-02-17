FROM bcgdesign/alpine-s6:alpine-3.13-1.5.0

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV \
    # set to "1" to compress backup sql files
    DB_BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    DB_BACKUP_KEEP_FOR_DAYS="28" \
    # the number of days before self-generated SSL certificates will expire
    DB_SSL_DAYS="3650" \
    # the size in bits of the CA SSL private key
    DB_SSL_CA_KEY_BITS="4096" \
    # the size in bits of the server SSL private key
    DB_SSL_SERVER_KEY_BITS="4096" \
    # the size in bits of the client SSL private key
    DB_SSL_CLIENT_KEY_BITS="4096" \
    # see https://mariadb.com/kb/en/server-system-variables/#character_set_server
    MARIADB_CHARACTER_SET="utf8" \
    # see https://mariadb.com/kb/en/server-system-variables/#collation_server
    MARIADB_COLLATION="utf8_general_ci" \
    # see https://mariadb.com/kb/en/server-system-variables/#log_warnings
    MARIADB_LOG_WARNINGS="2"

EXPOSE 3306

COPY ./overlay /
COPY ./MARIADB_BUILD /tmp/MARIADB_BUILD

RUN bcg-install

VOLUME [ "/var/lib/mysql", "/var/lib/backup", "/etc/my.cnf.d", "/ssl" ]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=5 CMD [ "healthcheck" ]
