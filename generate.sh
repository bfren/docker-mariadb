#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

DEBIAN_BASE_REVISION="2.0.8"
ALPINE_BASE_REVISION="5.1.3"

echo "Debian Base: ${DEBIAN_BASE_REVISION}"
MARIADB_VERSIONS="10.4 10.5 10.6 10.10 10.11 11.0 11.1 11.2 11.3"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile-debian.esh" \
        BASE_VERSION=${DEBIAN_BASE_REVISION} \
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

echo "Alpine Base: ${ALPINE_BASE_REVISION}"
ALPINE_EDITIONS="3.17 3.19"
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
