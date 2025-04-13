#!/bin/bash
# Description: Rebuild HLS source to Verilog

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
CLONE_DIR=$(realpath ../matmul)
COMPONENT_NAME=$(basename ${CLONE_DIR})

# Clean old sources
printf "\n${YELLOW}[REBUILD_HLS] Cleaning old RTL${NC}\n"
RTL_DIR=$(realpath ../rtl)
rm ${RTL_DIR}*
mkdir -p ${RTL_DIR}

# Move into HLS project
cd ${CLONE_DIR}/hw

# Synthesizing and copying verilog rtl files
printf "\n${YELLOW}[REBUILD_HLS] Starting c-synthesis for HLS sources${NC}\n"
make clean
make syn
printf "\n${YELLOW}[REBUILD_HLS] Copying all sources into rtl${NC}\n"
cp ${CLONE_DIR}/hw/${COMPONENT_NAME}/hls/syn/verilog/* ${RTL_DIR}/

# Back to top
cd ${TOP_DIR}
unset TOP_DIR
