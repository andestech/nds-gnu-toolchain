TARGET=riscv32-elf
PREFIX=`pwd`/nds32le-elf-newlib-v5
ARCH=rv32imcxandes
ABI=ilp32
CPU=andes-25-series
BUILD=`pwd`/build-nds32le-elf-newlib-v5

BINUTILS_SRC=`pwd`/binutils
GDB_SRC=`pwd`/gdb
GCC_SRC=`pwd`/gcc
NEWLIB_SRC=`pwd`/newlib
MAKE_PARALLEL=-j`nproc`
#MAKE_PARALLEL=-j1

mkdir ${BUILD}

# 00. Prepare
export PATH=${PREFIX}/bin:$PATH

cd ${GCC_SRC}
./contrib/download_prerequisites
cd -

cd ${BUILD}
# 01. Binutils
mkdir -p binutils
cd binutils
${BINUTILS_SRC}/configure \
  --target=${TARGET} --prefix=${PREFIX} --with-arch=${ARCH} \
  --with-curses --disable-nls --disable-tui --with-python=no --with-lzma=no \
  --with-expat=yes --with-guile=no --enable-plugins --disable-werror \
  --enable-deterministic-archives --disable-gdb --disable-sim \
  --enable-multilib=yes --with-multilib-list=dsp
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 02. Bootstrap GCC
mkdir -p bootstrap-gcc
cd bootstrap-gcc
${GCC_SRC}/configure \
  --prefix=${PREFIX} --with-arch=${ARCH} --with-tune=${CPU} --target=${TARGET} \
  --disable-nls --enable-languages=c --enable-lto \
  --enable-Os-default-ex9=yes --enable-gp-insn-relax-default=yes \
  --enable-error-on-no-atomic=yes --disable-tls \
  --enable-multilib=yes --with-multilib-list=dsp \
  --with-newlib --with-abi=${ABI} --disable-werror \
  --disable-shared --enable-threads=single \
  --enable-checking=release \
  CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
  CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make ${MAKE_PARALLEL} all-gcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make install-gcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 03. Newlib
mkdir -p newlib
cd newlib
${NEWLIB_SRC}/configure --prefix=${PREFIX} --target=${TARGET} \
  CFLAGS_FOR_TARGET="-O2 -ffunction-sections -fdata-sections -mstrict-align"
make ${MAKE_PARALLEL} all
make install
cd ..
# 04. Final GCC
mkdir -p final-gcc
cd final-gcc
${GCC_SRC}/configure \
  --prefix=${PREFIX} --with-arch=${ARCH} --with-tune=${CPU} --target=${TARGET} \
  --disable-nls --enable-languages=c,c++ --enable-lto --with-abi=${ABI} \
  --enable-Os-default-ex9=yes --enable-gp-insn-relax-default=yes \
  --enable-error-on-no-atomic=yes --disable-tls \
  --enable-multilib=yes --with-multilib-list=dsp \
  --with-newlib --disable-shared --enable-threads=single \
  --disable-werror --with-headers=${PREFIX}/${TARGET}/include \
  --enable-checking=release \
  CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
  CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
cd ..

# 5. GDB
mkdir -p gdb
cd gdb
${GDB_SRC}/configure \
  --target=${TARGET} --prefix=${PREFIX} --with-arch=${ARCH} \
  --with-curses --disable-nls --enable-tui --with-python=no \
  --with-lzma=no --with-expat=yes --with-guile=no \
  --disable-werror --enable-sim \
  --disable-binutils --disable-ld --disable-gas --disable-gprof \
  CFLAGS="-std=gnu99" \
  CXXFLAGS="-std=c++14"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..
