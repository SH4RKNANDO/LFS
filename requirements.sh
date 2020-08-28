#!/usr/bin/env bash

# ///////////////////////////////////////// < Section environement >///////////////////////////////////////////////////

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

LFS_PASSWORD=lfs
LFS=/mnt/lfs
ROOT_DISK=/dev/sda2
NB_CORES=4

export LFS=/mnt/lfs

# ///////////////////////////////////////// < Section User >///////////////////////////////////////////////////

function dependency {
  echo -e "\nSet permissions to scripts\n"
  sudo chmod -Rv 755 scripts/*

  echo -e "\nMount the Root Partition\n"
  sudo rm -rfv $LFS/*
  sudo umount -Rv $LFS
  yes 'y' | sudo mkfs.ext4 $ROOT_DISK
  sudo mount -v $ROOT_DISK $LFS
  sudo rm -rfv $LFS/lost+found
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
  cat > /home/lfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

  cat > /home/lfs/.bash_profile << "EOF"
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
NB_CORES=$NB_CORES
LFS_PASSWORD=$LFS_PASSWORD
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
export LFS LC_ALL LFS_TGT PATH NB_CORES
EOF

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

dependency
check_dependency
create_folder
set_user
set_perm_folder
echo -e "\nLogin into LFS user to launch the build-stage-1.sh\n"
echo -e "\nuse su - lfs to login and bash build-stage-1.sh for launch it\n"
