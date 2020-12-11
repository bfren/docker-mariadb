FROM bcgdesign/alpine-s6:1.0.9

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV BACKUP_COMPRESS_FILES="0" \
    BACKUP_KEEP_FOR_DAYS="28" \
    MARIADB_BINLOG_FORMAT="mixed" \
    MARIADB_CHARACTER_SET_SERVER="utf8" \
    MARIADB_COLLATION_SERVER="utf8_general_ci" \
    MARIADB_DEFAULT_CHARACTER_SET="utf8" \
    MARIADB_EXPIRE_LOGS_DAYS="28" \
    MARIADB_INNODB_BUFFER_POOL_SIZE="16M" \
    MARIADB_INNODB_DATA_FILE_PATH="ibdata1:10M:autoextend" \
    MARIADB_INNODB_FILE_PER_TABLE="ON" \
    MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT="1" \
    MARIADB_INNODB_LOCK_WAIT_TIMEOUT="50" \
    MARIADB_INNODB_LOG_BUFFER_SIZE="8M" \
    MARIADB_INNODB_LOG_FILE_SIZE="5M" \
    MARIADB_INNODB_USE_NATIVE_AIO="1" \
    MARIADB_KEY_BUFFER_SIZE="16M" \
    MARIADB_KEY_BUFFER_SIZE="20M" \
    MARIADB_LOG_BIN="mysql-bin" \
    MARIADB_MAX_ALLOWED_PACKET="16M" \
    MARIADB_MAX_ALLOWED_PACKET="1M" \
    MARIADB_MAX_CONNECTIONS="151" \
    MARIADB_MYISAM_SORT_BUFFER_SIZE="8M" \
    MARIADB_NET_BUFFER_SIZE="8K" \
    MARIADB_READ_BUFFER_SIZE="256K" \
    MARIADB_READ_BUFFER="2M" \
    MARIADB_READ_RND_BUFFER_SIZE="512K" \
    MARIADB_SERVER_ID="1" \
    MARIADB_SKIP_CHOWN="false" \
    MARIADB_SORT_BUFFER_SIZE="20M" \
    MARIADB_SORT_BUFFER_SIZE="512K" \
    MARIADB_TABLE_OPEN_CACHE="64" \
    MARIADB_WRITE_BUFFER="2M"

EXPOSE 3306

RUN mkdir -p /var/lib/mysql \
    && mkdir -p /var/lib/backup
VOLUME [ "/var/lib/mysql", "/var/lib/backup" ]

COPY ./VERSION /tmp/VERSION
RUN export MARIADB_VERSION=$(cat /tmp/VERSION) \
    && echo "MariaDB v${MARIADB_VERSION}" \
    && addgroup --gid 1000 mysql \
    && adduser --uid 1000 --no-create-home --disabled-password --ingroup mysql mysql \
    && apk -U upgrade \
    && apk add \
        bash \
        gomplate \
        mariadb@edgemain=${MARIADB_VERSION} \
        mariadb-client@edgemain=${MARIADB_VERSION} \
        mariadb-server-utils@edgemain=${MARIADB_VERSION} \
    && rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/* /tmp/*

COPY ./overlay /

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=5 CMD [ "healthcheck" ]
