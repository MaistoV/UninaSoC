#!/bin/python3.10
# Author: Manuel Maddaluno        <manuel.maddaluno@unina.it>
# Description: utility functions to properly read the config CSV file

####################
# Import libraries #
####################
# Manipulate CSV
import pandas as pd
# Sub-modules
import configuration
import parse_properties_wrapper

# Name of buses
BUS_NAMES                = {
    "config_main_bus.csv"       : "MBUS",
    "config_peripheral_bus.csv" : "PBUS"
}


###############
# Read config #
###############
def read_config(config_file_names : list) -> list:
    # List of configuration objects (one for each bus)
    configs = []
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



############
# PRINTING #
############

# Print/debug stuff
PRINT_PREFIX = "[CHECK_CONFIG]"
PRINT_ERROR_PREFIX = "[ERROR]"
PRINT_WARNING_PREFIX = "[WARNING]"

# print info
def print_info(txt : str) -> None:
    print(f"{PRINT_PREFIX} {txt}")

# print warning
def print_warning(txt : str) -> None:
    print(f"{PRINT_PREFIX}{PRINT_WARNING_PREFIX} {txt}")

# print error
def print_error(txt : str) -> None:
    print(f"{PRINT_PREFIX}{PRINT_ERROR_PREFIX} {txt}")