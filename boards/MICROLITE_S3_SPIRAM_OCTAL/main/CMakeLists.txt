# Include MicroPython ESP32 component.

get_filename_component(CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)
message(STATUS "microlite/main/cmake: CURRENT_DIR=${CURRENT_DIR}")

# Compute MICROPY_DIR relative to this file to avoid brittle relative paths.
get_filename_component(MICROPY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../third_party/micropython" ABSOLUTE)
get_filename_component(MICROPY_PORT_DIR "${MICROPY_DIR}/ports/esp32" REALPATH)


message(STATUS "microlite/main/cmake: MICROPY_DIR=${MICROPY_DIR}")

message(STATUS "Including ${MICROPY_PORT_DIR}/main/CMakeLists.txt")
include("${MICROPY_PORT_DIR}/main/CMakeLists.txt")
