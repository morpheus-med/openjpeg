#!/bin/bash
set -euxo pipefail

RELEASE_VERSION=$(cat RELEASE)

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BUILD_DIR="${DIR}/build-lib"
DIST_DIR="${DIR}/dist/openjpeg"

start=$SECONDS

echo "============================================="
echo "Compiling openjpeg library"
echo "============================================="
(
    rm -rf {${DIST_DIR},${BUILD_DIR}}
    mkdir -p ${DIST_DIR}
    mkdir ${BUILD_DIR}
    cd ${BUILD_DIR}
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${DIST_DIR}
    make install
    make clean
)
echo "============================================="
echo "Compiling openjpeg library done"
echo "============================================="
echo
echo "============================================="
echo "Archiving openjpeg library"
echo "============================================="
(
   echo "Branch: ${BRANCH_NAME:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Commit: ${GIT_COMMIT:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Job Name: ${JOB_NAME:-dev}" >> ${DIST_DIR}/build-info.txt
    echo "Build Number: ${BUILD_NUMBER:-0}" >> ${DIST_DIR}/build-info.txt
    echo "Release Version: ${RELEASE_VERSION}" >> ${DIST_DIR}/build-info.txt
    echo "${RELEASE_VERSION}" >> ${DIST_DIR}/build-version.txt

    ARCHIVE_NAME=openjpeg:${RELEASE_VERSION}
    ARTIFACT_DIR=${DIR}/artifacts
    mkdir -p ${ARTIFACT_DIR}
    cd ${DIST_DIR}
    tar -czf ${ARTIFACT_DIR}/${ARCHIVE_NAME/:/-}.tgz *
    echo Done building OpenJPEG! Took $(( SECONDS - start )) seconds.
)
echo "============================================="
echo "Archiving openjpeg library done"
echo "============================================="