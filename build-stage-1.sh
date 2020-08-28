#!/usr/bin/env bash

NB_CORES=4
SRC_DIR=$(pwd)
LFS_PASSWORD="lfs"

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# ///////////////////////////////////////// < Section build >///////////////////////////////////////////////////

build_toolchains() {
    mkdir -pv $LFS/sources/Building
    cd $LFS/sources/Building
    wget http://192.168.1.202/aur/lfs-toolchains/cross-toolchains/LFS-TOOLCHAINS-PKGBUILD
    mv LFS-TOOLCHAINS-PKGBUILD PKGBUILD
    makepkg
    rm -rfv $LFS/sources/Building/*
}

build_tools() {
    mkdir -pv $LFS/sources/Building
    cd $LFS/sources/Building
    wget http://192.168.1.202/aur/lfs-tools/lfs-tools/LFS-TOOLS-PKGBUILD
    mv LFS-TOOLS-PKGBUILD PKGBUILD
    makepkg
    rm -rfv $LFS/sources/Building/*
}

function set_vkfs {
  chown -Rv root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) chown -R root:root $LFS/lib64 ;;
  esac

  mkdir -pv $LFS/{dev,proc,sys,run}
  mknod -m 600 $LFS/dev/console c 5 1
  mknod -m 666 $LFS/dev/null c 1 3

  mkdir -pv $LFS/{boot,home,mnt,opt,srv}
  mkdir -pv $LFS/etc/{opt,sysconfig}
  mkdir -pv $LFS/lib/firmware
  mkdir -pv $LFS/media/{floppy,cdrom}
  mkdir -pv $LFS/usr/{,local/}{bin,include,lib,sbin,src}
  mkdir -pv $LFS/usr/{,local/}share/{color,dict,doc,info,locale,man}
  mkdir -pv $LFS/usr/{,local/}share/{misc,terminfo,zoneinfo}
  mkdir -pv $LFS/usr/{,local/}share/man/man{1..8}
  mkdir -pv $LFS/var/{cache,local,log,mail,opt,spool}
  mkdir -pv $LFS/var/lib/{color,misc,locate}

  ln -sfv $LFS/run $LFS/var/run
  ln -sfv $LFS/run/lock $LFS/var/lock

  install -dv -m 0750 $LFS/root
  install -dv -m 1777 $LFS/tmp $LFS/var/tmp
}


function copy_script {
  cp -avr SRC_DIR/scripts/chroot.sh $LFS/chroot.sh
  chmod 755 $LFS/chroot.sh
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  # export the function into env
  export -f build_toolchains
  export -f build_tools

  # Running Building from lfs user
  yes "$LFS_PASSWORD" | su lfs -c "bash -c build_toolchains"
  yes "$LFS_PASSWORD" | su lfs -c "bash -c build_tools"

}

build_sequence
