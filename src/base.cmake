#
# This file is part of the Tensorflow Micropython Examples Project.
#
# The MIT License (MIT)
#
# Copyright (c) 2021 Michael O'Cleirigh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#/

if(NOT MICROPY_DIR)
    get_filename_component(MICROPY_DIR ${PROJECT_DIR}/../.. ABSOLUTE)
endif()

# `py.cmake` for `micropy_gather_target_properties` macro usage
include(${MICROPY_DIR}/py/py.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/esp_nn.cmake)

get_filename_component(TENSORFLOW_DIR ${PROJECT_DIR}/../../../tensorflow ABSOLUTE)

add_library(microlite INTERFACE)

# needed when we have custom/specialized kernels.
# add_custom_command(
#     OUTPUT ${TF_MICROLITE_SPECIALIZED_SRCS}
#     COMMAND cd ${TENSORFLOW_DIR} && ${Python3_EXECUTABLE} ${MICROPY_DIR}/py/makeversionhdr.py ${MICROPY_MPVERSION}
#     DEPENDS MICROPY_FORCE_BUILD
# )

if (CONFIG_IDF_TARGET)
    set(TF_ESP_DIR "${CMAKE_CURRENT_LIST_DIR}/../third_party/esp-tflite-micro")
    set(TF_LITE_DIR "${TF_ESP_DIR}/tensorflow/lite")
    set(TF_MICRO_DIR "${TF_LITE_DIR}/micro")
    set(COMPILER_MLIR_DIR "${TF_ESP_DIR}/tensorflow/compiler/mlir")
    set(TF_MICROLITE_LOG
            ${TF_MICRO_DIR}/debug_log.cc
            ${TF_MICRO_DIR}/micro_time.cc
    )
else()
    set(TF_LITE_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite")
    set(TF_MICRO_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro")
endif()

# lite c

file(GLOB TF_LITE_C_SRCS
          "${TF_LITE_DIR}/c/*.cpp"
          "${TF_LITE_DIR}/c/*.c")

# lite core/api
if (CONFIG_IDF_TARGET)
file(GLOB TF_LITE_API_SRCS
          "${TF_LITE_DIR}/core/api/*.cc"
          "${TF_LITE_DIR}/core/api/*.c"
          "${TF_LITE_DIR}/core/c/*.cc"
          "${TF_LITE_DIR}/core/c/*.c")
else()
file(GLOB TF_LITE_API_SRCS
          "${TF_LITE_DIR}/core/api/*.cpp"
          "${TF_LITE_DIR}/core/api/*.c")
endif()

# lite kernels

file(GLOB TF_LITE_KERNELS_SRCS
          "${TF_LITE_DIR}/kernels/*.c"
          "${TF_LITE_DIR}/kernels/*.cpp"
          "${TF_LITE_DIR}/kernels/*.cc"
          "${TF_LITE_DIR}/kernels/internal/*.c"
          "${TF_LITE_DIR}/kernels/internal/*.cpp"
          "${TF_LITE_DIR}/kernels/internal/*.cc"
          "${TF_LITE_DIR}/kernels/internal/reference/*.c"
          "${TF_LITE_DIR}/kernels/internal/reference/*.cpp"
          "${TF_LITE_DIR}/kernels/internal/reference/*.cc"
          )

# lite schema
file(GLOB TF_LITE_SCHEMA_SRCS
          "${TF_LITE_DIR}/schema/*.c"
          "${TF_LITE_DIR}/schema/*.cc"
          "${TF_LITE_DIR}/schema/*.cpp")

# micro

file(GLOB TF_MICRO_SRCS
          "${TF_MICRO_DIR}/*.c"
          "${TF_MICRO_DIR}/*.cc"
          "${TF_MICRO_DIR}/*.cpp")


# logs are platform specific and added seperately

list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp)
list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp)

# arena allocator
file(GLOB TF_MICRO_ARENA_ALLOCATOR_SRCS
          "${TF_MICRO_DIR}/arena_allocator/*.cpp"
          "${TF_MICRO_DIR}/arena_allocator/*.cc"
          "${TF_MICRO_DIR}/arena_allocator/*.c")

# micro kernels

file(GLOB TF_MICRO_KERNELS_SRCS
          "${TF_MICRO_DIR}/kernels/*.c"
          "${TF_MICRO_DIR}/kernels/*.cc"
          "${TF_MICRO_DIR}/kernels/*.cpp")

# micro memory_planner

file(GLOB TF_MICRO_MEMORY_PLANNER_SRCS
          "${TF_MICRO_DIR}/memory_planner/*.cpp"
          "${TF_MICRO_DIR}/memory_planner/*.cc"
          "${TF_MICRO_DIR}/memory_planner/*.c")

# tflite_bridge

file(GLOB TF_MICRO_TFLITE_BRIDGE_SRCS
          "${TF_MICRO_DIR}/tflite_bridge/*.cpp"
          "${TF_MICRO_DIR}/tflite_bridge/*.cc"
          "${TF_MICRO_DIR}/tflite_bridge/*.c")

