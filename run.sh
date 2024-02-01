#!/bin/sh

IMAGE=`cat VERSION`
MARIADB=${1:-11.2}

docker buildx build \
    --load \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB}/Dockerfile \
    -t mariadb${MARIADB}-dev \
    . \
    && \
    docker run -it -e BF_DB_USERNAME=test -e BF_DB_ROOT_PASSWORD=test -e BF_DB_BACKUP_COMPRESS_FILES=1 mariadb${MARIADB}-dev sh
