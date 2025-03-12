#!/bin/bash
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description:
#   Replace config-based content of output file (hw/make/config.mk) based on input MBUS and PBUS configurations.
#   Target values are parsed and from inputs and updated in output file.
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

# Array of target values to parse from input and update in output
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
	    target_value=$(grep "${target}" ${CONFIG_MAIN_CSV=$1} | grep -v RANGE | awk -F "," '{print $2}');
    fi

    # Info print
    echo "[CONFIG_XILINX] Updating ${target} = ${target_value} "

    # Replace in target file
	sed -E -i "s/${target}.?\?=.+/${target} \?= ${target_value}/g" ${OUTPUT_MK_FILE};
done

# Done
echo "[CONFIG_XILINX] Output file is at ${OUTPUT_MK_FILE}"
