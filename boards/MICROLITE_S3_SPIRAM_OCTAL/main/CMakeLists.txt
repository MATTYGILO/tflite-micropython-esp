# Include MicroPython ESP32 component.

get_filename_component(CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)
message(STATUS "microlite/main/cmake: CURRENT_DIR=${CURRENT_DIR}")

# Compute MICROPY_DIR relative to this file to avoid brittle relative paths.
get_filename_component(MICROPY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../third_party/micropython" ABSOLUTE)
get_filename_component(MICROPY_PORT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../third_party/micropython/ports/esp32" REALPATH)


message(STATUS "microlite/main/cmake: MICROPY_DIR=${MICROPY_DIR}")

message(STATUS "Including ${MICROPY_PORT_DIR}/main/CMakeLists.txt")
include("${MICROPY_PORT_DIR}/main/CMakeLists.txt")

## Prefer the S3-specific entry if present, otherwise fall back to the generic one.
#if(EXISTS "${MICROPY_PORT_DIR}/main_esp32s3/CMakeLists.txt")
#    message(STATUS "Including ${MICROPY_PORT_DIR}/main_esp32s3/CMakeLists.txt")
#    include("${MICROPY_PORT_DIR}/main_esp32s3/CMakeLists.txt")
#elseif(EXISTS "${MICROPY_PORT_DIR}/main/CMakeLists.txt")
#
#else()
#    message(FATAL_ERROR "Could not find MicroPython ESP32 entry CMakeLists in ${MICROPY_PORT_DIR}. Expected one of:\n  ${MICROPY_PORT_DIR}/main_esp32s3/CMakeLists.txt\n  ${MICROPY_PORT_DIR}/main/CMakeLists.txt\nCheck that third_party/micropython/ports/esp32 exists and contains the correct CMake entry.")
#endif()