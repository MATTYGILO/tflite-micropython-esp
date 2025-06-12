#!/bin/bash
set -euo pipefail

# Helper to download and extract an archive from codeload.github.com
# Arguments: repo user/repo, destination directory, commit hash
fetch() {
  local repo=$1
  local dest=$2
  local commit=$3
  rm -rf "$dest"
  mkdir -p "$dest"
  curl -L "https://codeload.github.com/${repo}/tar.gz/${commit}" -o tmp.tar.gz
  tar -xzf tmp.tar.gz
  mv "${repo##*/}-${commit}"/* "$dest"/
  rm -rf "${repo##*/}-${commit}" tmp.tar.gz
}

MICROPYTHON_COMMIT=9bde12597a6980ff87ff0137a2616e6e430a1a0e
ESP_TFLITE_MICRO_COMMIT=772214721682ef2d3eed09cafea777edad55541f
ESP_NN_COMMIT=12129cf04b09af0023127ca7551dc1a363344211
MICROPYTHON_ULAB_COMMIT=a05ec05351260cf48fefc347265b8d8bf29c03f1

fetch espressif/esp-nn third_party/esp-nn "$ESP_NN_COMMIT"
fetch espressif/esp-tflite-micro third_party/esp-tflite-micro "$ESP_TFLITE_MICRO_COMMIT"
fetch micropython/micropython third_party/micropython "$MICROPYTHON_COMMIT"
fetch v923z/micropython-ulab third_party/micropython-ulab "$MICROPYTHON_ULAB_COMMIT"

echo "Submodules downloaded"
