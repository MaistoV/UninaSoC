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
    "HBUS"       : f"{os.environ.get('XILINX_ROOT')}/rtl/hbus_clk_assignments.svinc",
}

# TODO: update CONFIG DOCUMENTATION - say that the only possible frequency for the HBUS for now are 300 (from the DDR CH2 internal to the HBUS)
#                                     and 322 (from the CMAC external to the HBUS)

# HBUS internal clock frequencies
HBUS_INTERN_CLK_FREQUENCIES = {
    "ddr"  : 300,
    # "hbm"  : 450
}

# HBUS external clock frequencies
HBUS_EXTERN_CLK_FREQUENCIES = {
    "cmac" : 322,
}

# Clock owners (HBUS, DDR etc.)
CLK_OWNERS = [
    "HBUS",
    "DDR"
]

# TODO 127: Maybe refactor (?)
# Clocks declarations and assignments
def declare_and_assign_clocks(config : configuration.Configuration) -> None:
    # Declare and assign clocks
    if config.CONFIG_NAME == "MBUS":
        file = open(RTL_FILES["UNINASOC"], "w")

    elif config.CONFIG_NAME == "HBUS":
        file = open(RTL_FILES["HBUS"], "w")

    file.write(FILE_HEADER)

    # Uninasoc
    if config.CONFIG_NAME == "MBUS":

        # Get the HBUS clock domain (MHz)
        hbus_clk_freq = 300
        for i in range(len(config.RANGE_CLOCK_DOMAINS)):
            if config.RANGE_NAMES[i] == "HBUS":
                hbus_clk_freq = config.RANGE_CLOCK_DOMAINS[i]
                break

        file.write(f"assign main_clk = clk_{config.MAIN_CLOCK_DOMAIN}MHz;\n")
        file.write(f"assign main_rstn = rstn_{config.MAIN_CLOCK_DOMAIN}MHz;\n")
        # file.write(f"logic clk_300MHz;\n")
        # file.write(f"logic rstn_300MHz;\n")

        for i in range(len(config.RANGE_CLOCK_DOMAINS)):
            # Exclude the DDR and the HBUS from this since they have its own clock (they are clock owners )
            if config.RANGE_NAMES[i] not in CLK_OWNERS:
                file.write(f"logic {config.RANGE_NAMES[i]}_clk;\n")
                file.write(f"assign {config.RANGE_NAMES[i]}_clk = clk_{config.RANGE_CLOCK_DOMAINS[i]}MHz;\n")
                file.write(f"logic {config.RANGE_NAMES[i]}_rstn;\n")
                file.write(f"assign {config.RANGE_NAMES[i]}_rstn = rstn_{config.RANGE_CLOCK_DOMAINS[i]}MHz;\n")
            elif config.RANGE_NAMES[i] == "HBUS":

                # Find what is the external clock
                for freq in HBUS_EXTERN_CLK_FREQUENCIES:
                    if HBUS_EXTERN_CLK_FREQUENCIES[freq] == hbus_clk_freq:
                        file.write(f"assign HBUS_extern_clk  = clk_{HBUS_EXTERN_CLK_FREQUENCIES[freq]}MHz;\n")
                        file.write(f"assign HBUS_extern_rstn = rstn_{HBUS_EXTERN_CLK_FREQUENCIES[freq]}MHz;\n")

    # HBUS
    elif config.CONFIG_NAME == "HBUS":

        # This is the only point where we need to read this from the config
        hbus_clk_freq = config.HBUS_CLOCK_DOMAIN

        # If the clock frequency is an HBUS-internal clock then find from what component it comes
        if hbus_clk_freq in HBUS_INTERN_CLK_FREQUENCIES.values():
            for freq in HBUS_INTERN_CLK_FREQUENCIES:
                if HBUS_INTERN_CLK_FREQUENCIES[freq] == hbus_clk_freq:
                    file.write(f"assign HBUS_clk = {freq}_clk;\n")
                    file.write(f"assign HBUS_rstn = ~{freq}_rst;\n") # TODO: this work only in the DDR case, each peripheral has a different reset type...

        # If the clock frequency is NOT an HBUS-internal clock then take the clock from the extern (CMAC or other extern peripherals/accelerators)
        else:
            file.write(f"assign HBUS_clk = extern_clock_i;\n")
            file.write(f"assign HBUS_rstn = extern_reset_ni;\n")

    file.close()


########
# MAIN #
########
if __name__ == "__main__":
    config_file_names = sys.argv[1:]
    configs = read_config(config_file_names)
    for config in configs:
        if config.CONFIG_NAME == "MBUS" or config.CONFIG_NAME == "HBUS":
            declare_and_assign_clocks(config)