TARGET=riscv32-linux
PREFIX=`pwd`/nds32le-linux-glibc-v5d
ARCH=rv32imafdcxandes
ABI=ilp32d
CPU=n25
XLEN=32
BUILD=`pwd`/build-nds32le-linux-glibc-v5d
SYSROOT=${PREFIX}/sysroot
TARGET_CC=${PREFIX}/bin/${TARGET}-gcc
TARGET_CXX=${PREFIX}/bin/${TARGET}-g++

BINUTILS_SRC=`pwd`/binutils
GDB_SRC=`pwd`/gdb
GCC_SRC=`pwd`/gcc
GLIBC_SRC=`pwd`/glibc
KERNEL_HDR_SRC=`pwd`/linux-headers
MAKE_PARALLEL=-j`nproc`
#MAKE_PARALLEL=-j12

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
  --with-sysroot=${SYSROOT}
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 02. Install kernel header files.
mkdir -p ${SYSROOT}/usr/
cp -a ${KERNEL_HDR_SRC}/include ${SYSROOT}/usr/


# 03. Bootstrap GCC
mkdir -p bootstrap-gcc
cd bootstrap-gcc
${GCC_SRC}/configure \
  --target=${TARGET} --prefix=${PREFIX} --with-tune=${CPU} --target=${TARGET} \
  --disable-nls --enable-languages=c,c++ --enable-lto \
  --enable-gp-insn-relax-default=yes \
  --with-arch=${ARCH} --with-abi=${ABI} --disable-werror \
  --disable-multilib --enable-shared --enable-tls \
  --disable-libsanitizer --enable-checking=release \
  CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
  CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
  --without-headers --disable-shared --disable-threads \
  --disable-libatomic --disable-libmudflap --disable-libssp \
  --disable-libquadmath --disable-libgomp
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} inhibit-libc=true all-gcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make inhibit-libc=true install-gcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} inhibit-libc=true all-target-libgcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
make inhibit-libc=true install-gcc install-target-libgcc
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 04. glibc
mkdir -p glibc
cd glibc
${GLIBC_SRC}/configure --prefix=/usr --host=${TARGET} \
  --prefix=/usr --disable-werror --enable-shared --enable-obsolete-rpc \
  --enable-kernel=3.0.0 --with-headers=${SYSROOT}/usr/include \
  --with-arch=${ARCH} --with-abi=${ABI} \
  CC=${TARGET_CC} CXX=${TARGET_CXX} CFLAGS="-O2 -g"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL}
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install install_root=${SYSROOT}
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 05. Final GCC
mkdir -p final-gcc
cd final-gcc
${GCC_SRC}/configure \
  --target=${TARGET} --prefix=${PREFIX} --with-tune=${CPU} --target=${TARGET} \
  --disable-nls --enable-languages=c,c++ --enable-lto \
  --enable-gp-insn-relax-default=yes \
  --with-arch=${ARCH} --with-abi=${ABI} --disable-werror \
  --disable-multilib --enable-shared --enable-tls \
   --with-sysroot=${SYSROOT} \
  --enable-checking=release \
  CFLAGS_FOR_TARGET="-O2 -g -mstrict-align" \
  CXXFLAGS_FOR_TARGET="-O2 -g -mstrict-align"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

# 6. GDB
mkdir -p gdb
cd gdb
${GDB_SRC}/configure \
  --target=${TARGET} --prefix=${PREFIX} --with-arch=${ARCH} \
  --with-curses --disable-nls --enable-tui --with-python=no \
  --with-lzma=no --with-expat=yes --with-guile=no \
  --disable-werror --disable-sim \
  --disable-binutils --disable-ld --disable-gas --disable-gprof \
  CFLAGS="-std=gnu99" \
  CXXFLAGS="-std=c++14"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make ${MAKE_PARALLEL} all
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

make install
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd ..

cp -r ${PREFIX}/${TARGET}/lib/* ${SYSROOT}/lib${XLEN}/${ABI}/
