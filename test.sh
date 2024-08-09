#!/bin/sh

IMAGE=mariadb
VERSION=`cat VERSION`
MARIADB=${1:-11.5}
TAG=${IMAGE}-test

docker buildx build \
    --load \
    --build-arg BF_IMAGE=${IMAGE} \
    --build-arg BF_VERSION=${VERSION} \
    -f ${MARIADB}/Dockerfile \
    -t ${TAG} \
    . \
    && \
    docker run --entrypoint "/usr/bin/env" ${TAG} -i nu -c "use bf test ; test"
