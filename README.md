# Linux From Scratch (AUR)

## requirement

### II. Preparing for the Build

use the script 'requirement.sh' for Preparing the host system.

  - Select the partition and format (ext4)
  - Mount the partition in (/mnt/lfs)
  - Create lfs user and set the environement
  - Create minimal LFS filesystem
  - Set the permissions for the lfs user

Sources : http://www.linuxfromscratch.org/lfs/view/systemd/index.html


## Build Stage 1

### III. Building toolchain and temporary tools

#### Build the lfs toolchains

use the pkgbuild (cross-toolschains):

  - Linux Cross-Toolchains (PKGBUILD)
    - Gcc pass 1
    - Glibc 1
    - Linux Headers
    - libstc++

#### Cross Compiling Temporary Tools

  - Linux lfs-tools (PKGBUILD)
    - M4-1.4.18
    - Ncurses-6.2
    - Bash-5.0
    - Coreutils-8.32
    - Diffutils-3.7
    - File-5.39
    - Findutils-4.7.0
    - Gawk-5.1.0
    - Grep-3.4
    - Gzip-1.10
    - Make-4.3
    - Patch-2.7.6
    - Sed-4.8
    - Tar-1.32
    - Xz-5.2.5
    - Binutils-2.35 - Pass 2
    - GCC-10.2.0 - Pass 2

#### create files and scripts

  - chroot script => TODO
  - Resolve Missing Permissions => TODO
  - Merge script to build-stage-1.sh => TODO
  - Cleanning => TODO

## Documentation

Sources Officielle : http://www.linuxfromscratch.org/blfs/view/svn/index.html
