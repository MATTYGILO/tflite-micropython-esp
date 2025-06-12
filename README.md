# tflite-micropython-esp
Based on [tensorflow-micropython-examples](https://github.com/mocleiri/tensorflow-micropython-examples)
[![logo](assets/logo.png)]()

## Implementing:
The repo's structure is designed to be easily implemented.


We have two possible cmakes to use:
- src/base.cmake (Includes only tflite micro)
- src/full.cmake (Includes additional libraries like ulab)

## Building for ESP-IDF 5.4

A helper script `scripts/build_and_check.sh` can be used to build the firmware for a given board using ESP-IDF 5.4.  The script follows the same steps as the GitHub workflow and will fetch the required ESP-IDF release if missing.

```bash
# Build firmware for the default MICROLITE board
./scripts/build_and_check.sh

# Or specify a board
./scripts/build_and_check.sh MICROLITE_S3
```

The script expects the submodules to be accessible over the network in order to fetch Micropython and related dependencies.

## Third-party versions for ESP-IDF 5.4

When building with ESP-IDF 5.4 the following submodule commits have been verified to work:

- **micropython**: `9bde12597a6980ff87ff0137a2616e6e430a1a0e`
- **esp-tflite-micro**: `772214721682ef2d3eed09cafea777edad55541f`
- **esp-nn**: `12129cf04b09af0023127ca7551dc1a363344211`
- **micropython-ulab**: `a05ec05351260cf48fefc347265b8d8bf29c03f1`

These versions are pinned via Git submodules. After cloning the repository run
`git submodule update --init --recursive` to fetch the correct revisions.
