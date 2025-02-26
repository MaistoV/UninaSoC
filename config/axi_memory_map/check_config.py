#!/bin/python3.10
# Author: Manuel Maddaluno        <manuel.maddaluno@unina.it>
# Description:
#   Check the validity of the CSV configurations


####################
# Import libraries #
####################
# Parse args
import sys
# Manipulate CSV
import pandas as pd
# Sub-scripts
import parse_properties_wrapper
import configuration

# Constants
VALID_PROTOCOLS = ["AXI4", "AXI4LITE"]
BUS_NAMES = {
    "MBUS" : "config_main_bus.csv",
    "PBUS" : "config_peripheral_bus.csv"
}
MIN_AXI4_ADDR_WIDTH = 12
MIN_AXI4LITE_ADDR_WIDTH = 1

# Print/debug stuff
PRINT_PREFIX = "[CHECK_CONFIG]"
PRINT_ERROR_PREFIX = "[ERROR]"
PRINT_WARNING_PREFIX = "[WARNING]"
# print info
def __print(txt : str) -> None:  
    print(f"{PRINT_PREFIX} {txt}")

# print warning
def __print_warning(txt : str) -> None:
    print(f"{PRINT_PREFIX}{PRINT_WARNING_PREFIX} {txt}")

# print error
def __print_error(txt : str) -> None:
    print(f"{PRINT_PREFIX}{PRINT_ERROR_PREFIX} {txt}")


##############################
# Check single configuration #
##############################
def check_single_config(config : configuration.Configuration, config_file_name: str) -> bool: 
    # Check if the protocol is valid
    if config.PROTOCOL not in VALID_PROTOCOLS: 
        __print_error(f"Invalid protocol in {config_file_name}")
        return False
    
    # Check the number of slaves and relative data (range names, addresses, and address widths)
    if config.NUM_MI != len(config.RANGE_NAMES):
        __print_error(f"The NUM_MI does not match RANGE_NAMES in {config_file_name}")
        return False
    if config.NUM_MI != len(config.BASE_ADDR):
        __print(config.BASE_ADDR)
        __print_error(f"The NUM_MI does not match BASE_ADDR in {config_file_name}")
        return False
    if config.NUM_MI != len(config.RANGE_ADDR_WIDTH):
        __print_error(f"The NUM_MI does not match ADDR_WIDTH in {config_file_name}")
        return False

    # Check the minimum widths (AXI4 12, AXI4LITE 1)
    for addr_width in config.RANGE_ADDR_WIDTH:
        if addr_width > config.ADDR_WIDTH:
            __print_error(f"RANGE_ADDR_WIDTH is greater than {config.ADDR_WIDTH} in {config_file_name}")
        if config.PROTOCOL == "AXI4" and addr_width < MIN_AXI4_ADDR_WIDTH:
            __print_error(f"RANGE_ADDR_WIDTH is less than {MIN_AXI4_ADDR_WIDTH} in {config_file_name}")
            return False
        if config.PROTOCOL == "AXI4LITE" and addr_width < MIN_AXI4LITE_ADDR_WIDTH:
            __print_error(f"RANGE_ADDR_WIDTH is less than {MIN_AXI4LITE_ADDR_WIDTH} in {config_file_name}")
            return False
    
    # Check the address range
    # List of base and end addresses for each slave (e.g. with range_width=12 -> base_addr: 0x0, end_add: 0xfff)
    base_addresses = list()
    end_addresses = list()
    for i in range(len(config.BASE_ADDR)):
        base_address = int(config.BASE_ADDR[i], 16)
        end_address = base_address + ~(~1 << (config.RANGE_ADDR_WIDTH[i]-1)) 

        # Check if the base addr does not fall into the addr range (e.g. base_addr: 0x100 is not allowed with range_width=12)
        if (base_address & ~(~1 << (config.RANGE_ADDR_WIDTH[i]-1)) ) != 0:
            __print_error(f"BASE_ADDR does not match RANGE_ADDR_WIDTH in {config_file_name}")
            return False
        
        if i > 0:
            # Check if the current address does not fall into the addr range one of the previous slaves
            for j in range(len(base_addresses)):
                if (base_address < end_addresses[j]) and (base_address > base_addresses[j]):
                    __print_error(f"Address of {config.RANGE_NAMES[i]} overlaps with {config.RANGE_NAMES[i-1]} in {config_file_name}")
                    return False
                elif (end_address > base_addresses[j]) and (base_address < base_addresses[j]):
                    __print_error(f"Address of {config.RANGE_NAMES[i]} overlaps with {config.RANGE_NAMES[i-1]} in {config_file_name}")
                    return False
                elif (base_address < base_addresses[j]) and (end_address > end_addresses[j]):
                    __print_error(f"Address of {config.RANGE_NAMES[i]} overlaps with {config.RANGE_NAMES[i-1]} in {config_file_name}")
                    return False 
                elif (base_address > base_addresses[j]) and (end_address < end_addresses[j]):
                    __print_error(f"Address of {config.RANGE_NAMES[i]} overlaps with {config.RANGE_NAMES[i-1]} in {config_file_name}")
                    return False 
                elif (end_address == base_addresses[j]) or (end_address == end_addresses[j]) or (base_address == base_addresses[j]) or (base_address == end_addresses[j]):
                    __print_error(f"Address of {config.RANGE_NAMES[i]} overlaps with {config.RANGE_NAMES[i-1]} in {config_file_name}")
                    return False
                

        base_addresses.append(base_address)
        end_addresses.append(end_address)
            

