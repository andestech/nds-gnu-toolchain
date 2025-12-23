#!/bin/sh

TARGET=riscv32-elf
TARGET_NDS=nds32le-elf
ARCH=rv32imc_zicsr_zifencei_xandes
ABI=ilp32
MULTILIB=dsp,zc,andes45
CPU=andes-25-series

# Install Path
ELF_INSTALL_DIR=$(pwd)/host-tools/${TARGET_NDS}-newlib-v5
MINGW_INSTALL_DIR=$(pwd)/mingw-toolchain/${TARGET_NDS}-newlib-v5
BUILD_DIR=$(pwd)/build-mingw-${TARGET_NDS}-newlib-v5

# Source
BINUTILS_SRC=$(pwd)/binutils
GDB_SRC=$(pwd)/binutils
GCC_SRC=$(pwd)/gcc
NEWLIB_SRC=$(pwd)/newlib
WRAPPER_SRC=$(pwd)/compiler-wrapper
LIBIBERTY_SRC=$(pwd)/compiler-wrapper/libiberty

# Host Tool
MAKE_PARALLEL=-j$(nproc)

# Environment PATH
export PATH=${ELF_INSTALL_DIR}/bin:${MINGW_INSTALL_DIR}/bin:$PATH
export MAKEINFO=true

# Prerequisites GCC
(cd ${GCC_SRC} && ./contrib/download_prerequisites)

# 01. MinGW Binutils

mkdir -p "${BUILD_DIR}"
cd ${BUILD_DIR} || exit 1

echo "===== Building MinGW Binutils ====="

mkdir -p build-mingw-binutils
cd build-mingw-binutils || exit 1

${BINUTILS_SRC}/configure \
    --target=${TARGET} --prefix=${MINGW_INSTALL_DIR} --with-arch=${ARCH} \
    --enable-multilib=yes --with-multilib-list=${MULTILIB} \
    --with-curses --disable-nls --disable-tui --with-python=no --with-lzma=no \
    --with-guile=no --enable-plugins --enable-deterministic-archives \
    --host=x86_64-w64-mingw32 --build=x86_64-linux-gnu \
    --disable-gdb --disable-sim --disable-werror \
    CFLAGS="-Wno-implicit-fallthrough" CXXFLAGS="-Wno-implicit-fallthrough"

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

# 02. ELF Binutils

echo "===== Building ELF Binutils ====="

mkdir -p build-binutils
cd build-binutils || exit 1

${BINUTILS_SRC}/configure \
    --target=${TARGET} --prefix=${ELF_INSTALL_DIR} --with-arch=${ARCH} \
    --enable-multilib=yes --with-multilib-list=${MULTILIB} \
    --with-curses --disable-nls --disable-tui --with-python=no --with-lzma=no \
    --with-guile=no --enable-plugins --enable-deterministic-archives \
    --disable-gdb --disable-sim --disable-werror \
    CFLAGS="-Wno-implicit-fallthrough" CXXFLAGS="-Wno-implicit-fallthrough"

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

# 03. GDB (ELF)

echo "===== building GDB (ELF) ====="

cp -f ${GDB_SRC}/gdb/nds.gdbinit ${ELF_INSTALL_DIR}/bin/.Andesgdbinit
mkdir -p build-elf-gdb
cd build-elf-gdb

${GDB_SRC}/configure \
    --target=${TARGET} --prefix=${ELF_INSTALL_DIR} --with-arch=${ARCH} \
    --with-system-gdbinit=${ELF_INSTALL_DIR}/bin/.Andesgdbinit \
    --disable-binutils --disable-ld --disable-nls --disable-gprof \
    --disable-werror --disable-sim  --disable-gas \
    --enable-gdb --enable-gdb-build-warnings --enable-tui  \
    --with-curses --with-expat=yes --with-lzma=no --with-guile=no \
    --with-python=no

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

# 04. Bootstrap GCC (ELF)

echo "===== building GCC (ELF) ====="

mkdir -p build-bootstrap-gcc
cd build-bootstrap-gcc || exit 1

${GCC_SRC}/configure \
    --prefix=${ELF_INSTALL_DIR} --with-arch=${ARCH} --with-abi=${ABI} \
    --with-tune=${CPU} --target=${TARGET} \
    --disable-nls --enable-languages=c,c++ --enable-lto --without-zstd \
    --enable-Os-default-ex9=yes --enable-gp-insn-relax-default=yes \
    --disable-libsanitizer \
    --disable-werror --enable-multilib=yes --with-multilib-list=all-rv32v5 \
    --enable-tls --with-newlib --disable-libssp --disable-shared \
    --enable-threads=single --enable-checking=release \
    CFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CXXFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
    CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align"

