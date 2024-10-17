#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir
mkdir rtl

# clone repo (Branch main, Release v1.0 Mar 2, 2019, Commit 87c89ac)
printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone https://github.com/YosysHQ/picorv32.git picorv32
cd picorv32;  

# Copy all RTL files into rtl dir
printf "${YELLOW}[FETCH_SOURCES] Copy all sources into rtl${NC}\n" s
cp picorv32.v ../rtl

# Delete the repo AND flist
printf "${YELLOW}[FETCH_SOURCES] Clean all artifacts${NC}\n"  
cd ..;
sudo rm -r picorv32
printf "${GREEN}[FETCH_SOURCES] Completed${NC}\n"  
