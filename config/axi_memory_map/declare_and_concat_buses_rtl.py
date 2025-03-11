# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: utility functions to write RTL file for BUS declaration and concatenation

####################
# Import libraries #
####################
# Parse args
import sys
# Get env vars
import os
# Manipulate CSV
import pandas as pd
# Sub-scripts
import parse_properties_wrapper
import configuration


# Constants

# Header and trailing strings, used to identify sections in the rtl file where to put the declarations
DECLARE_MASTERS_HEADER             = "// AXI Masters //"
DECLARE_SLAVES_HEADER              = "// AXI Slaves  //"
CONCAT_MASTERS_HEADER              = "// Concatenate AXI master buses //"
CONCAT_SLAVES_HEADER               = "// Concatenate AXI slave buses //"

DECLARE_MASTERS_TRAILING           = "// END AXI Masters //"
DECLARE_SLAVES_TRAILING            = "// END AXI Slaves  //"
CONCAT_MASTERS_TRAILING            = "// END Concatenate AXI master buses //"
CONCAT_SLAVES_TRAILING             = "// END Concatenate AXI slave buses //"

# Template strings
DECLARE_BUS_PREFIX                 = "\t`DECLARE_AXI_BUS("
DECLARE_BUS_SUFFIX                 = ", AXI_DATA_WIDTH);\n"

DECLARE_AXILITE_BUS_PREFIX         = "\t`DECLARE_AXILITE_BUS("
DECLARE_AXILITE_BUS_SUFFIX         = ");\n"

DECLARE_BUS_ARRAY_PREFIX           = "\t`DECLARE_AXI_BUS_ARRAY("
DECLARE_BUS_ARRAY_SUFFIX           = ");\n"

DECLARE_AXILITE_BUS_ARRAY_PREFIX   = "\t`DECLARE_AXILITE_BUS_ARRAY("
DECLARE_AXILITE_BUS_ARRAY_SUFFIX   = ");\n"

CONCAT_SLAVE_BUS_PREFIX            = "\t`CONCAT_AXI_SLAVES_ARRAY"
CONCAT_MASTER_BUS_PREFIX           = "\t`CONCAT_AXI_MASTERS_ARRAY"

CONCAT_AXILITE_SLAVE_BUS_PREFIX    = "\t`CONCAT_AXILITE_SLAVES_ARRAY"
CONCAT_AXILITE_MASTER_BUS_PREFIX   = "\t`CONCAT_AXILITE_MASTERS_ARRAY"

CONCAT_BUS_SUFFIX                  = ");\n"

# RTL files to edit
RTL_FILES                = {
    "MBUS" : f"{os.environ.get('XILINX_ROOT')}/rtl/uninasoc.sv",
    "PBUS" : f"{os.environ.get('XILINX_ROOT')}/rtl/peripheral_bus.sv"
}

# Name of buses
BUS_NAMES                = {
    "config_main_bus.csv"       : "MBUS",
    "config_peripheral_bus.csv" : "PBUS"
}

# Write the concatenation macro for master buses to the rtl file
def concat_master_buses(lines : list, master_buses : list, config : configuration.Configuration) -> None:
    master_buses_string = str()
    for master_bus in master_buses:
        master_buses_string = f", {master_bus}{master_buses_string}"

    if config.BUS_NAME == "PBUS":
        lines.append(f"{DECLARE_AXILITE_BUS_ARRAY_PREFIX}{config.BUS_NAME}_masters, PBUS_NUM_SI{DECLARE_AXILITE_BUS_ARRAY_SUFFIX}")
        lines.append(f"{CONCAT_AXILITE_MASTER_BUS_PREFIX}{len(master_buses)}({config.BUS_NAME}_masters{master_buses_string}{CONCAT_BUS_SUFFIX}")
    else:
        lines.append(f"{DECLARE_BUS_ARRAY_PREFIX}{config.BUS_NAME}_masters, NUM_SI{DECLARE_BUS_ARRAY_SUFFIX}")
        lines.append(f"{CONCAT_MASTER_BUS_PREFIX}{len(master_buses)}({config.BUS_NAME}_masters{master_buses_string}{CONCAT_BUS_SUFFIX}")

# Write the concatenation macro for slave buses to the rtl file
def concat_slave_buses(lines : list, slave_buses : list, config : configuration.Configuration) -> None:
    slave_buses_string = str()
    for slave_bus in slave_buses:
        slave_buses_string = f", {slave_bus}{slave_buses_string}"

    if config.BUS_NAME == "PBUS":
        lines.append(f"{DECLARE_AXILITE_BUS_ARRAY_PREFIX}{config.BUS_NAME}_slaves, PBUS_NUM_MI{DECLARE_AXILITE_BUS_ARRAY_SUFFIX}")
        lines.append(f"{CONCAT_AXILITE_SLAVE_BUS_PREFIX}{len(slave_buses)}({config.BUS_NAME}_slaves{slave_buses_string}{CONCAT_BUS_SUFFIX}")
    else:
        lines.append(f"{DECLARE_BUS_ARRAY_PREFIX}{config.BUS_NAME}_slaves, NUM_MI{DECLARE_BUS_ARRAY_SUFFIX}")
        lines.append(f"{CONCAT_SLAVE_BUS_PREFIX}{len(slave_buses)}({config.BUS_NAME}_slaves{slave_buses_string}{CONCAT_BUS_SUFFIX}")



