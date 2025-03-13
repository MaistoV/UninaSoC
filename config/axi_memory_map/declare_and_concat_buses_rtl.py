#!/bin/python3.10
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: utility functions to write RTL file for BUS declaration and concatenation

####################
# Import libraries #
####################
# Parse args
import sys
# Get env vars
import os
# Sub-scripts
import configuration
from read_config import read_config

# Constants

# File comments
FILE_HEADER = \
f"// This file is auto-generated with {os.path.basename(__file__)}\n\n\
/////////////////////////////////////////\n\
// Buses declaration and concatenation //\n\
/////////////////////////////////////////\n"

FILE_MASTER_BUSES_HEADER = \
"\n/////////////////\n\
// AXI Masters //\n\
/////////////////\n"


FILE_SLAVE_BUSES_HEADER = \
"\n/////////////////\n\
// AXI Slaves  //\n\
/////////////////\n"

FILE_MASTER_CONCAT_HEADER = \
"\n//////////////////////////////////\n\
// Concatenate AXI master buses //\n\
//////////////////////////////////\n"

FILE_SLAVE_CONCAT_HEADER = \
"\n/////////////////////////////////\n\
// Concatenate AXI slave buses //\n\
/////////////////////////////////\n"



# Template strings
DECLARE_BUS_PREFIX                 = "`DECLARE_AXI_BUS("
DECLARE_BUS_SUFFIX                 = ", AXI_DATA_WIDTH)\n"

DECLARE_AXILITE_BUS_PREFIX         = "`DECLARE_AXILITE_BUS("

DECLARE_BUS_ARRAY_PREFIX           = "`DECLARE_AXI_BUS_ARRAY("

DECLARE_AXILITE_BUS_ARRAY_PREFIX   = "`DECLARE_AXILITE_BUS_ARRAY("

CONCAT_SLAVE_BUS_PREFIX            = "`CONCAT_AXI_SLAVES_ARRAY"
CONCAT_MASTER_BUS_PREFIX           = "`CONCAT_AXI_MASTERS_ARRAY"

CONCAT_AXILITE_SLAVE_BUS_PREFIX    = "`CONCAT_AXILITE_SLAVES_ARRAY"
CONCAT_AXILITE_MASTER_BUS_PREFIX   = "`CONCAT_AXILITE_MASTERS_ARRAY"

BASE_SUFFIX                        = ")\n"

# RTL files to edit
RTL_FILES                = {
    "MBUS" : f"{os.environ.get('XILINX_ROOT')}/rtl/mbus_buses.svinc",
    "PBUS" : f"{os.environ.get('XILINX_ROOT')}/rtl/pbus_buses.svinc"
}

# Write the concatenation macro for master/slave buses to the rtl file
def concat_buses(lines : list, buses : list, is_master : bool, config : configuration.Configuration) -> None:
    pbus_cnt_str       = str()
    bus_cnt_str        = str()
    buses_string       = str()
    suffix             = str()
    concat_prefix      = str()
    pbus_concat_prefix = str()

    if is_master:
        pbus_cnt_str       = "1"
        bus_cnt_str        = "NUM_SI"
        suffix             = "_masters"
        concat_prefix      = CONCAT_MASTER_BUS_PREFIX
        pbus_concat_prefix = CONCAT_AXILITE_MASTER_BUS_PREFIX
    else:
        pbus_cnt_str       = "PBUS_NUM_MI"
        bus_cnt_str        = "NUM_MI"
        suffix             = "_slaves"
        concat_prefix      = CONCAT_SLAVE_BUS_PREFIX
        pbus_concat_prefix = CONCAT_AXILITE_SLAVE_BUS_PREFIX

    for bus in buses:
        buses_string = f", {bus}{buses_string}"

    if config.BUS_NAME == "PBUS":
        lines.append(f"{DECLARE_AXILITE_BUS_ARRAY_PREFIX}{config.BUS_NAME}{suffix}, {pbus_cnt_str}{BASE_SUFFIX}")
        lines.append(f"{pbus_concat_prefix}{len(buses)}({config.BUS_NAME}{suffix}{buses_string}{BASE_SUFFIX}")
    else:
        lines.append(f"{DECLARE_BUS_ARRAY_PREFIX}{config.BUS_NAME}{suffix}, {bus_cnt_str}{BASE_SUFFIX}")
        lines.append(f"{concat_prefix}{len(buses)}({config.BUS_NAME}{suffix}{buses_string}{BASE_SUFFIX}")



# Write the declaration macro for the master/slave buses in the rtl file
def declare_buses(lines : list, is_master : bool, config : configuration.Configuration) -> list:
    buses = list()
    buses_cnt = 0

    if is_master:
        buses_cnt = config.NUM_SI
    else:
        buses_cnt = config.NUM_MI

    for i in range(buses_cnt):
        if is_master:
            buses.append(f"{config.MASTER_NAMES[i]}_to_{config.BUS_NAME}")
        else:
            buses.append(f"{config.BUS_NAME}_to_{config.RANGE_NAMES[i]}")

        if config.BUS_NAME == "PBUS":
            lines.append(f"{DECLARE_AXILITE_BUS_PREFIX}{buses[-1]}{BASE_SUFFIX}")
        else:
            lines.append(f"{DECLARE_BUS_PREFIX}{buses[-1]}{DECLARE_BUS_SUFFIX}")
    return buses


# Declare and concatenate the buses
def declare_and_concat_buses(file, config : configuration.Configuration) -> None:
    lines        = list()
    slave_buses  = list()
    master_buses = list()

    lines.append(FILE_HEADER)

    lines.append(FILE_MASTER_BUSES_HEADER)
    master_buses = declare_buses(lines, is_master=True, config=config)

    lines.append(FILE_SLAVE_BUSES_HEADER)
    slave_buses  = declare_buses(lines, is_master=False, config=config)

    lines.append(FILE_MASTER_CONCAT_HEADER)
    concat_buses(lines, master_buses, is_master=True, config=config)

    lines.append(FILE_SLAVE_CONCAT_HEADER)
    concat_buses(lines, slave_buses, is_master=False, config=config)

    file.seek(0)
    file.writelines(lines)

########
# MAIN #
########
if __name__ == "__main__":
    config_file_names = sys.argv[1:]
    configs = read_config(config_file_names)

    for config in configs:
        file = open(RTL_FILES[config.BUS_NAME], "w")
        declare_and_concat_buses(file, config)
        file.close()