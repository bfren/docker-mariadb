#!/bin/sh

IMAGE=`cat VERSION`
MARIADB_OLD=alpine3.17
MARIADB_NEW=alpine3.20
VOL_DATA=`pwd`/data
VOL_SSL=`pwd`/ssl

rm -rf ${VOL_DATA}
rm -rf ${VOL_SSL}

docker buildx build \
    --load \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB_OLD}/Dockerfile \
    -t mariadb${MARIADB_OLD}-dev \
    . \
    && \
    docker run -it \
        -v ${VOL_DATA}:/data \
        -v ${VOL_SSL}:/ssl \
        -e BF_DEBUG=1 \
        -e BF_DB_APPLICATION=bfren \
        -e BF_DB_ROOT_PASSWORD=bfren \
        -e BF_DB_SSL_ENABLE=1 \
        mariadb${MARIADB_OLD}-dev \
        sh

docker buildx build \
    --load \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB_NEW}/Dockerfile \
    -t mariadb${MARIADB_NEW}-dev \
    . \
    && \
    docker run -it \
        -v ${VOL_DATA}:/data \
        -v ${VOL_SSL}:/ssl \
        -e BF_DEBUG=1 \
        -e BF_DB_APPLICATION=bfren \
        -e BF_DB_ROOT_PASSWORD=bfren \
        -e BF_DB_SSL_ENABLE=1 \
        mariadb${MARIADB_NEW}-dev \
        sh
