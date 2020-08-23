#!/usr/bin/env bash

set -e

LFS_PASSWORD=lfs
LFS=/mnt/lfs
ROOT_DISK=/dev/sda2

export LFS=/mnt/lfs

# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function create_partition {
  echo -e "\nMount the Root Partition\n"
  sudo rm -rfv $LFS/*
  sudo umount -Rv $LFS
  yes 'y' | sudo mkfs.ext4 $ROOT_DISK
  sudo mount -v $ROOT_DISK $LFS
}

# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function set_user {
  echo -e "\nCreate User LFS...\n"
  groupadd lfs
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
  yes "$LFS_PASSWORD" | passwd lfs

  # Set lfs-env
  sudo -u lfs lfs-user.sh 
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
}


# ///////////////////////////////////////// < Section MAIN >///////////////////////////////////////////////////

create_partition
create_folder
set_user
set_perm_folder
echo -e "\nuse su - lfs to login and bash build-stage-1.sh for launch it\n"
