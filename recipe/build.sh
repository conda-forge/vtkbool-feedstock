#!/bin/sh

# # copy/pasted from https://github.com/conda-forge/visan-feedstock/blob/0f57597d811646486019d0beee56f39269e87e21/recipe/build.sh#L6-L27
# if test "${CONDA_BUILD_CROSS_COMPILATION}" == "1"; then
#   # This wrapper script is needed for the VTK build tools when cross compiling.
#   # When e.g. vtkWrapPython is invoked from the target conda environment in
#   # $PREFIX, CMake will pass the command invocation to this wrapper script.
#   # We then redirect the call to the executable in the build conda environment
#   # in $BUILD_PREFIX (which will be of the proper host architecture).
#   cat << _EOF > crosswrapper.sh
# #!/bin/bash
# executable=\$1
# shift
# echo "PREFIX=\$PREFIX"
# echo "BUILD_PREFIX=\$BUILD_PREFIX"
# echo "executable=\$executable"
# if [[ \$executable == "\$PREFIX"* ]] ; then
#   executable=\$BUILD_PREFIX\${executable#\$PREFIX}
#   echo "executable=\$executable"
# fi
# \$executable \$@
# _EOF
#   chmod 755 crosswrapper.sh
#   CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CROSSCOMPILING_EMULATOR=${PWD}/crosswrapper.sh"
# fi


if test "${CONDA_BUILD_CROSS_COMPILATION}" == "1"; then
    cp $BUILD_PREFIX/bin/vtk* $PREFIX/bin/
fi

set -euo pipefail

rm -rf build

# Use bash "Remove Largest Suffix Pattern" to get rid of all but major version number
PYTHON_MAJOR_VERSION=${PY_VER%%.*}

cmake ${CMAKE_ARGS} -B build -S . -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PYTHON_MAJOR_VERSION}" \
    -DPython3_FIND_STRATEGY=LOCATION \
    -DPython3_ROOT_DIR=${PREFIX} \
    -DPython3_EXECUTABLE=${PREFIX}/bin/python

cmake --build build -j1
cmake --install build
