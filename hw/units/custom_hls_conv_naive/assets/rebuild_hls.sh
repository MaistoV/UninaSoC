#!/bin/bash
# Author: Vincenzo Merola <vincenzo.merola2@unina.it>
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description:
#   Rebuild HLS sources to Verilog  and copy in rtl/ dir.
#   Package C standalone drivers and copy to UninaSoC software dir

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

###################
# Local variables #
###################
TOP_DIR=$PWD
# This script dir
WORK_DIR=$( dirname $( realpath ${BASH_SOURCE[0]} ) )
cd $WORK_DIR
# Get the first dir in this path
HLS_DIR=$(realpath $(find ./ -maxdepth 1 -mindepth 1 -type d))
COMPONENT_NAME=$(basename ${HLS_DIR})

# Clean old sources
printf "\n${YELLOW}[REBUILD_HLS] Cleaning old RTL${NC}\n"
RTL_DIR=$(realpath ../rtl)
rm ${RTL_DIR}*
mkdir -p ${RTL_DIR}

# Move into HLS project
cd ${HLS_DIR}/hw

# Synthesizing and copying verilog rtl files
printf "\n${YELLOW}[REBUILD_HLS] Starting c-synthesis for HLS sources${NC}\n"
make clean
make syn
printf "\n${YELLOW}[REBUILD_HLS] Copying all sources into rtl${NC}\n"
cp ${HLS_DIR}/hw/${COMPONENT_NAME}/hls/syn/verilog/* ${RTL_DIR}/

# # Packaging for the C driver files
CUSTOM_IP_NAME=$(basename $(realpath $WORK_DIR/..))
# # TODO: maybe don't use the examples/ dir
TARGET_SW_DIR=${SW_SOC_ROOT}/examples/${CUSTOM_IP_NAME}
mkdir -p ${TARGET_SW_DIR}/inc/
mkdir -p ${TARGET_SW_DIR}/src/
printf "\n${YELLOW}[FETCH_SOURCES] Packaging for C standalone driver files${NC}\n"
make package
printf "\n${YELLOW}[FETCH_SOURCES] Copying C standalone driver sources into ${TARGET_SW_DIR}${NC}\n"
DRIVER_SOURCE_DIR=${HLS_DIR}/hw/${COMPONENT_NAME}/hls/impl/ip/drivers/krnl_${COMPONENT_NAME}_v1_0/src
# Driver headers
cp ${DRIVER_SOURCE_DIR}/xkrnl_conv_naive_hw.h \
    ${TARGET_SW_DIR}/inc/

# Source headers
cp ${HLS_DIR}/hw/src/utils.h \
    ${HLS_DIR}/hw/src/krnl_conv_naive.h \
    ${TARGET_SW_DIR}/inc/

# C sources
# Exclude Linux sources
# ${DRIVER_SOURCE_DIR}/krnl_${COMPONENT_NAME}_sinit.c
# cp ${DRIVER_SOURCE_DIR}/xkrnl_${COMPONENT_NAME}.c    \
#     ${TARGET_SW_DIR}/src/

# Host code
printf "\n${YELLOW}[FETCH_SOURCES] Copying host standalone sources into ${TARGET_SW_DIR}${NC}\n"
printf "\n${YELLOW}[FETCH_SOURCES] Skipping this durig development${NC}\n"
# cp ${HLS_DIR}/sw/src/host.c ${TARGET_SW_DIR}/src/

# Back to top
cd ${TOP_DIR}
unset TOP_DIR
