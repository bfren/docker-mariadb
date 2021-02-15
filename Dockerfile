FROM bcgdesign/alpine-s6:alpine-3.13-1.4.0

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV \
    # set to "1" to compress backup sql files
    BACKUP_COMPRESS_FILES="0" \
    # the number of days after which backups will be deleted
    BACKUP_KEEP_FOR_DAYS="28" \
    # see https://mariadb.com/kb/en/server-system-variables/#character_set_server
    MARIADB_CHARACTER_SET="utf8" \
    # see https://mariadb.com/kb/en/server-system-variables/#collation_server
    MARIADB_COLLATION="utf8_general_ci" \
    # see https://mariadb.com/kb/en/server-system-variables/#log_warnings
    MARIADB_LOG_WARNINGS="2"

EXPOSE 3306

COPY ./MARIADB_BUILD /tmp/MARIADB_BUILD
RUN export MARIADB_VERSION=$(cat /tmp/MARIADB_BUILD) \
    && echo "MariaDB v${MARIADB_VERSION}" \
    && addgroup --gid 1000 dbadm \
    && adduser --uid 1000 --no-create-home --disabled-password --ingroup dbadm dbadm \
    && apk -U upgrade \
    && apk add \
        bash \
        openssl \
        mariadb=${MARIADB_VERSION} \
        mariadb-client=${MARIADB_VERSION} \
        mariadb-server-utils=${MARIADB_VERSION} \
    && rm -rf /var/cache/apk/* /etc/mysql /etc/my.cnf* /var/lib/mysql/* /tmp/* \
    && echo "0 */8 * * * /usr/local/bin/db-backup" >> /etc/crontabs/root

COPY ./overlay /

VOLUME [ "/var/lib/mysql", "/var/lib/backup", "/etc/my.cnf.d" ]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=5 CMD [ "healthcheck" ]
