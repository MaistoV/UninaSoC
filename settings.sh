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

# Check if Questa/ModelSim is in path
if ! command -v vsim &> /dev/null; then
    echo "[Error] Can't find vsim in PATH!" >&2 ;
fi

#################
# Configuration #
#################
export CONFIG_ROOT=${ROOT_DIR}/config

############
# Hardware #
############
export HW_ROOT=${ROOT_DIR}/hw
export HW_RTL_ROOT=${ROOT_DIR}/hw/rtl
# TBD

###################
# Unit Simulation #
###################
export GXX=g++
export VERILATOR=verilator
export GTKWAVE=gtkwave
# Verilator paths - Insert here your include path
export VERILATOR_INC=/usr/share/verilator/include
export VLTSTD_INC=/usr/share/verilator/include/vltstd/

##########
# Xilinx #
##########
# Xilinx project name
export XILINX_PROJECT_NAME=uninasoc
# Target device
# Nexsys A7
export XILINX_PART_NUMBER=xc7a100tcsg324-1
export XILINX_BOARD=Nexys-A7-100T-Master
export XILINX_HW_DEVICE=xc7a100t_0
# Nexsys Alveo XXX
# export XILINX_PART_NUMBER=TBD
# export XILINX_BOARD=TBD
# export XILINX_HW_DEVICE=TBD
# Root directoriy
export XILINX_ROOT=${ROOT_DIR}/hw/xilinx
export XILINX_IPS_ROOT=${XILINX_ROOT}/ips
# Synthesis
export XILINX_SYNTH_ROOT=${XILINX_ROOT}/synth
export XILINX_SYNTH_TCL_ROOT=${XILINX_SYNTH_ROOT}/tcl
export XILINX_SYNTH_XDC_ROOT=${XILINX_SYNTH_ROOT}/constraints
# Hardware Server Host
export XILINX_HW_SERVER_HOST=127.0.0.1
export XILINX_HW_SERVER_PORT=3121
# NOTE: this is device-specific
# export XILINX_HW_SERVER_FPGA_PATH=xilinx_tcf/Digilent/210292B17F3DA
# Use wildcard instead
export XILINX_HW_SERVER_FPGA_PATH=xilinx_tcf/Digilent/*

# Simulation
export XILINX_SIM_ROOT=${XILINX_ROOT}/sim
export XILINX_SIM_TCL_ROOT=${XILINX_SIM_ROOT}/tcl
export XILINX_SIM_IP_ROOT=${XILINX_SIM_ROOT}/ips

export XILINX_SIMLIB_PATH=${XILINX_SIM_ROOT}/simlib
export GCC_PATH=$(dirname $(which gcc))
export QUESTA_PATH=$(dirname $(which vsim))


############
# Software #
############
# Add GCC and Spike to path
export SW_ROOT=${ROOT_DIR}/sw
export BOOTROM_COE=${SW_ROOT}/bootrom.coe



