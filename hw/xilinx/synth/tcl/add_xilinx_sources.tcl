## Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
## Description: Utility variables and macros for AXI interconnections in UninaSoC

# Define a list of all the source files
set src_file_list [ list \
    $::env(XILINX_ROOT)/rtl/uninasoc_pkg.sv  \
    $::env(XILINX_ROOT)/rtl/uninasoc_axi.svh \
    $::env(XILINX_ROOT)/rtl/uninasoc.sv      \
]

# Add files to project
add_files -norecurse -fileset [current_fileset] $src_file_list