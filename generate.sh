#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

DEBIAN_BASE_REVISION="4.5.0"

echo "Debian Base: ${DEBIAN_BASE_REVISION}"
MARIADB_VERSIONS="10.11 11.4 11.8 12.3 13.0"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    MARIADB_VERSION=`cat ./${V}/overlay/tmp/MARIADB_BUILD`
    MARIADB_KEYRING=/etc/apt/keyrings/mariadb-keyring.pgp

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
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

docker system prune -f
echo "Done."