########################
# Check configurations #
########################
def check_configs (configs : list, config_file_names : list) -> bool: 
    status = True
    __print(f"Starting checking {len(configs)} config...")
    for i in range(len(configs)):
        status = check_single_config(configs[i], config_file_names[i])

    if status == False:
        return False

    # Check if the first element of a secondary bus (pbus) has the same address of the main bus TODO - add other checks (?)
    for i in range(len(configs)):
        for j in range(configs[i].NUM_MI):
            if configs[i].RANGE_NAMES[j] in BUS_NAMES:
                for k in range(len(config_file_names)):
                    config_fname = config_file_names[k].split('/')[-1]
                    if BUS_NAMES[configs[i].RANGE_NAMES[j]] == config_fname:
                        if configs[k].BASE_ADDR[0] != configs[i].BASE_ADDR[j]:
                            __print_warning(f"The first slave of {configs[i].RANGE_NAMES[j]} does not have the same base address in its parent bus")

    __print("Checking configuration done!")


###############
# Read config #
###############
def read_config(config_file_names : list) -> list: 
    __print("Reading configuration...")
    # List of configuration objects (one for each bus)
    configs = []
    for name in config_file_names:
        # Create a configuration object for each bus
        config = configuration.Configuration()
    
        # Reading the CSV
        for index, row in pd.read_csv(name, sep=",").iterrows():
            # Update the config
	        config = parse_properties_wrapper.parse_property(config, row["Property"], row["Value"])
        # Append the config to the list
        configs.append(config)

    __print("Configuration read!")
    
    return configs


##############
# Parse args #
##############
def parse_args(argv : list) -> list:
    __print("Parsing arguments...")
    # CSV configuration file path
    config_file_names = ['configs/embedded/config_main_bus.csv', 'configs/embedded/config_peripheral_bus.csv'] 
    if len(sys.argv) >= 3:
        # Get the array of bus names from the second arg to the last but one
        config_file_names = sys.argv[1:3]
    __print("Parsing done!")
    return config_file_names


if __name__ == "__main__":
    config_file_names = parse_args(sys.argv)
    configs = read_config(config_file_names)
    if check_configs(configs, config_file_names) == False: 
        exit(1)
    else:
        exit(0)