if (CONFIG_IDF_TARGET)
file(GLOB TF_MLIR_API_SRCS
        "${COMPILER_MLIR_DIR}/lite/core/api/error_reporter.cc"
)
else()
file(GLOB TF_MLIR_API_SRCS
        "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/compiler/mlir/lite/core/api/error_reporter.cc"
)
endif()

set (BOARD_ADDITIONAL_SRCS "")

if (CONFIG_IDF_TARGET)
    set(tfmicro_kernels_dir ${TF_MICRO_DIR}/kernels)
    # set(tfmicro_nn_kernels_dir
    #     ${tfmicro_kernels_dir}/)

    # remove sources which will be provided by esp_nn
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS
        "${tfmicro_kernels_dir}/add.cc"
        "${tfmicro_kernels_dir}/conv.cc"
        "${tfmicro_kernels_dir}/depthwise_conv.cc"
        "${tfmicro_kernels_dir}/fully_connected.cc"
        "${tfmicro_kernels_dir}/mul.cc"
        "${tfmicro_kernels_dir}/pooling.cc"
        "${tfmicro_kernels_dir}/softmax.cc"
    )

    # tflm wrappers for ESP_NN
    FILE(GLOB ESP_NN_WRAPPERS
        "${tfmicro_kernels_dir}/esp_nn/*.cc")
endif()

#   microlite micropython module sources
set (MICROLITE_PYTHON_SRCS
    ${CMAKE_CURRENT_LIST_DIR}/microlite/tensorflow-microlite.c
)

if (CONFIG_IDF_TARGET)
    list(APPEND MICROLITE_PYTHON_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/microlite/openmv-libtf.cpp
    )
else()
    list(APPEND MICROLITE_PYTHON_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/microlite/openmv-libtf.cpp
    )
endif()

target_sources(microlite INTERFACE
    # micro_python sources for tflite
    ${MICROLITE_PYTHON_SRCS}

    # tf lite sources
    ${TF_LITE_C_SRCS}
    ${TF_LITE_API_SRCS}
    ${TF_LITE_KERNELS_SRCS}
    ${TF_LITE_SCHEMA_SRCS}

    # tf micro sources
    ${TF_MICRO_SRCS}
    ${TF_MICRO_ARENA_ALLOCATOR_SRCS}
    ${TF_MICRO_KERNELS_SRCS}
    ${TF_MICRO_MEMORY_PLANNER_SRCS}
    ${TF_MICRO_TFLITE_BRIDGE_SRCS}

    ${TF_MICROLITE_LOG}
    ${ESP_NN_SRCS} # include esp-nn sources for Espressif chipsets
    ${ESP_NN_WRAPPERS} # add tflm wrappers for ESP_NN

    ${TF_MLIR_API_SRCS}

    )

if (CONFIG_IDF_TARGET)
    set(signal_srcs
        ${TF_ESP_DIR}/signal/micro/kernels/rfft.cc
        ${TF_ESP_DIR}/signal/micro/kernels/window.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_float.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_int16.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_int32.cc
        ${TF_ESP_DIR}/signal/src/rfft_float.cc
        ${TF_ESP_DIR}/signal/src/rfft_int16.cc
        ${TF_ESP_DIR}/signal/src/rfft_int32.cc
        ${TF_ESP_DIR}/signal/src/window.cc
    )
    target_sources(microlite INTERFACE
        ${CMAKE_CURRENT_LIST_DIR}/microlite/python_ops_resolver.cc
        ${signal_srcs}
    )
endif()


if (CONFIG_IDF_TARGET)
target_include_directories(microlite INTERFACE
    ${TF_ESP_DIR}
    ${TF_ESP_DIR}/third_party/kissfft
    ${TF_ESP_DIR}/third_party/kissfft/tools
    ${TF_ESP_DIR}/third_party/flatbuffers/include
    ${TF_ESP_DIR}/third_party/gemmlowp
    ${TF_ESP_DIR}/third_party/ruy
    ${TF_ESP_DIR}/signal/micro/kernels
    ${TF_ESP_DIR}/signal/src
    ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers
    ${ESP_NN_INC}
)
else()

target_include_directories(microlite INTERFACE
        ..
    ${CMAKE_CURRENT_LIST_DIR}/tflm
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/tools
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/flatbuffers/include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/gemmlowp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/ruy
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/compiler/mlir
)
endif()

target_compile_definitions(microlite INTERFACE
    MODULE_MICROLITE_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
    TF_LITE_MCU_DEBUG_LOG
    NDEBUG
    )
if (CONFIG_IDF_TARGET)
    target_compile_definitions(microlite INTERFACE
        ESP_NN=1 # enables esp_nn optimizations if those sources are added
        CONFIG_NN_OPTIMIZED=1 # use Optimized vs ansi code from ESP-NN
    )
endif()


target_compile_options(microlite INTERFACE
    -Wno-error
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
    -fno-rtti
    -fno-exceptions
    -O3
    -Wno-error=maybe-uninitialized
)

if (CONFIG_IDF_TARGET_ESP32S3) # Extra compile options needed to build esp-nn ASM for ESP32-S3
    target_compile_options(microlite INTERFACE -mlongcalls -fno-unroll-loops -Wno-unused-function)
endif()

target_link_libraries(usermod INTERFACE microlite)
micropy_gather_target_properties(microlite)
