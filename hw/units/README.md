# Custom IP Implementation and Simulation

The source files for the custom IPs used in the SoC are located in this directory. These custom IPs are packaged using the Makefile IPs flow found in the `hw/xilinx directory`. Each IP's build and packaging process directly references the source files in `units/custom_IP_NAME`.

## Custom Units Integration

Each custom IP, or unit, is represented by two subdirectories: one in `hw/units` and another in `hw/xilinx/ips`.

```
├── units
│   └── custom_<IP name>
|       ├── assets/
|       ├── custom_top_wrapper.sv
|       └── fetch_sources.sh
└── xilinx
    ├── doc
    ├── ips
    ├── common
    │   └── custom_<IP name>
    |       └── config.tcl -> ../tcl/custom_config.tcl
    ├── embedded
    └── hpc
```

These two directories must share the same name, both using the `custom_` prefix:
- The directory in `hw/xilinx/ips`, you can simply link to the `ips/common/config.tcl` file.
- The directory in `hw/units` must expose:
    1. A `fetch_sources.sh` script.
    2. A `custom_top_wrapper.sv` RTL source to wrap


If the custom IP originates from a remote repository (e.g., a GitHub project), the  `fetch_sources.sh` script should:
(a) create an `rtl/` directory,
(b) clone and copy all source files into the `rtl/` directory in a **flattened structure**, and
(c) remove all temporary files created during this process.

The `custom_template/` directory contains a template project for custom IPs, including a wrapper module and a script.

## Using MEM and AXI interfaces

The file `custom_template/custom_top_wrapper.sv` is a wrapper module designed to make the custom IP compatible with the SoC. It leverages the `hw/xilinx/rtl/uninasoc_mem.svh` and `hw/xilinx/rtl/uninasoc_axi.svh` headers (which are already included in the Vivado project packaging flow) to define macros for the MEM and AXI bus interfaces. While custom signals are allowed, we expect the custom IP to primarily communicate via either AXI (preferably) or MEM.

To fetch rtl sources, just use:
```
make units
```

## Units Simulation
This tree is meant to allow users to automate the creation of a simulation environment for SystemVerilog-based units by using the open-source simulator Verilator.

### Install Verilator
Installation steps: TBD

### Creating a new simulation environment
A template project structure is provided in `template.prj/`. In this directory, a symlink to a common Makefile is provided to orchestrate the whole flow, while the template directory contains an example of the final outcome for whichever unit.

To create a new project, you need to:
```
 source the create_project.sh <your-proj-name>
```
This will create a directory similar to the template, with all sub-folders and a skeleton for your testbench.

### Prepare and Run the testbench
Now, you can add your SV sources in `PROJECT_NAME/src`. If your module includes more SV files, specify them in the `SV_INC_DIR` Makefile varibale.
Then run:
```
make verilate
```
This will compile your module files into a cpp verilator class, that is already imported in the testbench.
If you are experiencing some errors with this step, you can get verbose debug info from verilator by decommenting the line VERILATOR_DEBUG.
The testbench skeleton assumes the units to have a reset (rstn_i) and a clock (clk_i).
You can remove them, or add them to your SV design, even if unused.
You can modify the testbench as you please, and then add in TB_INC_DIR all the header files and in TB_SRC_DIR extra cpp files beside the main.
One your tb is ready, run
```
make compile
```
This will create an executable file in the bin folder.
Now run your application with
```
make run
```
By default, the tb will generate a trace.vcd file in the waves directory.
If you want to visualize them with GTKWave, just use
```
make wave
```
It will load a configuration file called conf.gtkw, if present.
To clean compilation files (for both verilator and gcc), run
```
make clean
```

### Simulation of a RISC-V core
When it comes to full-core simulation, we rely atm on the cv32e41s SoC simulation environment.
Check https://github.com/Granp4sso/cv32e41s_SoC_env.