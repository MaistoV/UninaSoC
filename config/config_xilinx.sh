#!/bin/bash
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Replace config-based content of hw/make/config.mk
# Args:
#   $1: MBUS Source CSV config
#   $2: PBUS Target MK file
#   $3: Target MK file

##############
# Parse args #
##############

EXPECTED_ARGC=3;
ARGC=$#;

# Check argc
if [ $ARGC -ne $EXPECTED_ARGC ]; then
    echo  "[CONFIG_XILINX][ERROR] Invalid number of arguments, please check the inputs and try again";
    return 1;
fi

# Read args
CONFIG_MAIN_CSV=$1
CONFIG_PBUS_CSV=$2
OUTPUT_MK_FILE=$3

##########
# Script #
##########

# Array of target values
target_values=(
        CORE_SELECTOR
        ADDR_WIDTH
        DATA_WIDTH
        ID_WIDTH
        NUM_SI
        NUM_MI
        PBUS_NUM_MI
    )

# Loop over targets
for target in ${target_values[*]}; do

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
prefix_len=4
bram_sizes=
# Find the index for each BRAM into the slave names and get the right range_addr_width
for slave in ${slaves[*]}; do
    # Assume each BRAM name starts with BRAM
    if [[ ${slave:0:$prefix_len} == $bram_name ]]; then
        range_width=${range_addr_widths[$cnt]}
        bram_size=$(( (1 << $range_width )/8 ))
        bram_sizes="$bram_sizes $bram_size"
    fi
    ((cnt++))
done

# Replace in target file
sed -E -i "s/${bram_size_name}.?\?=.+/${bram_size_name} \?= ${bram_sizes}/g" ${OUTPUT_MK_FILE};

# Done
echo "[CONFIG_XILINX] Output file is at ${OUTPUT_MK_FILE}"
