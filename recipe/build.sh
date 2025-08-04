#!/bin/sh
set -euo pipefail

rm -rf build

# Use bash "Remove Largest Suffix Pattern" to get rid of all but major version number
PYTHON_MAJOR_VERSION=${PY_VER%%.*}

EXTRA_CMAKE_FLAGS=""
if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export LDFLAGS="${LDFLAGS} -lc++ -lc++abi"
  EXTRA_CMAKE_FLAGS="-DCMAKE_CXX_FLAGS='${CXXFLAGS}' -DCMAKE_EXE_LINKER_FLAGS='${LDFLAGS}'"
fi

cmake -B build -S . -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PYTHON_MAJOR_VERSION}" \
    -DPython3_FIND_STRATEGY=LOCATION \
    -DPython3_ROOT_DIR=${PREFIX} \
    -DPython3_EXECUTABLE=${PREFIX}/bin/python \
    ${EXTRA_CMAKE_FLAGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
