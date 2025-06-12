#!/bin/bash

set -e

BOARD=${1:-MICROLITE}
IDF_VERSION=${IDF_VERSION:-v5.4}

# Update submodules required for build
if [ ! -d third_party/micropython ]; then
    echo "Micropython submodule missing" >&2
    exit 1
fi

git submodule update --init --recursive
pushd third_party/micropython >/dev/null
# ensure required nested submodules
git submodule update --init lib/axtls
git submodule update --init lib/berkeley-db-1.xx
popd >/dev/null

# Fetch esp-idf if not already present
if [ ! -d esp-idf ]; then
    git clone --branch "$IDF_VERSION" --depth 1 --recursive https://github.com/espressif/esp-idf.git
    pushd esp-idf >/dev/null
    ./install.sh
    popd >/dev/null
fi

# Source esp-idf environment
source ./esp-idf/export.sh

pip3 install pyelftools
pip3 install ar

# Build micropython cross compiler
pushd third_party/micropython >/dev/null
make -C mpy-cross V=1 clean all
popd >/dev/null

# Build firmware for the selected board
pushd boards/${BOARD} >/dev/null
rm -rf build

# Inject flags so that:
#  • C builds drop -Werror=stringop-overflow
#  • C++ builds retain -fno-rtti
idf.py fullclean \
    -DCMAKE_C_FLAGS="-Wno-error=stringop-overflow -Wno-stringop-overflow" \
    -DCMAKE_CXX_FLAGS="-fno-rtti" \
    build
chmod +x ../../scripts/assemble-unified-image-esp.sh
../../scripts/assemble-unified-image-esp.sh ../../third_party/micropython/ports/esp32
popd >/dev/null

echo "Build complete for board ${BOARD}" 
