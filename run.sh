#!/bin/sh

IMAGE=`cat VERSION`
MARIADB=${1:-10.9}

docker buildx build \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB}/Dockerfile \
    -t mariadb${MARIADB}-dev \
    . \
    && \
    docker run -it -e MARIADB_USERNAME=test -e MARIADB_ROOT_PASSWORD=test mariadb${MARIADB}-dev bash
