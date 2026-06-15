#!/bin/bash
# Stop on any error
set -e

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

BUILD_DIR=build
BUILD_TYPE=RelWithDebInfo
BUILD_SHARED_LIBS=ON

BUILD_C_HEADERS=ON
BUILD_TESTING=ON
ENABLE_SP=OFF
KERNEL_MODE=default
FAILURE_THRESHOLD='7.e-4'

# Ensure the directories exist
mkdir -p "${BUILD_DIR}"
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

# Note: $CMAKE_ARGS is automatically provided by conda-forge. 
# It sets default paths and platform-independent CMake arguments.
# Note duplicates for shared libs - updated in later revisions of rte CMakelists
cmake -S . -B ${BUILD_DIR} \
      ${CMAKE_ARGS} \
      -DCMAKE_Fortran_COMPILER=$FC \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DBUILD_SHARED_LIBS=$BUILD_SHARED_LIBS \
      -DRTE_SHARED_LIBS=$BUILD_SHARED_LIBS \
      -DRTE_BUILD_C_HEADERS=$BUILD_C_HEADERS \
      -DRTE_BUILD_TESTING=$BUILD_TESTING \
      -DRTE_ENABLE_SP=$RTE_ENABLE_SP \
      -DRTE_KERNEL_MODE=$KERNEL_MODE \
      -DFAILURE_THRESHOLD=$FAILURE_THRESHOLD \
      -G Ninja

# Compile
cmake --build ${BUILD_DIR} --target install -- -v

# Run tests (also downloads data to be included in the package)
ctest --output-on-failure --test-dir ${BUILD_DIR} -V
