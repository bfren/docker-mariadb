#FROM bcgdesign/alpine-s6:alpine-3.13-1.3.1
FROM bcgdesign/alpine-s6:dev

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV BACKUP_COMPRESS_FILES="0" \
    BACKUP_KEEP_FOR_DAYS="28" \
    MARIADB_CHARACTER_SET="utf8" \
    MARIADB_COLLATION="utf8_general_ci" \
    MARIADB_LOG_WARNINGS="2"

EXPOSE 3306

RUN mkdir -p /var/lib/mysql \
    && mkdir -p /var/lib/backup
VOLUME [ "/var/lib/mysql", "/var/lib/backup" ]

COPY ./MARIADB_BUILD /tmp/MARIADB_BUILD
RUN export MARIADB_VERSION=$(cat /tmp/MARIADB_BUILD) \
    && echo "MariaDB v${MARIADB_VERSION}" \
    && addgroup --gid 1000 mysql \
    && adduser --uid 1000 --no-create-home --disabled-password --ingroup mysql mysql \
    && apk -U upgrade \
    && apk add \
        bash \
        mariadb=${MARIADB_VERSION} \
        mariadb-client=${MARIADB_VERSION} \
        mariadb-server-utils=${MARIADB_VERSION} \
    && rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/* /tmp/* \
    && echo "0 */8 * * * /usr/local/bin/db-backup" >> /etc/crontabs/root

COPY ./overlay /

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=5 CMD [ "healthcheck" ]
