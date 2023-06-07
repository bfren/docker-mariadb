#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_REVISION="1.2.7"
echo "Base: ${BASE_REVISION}"

MARIADB_VERSIONS="10.4 10.5 10.6 10.7 10.8 10.9 10.10 10.11 11.0 11.1"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    if [ -f "${V}/DEBIAN_NAME" ] ; then
        DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    else
        DEBIAN_NAME="bullseye"
    fi

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        BASE_REVISION=${BASE_REVISION} \
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

docker system prune -f
echo "Done."
