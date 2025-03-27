#!/bin/bash
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   Replace config-based content of output file (hw/make/config.mk) based on input MBUS and PBUS configurations.
#   Target values are parsed and from inputs and updated in output file.
# Args:
#   $1: System CSV config
#   $2: MBUS Source CSV config
#   $3: PBUS Source CSV config
#   $4: Target MK file

##############
# Parse args #
##############

EXPECTED_ARGC=4;
ARGC=$#;

# Check argc
if [ $ARGC -ne $EXPECTED_ARGC ]; then
    echo  "[CONFIG_XILINX][ERROR] Invalid number of arguments, please check the inputs and try again";
    return 1;
fi

# Read args
CONFIG_SYS_CSV=$1
CONFIG_MAIN_CSV=$2
CONFIG_PBUS_CSV=$3
OUTPUT_MK_FILE=$4

##########
# Script #
##########

# Arrays of target values to parse from input and update in output
sys_target_values=(
        CORE_SELECTOR
        VIO_RESETN_DEFAULT
        XLEN
    )

bus_target_values=(
        ID_WIDTH
        NUM_SI
        NUM_MI
        PBUS_NUM_MI
    )

# Loop over system targets
for target in ${sys_target_values[*]}; do
    # Search in the system_config.csv
    target_value=$(grep "${target}" ${CONFIG_SYS_CSV} | grep -v RANGE | awk -F "," '{print $2}');
    # Info print
    echo "[CONFIG_XILINX] Updating ${target} = ${target_value} "

    # Check for XLEN
    if [[ "$target" == "XLEN" ]]; then
        # Replace ADDR_WIDTH and DATA_WIDTH according to XLEN
        sed -E -i "s/ADDR_WIDTH.?\?=.+/ADDR_WIDTH \?= ${target_value}/g" ${OUTPUT_MK_FILE};
        sed -E -i "s/DATA_WIDTH.?\?=.+/DATA_WIDTH \?= ${target_value}/g" ${OUTPUT_MK_FILE};
    else 
        # Replace in target file
        sed -E -i "s/${target}.?\?=.+/${target} \?= ${target_value}/g" ${OUTPUT_MK_FILE};
    fi
    
done

# Loop over bus targets
for target in ${bus_target_values[*]}; do
    # Special case for PBUS
    # Assume a prexif
    if [[ "$target" == "PBUS_"* ]]; then
        # Discard prefix (first 5 chars)
        prefix_len=5
        grep_target=${target:$prefix_len}
        # Search for value
        target_value=$(grep "${grep_target}" ${CONFIG_PBUS_CSV} | awk -F "," '{print $2}');
    else
        # Search in main bus config
        target_value=$(grep "${target}" ${CONFIG_MAIN_CSV} | grep -v RANGE | awk -F "," '{print $2}');
    fi

    # Info print
    echo "[CONFIG_XILINX] Updating ${target} = ${target_value} "

    # Replace in target file
    sed -E -i "s/${target}.?\?=.+/${target} \?= ${target_value}/g" ${OUTPUT_MK_FILE};
done

#################
# BRAM RESIZING #
#################

# Assume each BRAM name starts with BRAM
bram_name=BRAM
bram_size_name=BRAM_DEPTHS
# Get all slave names
slaves=$(grep "RANGE_NAMES" ${CONFIG_MAIN_CSV} | awk -F "," '{print $2}');
# Get all slave range address widths
range_addr_widths=($(grep "RANGE_ADDR_WIDTH" ${CONFIG_MAIN_CSV} | awk -F "," '{print $2}'));

# For loop variables
let cnt=0
# prefix_len = strlen(bram_name)
prefix_len=${#bram_name}
bram_size_list=
# Find the index for each BRAM into the slave names and get the right range_addr_width
for slave in ${slaves[*]}; do
    # Assume each BRAM name starts with BRAM
    if [[ ${slave:0:$prefix_len} == $bram_name ]]; then
        range_width=${range_addr_widths[$cnt]}
        bram_size=$(( (1 << $range_width )/8 ))
        bram_size_list="$bram_size_list $bram_size"
    fi
    ((cnt++))
done

# Replace in target file
sed -E -i "s/${bram_size_name}.?\?=.+/${bram_size_name} \?= ${bram_size_list}/g" ${OUTPUT_MK_FILE};

# Done
echo "[CONFIG_XILINX] Output file is at ${OUTPUT_MK_FILE}"
