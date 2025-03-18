# Author: Stefano Toscano <stefa.toscano@studenti.unina.it>
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: utility functions to write TCL file for AXI crossbar IP

# Creates the standard initial part of the tcl Configuration file
def initialize_File(file, script_file_name):
    file.write("# This file is auto-generated with " + script_file_name + "\n")
    file.write("# Import IP\n")
    file.write("create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)\n")
    file.write("# Configure IP\n")
    file.write("set_property -dict [list ")

# Creates the standard final part of the tcl Configuration file
def end_File(file):
    file.write("] [get_ips $::env(IP_NAME)]")

# Creates a single property of the tcl Configuration file
def write_single_value_configuration(file, command):
    file.write(command)

