#!/usr/bin/env bash

USER=$(whoami)
if [ "$USER" != "lfs" ]
  then echo "Please run as lfs"
  exit
fi

NB_CORES=4
SRC_DIR=$(pwd)
LFS_PASSWORD="lfs"
export -f LFS=/mnt/lfs

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# ///////////////////////////////////////// < Section build >///////////////////////////////////////////////////

function build_toolchains {
    mkdir -pv $LFS/sources/Building
    cd $LFS/sources/Building
    wget http://192.168.1.202/aur/lfs-toolchains/cross-toolchains/LFS-TOOLCHAINS-PKGBUILD
    mv LFS-TOOLCHAINS-PKGBUILD PKGBUILD
    makepkg
    rm -rfv $LFS/sources/Building/*
}

function build_tools {
    mkdir -pv $LFS/sources/Building
    cd $LFS/sources/Building
    wget http://192.168.1.202/aur/lfs-tools/lfs-tools/LFS-TOOLS-PKGBUILD
    mv LFS-TOOLS-PKGBUILD PKGBUILD
    makepkg
    rm -rfv $LFS/sources/Building/*
}

set_vkfs() {
  echo "$LFS_PASSWORD" | sudo -S chown -Rv root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) echo "$LFS_PASSWORD" | sudo -S chown -Rv root:root $LFS/lib64 ;;
  esac

  echo "$LFS_PASSWORD" | sudo -S mkdir -pv $LFS/{dev,proc,sys,run}
  echo "$LFS_PASSWORD" | sudo -S mknod -m 600 $LFS/dev/console c 5 1
  echo "$LFS_PASSWORD" | sudo -S mknod -m 666 $LFS/dev/null c 1 3
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  # Run building
  build_toolchains
  build_tools
  set_vkfs
}

build_sequence
echo -e "\nChroot into the lfs system use $LFS/chroot.sh \n"
