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

function build_sequence {
  cmp_binutils_pass1
}
