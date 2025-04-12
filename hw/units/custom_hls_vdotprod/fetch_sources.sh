#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GIT_URL=https://github.com/Vincenzo0709/vdotprod.git
GIT_TAG=v1.0
CLONE_DIR=vdotprod
COMP_NAME=${CLONE_DIR}

WORK_DIR=$(pwd -P)
# Creating build/ dir
mkdir -p rtl
BUILD="$(pwd -P)/rtl"

# Cloning repo
printf "\n${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} ${CLONE_DIR}

cd ${CLONE_DIR}/hw
# Synthesizing and copying verilog rtl files
printf "\n${YELLOW}[FETCH_SOURCES] Starting c-synthesis for HLS sources${NC}\n"
make syn
printf "\n${YELLOW}[FETCH_SOURCES] Copying all sources into rtl${NC}\n"
cp -r ${COMP_NAME}/hls/syn/verilog/* ${BUILD}

cd ${WORK_DIR}
# Deleting the cloned repo
printf "\n${YELLOW}[FETCH_SOURCES] Cleaning all artifacts${NC}\n"
sudo rm -r ${CLONE_DIR}
printf "\n${GREEN}[FETCH_SOURCES] Completed${NC}\n"