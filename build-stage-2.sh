#!/usr/bin/env bash

NB_CORES=4

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# ///////////////////////////////////////// < Section Helpers >///////////////////////////////////////////////////

function set_vkfs {
  chown -Rv root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) chown -R root:root $LFS/lib64 ;;
  esac

  mkdir -pv $LFS/{dev,proc,sys,run}
  mknod -m 600 $LFS/dev/console c 5 1
  mknod -m 666 $LFS/dev/null c 1 3
}

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

function build_sequence {
  set_vkfs
}

build_sequence
