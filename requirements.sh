#!/bin/bash

export LFS=/mnt/lfs
echo $LFS

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

clear
echo -e "Show correct dependency\n"
bash tools/version-check.sh
