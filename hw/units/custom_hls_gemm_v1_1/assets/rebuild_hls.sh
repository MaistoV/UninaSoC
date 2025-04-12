#!/bin/bash
# Description: Rebuild HLS source to Verilog

# Local variables
CLONE_DIR=matmul
COMP_NAME=${CLONE_DIR}

# Clean old sources
printf "\n${YELLOW}[REBUILD_HLS] Cleaning old RTL${NC}\n"
rm ${CLONE_DIR}/../rtl/*

# Move into HLS project
cd ${CLONE_DIR}/hw

# Synthesizing and copying verilog rtl files
printf "\n${YELLOW}[REBUILD_HLS] Starting c-synthesis for HLS sources${NC}\n"
make clean
make syn
printf "\n${YELLOW}[REBUILD_HLS] Copying all sources into rtl${NC}\n"
cp -r ${COMP_NAME}/hls/syn/verilog/* ${BUILD}

# Back to top
cd ${WORK_DIR}
