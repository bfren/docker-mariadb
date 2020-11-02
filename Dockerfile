FROM bcgdesign/alpine-s6:0.5.3

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
    org.label-schema.name="MariaDB" \
    org.label-schema.version="latest" \
    org.label-schema.vendor="Ben Green" \
    org.label-schema.schema-version="1.0"

EXPOSE 3306

RUN mkdir -p /var/lib/mysql && \
    mkdir -p /var/lib/backup
VOLUME [ "/var/lib/mysql", "/var/lib/backup" ]

COPY ./overlay /

ENV MYSQL_USER_GID=1000
ENV MYSQL_USER_UID=1000

RUN /bin/bash -c 'chmod +x /tmp/install/fixpermissions' && \
    /tmp/install/fixpermissions && \
    rm -rf /tmp/install

RUN apk update && \
    apk upgrade && \
    apk add mariadb mariadb-client mariadb-server-utils gomplate && \
    rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/*
