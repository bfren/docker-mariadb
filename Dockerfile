FROM webhippie/alpine:latest

LABEL maintainer="Ben Green <ben@bcgdesign.com>" \
  org.label-schema.name="MariaDB" \
  org.label-schema.version="latest" \
  org.label-schema.vendor="Ben Green" \
  org.label-schema.schema-version="1.0"

EXPOSE 3306

VOLUME ["/var/lib/mysql", "/var/lib/backup"]
WORKDIR /root
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]

ENV CRON_ENABLED true

RUN apk update && \
  apk upgrade && \
  mkdir -p /var/lib/mysql && \
  groupadd -g 1000 mysql && \
  useradd -u 1000 -d /var/lib/mysql -g mysql -s /bin/bash -m mysql && \
  apk add mariadb mariadb-client mariadb-server-utils tzdata && \
  rm -rf /var/cache/apk/* /etc/mysql/* /etc/my.cnf* /var/lib/mysql/*

COPY ./overlay /