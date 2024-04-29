##############
# Tools path #
##############

G++ = g++
VERILATOR = verilator
GTKWAVE = gtkwave

# Verilator path - Insert here your include path
VERILATOR_INC = /usr/share/verilator/include
VLTSTD_INC = /usr/share/verilator/include/vltstd/

#######################
# Project directories #
#######################

# Directory containing the RTL module
RTL_DIR = template
# Directory containing the TestBench module
TB_DIR = tb
# Directory containing the simulation traces (waves)
WAVES_DIR = waves
# Directory containing the simulation executable
BIN_DIR = bin
# Unit-Under-Test top module sv file name 											
TOP_SV = test

#######################
# Verilator Testbench #
#######################

# TestBench name for UUT
TB = $(TB_DIR)/$(TOP_SV)_tb

# Add here all t he .sv dependencies dirs (e.g. -y dir0 -y dir1 -y dir2 etc.)
SV_INC_DIR = 
# TestBench included cpp files, separated by space (e.g. $(RTL_DIR)/module0.cpp $(RTL_DIR)/module1.cpp $(RTL_DIR)/module2.cpp etc.)
TB_INC_DIR =
# Verilator warning suppression. (Check https://verilator.org/guide/latest/warnings.html)
WARNINGSBYPASS = -Wno-UNUSED -Wno-PINCONNECTEMPTY -Wno-SYNCASYNCNET -Wno-IMPORTSTAR -Wno-MODDUP 
# Enable Verilator debug messages
VERILATOR_DEBUG = #--debug --gdbbt

#Targets
sim_run:
	$(BIN_DIR)/$(TOP_SV)_run

sim_compile: verilate 
	$(G++) -I $(VERILATOR_INC) -I $(VLTSTD_INC) -I obj_dir -I $(TB_DIR) $(VERILATOR_INC)/verilated.cpp $(VERILATOR_INC)/verilated_vcd_c.cpp $(TB).cpp $(TB_INC_DIR) obj_dir/V$(TOP_SV)__ALL.a -o $(BIN_DIR)/$(TOP_SV)_run

sim_create:
	cp template/uut_tb.cpp $(TB_DIR)/$(TOP_SV)_tb.cpp; sed -i 's/uut/$(TOP_SV)/g' $(TB_DIR)/$(TOP_SV)_tb.cpp

verilate:
	$(VERILATOR) $(VERILATOR_DEBUG) -Wall $(WARNINGSBYPASS) --top-module $(TOP_SV) --trace -cc $(RTL_DIR)/$(TOP_SV).sv $(SV_INC_DIR);
	cd obj_dir; make -f V$(TOP_SV).mk

wave:
	$(GTKWAVE) $(WAVES_DIR)/trace.vcd $(WAVES_DIR)/conf.gtkw &

clean:
	@if [ -d "obj_dir" ]; then rm -r obj_dir; fi;
	@if [ -f "$(BIN_DIR)/$(TOP_SV)_run" ]; then rm $(BIN_DIR)/$(TOP_SV)_run; fi;
	@if [ -f "$(WAVES_DIR)/trace.vcd" ]; then rm $(WAVES_DIR)/trace.vcd; fi;

	
