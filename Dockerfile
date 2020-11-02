FROM bcgdesign/alpine-s6:latest

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
  org.label-schema.name="MariaDB" \
  org.label-schema.version="latest" \
  org.label-schema.vendor="Ben Green" \
  org.label-schema.schema-version="1.0"

EXPOSE 3306

VOLUME [ "/var/lib/mysql", "/var/lib/backup" ]

COPY ./overlay /

RUN /bin/bash -c 'chmod +x /tmp/install/fixpermissions' && \
  /tmp/install/fixpermissions && \
  apk add --no-cache --virtual .install gomplate && \
  /tmp/install/config && \
  rm -rf /tmp/install && \
  apk del --no-cache .install

RUN \
  mkdir -p /var/lib/mysql && \
  groupadd -g 1000 mysql && \
  useradd -u 1000 -d /var/lib/mysql -g mysql -s /bin/bash -m mysql && \
  apk update && \
  apk upgrade && \
  apk add mariadb mariadb-client mariadb-server-utils && \
  rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/*
