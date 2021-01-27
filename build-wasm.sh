#!/bin/bash

set -euxo pipefail

RELEASE_VERSION=$(cat RELEASE)
DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BUILD_DIR="${DIR}/build-wasm"
DIST_DIR="${DIR}/dist/openjpeg-wasm"

ENVIRONMENT=${ENVIRONMENT:-production};
BROWSER_OUTPUT="openjpeg"
OPTIMIZE="-Os"
if [$ENVIRONMENT != "production"]
then
    OPTIMIZE="-O2 --js-opts 0 -g4"
fi

start=$SECONDS

echo "============================================="
echo "Compiling openjpeg wasm"
echo "============================================="
(
    rm -rf {${DIST_DIR},${BUILD_DIR}}
    mkdir -p ${DIST_DIR}
    mkdir ${BUILD_DIR}
    cd ${BUILD_DIR}
    emconfigure cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_CODEC=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DOPJ_BIG_ENDIAN=0 \
        -DHAVE_OPJ_BIG_ENDIAN=1 \
        ..
    emmake make

    emcc \
        ${BUILD_DIR}/bin/libopenjp2.a \
        -o ${BUILD_DIR}/bin/${BROWSER_OUTPUT}.js \
        ${OPTIMIZE} \
        --memory-init-file 0 \
        -s MODULARIZE=1 \
        -s EXPORT_NAME="'Jpeg2k'" \
        -s ERROR_ON_UNDEFINED_SYMBOLS=1 \
        -s ERROR_ON_MISSING_LIBRARIES=1 \
        -s USE_PTHREADS=1 \
        -s PTHREAD_POOL_SIZE=8 \
        -s SINGLE_FILE=1 \
        -s TOTAL_MEMORY=350MB \
        -s ENVIRONMENT="web,worker" \
        -s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall', 'writeArrayToMemory', 'getValue']" \
        -s EXPORTED_FUNCTIONS="['_jp2_decode']"
)
echo "============================================="
echo "Compiling openjpeg wasm done"
echo "============================================="
echo
echo "============================================="
echo "Archiving openjpeg wasm library"
echo "============================================="
(
    echo "Branch: ${BRANCH_NAME:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Commit: ${GIT_COMMIT:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Job Name: ${JOB_NAME:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Build Number: ${BUILD_NUMBER:-0}" >> ${DIST_DIR}/build-info.txt
    echo "Release Version: ${RELEASE_VERSION}" >> ${DIST_DIR}/build-info.txt
    echo "${RELEASE_VERSION}" >> ${DIST_DIR}/build-version.txt

    mv ${BUILD_DIR}/bin/${BROWSER_OUTPUT}.{js,worker.js} ${DIST_DIR}

    ARCHIVE_NAME=openjpeg-wasm:${RELEASE_VERSION}
    ARTIFACT_DIR=${DIR}/artifacts
    mkdir -p ${ARTIFACT_DIR}
    cd ${DIST_DIR}
    tar -czf ${ARTIFACT_DIR}/${ARCHIVE_NAME/:/-}.tgz *
    echo Done building OpenJPEG! Took $(( SECONDS - start )) seconds.
)
echo "============================================="
echo "Archiving openjpeg wasm library done"
echo "============================================="
