#!/bin/bash
# Author: Vincenzo Merola <vincenzo.merola2@unina.it>

# Description:
# This script downloads Vitis HLS GEMM sources and flattens them into a build/ directory.

# To execute: ./fetch_sources.sh
# To execute you need:
#   git
#   Vitis 2024.2

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GIT_URL=https://github.com/Vincenzo0709/matmul.git
GIT_TAG=main
CLONE_DIR=matmul
COMP_NAME=${CLONE_DIR}

# Display help
Help()
{
   echo
   echo "This script downloads from Git or directly builds Vitis HLS vdotprod accelerator sources"
   echo "and flattens rtl files, Vivado ip directory and ip .zip into a build/ directory."
   echo
   echo "Syntax: fetch_source.sh [--option]"
   echo
   echo "options:"
   echo "-h | --help            Prints help"
   echo
}

GitFlatten()
{

    printf "\n${GREEN}[FETCH_SOURCES] Fetching with git${NC}\n"

    # Creating build/ dir
    rm -rf build/
    mkdir -p build/rtl build/ip
    BUILD="`pwd -P`/build"

    # Cloning repo
    printf "\n${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
    git clone ${GIT_URL} -b ${GIT_TAG} ${CLONE_DIR}

    # Clone Bender (future development)
    # printf "\n${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
    # curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

    cd ${CLONE_DIR}/hw
    # Synthesizing and copying verilog rtl files
    printf "\n${YELLOW}[FETCH_SOURCES] Starting synthesis${NC}\n"
    make syn
    cp -r ${COMP_NAME}/hls/syn/verilog/* ${BUILD}/rtl

    # Packaging and copying Vivado ip files and ip .zip
    printf "\n${YELLOW}[FETCH_SOURCES] Starting packaging${NC}\n"
    make package
    cp ${COMP_NAME}_hls.zip ${BUILD}/
    cp -r ${COMP_NAME}/hls/impl/ip/* ${BUILD}/ip
    
    cd ${WORK_DIR}
    # Deleting the cloned repo
    printf "\n${YELLOW}[FETCH_SOURCES] Cleaning all artifacts${NC}\n"
    sudo rm -r ${CLONE_DIR}
    printf "\n${GREEN}[FETCH_SOURCES] Completed${NC}\n"

}

Flatten() {
    
    printf "\n${GREEN}[FETCH_SOURCES] Fetching without git${NC}\n"

    # Creating build/ dir
    cd hw
    rm -rf build/
    mkdir -p build/rtl build/ip
    BUILD="`pwd -P`/build"

    # Clone Bender (future development)
    # printf "\n${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
    # curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

    # Copy all RTL files into rtl dir
    printf "\n${YELLOW}[FETCH_SOURCES] Copying all sources into rtl${NC}\n"

    # Synthesizing and copying verilog rtl files
    make syn
    cp -r ${COMP_NAME}/hls/syn/verilog/* ${BUILD}/rtl

    # Packaging and copying Vivado ip files and ip .zip
    make package
    mv ${COMP_NAME}_hls.zip ${BUILD}
    cp -r ${COMP_NAME}/hls/impl/ip/* ${BUILD}/ip

    cd ${WORK_DIR}
    printf "\n${GREEN}[FETCH_SOURCES] Completed${NC}\n"

}

OPTS=$(getopt -o h --long help -n 'fetch_sources.sh' -- "$@")
eval set -- "$OPTS"

if [ "$OPTS" != " --" ]; then
    while true; do
        case "$1" in
            -h | --help) 
                # Print help
                Help
                exit 0
                ;;
            --)
                # Terminating symbol
                shift
                break
                ;;
            ?)
                # Unrecognized options
                echo "Invalid option: -${OPTARG}."
                exit 1
                ;;
        esac
    done
fi


# Moving to right directory (if you cloned the whole repository instead of using only fetch_sources.sh)
cd "$(dirname "$0")" ; printf "\n${GREEN}[FETCH_SOURCES] Starting from directory `pwd -P`${NC}\n"
WORK_DIR=`pwd -P`
if [ "$(basename `pwd -P`)" == "scripts" ]; then
    cd .. ; printf "\n${GREEN}[FETCH_SOURCES] Moving to directory `pwd -P`${NC}\n"
    WORK_DIR=`pwd -P`
    Flatten
else
    GitFlatten
fi