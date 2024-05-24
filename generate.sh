#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

DEBIAN_BASE_REVISION="2.1.5"
ALPINE_BASE_REVISION="5.3.0"

echo "Debian Base: ${DEBIAN_BASE_REVISION}"
MARIADB_VERSIONS="10.5 10.6 10.11 11.0 11.1 11.2 11.3"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    MARIADB_VERSION=`cat ./${V}/overlay/tmp/MARIADB_BUILD`
    MARIADB_KEYRING=/etc/apt/keyrings/mariadb-keyring.pgp

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile-debian.esh" \
        BASE_VERSION=${DEBIAN_BASE_REVISION} \
        DEBIAN_NAME=${DEBIAN_NAME} \
        MARIADB_KEYRING=${MARIADB_KEYRING} \
        MARIADB_MINOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

    LIST=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/mariadb.sources.esh" \
        DEBIAN_NAME=${DEBIAN_NAME} \
        MARIADB_MINOR=${V} \
        MARIADB_VERSION=${MARIADB_VERSION} \
        MARIADB_KEYRING=${MARIADB_KEYRING}
    )

    echo "${LIST}" > ./${V}/overlay/etc/apt/sources.list.d/mariadb.sources

done

echo "Alpine Base: ${ALPINE_BASE_REVISION}"
ALPINE_EDITIONS="3.17 3.20"
for V in ${ALPINE_EDITIONS} ; do

    echo "Alpine ${V}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile-alpine.esh" \
        BASE_VERSION=${ALPINE_BASE_REVISION} \
        ALPINE_EDITION=${V}
    )

    echo "${DOCKERFILE}" > ./alpine${V}/Dockerfile

done

docker system prune -f
echo "Done."
