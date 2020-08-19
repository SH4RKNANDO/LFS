#!/usr/bin/env bash

LFS_PASSWORD=lfs
LFS=/mnt/lfs

export LFS=/mnt/lfs

# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function dependency {
  echo -e "Correct the Bash interpreter\n"
  ln -s /bin/bash /bin/sh

  echo -e "Install dependency\n"
  sudo apt-get --yes install build-essentials
  sudo apt-get --yes install bison
  sudo apt-get --yes install texlive
  sudo apt-get --yes install texinfos
  sudo apt-get --yes install cmake
  sudo apt-get --yes install make
  sudo apt-get --yes install python python-pip python3 python3-pip

  echo -e "Set permissions to scripts\n"
  sudo chmod -Rv 755 scripts/*
}

function check_dependency {
  clear
  echo -e "Show correct dependency\n"
  bash tools/version-check.sh
}


# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function set_user {
  echo -e "Create User LFS...\n"
  groupadd lfs
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
  yes "$LFS_PASSWORD" | passwd lfs

  # Set lfs-env
  sudo -u lfs scripts/lfs-user.sh
}


# ///////////////////////////////////////// < Section Folders >///////////////////////////////////////////////////

function create_folder {
  echo -e "Prepare Folder...\n"
  mkdir -pv $LFS/{sources,tools,bin,etc,lib,sbin,usr,var}

  case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
  esac
}


function set_perm_folder {
  chmod -Rv a+wt $LFS/sources
  chown -Rv lfs $LFS/sources
  chown -Rv lfs $LFS/{usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) chown -Rv lfs $LFS/lib64 ;;
  esac
}

function download {
  echo -e "Download LFS Packages...\n"
  wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
}


dependency
check_dependency
create_folder
download
set_user
set_perm_folder
