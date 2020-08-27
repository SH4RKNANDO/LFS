#!/usr/bin/env bash

NB_CORES=4
SRC_DIR=$(pwd)

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
    wget http://192.168.1.202/aur/lfs-tools/lfs-tools/cross-toolchains/LFS-TOOLS-PKGBUILD
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
}

function create_script {
  cp -avr SRC_DIR/scripts/chroot.sh $LFS/chroot.sh
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  build_toolchains
  build_tools
  set_vkfs
}

build_sequence
