# Xilinx flow
This tree is structured as:
```
├── ips                             # Xilinx IPs directory
│   ├── common                      # Common IPs (both hpc and embedded) 
│   │   ├── tcl                     # Common IP flow scripts
│   │   |   ├── post_config.tcl 
|   |   |   └── pre_config.tcl
│   |   ├── <ip_name>               # IP directory, configuration-specific
│   │   |   └── config.tcl          # Script setting IP properties
│   |   └── ....
|   ├── embedded                    # Embedded IPs
|   |   ├── <ip_name>               # IP directory, configuration-specific
|   |   |   └── config.tcl          # Script setting IP properties
|   |   └── ....
|   └── hpc                         # HPC IPs
|       ├── <ip_name>               # IP directory, configuration-specific
|       |   └── config.tcl          # Script setting IP properties
|       └── .... 
├── Makefile                        # Make file for Xilinx flow
├── README.md                       # This file
├── rtl                             # RTL sources
|   └── .... 
├── sim                             # Xilinx-specific simulation
│   ├── README.md                   # Documentation
│   └── tcl                         # Questa TCL scripts
└── synth                           # Xilinx-specific synthesis
    ├── constraints                 # Constraint files for Xilinx FPGA designs
    └── tcl                         # FPGA-synthesis TCL scripts
└── tcl                    
```

# Build Bitstream
TBD

# Add and Configure a Xilinx IP
Based on the specific SoC configuration to which the IP to be inserted must belong,
add a new directory under the:
* `ips/common/` folder if the IP target is both embedded and hpc 
* `ips/embedded/` folder if the IP target is only embedded
* `ips/hpc/` folder if the IP target is only hpc. 

The name of the directory will be the name of your IP in the design. In the directory, put a single file `config.tcl` with the two basic commands to import your target IP:
* `create_ip ... -module_name $::env(IP_NAME)`
* `set_property -dict [list CONFIG.<property_key> {<property_value>} CONFIG.<property_key> {<property_value>} ...] [get_ips $::env(IP_NAME)]`

## Configure IP
(Re-)configure the IP by:
1. Editing the property keys and values;
2. Running make `<ip_name>`
> NOTE: Vivado versions must match between IP build and IP import during system build.

## Prepare IP Simulation
tbd

 