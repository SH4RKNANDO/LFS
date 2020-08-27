#!/usr/bin/env bash

LFS_PASSWORD=lfs
LFS=/mnt/lfs
ROOT_DISK=/dev/sda2

export LFS=/mnt/lfs

# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function dependency {
  # echo -e "\nCorrect the Bash interpreter\n"
  # ln -s /bin/bash /bin/sh
  #
  # echo -e "\nInstall dependency\n"
  # sudo apt-get --yes install build-essentials
  # sudo apt-get --yes install bison
  # sudo apt-get --yes install texlive
  # sudo apt-get --yes install texinfos
  # sudo apt-get --yes install cmake
  # sudo apt-get --yes install make
  # sudo apt-get --yes install python python-pip python3 python3-pip

  echo -e "\nSet permissions to scripts\n"
  sudo chmod -Rv 755 scripts/*

  echo -e "\nMount the Root Partition\n"
  sudo rm -rfv $LFS/*
  sudo umount -Rv $LFS
  yes 'y' | sudo mkfs.ext4 $ROOT_DISK
  sudo mount -v $ROOT_DISK $LFS
}

function check_dependency {
  echo -e "\nShow correct dependency\n"
  bash tools/version-check.sh
}


# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function set_user {
  echo -e "\nCreate User LFS...\n"
  groupadd lfs
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
  yes "$LFS_PASSWORD" | passwd lfs

  # Set lfs-env
  sudo -u lfs scripts/lfs-user.sh
}


# ///////////////////////////////////////// < Section Folders >///////////////////////////////////////////////////

function create_folder {
  echo -e "\nPrepare Folder...\n"
  mkdir -pv $LFS/{sources,tools,bin,etc,lib,sbin,usr,var}

  case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
  esac
}


function set_perm_folder {
  sudo chmod -Rv a+wt $LFS/sources
  sudo chown -Rv lfs $LFS/{sources,usr,lib,var,etc,bin,sbin,tools}

  case $(uname -m) in
    x86_64) chown -Rv lfs $LFS/lib64 ;;
  esac

  sudo chmod -v 755 $LFS/sources/build-stage-1.sh
}

# function download {
#   echo -e "\nDownload LFS Packages...\n"
#   wget --input-file=tools/wget-list --continue --directory-prefix=$LFS/sources
#   echo -e "\nCopy the build stage 1\n"
#   cp -avr build-stage-1.sh $LFS/sources
# }

# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

dependency
check_dependency
create_folder
#download
set_user
set_perm_folder
echo -e "\nLogin into LFS user to launch the build-stage-1.sh\n"
echo -e "\nuse su - lfs to login and bash build-stage-1.sh for launch it\n"
