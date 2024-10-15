# Xilinx flow
This tree holds the building environment for Xilinx FPGAs.

More technical documentation can be found in the `doc/` folder for:
* [board-specific installation instructions](doc/BOARDS_INSTALLATION.md).
* [Linux-specific instructions for Vivado](doc/INSTALL_CABLE_DRIVERS.md).
* [Vivado-specific patches](doc/VIVADO_PATCHES.md).

## Build Bitstream and Program Device
To build the bitstream just run:
``` bash
make bistream
```

Once the build is completed, program target device running:
``` bash
make start_hw_server # Only once after host boot
make program_bitstream
```

## Load Binary on the Device
Assuming:
1. The bistream has been programmed
2. A binary has been built (in binary, non elf format), e.g. bootrom

You can load your binary into the device memory running the following command, optionally setting some environment variables:
``` bash
make load_binary bin_path=<path-to-bin> base_address=<value> JTAG_READBACK=<false|true>
```
The default configuration load the bootrom.

## Directory Structure
This tree is structured as follows:
``` bash
├── ips                             # Xilinx IPs directory
│   ├── common                      # Common IPs (both hpc and embedded)
│   │   ├── tcl                     # Common IP flow scripts
│   │   |   ├── post_config.tcl
|   |   |   └── pre_config.tcl
│   |   └── <ip_name>               # IP directory, configuration-specific
│   │       └── config.tcl          # Script setting IP properties
|   ├── embedded                    # Embedded IPs
|   └── hpc                         # HPC IPs
├── Makefile                        # Make file for Xilinx flow
├── README.md                       # This file
├── rtl                             # RTL sources
├── sim                             # Xilinx-specific simulation
└── synth                           # Xilinx-specific synthesis
    ├── constraints                 # Constraint files for Xilinx FPGA designs
    └── tcl                         # FPGA-synthesis TCL scripts
```

## IPs flow
The system features both Xilinx-provided and custom IPs.

### Add and Configure a Xilinx IP
IPs are characterized by being configuration-specific (hpc or embedded) or common:
* `ips/common/`
* `ips/embedded/`
* `ips/hpc/`

The name of the directory will be the name of your IP in the design. In the directory, put a single file `config.tcl` with the two basic commands to import your target IP:
* `create_ip ... -module_name $::env(IP_NAME)`
* `set_property -dict [list CONFIG.<property_key> {<property_value>} CONFIG.<property_key> {<property_value>} ...] [get_ips $::env(IP_NAME)]`

(Re-)configure the IP by:
1. Editing the property keys and values in `config.tcl`;
2. Running make `<ip_name>`
> NOTE: Vivado versions must match between IP build and IP import during system build.

### Prepare IP Simulation
tbd

## Custom IPs
TBD

## In-system Debug Probing with Xilinx ILAs
This environment supports the automatic insertion of Internal Logic Analyzer (ILA) probes, ([PG172](https://docs.amd.com/v/u/en-US/pg172-ila) ).

ILA probes are enabled by default, and can be disabled by setting the envvar `XILINX_ILA=0`.
To add probe on a net, you should mark it as `MARK_DEBUG=1` or `TRUE`, in one of the following ways:
* Mark it in RTL with a source code specifier, e.g. `(* MARK_DEBUG = "TRUE" *) wire debug_wire;`
* Mark it in the [hw/xilinx/synth/tcl/mark_debug_nets.tcl](hw/xilinx/synth/tcl/mark_debug_nets.tcl) script, e.g. `set_property MARK_DEBUG true [get_nets ...]`

### Notes on Using ILAs
1. Using the ILA core adds a couple of minutes to the flow to synthesize.
2. Max 1023 nets can be probed in the current setup.
3. Adding many probes might complicate the design and make it more difficult to build.
