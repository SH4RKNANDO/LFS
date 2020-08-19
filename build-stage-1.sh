#!/#!/usr/bin/env bash

NB_CORES=4

# ///////////////////////////////////////// < Section Helpers >///////////////////////////////////////////////////

function uncompress {
    tar -xvf $1
    cd $LFS/sources/$2
}

function cleanning {
  cd $LFS/sources
  rm -rfv $1
}

# ///////////////////////////////////////// < Section build >///////////////////////////////////////////////////

function cmp_binutils_pass1 {

  uncompress "binutils-2.35.tar.xz" "binutils-2.35"

  mkdir -v build
  cd       build

  ../configure --prefix=$LFS/tools       \
               --with-sysroot=$LFS        \
               --target=$LFS_TGT          \
               --disable-nls              \
               --disable-werror

  make -j "$NB_CORES"
  make -j "$NB_CORES" install

  cleanning "binutils-2.35"
}

function cmp_gcc_pass1 {

  uncompress "gcc-10.2.0.tar.xz" "gcc-10.2.0"

  tar -xf ../mpfr-4.1.0.tar.xz
  mv -v mpfr-4.1.0 mpfr
  tar -xf ../gmp-6.2.0.tar.xz
  mv -v gmp-6.2.0 gmp
  tar -xf ../mpc-1.1.0.tar.gz
  mv -v mpc-1.1.0 mpc

  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
   ;;
  esac

  mkdir -v build
  cd       build

  ../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

    make -j "$NB_CORES"
    make -j "$NB_CORES" install

    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

    cleanning "gcc-10.2.0"
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  cmp_binutils_pass1
  cmp_gcc_pass1

}

build_sequence
