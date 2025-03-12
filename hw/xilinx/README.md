# Xilinx FPGA Flow
This tree holds the building environment for Xilinx FPGAs.

## Installation

Additional installation-related technical documentation can be found in the `doc/` folder for:
* [UART FDTI connection](doc/UART_CONNECTION.md).
* [Board-specific installation instructions](doc/BOARDS_INSTALLATION.md).
* [Linux-specific instructions for Vivado](doc/INSTALL_CABLE_DRIVERS.md).
* [Vivado-specific patches](doc/VIVADO_PATCHES.md).


## Build Bitstream and Program Device
In order to build the bitstream all sources for custom IPs must be available for the project.
Check [hw/units/README.md](../units/README.md) for more info.

To build Xilinx and custom IPs:
``` bash
make ips
make ips/<IP name>.xci # For a single IP
```

To build the bitstream just run:
``` bash
make bistream
```

Once the build is completed, program target device running:
``` bash
make start_hw_server # Only once after host boot and for older versions of Vivado
make program_bitstream
```

## Load Binary on the Device
Assuming:
1. The bistream has been programmed
2. A binary has been built (in binary or elf format).
> The software compilation flow builds both elf and binary.

### Load ELFs
Load ELF with GDB and either OpenOCD or XSDB as back-ends.

#### Microblaze-V
If `CORE_SELECTION` is `CORE_MICROBLAZEV`:
``` bash
make xsdb_run_elf
```
Or
``` bash
make xsdb_backend
```

##### Other Cores
Otherwise, **for all other cores**, assuming no `hw_server` instance is running:
``` bash
make run_openocd
```

##### All cores
Once OpenOCD or XSDB backends are up, in another shell run RISC-V GDB and attach to GDB port `3004`, or run:

> 3004 is just the default RISC-V 32-bits GDB port for XSDB

``` bash
make run_gdb
```


### Load Binary
You can load your binary into the device memory running the following command, optionally setting some environment variables:
``` bash
make load_binary bin_path=<path-to-bin> base_address=<value> JTAG_READBACK=<false|true>
```
The default variable values loads the [blinky](../../sw/SoC/examples/blinky/) example.

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
├── make                            # Included Makefiles
├── Makefile                        # Top Make file for Xilinx flow
├── README.md                       # This file
├── rtl                             # RTL sources
├── scripts                         # Utilty scripts
├── sim                             # Xilinx-specific simulation
└── synth                           # Xilinx-specific synthesis
    ├── constraints                 # Constraint files for Xilinx FPGA designs
    └── tcl                         # Synthesis-related TCL scripts
```

## IPs Flow
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
2. Running `make ips/<ip_name>.xci`
> NOTE: Vivado versions must match between IP build and IP import during system build.

## Custom IPs
Custom IPs are built alongside Xilinx IPs.

For further info on custom IPs see [related documentation](../units/README.md).

### Prepare IP Simulation
tbd

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
