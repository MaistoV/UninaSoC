#!/bin/bash
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Replace config-based content of hw/make/config.mk
# Args:
#   $1: Source CSV config
#   $2: Target MK file

##############
# Parse args #
##############

EXPECTED_ARGC=3;
ARGC=$#;

# Check argc
if [ $ARGC -ne $EXPECTED_ARGC ]; then
    echo  "Invalid number of arguments, please check the inputs and try again";

    return 1;
fi

# Read args
CONFIG_CSV=$1
OUTPUT_MK_FILE=$2

##########
# Script #
##########

# Array of target values
target_values=(
        CORE_SELECTOR
        ADDR_WIDTH
        DATA_WIDTH
        ID_WIDTH
    )

# Loop over targets
for target in ${target_values[*]}; do
    echo "[CONFIG] Updating ${target}"
	target_value=$(grep "${target}" ${CONFIG_CSV} | grep -v RANGE | awk -F "," '{print $2}');
	sed -E -i "s/${target}.?\?=.+/${target} \?= ${target_value}/g" ${OUTPUT_MK_FILE};
done

# Done
echo "[CONFIG] Output file is at ${OUTPUT_MK_FILE}"
