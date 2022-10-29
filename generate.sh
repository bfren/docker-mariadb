#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_REVISION="1.1.2"
echo "Base: ${BASE_REVISION}"

MARIADB_VERSIONS="10.4 10.5 10.6 10.7 10.8 10.9 10.10"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    DEBIAN_VERSION=`cat ./${V}/DEBIAN_VERSION`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        BASE_REVISION=${BASE_REVISION} \
        DEBIAN_VERSION=${DEBIAN_VERSION} \
        MARIADB_MINOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

    LIST=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/mariadb.list.esh" \
        DEBIAN_VERSION=${DEBIAN_VERSION} \
        MARIADB_MINOR=${V}
    )

    echo "${LIST}" > ./${V}/overlay/etc/apt/sources.list.d/mariadb.list

done

docker system prune -f
echo "Done."
