#!/bin/bash

set -e

# Determine repository root (one level up from this script's directory)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Print/speak build completion on exit (whether successful or not)
function finish {
    echo "Build complete for board ${BOARD}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        say "Finished building" || true
    else
        echo "Build complete"
    fi
}
trap finish EXIT

BOARD=${1:-MICROLITE}
IDF_VERSION=${IDF_VERSION:-v5.4.2}

# Define the absolute path to the micropython folder
export MICROPYTHON_PATH="${ROOT_DIR}/third_party/micropython"

# Update submodules required for build
if [ ! -d "${MICROPYTHON_PATH}" ]; then
    echo "Micropython submodule missing at ${MICROPYTHON_PATH}" >&2
    exit 1
fi

pushd "${ROOT_DIR}" >/dev/null

git submodule update --init --recursive
pushd third_party/micropython >/dev/null
# ensure required nested submodules
git submodule update --init lib/axtls
git submodule update --init lib/berkeley-db-1.xx
popd >/dev/null

# Fetch esp-idf if not already present
if [ ! -d esp-idf ]; then
    git clone --branch "$IDF_VERSION" --depth 1 --recursive https://github.com/espressif/esp-idf.git
fi
pushd esp-idf >/dev/null
./install.sh
popd >/dev/null

# Source esp-idf environment
# shellcheck disable=SC1091
source ./esp-idf/export.sh

pip3 install pyelftools
pip3 install ar
# Ensure uf2conv.py is importable by setting PYTHONPATH
export PYTHONPATH="${MICROPYTHON_PATH}/tools${PYTHONPATH:+:$PYTHONPATH}"

# Build micropython cross compiler
pushd "${MICROPYTHON_PATH}" >/dev/null
make -C mpy-cross V=1 clean all
popd >/dev/null

# Define project and build directories
FIRMWARE_DIR="${ROOT_DIR}/firmware"
BOARD_DIR="${FIRMWARE_DIR}/boards/${BOARD}"
BUILD_DIR="${BOARD_DIR}/build"

if [ ! -d "${BOARD_DIR}" ]; then
    echo "Board directory does not exist: ${BOARD_DIR}" >&2
    exit 1
fi

# Clean and build from the firmware project root, writing outputs into the board's build dir
pushd "${FIRMWARE_DIR}" >/dev/null

# Clean build dir if it exists
if [ -d "${BUILD_DIR}" ]; then
    idf.py -B "${BUILD_DIR}" clean || true
fi

idf.py -B "${BUILD_DIR}" build \
    -DMICROPY_BOARD=${BOARD} \
    -DMICROPY_BOARD_VARIANT=SPIRAM_OCT \
    -DCMAKE_C_FLAGS="-Wno-error=stringop-overflow -Wno-stringop-overflow" \
    -DCMAKE_CXX_FLAGS="-fno-rtti" \
    -DMICROPY_USER_FROZEN_MANIFEST="${MICROPYTHON_PATH}/ports/esp32/boards/manifest.py"

popd >/dev/null

# Assemble unified image (run from board directory so relative build/ paths in the script resolve)
ASSEMBLE_SCRIPT="${ROOT_DIR}/scripts/assemble-unified-image-esp.sh"
if [ ! -x "${ASSEMBLE_SCRIPT}" ]; then
    chmod +x "${ASSEMBLE_SCRIPT}" || true
fi
if [ ! -f "${ASSEMBLE_SCRIPT}" ]; then
    echo "Assemble script missing: ${ASSEMBLE_SCRIPT}" >&2
    exit 1
fi

MP_PORTS_PATH="${MICROPYTHON_PATH}/ports/esp32"
if [ ! -d "${MP_PORTS_PATH}" ]; then
    echo "Micropython ports directory missing: ${MP_PORTS_PATH}" >&2
    exit 1
fi

pushd "${BOARD_DIR}" >/dev/null
"${ASSEMBLE_SCRIPT}" "${MP_PORTS_PATH}"
popd >/dev/null

popd >/dev/null
