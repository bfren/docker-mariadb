#!/bin/sh

IMAGE=`cat VERSION`
MARIADB=${1:-11.1}

docker buildx build \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB}/Dockerfile \
    -t mariadb${MARIADB}-dev \
    . \
    && \
    docker run -it -e MARIADB_USERNAME=test -e MARIADB_ROOT_PASSWORD=test -e MARIADB_BACKUP_COMPRESS_FILES=1 mariadb${MARIADB}-dev sh
