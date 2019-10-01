#!/bin/bash
# script for building openjpeg and openjpeg wasm binaries locally
set -euxo pipefail

echo "============================================="
echo "Building openjpeg library"
echo "============================================="
(
    IMAGE_NAME=openjpeg
    docker build --tag ${IMAGE_NAME} - < Dockerfile.ubuntu
    docker run --rm \
        --volume $(pwd):/workdir \
        ${IMAGE_NAME}
)
echo "============================================="
echo "Building openjpeg library done"
echo "============================================="
echo
echo "============================================="
echo "Building openjpeg wasm bundle"
echo "============================================="
(
    IMAGE_NAME=openjpeg_emscripten
    docker build --no-cache --tag ${IMAGE_NAME} - < Dockerfile.emscripten
    docker run --rm \
        --volume $(pwd):/workdir \
        ${IMAGE_NAME}
)
echo "============================================="
echo "Building openjpeg library done"
echo "============================================="
