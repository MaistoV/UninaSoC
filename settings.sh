#!/bin/bash

#################
# Initial setup #
#################
# Root directory of current project, same path as this script
export ROOT_DIR=$( dirname $( realpath $BASH_SOURCE[0]} ) )

# Check if Vivado is in path
if ! command -v vivado &> /dev/null; then 
    echo "[Error] Can't find Vivado in PATH!" >&2 ; 
fi

############
# Hardware #
############
export HW_ROOT=${ROOT_DIR}/hw
export HW_RTL_ROOT=${ROOT_DIR}/hw/rtl
# TBD

##############
# Simulation #
##############
export SIM_ROOT=${ROOT_DIR}/hw/sim
# TBD

##########
# Xilinx #
##########
export XILINX_ROOT=${ROOT_DIR}/hw/xilinx
export XILINX_IPS_ROOT=${ROOT_DIR}/hw/xilinx/ips
export XILINX_TCL_ROOT=${ROOT_DIR}/hw/xilinx/ips
export XILINX_PART_NUMBER= 
export XILINX_BOARD= 
export XILINX_PROJECT_NAME=uninasoc

############
# Software #
############
export SW_ROOT=${ROOT_DIR}/sw
export BOOTROM_COE=${SW_ROOT}/bootrom.coe



