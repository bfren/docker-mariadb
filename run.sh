#!/bin/sh

IMAGE=`cat VERSION`
MARIADB=${1:-12.2}
VOL_BACKUP=`pwd`/backup
VOL_DATA=`pwd`/data
VOL_SSL=`pwd`/ssl

rm -rf ${VOL_BACKUP}
rm -rf ${VOL_DATA}
rm -rf ${VOL_SSL}

docker buildx build \
    --load \
    --build-arg BF_IMAGE=mariadb \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${MARIADB}/Dockerfile \
    -t mariadb${MARIADB}-dev \
    . \
    && \
    docker run -it \
        -p "3306:3306" \
        -v ${VOL_BACKUP}:/backup \
        -v ${VOL_DATA}:/data \
        -v ${VOL_SSL}:/ssl \
        -e BF_DEBUG=1 \
        -e BF_DB_APPLICATION=bfren \
        -e BF_DB_ROOT_PASSWORD=bfren \
        -e BF_DB_SSL_ENABLE=1 \
        mariadb${MARIADB}-dev \
        sh
