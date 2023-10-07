#!/bin/sh

BASE_DIR=$1


# Set BASE_DIR to ../../submodules/micropython/ports/esp32/
#BASE_DIR=../../submodules/micropython/ports/esp32/

# Echo the base directory
echo "BASE_DIR: $BASE_DIR"

if test -z "$BASE_DIR"; then
	echo "USAGE: <Absolute Path to micropython/ports/esp32>"
	exit 1
fi

# Copy ${BASE_DIR}/makeimg.py to the current directory
cp ${BASE_DIR}/makeimg.py .

# Echo the files in the current directory
ls -l

# ${BASE_DIR}/makeimg.py
# Let's run and see
python3 makeimg.py \
build/sdkconfig \
build/bootloader/bootloader.bin \
build/partition_table/partition-table.bin \
build/micropython.bin \
build/firmware.bin \
build/micropython.uf2