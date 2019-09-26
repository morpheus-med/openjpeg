#!/bin/bash
set -eu
set -o pipefail

rm -rf {dist,build}
mkdir dist
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=../dist ..
make install
