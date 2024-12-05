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
    echo "[Warning] Can't find vsim in PATH!" >&2 ;
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
export HW_UNITS_ROOT=${ROOT_DIR}/hw/units

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

#############################
# SoC & Board Configuration # 
#############################
# Select the Device category (hpc or embedded). This instantiate the specific
# System-on-chip layout. In addition you can specify the board configuration
# Which uses the board-defined constraints and IPs (if any).
# Default is "embedded" "Nexys-A7-100T". If "hpc" is selected, "Alveo U250" is
# the default board configuration.

# hpc      -> { au250           , au280 (TBD)   , au50 (TBD)  }
# embedded -> { nexys_a7_100t   , nexys_a7_50t                }    

# PS: Environmental variable BOARD should match the .xdc constraint file name.

SOC_CONFIG=$1
BOARD_CONFIG=$2

if [[ ${SOC_CONFIG} == "hpc" ]]; then
    
    export SOC_CONFIG=hpc

    if [[ ${BOARD_CONFIG} == "au280" ]]; then
        # TBD
        echo "[Error] Board Configuration ${BOARD_CONFIG} unsupported!" >&2 ; 
    elif [[ ${BOARD_CONFIG} == "au50" ]]; then
        # TBD
        echo "[Error] Board Configuration ${BOARD_CONFIG} unsupported!" >&2 ; 
    else
        # Alveo  250
        export XILINX_PART_NUMBER=xcu250-figd2104-2L-e
        export XILINX_BOARD_PART=xilinx.com:au250:part0:1.3
        export XILINX_HW_DEVICE=xcu250
        export BOARD=au250
    fi

else

    export SOC_CONFIG=embedded

    if [[ ${BOARD_CONFIG} == "nexys_a7_50t" ]]; then
        # Nexys A7-50t
        export XILINX_PART_NUMBER=xc7a50ticsg324-1L
        export XILINX_BOARD_PART=digilentinc.com:nexys-a7-50t:part0:1.3
        export XILINX_HW_DEVICE=xc7a50t_0
        export BOARD=Nexys-A7-50T-Master 
    else 
        # Nexsys A7-100T
        export XILINX_PART_NUMBER=xc7a100tcsg324-1
        export XILINX_BOARD_PART=digilentinc.com:nexys-a7-100t:part0:1.3
        export XILINX_HW_DEVICE=xc7a100t_0
        export BOARD=Nexys-A7-100T-Master
    fi
fi

###############
# SoC Project #
###############

# Root directory
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



