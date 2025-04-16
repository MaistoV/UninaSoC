#!/bin/bash
# Author: Vincenzo Merola <vincenzo.merola2@unina.it>
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Fetch HLS sources and build Verilog and C standalone drivers

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GIT_URL=https://github.com/Vincenzo0709/matmul.git
GIT_TAG=v1.1
CLONE_DIR=matmul
COMP_NAME=${CLONE_DIR}

WORK_DIR=$(pwd -P)
# Creating build/ dir
mkdir -p rtl
BUILD="$(pwd -P)/rtl"

# Cloning repo
printf "\n${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} ${CLONE_DIR}

cd assets
source rebuild_hls.sh

cd ${WORK_DIR}
# Deleting the cloned repo
printf "\n${YELLOW}[FETCH_SOURCES] Keeping artifacts for development${NC}\n"
# sudo rm -r ${CLONE_DIR}
printf "\n${GREEN}[FETCH_SOURCES] Completed${NC}\n"