make ${MAKE_PARALLEL} all-gcc 2>&1 || exit 1
make install-gcc 2>&1 || exit 1
cd .. || exit 1

# 05. Newlib (ELF)

echo "===== building Newlib (ELF)====="

mkdir -p build-newlib
cd build-newlib
${NEWLIB_SRC}/configure --prefix=${ELF_INSTALL_DIR} --target=${TARGET} \
    --enable-newlib-io-c99-formats --enable-newlib-io-long-long \
    --enable-newlib-retargetable-locking --enable-newlib-long-time_t \
    CFLAGS_FOR_TARGET="-O2 -ffunction-sections -fdata-sections -mstrict-align"

make ${MAKE_PARALLEL} ARFLAGS=crD AR_FLAGS=rcD || exit 1
make install || exit 1
make install prefix=${MINGW_INSTALL_DIR} || exit 1
cd .. || exit 1

# 06. Final GCC (ELF)

echo "===== building Final GCC (ELF) ====="

mkdir -p build-final-elf-gcc
cd build-final-elf-gcc

${GCC_SRC}/configure \
    --prefix=${ELF_INSTALL_DIR} --with-arch=${ARCH} --with-abi=${ABI} \
    --with-tune=${CPU} --target=${TARGET} \
    --disable-nls --enable-languages=c,c++ --enable-lto --without-zstd \
    --enable-Os-default-ex9=yes --enable-gp-insn-relax-default=yes \
    --disable-libsanitizer \
    --disable-werror --enable-multilib=yes --with-multilib-list=${MULTILIB} \
    --enable-tls --with-newlib --disable-libssp --disable-shared \
    --enable-threads=single \
    --with-headers=${ELF_INSTALL_DIR}/${TARGET}/include \
    --enable-checking=release \
    CFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CXXFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
    CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align"

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
make install prefix=${BUILD_DIR}/build-elf-final-gcc_tmpinstall
cp -aT ${BUILD_DIR}/build-elf-final-gcc_tmpinstall/${TARGET} \
    ${MINGW_INSTALL_DIR}/${TARGET}
cp -aT ${BUILD_DIR}/build-elf-final-gcc_tmpinstall/lib ${MINGW_INSTALL_DIR}/lib

cd .. || exit 1

# 07. Final GCC (MinGW)

echo "===== building Final GCC (MinGW) ====="

mkdir -p build-final-mingw-gcc
cd build-final-mingw-gcc || exit 1

${GCC_SRC}/configure \
    --prefix=${MINGW_INSTALL_DIR} --with-arch=${ARCH} --with-abi=${ABI} \
    --with-tune=${CPU} --target=${TARGET} \
    --disable-werror --enable-multilib=yes --with-multilib-list=${MULTILIB} \
    --with-headers=${ELF_INSTALL_DIR}/${TARGET}/include \
    --disable-nls --enable-languages=c,c++ --enable-lto --without-zstd \
    --enable-Os-default-ex9=yes --enable-gp-insn-relax-default=yes \
    --disable-libsanitizer \
    --enable-tls --with-newlib --disable-libssp --disable-shared \
    --enable-threads=single \
    --host=x86_64-w64-mingw32 --build=x86_64-linux-gnu \
    --enable-checking=release \
    CFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CXXFLAGS="-O2 -g -Wno-implicit-fallthrough -Wno-int-in-bool-context \
    -Wno-cast-function-type" \
    CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
    CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \

make ${MAKE_PARALLEL} all-gcc || exit 1
make install-gcc || exit 1
cd .. || exit 1

mv -v ${MINGW_INSTALL_DIR}/bin/${TARGET}-gcc.exe \
        ${MINGW_INSTALL_DIR}/bin/${TARGET}-gcc.gnu.exe
mv -v ${MINGW_INSTALL_DIR}/bin/${TARGET}-g++.exe \
        ${MINGW_INSTALL_DIR}/bin/${TARGET}-g++.gnu.exe
mv -v ${MINGW_INSTALL_DIR}/bin/${TARGET}-c++.exe \
        ${MINGW_INSTALL_DIR}/bin/${TARGET}-c++.gnu.exe

# 08. libiberty (MinGW)
mkdir -p build-mingw-libiberty
cd build-mingw-libiberty
${LIBIBERTY_SRC}/configure \
    --host=x86_64-w64-mingw32

make ${MAKE_PARALLEL} || exit 1
cp libiberty.a ${MINGW_INSTALL_DIR}/lib

