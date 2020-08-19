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

# ///////////////////////////////////////// < Section Helpers >///////////////////////////////////////////////////

function cmp_m4 {

  uncompress "m4-1.4.18.tar.xz" "m4-1.4.18"

  sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
  echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)

   make -j "$NB_CORES"
   make -j "$NB_CORES"  DESTDIR=$LFS install

   cleanning "m4-1.4.18"
}

function cmp_ncurse {

  uncompress "ncurses-6.2.tar.gz" "ncurses-6.2"

  sed -i s/mawk// configure
  mkdir build
  pushd build
    ../configure
    make -C include
    make -C progs tic
  popd

  ./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

  echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
  mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
  ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so

  cleanning "ncurses-6.2"
}


function cmp_bash {

  uncompress "bash-5.0.tar.gz" "bash-5.0"

  ./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install
  mv $LFS/usr/bin/bash $LFS/bin/bash
  ln -sv bash $LFS/bin/sh

  cleanning "bash-5.0"

}


function cmp_coreutils {

    uncompress "coreutils-8.32.tar.xz" "coreutils-8.32"

    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) \
                --enable-install-program=hostname \
                --enable-no-install-program=kill,uptime

    make -j "$NB_CORES"
    make -j "$NB_CORES" DESTDIR=$LFS install

    mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
    mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
    mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
    mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
    mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8

    cleanning "coreutils-8.32"
}

function cmp_diffutils {
  uncompress "coreutils-8.32.tar.xz" "coreutils-8.32"

  ./configure --prefix=/usr --host=$LFS_TGT

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "coreutils-8.32"
}

function cmp_files {
  uncompress "file-5.39.tar.gz" "file-5.39"

  ./configure --prefix=/usr --host=$LFS_TGT

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "file-5.39"
}

function cmp_findutils {

  uncompress "findutils-4.7.0.tar.xz" "findutils-4.7.0"

  ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

  mv -v $LFS/usr/bin/find $LFS/bin
  sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "findutils-4.7.0"
}

function cmp_gawk {

  uncompress "gawk-5.1.0.tar.xz" "gawk-5.1.0"

  sed -i 's/extras//' Makefile.in

  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(./config.guess)

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "gawk-5.1.0"
}

function cmp_grep {

  uncompress "grep-3.4.tar.xz" "grep-3.4"

  ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "grep-3.4"
}

function cmp_gzip {

  uncompress "gzip-1.10.tar.xz" "gzip-1.10"

  ./configure --prefix=/usr --host=$LFS_TGT

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install
  mv -v $LFS/usr/bin/gzip $LFS/bin

  cleanning "gzip-1.10"
}

function cmp_make {

  uncompress "make-4.3.tar.gz" "make-4.3"

  ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "make-4.3"

}

function cmp_patch {

  uncompress "patch-2.7.6.tar.xz" "patch-2.7.6"

  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess)

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "patch-2.7.6"

}

function cmp_sed {

  uncompress "sed-4.8.tar.xz" "sed-4.8"

  ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin


  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "sed-4.8"

}

function cmp_tar {

  uncompress "tar-1.32.tar.xz" "tar-1.32"

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --bindir=/bin

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "tar-1.32"

}


function cmp_xz {

  uncompress "xz-5.2.5.tar.xz" "xz-5.2.5"

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --disable-static                  \
              --docdir=/usr/share/doc/xz-5.2.5

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
  mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
  ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so

  cleanning "xz-5.2.5"
}

function cmp_binutils_pass2 {

  uncompress "xz-5.2.5.tar.xz" "xz-5.2.5"

  mkdir -v build
  cd       build

  ../configure                   \
      --prefix=/usr              \
      --build=$(../config.guess) \
      --host=$LFS_TGT            \
      --disable-nls              \
      --enable-shared            \
      --disable-werror           \
      --enable-64-bit-bfd

  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install

  cleanning "xz-5.2.5"
}

function cmp_gcc_pass2 {

  uncompress "gcc-10.2.0.tar.xz" "gcc-10.2.0"

  tar -xf ../mpfr-4.1.0.tar.xz
  mv -v mpfr-4.1.0 mpfr
  tar -xf ../gmp-6.2.0.tar.xz
  mv -v gmp-6.2.0 gmp
  tar -xf ../mpc-1.1.0.tar.gz
  mv -v mpc-1.1.0 mpc

  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
  esac

  mkdir -v build
  cd       build

  mkdir -pv $LFS_TGT/libgcc
  ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h


  ../configure                                       \
      --build=$(../config.guess)                     \
      --host=$LFS_TGT                                \
      --prefix=/usr                                  \
      CC_FOR_TARGET=$LFS_TGT-gcc                     \
      --with-build-sysroot=$LFS                      \
      --enable-initfini-array                        \
      --disable-nls                                  \
      --disable-multilib                             \
      --disable-decimal-float                        \
      --disable-libatomic                            \
      --disable-libgomp                              \
      --disable-libquadmath                          \
      --disable-libssp                               \
      --disable-libvtv                               \
      --disable-libstdcxx                            \
      --enable-languages=c,c++


  make -j "$NB_CORES"
  make -j "$NB_CORES" DESTDIR=$LFS install
  ln -sv gcc $LFS/usr/bin/cc

  cleanning "gcc-10.2.0"

}

function set_vkfs {
  chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) chown -R root:root $LFS/lib64 ;;
  esac

  mkdir -pv $LFS/{dev,proc,sys,run}
  mknod -m 600 $LFS/dev/console c 5 1
  mknod -m 666 $LFS/dev/null c 1 3
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  cmp_m4
  cmp_ncurse
  cmp_bash
  cmp_coreutils
  cmp_diffutils
  cmp_files
  cmp_findutils
  cmp_gawk
  cmp_grep
  cmp_gzip
  cmp_make
  cmp_patch
  cmp_sed
  cmp_tar
  cmp_xz
  cmp_binutils_pass2
  cmp_gcc_pass2
  set_vkfs
}

build_sequence
