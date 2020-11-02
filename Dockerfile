FROM bcgdesign/alpine-s6:1.0.0

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

ENV BACKUP_COMPRESS_FILES="0"
ENV BACKUP_KEEP_FOR_DAYS="28"
ENV MARIADB_DEFAULT_CHARACTER_SET="utf8"
ENV MARIADB_CHARACTER_SET_SERVER="utf8"
ENV MARIADB_COLLATION_SERVER="utf8_general_ci"
ENV MARIADB_KEY_BUFFER_SIZE="16M"
ENV MARIADB_MAX_ALLOWED_PACKET="1M"
ENV MARIADB_TABLE_OPEN_CACHE="64"
ENV MARIADB_SORT_BUFFER_SIZE="512K"
ENV MARIADB_NET_BUFFER_SIZE="8K"
ENV MARIADB_READ_BUFFER_SIZE="256K"
ENV MARIADB_READ_RND_BUFFER_SIZE="512K"
ENV MARIADB_MYISAM_SORT_BUFFER_SIZE="8M"
ENV MARIADB_LOG_BIN="mysql-bin"
ENV MARIADB_BINLOG_FORMAT="mixed"
ENV MARIADB_EXPIRE_LOGS_DAYS="28"
ENV MARIADB_SERVER_ID="1"
ENV MARIADB_INNODB_DATA_FILE_PATH="ibdata1:10M:autoextend"
ENV MARIADB_INNODB_BUFFER_POOL_SIZE="16M"
ENV MARIADB_INNODB_LOG_FILE_SIZE="5M"
ENV MARIADB_INNODB_LOG_BUFFER_SIZE="8M"
ENV MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT="1"
ENV MARIADB_INNODB_LOCK_WAIT_TIMEOUT="50"
ENV MARIADB_INNODB_USE_NATIVE_AIO="1"
ENV MARIADB_INNODB_FILE_PER_TABLE="ON"
ENV MARIADB_MAX_ALLOWED_PACKET="16M"
ENV MARIADB_KEY_BUFFER_SIZE="20M"
ENV MARIADB_SORT_BUFFER_SIZE="20M"
ENV MARIADB_READ_BUFFER="2M"
ENV MARIADB_WRITE_BUFFER="2M"
ENV MARIADB_MAX_CONNECTIONS="151"
ENV MARIADB_SKIP_CHOWN="false"

EXPOSE 3306

RUN mkdir -p /var/lib/mysql && \
    mkdir -p /var/lib/backup
VOLUME [ "/var/lib/mysql", "/var/lib/backup" ]

RUN addgroup --gid 1000 mysql && \
    adduser --uid 1000 --no-create-home --disabled-password --ingroup mysql mysql && \
    apk update && \
    apk upgrade && \
    apk add mariadb mariadb-client gomplate && \
    rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/*

COPY ./overlay /