# Write the declaration macro for the master buses in the rtl file
def declare_master_buses(lines : list, config : configuration.Configuration) -> list:
    master_buses = list()
    for i in range(config.NUM_SI):
        master_buses.append(f"{config.MASTER_NAMES[i]}_to_{config.BUS_NAME}")
        if config.BUS_NAME == "PBUS":
            lines.append(f"{DECLARE_AXILITE_BUS_PREFIX}{master_buses[-1]}{DECLARE_AXILITE_BUS_SUFFIX}")
        else:
            lines.append(f"{DECLARE_BUS_PREFIX}{master_buses[-1]}{DECLARE_BUS_SUFFIX}")
    return master_buses

# Write the declaration macro for the slave buses in the rtl file
def declare_slave_buses(lines : list, config : configuration.Configuration) -> list:
    slave_buses = list()
    for i in range(config.NUM_MI):
        slave_buses.append(f"{config.BUS_NAME}_to_{config.RANGE_NAMES[i]}")
        if config.BUS_NAME == "PBUS":
            lines.append(f"{DECLARE_AXILITE_BUS_PREFIX}{slave_buses[-1]}{DECLARE_AXILITE_BUS_SUFFIX}")
        else:
            lines.append(f"{DECLARE_BUS_PREFIX}{slave_buses[-1]}{DECLARE_BUS_SUFFIX}")
    return slave_buses

# Go through the rtl file and when a section (bus declaration or bus concatenation) is encountered call the right function
def declare_and_concat_buses(file, config : configuration.Configuration) -> None:

    new_lines = list()
    slave_buses = list()
    master_buses = list()

    i = 0
    lines = file.readlines()
    while i < len(lines):
        # Need master buses declarations
        if DECLARE_MASTERS_HEADER in lines[i]:
            new_lines.append(lines[i])
            new_lines.append(lines[i+1])
            new_lines.append(lines[i+2])

            master_buses = declare_master_buses(new_lines, config)
            i += 3

            while DECLARE_MASTERS_TRAILING not in lines[i]:
                i += 1
            new_lines.append(lines[i])
            i += 1

        # Need slave buses declarations
        elif DECLARE_SLAVES_HEADER in lines[i]:
            new_lines.append(lines[i])
            new_lines.append(lines[i+1])
            new_lines.append(lines[i+2])

            slave_buses = declare_slave_buses(new_lines, config)
            i += 3

            while DECLARE_SLAVES_TRAILING not in lines[i]:
                i += 1
            new_lines.append(lines[i])
            i += 1

        # Need master buses contatenation
        elif CONCAT_MASTERS_HEADER in lines[i]:
            new_lines.append(lines[i])
            new_lines.append(lines[i+1])
            concat_master_buses(new_lines, master_buses, config)
            i += 2

            while CONCAT_MASTERS_TRAILING not in lines[i]:
                i += 1
            new_lines.append(lines[i])
            i += 1

        # Need slave buses concatenation
        elif CONCAT_SLAVES_HEADER in lines[i]:
            new_lines.append(lines[i])
            new_lines.append(lines[i+1])
            concat_slave_buses(new_lines, slave_buses, config)
            i += 2

            while CONCAT_SLAVES_TRAILING not in lines[i]:
                i += 1
            new_lines.append(lines[i])
            i += 1

        else:
            new_lines.append(lines[i])
            i += 1
    file.seek(0)
    file.writelines(new_lines)


###############
# Read config #
###############
def read_config(config_file_names : list) -> list:
    # List of configuration objects (one for each bus)
    configs = list()
    for name in config_file_names:
        # Create a configuration object for each bus
        config = configuration.Configuration()

        # Reading the CSV
        for index, row in pd.read_csv(name, sep=",").iterrows():
            # Update the config
	        config = parse_properties_wrapper.parse_property(config, row["Property"], row["Value"])

        # Naming the actual bus
        end_name = name.split("/")[-1]
        config.BUS_NAME = BUS_NAMES[end_name]
        # Append the config to the list
        configs.append(config)

    return configs

########
# MAIN #
########
if __name__ == "__main__":
    config_file_names = sys.argv[1:]
    configs = read_config(config_file_names)

    for config in configs:
        file = open(RTL_FILES[config.BUS_NAME], "r+")
        declare_and_concat_buses(file, config)
        file.close()