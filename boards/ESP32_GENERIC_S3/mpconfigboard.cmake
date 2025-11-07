set(IDF_TARGET esp32s3)

set(SDKCONFIG_DEFAULTS
    ${MICROPY_ESP32_DIR}/boards/sdkconfig.base
    ${MICROPY_ESP32_DIR}/boards/sdkconfig.usb
    ${MICROPY_ESP32_DIR}/boards/sdkconfig.ble
    ${MICROPY_ESP32_DIR}/boards/sdkconfig.spiram_sx
    ${MICROPY_ESP32_DIR}/boards/ESP32_GENERIC_S3/sdkconfig.board
)
