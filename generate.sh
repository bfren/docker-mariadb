#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

DEBIAN_BASE_REVISION="1.3.8"
echo "Debian Base: ${DEBIAN_BASE_REVISION}"

MARIADB_VERSIONS="10.5 10.6 10.9 10.10 10.11 11.0 11.1 11.2"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile-debian.esh" \
        BASE_REVISION=${DEBIAN_BASE_REVISION} \
        DEBIAN_NAME=${DEBIAN_NAME} \
        MARIADB_MINOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

    LIST=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/mariadb.list.esh" \
        DEBIAN_NAME=${DEBIAN_NAME} \
        MARIADB_MINOR=${V}
    )

    echo "${LIST}" > ./${V}/overlay/etc/apt/sources.list.d/mariadb.list

done

ALPINE_BASE_REVISION="4.5.9"
echo "Alpine Base: ${ALPINE_BASE_REVISION}"

ALPINE_VERSIONS="3.17 3.18"
for V in ${ALPINE_VERSIONS} ; do

    echo "Alpine ${V}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile-alpine.esh" \
        BASE_REVISION=${ALPINE_BASE_REVISION} \
        ALPINE_REVISION=${V}
    )

    echo "${DOCKERFILE}" > ./alpine${V}/Dockerfile

done

docker system prune -f
echo "Done."
