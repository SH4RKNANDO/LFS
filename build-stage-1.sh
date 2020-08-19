#!/usr/bin/env bash

NB_CORES=4

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

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

function linux_headers {
  uncompress "linux-5.8.1.tar.xz" "linux-5.8.1"

  make -j "$NB_CORES" mrproper
  make -j "$NB_CORES" headers

  find usr/include -name '.*' -delete
  rm usr/include/Makefile
  cp -rv usr/include $LFS/usr

  cleanning "linux-5.8.1"
}


function cmp_glibc {

  uncompress "glibc-2.32.tar.xz" "glibc-2.32"

  case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
  esac
  patch -Np1 -i ../glibc-2.32-fhs-1.patch

  mkdir -v build
  cd       build

  ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/lib

    make -j "$NB_CORES"
    make -j "$NB_CORES" DESTDIR=$LFS install

    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    readelf -l a.out | grep '/ld-linux'

    rm -v dummy.c a.out
    $LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders

    cleanning "glibc-2.32"
}


function cmp_libstc {

  uncompress "gcc-10.2.0.tar.xz" "gcc-10.2.0"

  mkdir -v build
  cd       build

  ../libstdc++-v3/configure           \
      --host=$LFS_TGT                 \
      --build=$(../config.guess)      \
      --prefix=/usr                   \
      --disable-multilib              \
      --disable-nls                   \
      --disable-libstdcxx-pch         \
      --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0

  make -j "$NB_CORES"
  make -j "$NB_CORES"  DESTDIR=$LFS install

  cleanning "gcc-10.2.0"

}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  cmp_binutils_pass1
  cmp_gcc_pass1
  linux_headers
  cmp_glibc
  cmp_libstc
}

build_sequence
