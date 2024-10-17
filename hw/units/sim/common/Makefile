##############
# Tools path #
##############

GXX ?= g++
VERILATOR ?= verilator
GTKWAVE ?= gtkwave

# Verilator path - Insert here your include path
VERILATOR_INC = /usr/share/verilator/include
VLTSTD_INC = /usr/share/verilator/include/vltstd/

#######################
# Project directories #
#######################

# Unit-Under-Test top module sv file name 	
PROJECT_NAME ?= test
# Directory containing the RTL module
RTL_DIR = rtl
# Directory containing the TestBench module
TB_DIR = tb
# Directory containing the simulation traces (waves)
WAVES_DIR = waves
# Directory containing the simulation executable
BIN_DIR = bin
# Directory containing the verilator generated files
VGEN_DIR = verilator

#######################
# Verilator Testbench #
#######################

# TestBench name for UUT
TB = $(TB_DIR)/$(PROJECT_NAME)_tb

# Add here all the .sv dependencies dirs (e.g. -y dir0 -y dir1 -y dir2 etc.)
SV_INC_DIR = 
# TestBench included cpp files, separated by space (e.g. $(RTL_DIR)/module0.cpp $(RTL_DIR)/module1.cpp $(RTL_DIR)/module2.cpp etc.)
TB_INC_DIR =
TB_SRC_DIR = 
# Verilator warning suppression. (Check https://verilator.org/guide/latest/warnings.html)
WARNINGSBYPASS = -Wno-UNUSED -Wno-PINCONNECTEMPTY -Wno-SYNCASYNCNET -Wno-IMPORTSTAR -Wno-MODDUP 
# Enable Verilator debug messages
VERILATOR_DEBUG = #--debug --gdbbt

verilate:
	$(VERILATOR) $(VERILATOR_DEBUG) -Wall $(WARNINGSBYPASS) --top-module $(PROJECT_NAME) --trace -cc $(PROJECT_NAME)/$(RTL_DIR)/$(PROJECT_NAME).sv $(SV_INC_DIR);
	@if [ -d "obj_dir" ]; then cp obj_dir/* $(PROJECT_NAME)/$(VGEN_DIR); rm -r obj_dir; else echo "[Error] Verilator files were not correctly created"; fi;
	cd $(PROJECT_NAME)/$(VGEN_DIR); make -f V$(PROJECT_NAME).mk

compile:
	$(GXX) \
	-I $(VERILATOR_INC) -I $(VLTSTD_INC) -I $(PROJECT_NAME)/$(VGEN_DIR) -I $(PROJECT_NAME)/$(TB_DIR) \
	$(VERILATOR_INC)/verilated.cpp $(VERILATOR_INC)/verilated_vcd_c.cpp \
	$(PROJECT_NAME)/$(TB).cpp $(TB_INC_DIR) \
	$(PROJECT_NAME)/$(VGEN_DIR)/V$(PROJECT_NAME)__ALL.a -o $(PROJECT_NAME)/$(BIN_DIR)/$(PROJECT_NAME)_run

run:
	$(PROJECT_NAME)/$(BIN_DIR)/$(PROJECT_NAME)_run

wave:
	$(GTKWAVE) $(WAVES_DIR)/trace.vcd $(WAVES_DIR)/conf.gtkw &

clean:
	rm -f $(PROJECT_NAME)/$(VGEN_DIR)/*
	rm -f "$(PROJECT_NAME)/$(BIN_DIR)/$(PROJECT_NAME)_run
	rm -f $(PROJECT_NAME)/$(WAVES_DIR)/trace.vcd;

	
