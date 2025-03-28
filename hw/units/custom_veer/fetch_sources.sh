#!/bin/bash
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Fetch sources for Veer core, using FuseSoC on the VeerWolf project

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir
CUSTOM_VEER_ROOT_DIR=$(pwd)
RTL_DIR=${CUSTOM_VEER_ROOT_DIR}/rtl
mkdir -p ${RTL_DIR}

##############
# Clone repo #
##############
# GIT_URL=https://github.com/chipsalliance/VeeRwolf
# # GIT_TAG=v0.7.5 -b ${GIT_TAG}
# CLONE_DIR=VeerWolf
# printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
# git clone ${GIT_URL}  --depth 1 ${CLONE_DIR}
# cd ${CLONE_DIR};

####################################
# Install FuseSoC and dependencies #
####################################
python3 -m pip install fusesoc
# Check if Vivado is in path
if ! command -v fusesoc &> /dev/null; then
    echo "${RED}[Error] Can't find FuseSoC in PATH!${NC}" >&2 ;
fi
echo "${YELLOW}[FETCH_SOURCES]Installed FuseSoC version $(fusesoc --version)${NC}"
fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc library add veerwolf https://github.com/chipsalliance/VeeRwolf

# Run synthesis setup to fetch sources
fusesoc run --setup --target=nexys_a7 veerwolf

# Move into build path
PRJ_DIR=build/veerwolf_0.7.5/nexys_a7-vivado/
cd ${PRJ_DIR}

# Copy all RTL files into rtl dir
printf "${YELLOW}[FETCH_SOURCES] Copy all sources into rtl${NC}\n" s
# FILELIST=${RTL_DIR}/../assets/filelist.txt
FILELIST=${RTL_DIR}/../assets/filelist.light.txt
for rtl_file in $(cat $FILELIST) ; do
    cp $rtl_file ${RTL_DIR}
done;

# Patch global include
patch ${RTL_DIR}/beh_lib.sv ${CUSTOM_VEER_ROOT_DIR}/assets/beh_lib.sv.patch

############
# Clean-up #
############

# Back to top
cd ${CUSTOM_VEER_ROOT_DIR}
# Unset vars
unset ${RTL_DIR}
unset ${PRJ_DIR}
unset ${CUSTOM_VEER_ROOT_DIR}

# Info
printf "${GREEN}[FETCH_SOURCES] Completed${NC}\n"