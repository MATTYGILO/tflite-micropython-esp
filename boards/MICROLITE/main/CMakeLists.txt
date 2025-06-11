# Include MicroPython ESP32 component.

get_filename_component(CURRENT_DIR "." ABSOLUTE)
message(STATUS "microlite/main/cmake: CURRENT_DIR=${CURRENT_DIR}")

get_filename_component(MICROPY_DIR "../../../third_party/micropython" ABSOLUTE)


message (STATUS "microlite/main/cmake: MICROPY_DIR=${MICROPY_DIR}")

set(PROJECT_DIR ${MICROPY_DIR}/ports/esp32)

# ——————————————————————————————————————————————————————————————
# Ensure ESP-Ethernet is built alongside the other IDF components
# ——————————————————————————————————————————————————————————————
list(APPEND IDF_COMPONENTS "esp_eth")
message(STATUS "microlite/main/cmake: IDF_COMPONENTS=${IDF_COMPONENTS}")

# Now include the MicroPython ESP32 build
include(${PROJECT_DIR}/main/CMakeLists.txt)

message(STATUS "microlite/main/cmake: After IDF_COMPONENTS=${IDF_COMPONENTS}")
