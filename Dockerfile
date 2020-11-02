FROM bcgdesign/alpine-s6:0.5.4

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

EXPOSE 3306

ENV MARIADB_DEFAULT_CHARACTER_SET="utf8"

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

RUN /bin/bash -c 'chmod +x /tmp/install/fixpermissions' && \
    /tmp/install/fixpermissions && \
    rm -rf /tmp/install
