#!/bin/bash

#######################
# Project directories #
#######################

# Unit-Under-Test top module sv file name 	
PROJECT_NAME=test.prj
if [ $1 != "" ]; then
	PROJECT_NAME=$1.prj
fi
# Directory containing the RTL module
RTL_DIR=src/rtl
# Directory containing the TestBench module
TB_DIR=tb
# Directory containing the simulation traces (waves)
WAVES_DIR=waves
# Directory containing the simulation executable
BIN_DIR=bin
# Directory containing the verilator generated files
VGEN_DIR=verilator

#######################
# Verilator Testbench #
#######################

# TestBench name for UUT
TB=${TB_DIR}/${PROJECT_NAME}_tb

if [ -d "${PROJECT_NAME}" ]; then 
	echo "[Error] Project directory ${PROJECT_NAME} already exists"
else
	# Copy the whole template directory
	cp -r template.prj/ ${PROJECT_NAME}
	# Create artifact directories
	mkdir ${PROJECT_NAME}/${BIN_DIR}
	mkdir ${PROJECT_NAME}/${VGEN_DIR}
	mkdir ${PROJECT_NAME}/${WAVES_DIR}
	# Rename tb module
	mv ${PROJECT_NAME}/${TB_DIR}/template_tb.cpp ${PROJECT_NAME}/${TB_DIR}/${PROJECT_NAME}_tb.cpp
	sed -i 's/template.prj/\${PROJECT_NAME}/g' ${PROJECT_NAME}/${TB_DIR}/${PROJECT_NAME}_tb.cpp
fi


