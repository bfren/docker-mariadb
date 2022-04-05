#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BASE_REVISION="4.2.8"
echo "Base: ${BASE_REVISION}"

MARIADB_VERSIONS="10.4 10.5 10.6"
for V in ${MARIADB_VERSIONS} ; do

    echo "MariaDB ${V}"
    ALPINE_MINOR=`cat ./${V}/ALPINE_MINOR`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        BASE_REVISION=${BASE_REVISION} \
        ALPINE_MINOR=${ALPINE_MINOR} \
        MARIADB_MINOR=${V}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
