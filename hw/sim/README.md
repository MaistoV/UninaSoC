# Simulation Readme

Simulation flow is structured as follows: (1) SoC simulation and (2) unit-test simulation.
The former is performed using QuestaSIM, a commercial simulator for RTL, while the latter is performed with the open-source simulator Verilator.

# Verilator Unit-Test Simulation
Before integration, you can use the verilator-based simulation environment in the verilator directory.
To create a verilator simulation, first you need to copy the .sv files in the rtl folder.
The Makefile allows the definition of a top module (TOP_SV) and the other .sv dependencies (SV_INC_DIR).
Once all files are placed, run
make verilate

The template directory contains a dummy .sv file and the verilator tb template. 
make sim_create
This creates a copy of the testbench for the TOP_SV file previously built with verilator.
The testbench will be put into the tb directory. From here it is possible to customize it as you prefer.

After finishing the testbench, just run
make sim_compile
to compile all the .cpp files and finally
make sim_run
to run the simulation. Wave traces are also built in the directory waves.
If you have gtkwave installed, you can visualize them by
make wave