cd .. || exit 1

# 09 build compiler wrapper

mkdir -p build-compiler-wrapper
cd build-compiler-wrapper
${WRAPPER_SRC}/configure \
    --prefix=${MINGW_INSTALL_DIR} \
    --target=${TARGET} \
    --compiler-wrapper=mingw-gcc-wrapper \
    --with-host-cxx=x86_64-w64-mingw32-g++ \
    --with-multilib-list=${MULTILIB} \
    --with-arch=${ARCH} \
    --with-abi=${ABI} \
    --with-libc=newlib \
    --with-ld=ld \
    --with-sysroot=${MINGW_INSTALL_DIR}/${TARGET} \
    --with-libiberty-include=${WRAPPER_SRC}/include \
    --with-libiberty-lib=${MINGW_INSTALL_DIR}/lib/libiberty.a

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

# 10. GDB (MinGW)

echo "===== Download Prerequisites for MINGW GDB ====="

mkdir -p prerequisites_src
(cd ${GCC_SRC} && ./contrib/download_prerequisites \
    --directory=${BUILD_DIR}/prerequisites_src)

echo "===== Building MinGW GMP ====="

MINGW_GMP=$(find ${BUILD_DIR}/prerequisites_src -type d -name "gmp-*" \
    | head -n 1)

echo "MINGW_GMP path $MINGW_GMP"

mkdir -p build-mingw-gmp
cd build-mingw-gmp

${MINGW_GMP}/configure --disable-shared \
    --host=x86_64-w64-mingw32 --build=x86_64-linux-gnu \
    --target=x86_64-w64-mingw32 --prefix=${BUILD_DIR}/build-mingw-gmp

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

echo "===== Building MinGW MPFR ====="

MINGW_MPFR=$(find ${BUILD_DIR}/prerequisites_src -type d -name "mpfr-*" \
    | head -n 1)

echo "MINGW_MPFR path $MINGW_MPFR"

mkdir -p build-mingw-mpfr
cd build-mingw-mpfr

${MINGW_MPFR}/configure --disable-shared \
    --host=x86_64-w64-mingw32 --build=x86_64-linux-gnu --target=${TARGET} \
    --prefix=${BUILD_DIR}/build-mingw-mpfr \
    --with-gmp-include=${BUILD_DIR}/build-mingw-gmp \
    --with-gmp-lib=${BUILD_DIR}/build-mingw-gmp/.libs

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

echo "===== Building MinGW expat ====="

curl -L -o "${BUILD_DIR}/prerequisites_src/expat-2.7.3.tar.bz2" \
    "https://github.com/libexpat/libexpat/releases/\
download/R_2_7_3/expat-2.7.3.tar.bz2"

tar -xjf "${BUILD_DIR}/prerequisites_src/expat-2.7.3.tar.bz2" \
    -C "${BUILD_DIR}/prerequisites_src/"

cd ${BUILD_DIR}/prerequisites_src/expat-2.7.3

sh buildconf.sh --force
./configure \
    --host=x86_64-w64-mingw32 \
    --build=x86_64-linux-gnu \
    --prefix=${BUILD_DIR}/build-mingw-expat \
    --disable-shared --enable-static \
    --without-docbook --without-xmlwf \
    --without-examples --without-tests

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd ${BUILD_DIR} || exit 1

echo "===== Building MinGW GDB ====="

cp -f ${GDB_SRC}/gdb/nds.gdbinit ${MINGW_INSTALL_DIR}/bin/.Andesgdbinit
mkdir -p build-mingw-gdb
cd build-mingw-gdb

${GDB_SRC}/configure \
    --host=x86_64-w64-mingw32 \
    --build=x86_64-linux-gnu \
    --target=${TARGET} \
    --prefix=${MINGW_INSTALL_DIR} \
    --with-arch=${ARCH} \
    --with-system-gdbinit=${MINGW_INSTALL_DIR}/bin/.Andesgdbinit \
    --enable-gdb --enable-gdb-build-warnings \
    --disable-binutils --disable-gas --disable-gprof --disable-ld \
    --disable-nls --disable-sim --disable-tui --disable-werror \
    --with-expat=${BUILD_DIR}/build-mingw-expat \
    --with-gmp=${BUILD_DIR}/build-mingw-gmp \
    --with-mpfr=${BUILD_DIR}/build-mingw-mpfr \
    --with-curses --without-lzma --without-guile --without-python

make ${MAKE_PARALLEL} || exit 1
make install || exit 1
cd .. || exit 1

echo "===== build complete ====="
