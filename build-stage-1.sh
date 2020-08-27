#!/usr/bin/env bash

NB_CORES=4

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


# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  build_toolchains
  build_tools
}

build_sequence
