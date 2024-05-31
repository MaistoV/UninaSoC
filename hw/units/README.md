# Units Simulation
This tree is meant to allow users to automate the creation of a simulation environment for SystemVerilog-based units by using the open-source simulator Verilator.

# Install Verilator
Installation steps: TBD

# Creating a new simulation environment
A template project structure is provided in `template.prj/`. In this directory, a symlink to a common Makefile is provided to orchestrate the whole flow, while the template directory contains an example of the final outcome for whichever unit. 

To create a new project, you need to:
```
 source the create_project.sh <your-proj-name>
```
This will create a directory similar to the template, with all sub-folders and a skeleton for your testbench.

# Prepare and Run the testbench
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

# Simulation of a RISC-V core
When it comes to full-core simulation, we rely atm on the cv32e41s SoC simulation environment.
Check https://github.com/Granp4sso/cv32e41s_SoC_env.