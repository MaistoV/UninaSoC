#!/bin/python3.10
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: utility functions to write RTL file for CLOCKS declaration and assignments

####################
# Import libraries #
####################
# Parse args
import sys
# Get env vars
import os
# Sub-scripts
import configuration
from utils import *

# Constants

# File comments
FILE_HEADER = \
f"// This file is auto-generated with {os.path.basename(__file__)}\n\n\
/////////////////////////////////////////\n\
// Clocks declaration and assignments  //\n\
/////////////////////////////////////////\n"

# RTL files to edit
RTL_FILES                = {
    "UNINASOC"   : f"{os.environ.get('XILINX_ROOT')}/rtl/uninasoc_clk_assignments.svinc",
}

# Clocks declarations and assignments
def declare_and_assign_clocks(config : configuration.Configuration) -> None:
    # Declare and assign clocks in uninasoc
    file = open(RTL_FILES["UNINASOC"], "w")
    file.write(FILE_HEADER)
    file.write(f"assign main_clk = clk_{config.MAIN_CLOCK_DOMAIN}MHz;\n")
    file.write(f"assign main_rstn = rstn_{config.MAIN_CLOCK_DOMAIN}MHz;\n")
    for i in range(len(config.RANGE_CLOCK_DOMAINS)):
        # Exclude the DDR from this since it has its own clock
        if config.RANGE_NAMES[i] != "DDR":
            file.write(f"logic {config.RANGE_NAMES[i]}_clk;\n")
            file.write(f"assign {config.RANGE_NAMES[i]}_clk = clk_{config.RANGE_CLOCK_DOMAINS[i]}MHz;\n")
            file.write(f"logic {config.RANGE_NAMES[i]}_rstn;\n")
            file.write(f"assign {config.RANGE_NAMES[i]}_rstn = rstn_{config.RANGE_CLOCK_DOMAINS[i]}MHz;\n")

    file.close()


########
# MAIN #
########
if __name__ == "__main__":
    config_file_names = sys.argv[1:]
    configs = read_configs(config_file_names)
    for config in configs:
        if config.CONFIG_NAME == "MBUS":
            declare_and_assign_clocks(config)