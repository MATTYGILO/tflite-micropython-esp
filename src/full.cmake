

# Include the base microlite
include(${CMAKE_CURRENT_LIST_DIR}/base.cmake)

# Include ulab
include(${CMAKE_CURRENT_LIST_DIR}/../third_party/micropython-ulab/code/micropython.cmake)

# the camera driver
include(${CMAKE_CURRENT_LIST_DIR}/micropython-camera-driver/micropython.cmake)
