#!/bin/sh

IMAGE=`cat VERSION`
MARIADB=${1:-10.6}

docker buildx build \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB}/Dockerfile \
    -t mariadb${MARIADB}-dev \
    . \
    && \
    docker run -it mariadb${MARIADB}-dev sh