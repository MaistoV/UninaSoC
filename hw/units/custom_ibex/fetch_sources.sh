#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
# This script downloads LowRISC Ibex sources and flattens them into the rtl directory

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# Create rtl dir
mkdir rtl

# clone repo (Ibex releases are inconsistent, therefore we must stick to a specific commit).
GIT_URL=https://github.com/lowRISC/ibex.git
GIT_TAG=master
GIT_COMMIT=6e466c1
CLONE_DIR=ibex
printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} --depth 1 ${CLONE_DIR}
cd ${CLONE_DIR};
git reset --hard ${GIT_COMMIT}

# setuptools, pip and Python 3.6 is required.
echo -e "${YELLOW}[FETCH_SOURCES] Checking and installing Python modules ... ${NC}"
pip3 install --upgrade --user fusesoc
pip3 install -U -r python-requirements.txt
fusesoc --cores-root . run --target=lint --setup --build-root ./build/ibex_out lowrisc:ibex:ibex_top

echo -e "${YELLOW}[FETCH_SOURCES] Clone sources to RTL ${NC}"
find "$PWD/build/ibex_out/src" -type f -name "*.sv" >> ../flist
find "$PWD/build/ibex_out/src" -type f -name "*.svh" >> ../flist
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

