#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   Replace config-based content of output file (sw/SoC/common/config.mk) based on XLEN values (system_config.csv)
#   Target values are parsed and from inputs and updated in output file.
#   Currently we only support 32 and 64 unknown toolchain.
#   In the future, we might support a more flexible toolchain selection flow (e.g. rv64-linux) and flags

# Args:
#   $1: System CSV config
#   $2: Target MK file (currently unmodified, left for forward compatibility)

##############
# Parse args #
##############

EXPECTED_ARGC=2;
ARGC=$#;

# Check argc
if [ $ARGC -ne $EXPECTED_ARGC ]; then
    echo  "[CONFIG_SW][ERROR] Invalid number of arguments, please check the inputs and try again";
    return 1;
fi

# Read args
CONFIG_SYS_CSV=$1
OUTPUT_MK_FILE=$2

##########
# Script #
##########

xlen_value=$(grep "XLEN" ${CONFIG_SYS_CSV} | grep -v RANGE | awk -F "," '{print $2}');

if [[ "$xlen_value" == "32" || "$xlen_value" == "64" ]]; then

    export XLEN=$xlen_value

    echo "[CONFIG_SW] Setting XLEN to ${XLEN} "

    # riscv32-unknown-elf toolchain
    #rv_prefix="riscv32-unknown-elf-"
    #dflag="-g"
    #cflags="-march=rv32imac_zicsr_zifencei -mabi=ilp32 -O0 \$(DFLAG) -c"
    #ldflags="\$(LIB_OBJ_LIST) -nostdlib -T\$(LD_SCRIPT)"
#
    #echo "[CONFIG_SW] Setting toolchain to ${rv_prefix} "
    #echo "[CONFIG_SW] DFLAG = ${dflag} "
    #echo "[CONFIG_SW] CLFAGS = ${cflags} "
    #echo "[CONFIG_SW] LDFLAGS = ${ldflags} "
#
    #sed -E -i "s/RV_PREFIX.?\?=.+/RV_PREFIX \?= ${rv_prefix}/g" ${OUTPUT_MK_FILE};
    #sed -E -i "s/DFLAG.?\?=.+/DFLAG \?= ${dflag}/g" ${OUTPUT_MK_FILE};
    #sed -E -i "s/CFLAGS.?\?=.+/CFLAGS \?= ${cflags}/g" ${OUTPUT_MK_FILE};
    #sed -E -i "s/LDFLAGS.?\?=.+/LDFLAGS \?= ${ldflags}/g" ${OUTPUT_MK_FILE};
    
else
    echo  "[CONFIG_SW][ERROR] Invalid XLEN=$xlen_value value; no toolchain is supported for this XLEN value";
    return 1;
fi

echo "[CONFIG_SW] Output file is at ${OUTPUT_MK_FILE}"
