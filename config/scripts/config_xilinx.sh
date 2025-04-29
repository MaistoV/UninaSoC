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
#   $3: HBUS Source CSV config
#   $4: Target MK file

##############
# Parse args #
##############

EXPECTED_ARGC=5;
ARGC=$#;

# Check argc
if [ $ARGC -ne $EXPECTED_ARGC ]; then
    echo  "[CONFIG_XILINX][ERROR] Invalid number of arguments, please check the inputs and try again";
    exit 1;
fi

# Read args
CONFIG_SYS_CSV=$1
CONFIG_MAIN_CSV=$2
CONFIG_PBUS_CSV=$3
CONFIG_HBUS_CSV=$4
OUTPUT_MK_FILE=$5

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
        HBUS_NUM_MI
        HBUS_NUM_SI
    )

# Loop over system targets
for target in ${sys_target_values[*]}; do
    # Search in the system_config.csv
    target_value=$(grep "${target}" ${CONFIG_SYS_CSV} | grep -v RANGE | awk -F "," '{print $2}');
    # Info print
    echo "[CONFIG_XILINX] Updating ${target} = ${target_value} "

    # Replace in target file
    sed -E -i "s/${target}.?\?=.+/${target} \?= ${target_value}/g" ${OUTPUT_MK_FILE};

done

# Loop over bus targets
for target in ${bus_target_values[*]}; do

    # Prefixed targets for PBUS nad HBUS
    if [[ "$target" == "PBUS_"* || "$target" == "HBUS_"*  ]]; then
        # Discard prefix (first 5 chars)
        prefix_len=5
        grep_target=${target:$prefix_len}
        # Select source config file
        if [[ "$target" == "PBUS_"* ]]; then
            source_config=${CONFIG_PBUS_CSV}
        fi
        if [[ "$target" == "HBUS_"* ]]; then
            source_config=${CONFIG_HBUS_CSV}
        fi
        # Search for value
        target_value=$(grep "${grep_target}" ${source_config} | awk -F "," '{print $2}');
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

    # Increment counter
    ((cnt++))
done

# Replace in target file
sed -E -i "s/${bram_size_name}.?\?=.+/${bram_size_name} \?= ${bram_size_list}/g" ${OUTPUT_MK_FILE};

#################
# CLOCK DOMAINS #
#################

# Get the main clock domain
main_clock_domain=$(grep "MAIN_CLOCK_DOMAIN" ${CONFIG_MAIN_CSV} | awk -F "," '{print $2}');

# Get all clock domains
clock_domains=$(grep "RANGE_CLOCK_DOMAINS" ${CONFIG_MAIN_CSV} | awk -F "," '{print $2}');

# Get all slave names as list (not string)
slaves=($(grep "RANGE_NAMES" ${CONFIG_MAIN_CSV} | awk -F "," '{print $2}'));

# Clock domains different from the main domain (litterally new clock domains)
clock_domains_list=MAIN_CLOCK_DOMAIN

let cnt=0
# For each clock domain check if the clock domain is equal to the main clock domain
for clock_domain in ${clock_domains[*]}; do

    if [[ $clock_domain != $main_clock_domain ]]; then
        slave_clock_domain=${slaves[$cnt]}_HAS_CLOCK_DOMAIN
        clock_domains_list="$clock_domains_list $slave_clock_domain";
    fi

    # Save PBUS clock domain for UART sythesis
    if [[ "${slaves[$cnt]}" == "PBUS" ]]; then
        PBUS_CLOCK_FREQ_MHZ=$clock_domain
    fi

    # Increment counter
    ((cnt++))
done

# Replace in target MK file
sed -E -i "s/MAIN_CLOCK_FREQ_MHZ.?\?=.+/MAIN_CLOCK_FREQ_MHZ \?= ${main_clock_domain}/g" ${OUTPUT_MK_FILE};
sed -E -i "s/RANGE_CLOCK_DOMAINS.?\?=.+/RANGE_CLOCK_DOMAINS \?= ${clock_domains_list}/g" ${OUTPUT_MK_FILE};
# Replace in AXI Lite UART
# NOTE: this will trigger the rebuild of the IP
AXI_UARTLITE_CONFIG=${XILINX_IPS_ROOT}/embedded/xlnx_axi_uartlite/config.tcl
sed -E -i "s/CONFIG.C_S_AXI_ACLK_FREQ_HZ ?\{[[:digit:]]+\}/CONFIG.C_S_AXI_ACLK_FREQ_HZ {${PBUS_CLOCK_FREQ_MHZ}000000}/g" ${AXI_UARTLITE_CONFIG};

# Info print
echo "[CONFIG_XILINX] Updating MAIN_CLOCK_FREQ_MHZ = ${main_clock_domain} "
echo "[CONFIG_XILINX] Updating RANGE_CLOCK_DOMAINS = ${clock_domains_list} "
echo "[CONFIG_XILINX] Updating PBUS_CLOCK_FREQ_MHZ = ${PBUS_CLOCK_FREQ_MHZ} "

# Done
echo "[CONFIG_XILINX] Output file is at ${OUTPUT_MK_FILE}"
