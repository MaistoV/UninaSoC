# Environment check
ifndef XILINX_ROOT
$(error Setup script settings.sh has not been sourced, aborting)
endif

# Basic variables for Vivado
XILINX_VIVADO_CMD ?= vivado
XILINX_VIVADO_MODE ?= batch
# Build directory
XILINX_PROJECT_BUILD_DIR ?= ${XILINX_ROOT}/build
# Vivado's compilation reports directory
XILINX_PROJECT_REPORTS_DIR ?= ${XILINX_PROJECT_BUILD_DIR}/reports

# List of the Xilinx IPs to build and import in the design
# Parsing from directory ips/

XILINX_COMMON_IP_LIST = $(shell basename --multiple ${XILINX_IPS_ROOT}/common/xlnx_*)
XILINX_HPC_IP_LIST = $(shell basename --multiple ${XILINX_IPS_ROOT}/hpc/xlnx_*) 
XILINX_EMBEDDED_IP_LIST = $(shell basename --multiple ${XILINX_IPS_ROOT}/embedded/xlnx_*) 

XILINX_IP_LIST = ${XILINX_COMMON_IP_LIST}

# List of IPs' xci files
XILINX_COMMON_IP_LIST_XCI := $(foreach ip,${XILINX_COMMON_IP_LIST},${XILINX_IPS_ROOT}/common/${ip}/build/${ip}.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_HPC_IP_LIST_XCI := $(foreach ip,${XILINX_HPC_IP_LIST},${XILINX_IPS_ROOT}/hpc/${ip}/build/${ip}.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_EMBEDDED_IP_LIST_XCI := $(foreach ip,${XILINX_EMBEDDED_IP_LIST},${XILINX_IPS_ROOT}/embedded/${ip}/build/${ip}.srcs/sources_1/ip/${ip}/${ip}.xci)

XILINX_IP_LIST_XCI = ${XILINX_COMMON_IP_LIST_XCI}

# Selecting flow: HPC or EMBEDDED
ifeq (${SOC_CONFIG}, hpc)
	XILINX_IP_LIST += ${XILINX_HPC_IP_LIST}
	XILINX_IP_LIST_XCI += ${XILINX_HPC_IP_LIST_XCI}
else ifeq (${SOC_CONFIG}, embedded) 
	XILINX_IP_LIST += ${XILINX_EMBEDDED_IP_LIST}
	XILINX_IP_LIST_XCI += ${XILINX_EMBEDDED_IP_LIST_XCI}
else
$(error "Unsupported config ${SOC_CONFIG}") 
endif

# Runtime optimized run strategies
SYNTH_STRATEGY ?= Flow_RuntimeOptimized
IMPL_STRATEGY ?= Flow_RuntimeOptimized

# Full environment variables list for Vivado
# XILINX_PROJECT_LTX=${XILINX_PROJECT_LTX}
XILINX_BITSTREAM ?= ${XILINX_PROJECT_BUILD_DIR}/${XILINX_PROJECT_NAME}.runs/impl_1/${XILINX_PROJECT_NAME}.bit
XILINX_VIVADO_ENV ?=              					\
	SYNTH_STRATEGY=${SYNTH_STRATEGY}				\
	IMPL_STRATEGY=${IMPL_STRATEGY}					\
    XILINX_PART_NUMBER=${XILINX_PART_NUMBER}   		\
    XILINX_PROJECT_NAME=${XILINX_PROJECT_NAME}   	\
    SOC_CONFIG=${SOC_CONFIG}   					    \
	XILINX_BOARD_PART=${XILINX_BOARD_PART}          \
    XILINX_HW_SERVER_HOST=${XILINX_HW_SERVER_HOST}  \
    XILINX_HW_SERVER_PORT=${XILINX_HW_SERVER_PORT}  \
    XILINX_FPGA_DEVICE=${XILINX_FPGA_DEVICE}		\
    XILINX_BITSTREAM=${XILINX_BITSTREAM}   			\
	XILINX_IP_LIST_XCI="${XILINX_IP_LIST_XCI}" 		\
	XILINX_ROOT=${XILINX_ROOT}						\
    QUESTA_PATH=${QUESTA_PATH}   					\
    GCC_PATH=${GCC_PATH}   							\
    XILINX_SIMLIB_PATH=${XILINX_SIMLIB_PATH}

# Package Vivado command in a single variable
XILINX_VIVADO := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode ${XILINX_VIVADO_MODE}
XILINX_VIVADO_BATCH := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode batch

all: bitstream

# Open project in TCL mode
open_prj:
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode tcl ${XILINX_PROJECT_NAME}.xpr

# Open project and GUI
open_gui:
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode gui ${XILINX_PROJECT_NAME}.xpr

# Build bitstream from scratch
bitstream: ips
	mkdir -p ${XILINX_PROJECT_BUILD_DIR}
	mkdir -p ${XILINX_PROJECT_REPORTS_DIR}
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO} -source ${XILINX_ROOT}/synth/tcl/build_bitstream.tcl

# Generate ips
XILINX_IP_NAMES ?= $(addsuffix .xci, ${XILINX_IP_LIST})
ips: ${XILINX_IP_NAMES}

# Build single IP
%.xci: IP_NAME=$*
%.xci: IP_DIR=$(firstword $(shell find ${XILINX_IPS_ROOT} -name '$*'))
%.xci: IP_BUILD_DIR=${IP_DIR}/build
%.xci: ips/*/%/config.tcl
	@echo "Generating IP $@"
	mkdir -p ${IP_BUILD_DIR}; 						 		\
	cd       ${IP_BUILD_DIR}; 						 		\
	export IP_NAME=${IP_NAME}; ${XILINX_VIVADO_BATCH}		\
		-source ${XILINX_IPS_ROOT}/common/tcl/pre_config.tcl 	\
		-source ${IP_DIR}/config.tcl \
		-source ${XILINX_IPS_ROOT}/common/tcl/post_config.tcl
	touch $@

# Start hardware server
start_hw_server:
	hw_server -d -L- -stcp::${XILINX_HW_SERVER_PORT}

# Open Vivado hardware manager
open_hw_manager:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode tcl \
		-source ${XILINX_SYNTH_TCL_ROOT}/$@.tcl
# -source ${XILINX_SYNTH_TCL_ROOT}/set_ila_trigger.tcl

program_bitstream:
	${XILINX_VIVADO} \
		-source ${XILINX_SYNTH_TCL_ROOT}/$@.tcl

# Simulation
sim_compile_simlib:
	${XILINX_VIVADO_BATCH} -source ${XILINX_SIM_TCL_ROOT}/compile_simlib.tcl

sim_export_%: ${XILINX_IPS_ROOT}/%/questa/compile.do
${XILINX_IPS_ROOT}/%/questa/compile.do: ${XILINX_SIM_IP_ROOT}
	cd ${XILINX_SIMLIB_PATH}; \
	VIVADO_PROJECT=${XILINX_IPS_ROOT}/$*/build/$*.xpr \
	${XILINX_VIVADO_BATCH} -source ${XILINX_SIM_TCL_ROOT}/export_simulation.tcl

${XILINX_SIM_IP_ROOT}/ips:
	mkdir -p $@

bin_path ?= ${SW_ROOT}/src/PoC_jtag2axi/blink.bin # TODO: update this for bootrom 
base_address ?= 0x00000000                        # BRAM base address
LOAD_BINARY_READBACK ?= false                     # Whether to readback and check the loaded binary or not

# Load the binary into SoC memory (BRAM for now)
# Call the specific load script based on the SOC_CONFIG (HPC or EMBEDDED) 
load_binary: load_binary_${SOC_CONFIG}

# Write the binary to BRAM through jtag2axi
load_binary_embedded: ${bin_path}
	${XILINX_VIVADO} \
		-source ${XILINX_SYNTH_TCL_ROOT}/jtag2axi_load_binary.tcl \
		-tclargs ${bin_path} ${base_address} ${LOAD_BINARY_READBACK}

# Write the binary to BRAM/DDR through XDMA
load_binary_hpc: ${bin_path}
	@bash -c "source ${XILINX_SYNTH_TCL_ROOT}/xdma_load_binary.sh ${bin_path} ${base_address} ${LOAD_BINARY_READBACK}"



# Clean up project
clean:
	rm -rf ${XILINX_PROJECT_BUILD_DIR}
	rm -rf vivado*.log vivado*.jou vivado*.str

clean_ips:
	rm -rf ${XILINX_IPS_ROOT}/*/*/build
	rm -rf *.xci

###########
# PHONIES #
###########
.PHONY: open_gui open_prj bitstream ips open_hw_manager sim_compile_simlib clean clean_ips load_binary load_binary_embedded load_binary_hpc

