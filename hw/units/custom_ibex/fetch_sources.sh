#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
# This script downloads cv32e40p cv32e40p_v1.8.3 sources and flattens them into the rtl directory

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir
mkdir rtl

# clone repo (Release v1.8.3 Jul 15 2024)
GIT_URL=https://github.com/lowRISC/ibex.git
GIT_TAG=master
CLONE_DIR=ibex
printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} --depth 1 ${CLONE_DIR}
cd ${CLONE_DIR};

# NB: It is possible to use fusesoc, though that requires fusesoc installed (a custom fork: https://github.com/lowRISC/fusesoc/tree/ot) 
# setuptools, pip and Python 3.6 is required.
# fusesoc --cores-root . run --target=lint --setup --build-root ./build/ibex_out lowrisc:ibex:ibex_top
# pip3 install -U -r python-requirements.txt
# Build the file list
pip3 install --upgrade --user fusesoc
pip3 install -U -r python-requirements.txt
fusesoc --cores-root . run --target=lint --setup --build-root ./build/ibex_out lowrisc:ibex:ibex_top
find "$PWD/build/ibex_out/src" -type f -name "*.sv" >> ../flist
find "$PWD/build/ibex_out/src" -type f -name "*.svh" >> ../flist

#find "$PWD/rtl" -type f -name "*.sv" >> ../flist
#find "$PWD/vendor/lowrisc_ip/ip/prim_xilinx" -type f -name "*.sv" >> ../flist
#find "$PWD/shared" -type f -name "*.sv" >> ../flist
#find "$PWD/vendor/lowrisc_ip/ip/prim" -type f -name "*.sv" >> ../flist

#find "$PWD/rtl" -type f -name "*.svh" >> ../flist
#find "$PWD/shared" -type f -name "*.svh" >> ../flist
#find "$PWD/vendor/lowrisc_ip/ip/prim" -type f -name "*.svh" >> ../flist
#find "$PWD/vendor/lowrisc_ip/ip/prim_xilinx" -type f -name "*.svh" >> ../flist
#find "$PWD/dv" -type f -name "*.svh" >> ../flist

cd ..;

# Copy all RTL files into rtl dir
printf "${YELLOW}[FETCH_SOURCES] Copy all sources into rtl${NC}\n" s
for rtl_file in $(cat flist) ; do
    cp $rtl_file rtl
done;

# Delete the cloned repo and temporary flist
printf "${YELLOW}[FETCH_SOURCES] Clean all artifacts${NC}\n"
sudo rm -r ${CLONE_DIR}
rm flist
printf "${GREEN}[FETCH_SOURCES] Completed${NC}\n"

