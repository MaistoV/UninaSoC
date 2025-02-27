# Environment check
ifndef XILINX_ROOT
$(error Setup script settings.sh has not been sourced, aborting)
endif

#########################
# Include configuration #
#########################
include make/config.mk


######################
# Vivado environment #
######################

# Basic variables for Vivado #
XILINX_VIVADO_CMD ?= vivado
XILINX_VIVADO_MODE ?= batch
# Build directory
XILINX_PROJECT_BUILD_DIR ?= ${XILINX_ROOT}/build
# Vivado's compilation reports directory
XILINX_PROJECT_REPORTS_DIR ?= ${XILINX_PROJECT_BUILD_DIR}/reports
# Hardware server
XILINX_HW_SERVER ?= hw_server

# List of the Xilinx IPs to build and import in the design
# Parsing from directory ips/
XILINX_COMMON_IP_LIST 	= $(shell basename --multiple ${XILINX_IPS_ROOT}/common/xlnx_*)
XILINX_HPC_IP_LIST 		= $(shell basename --multiple ${XILINX_IPS_ROOT}/hpc/xlnx_*)
XILINX_EMBEDDED_IP_LIST = $(shell basename --multiple ${XILINX_IPS_ROOT}/embedded/xlnx_*)

# List of the Custom IPs to build and import in the design
# Parsing from directory ips/
CUSTOM_COMMON_IP_LIST	= $(shell if ls ${XILINX_IPS_ROOT}/common/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/common/custom_*; else echo ""; fi)
CUSTOM_HPC_IP_LIST 		= $(shell if ls ${XILINX_IPS_ROOT}/hpc/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/hpc/custom_*; else echo ""; fi)
CUSTOM_EMBEDDED_IP_LIST	= $(shell if ls ${XILINX_IPS_ROOT}/embedded/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/embedded/custom_*; else echo ""; fi)

# Board-independent IP lists
XILINX_IP_LIST	= ${XILINX_COMMON_IP_LIST}
CUSTOM_IP_LIST 	= ${CUSTOM_COMMON_IP_LIST}

# List of IPs' xci files
XILINX_COMMON_IP_LIST_XCI 	:= $(foreach ip,${XILINX_COMMON_IP_LIST},${XILINX_IPS_ROOT}/common/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_HPC_IP_LIST_XCI 		:= $(foreach ip,${XILINX_HPC_IP_LIST},${XILINX_IPS_ROOT}/hpc/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_EMBEDDED_IP_LIST_XCI := $(foreach ip,${XILINX_EMBEDDED_IP_LIST},${XILINX_IPS_ROOT}/embedded/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_COMMON_IP_LIST_XCI	:= $(foreach ip,${CUSTOM_COMMON_IP_LIST},${XILINX_IPS_ROOT}/common/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_HPC_IP_LIST_XCI 		:= $(foreach ip,${CUSTOM_HPC_IP_LIST},${XILINX_IPS_ROOT}/hpc/${ip}/build/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_EMBEDDED_IP_LIST_XCI	:= $(foreach ip,${CUSTOM_EMBEDDED_IP_LIST},${XILINX_IPS_ROOT}/embedded/${ip}/build/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)

# Board-independent XCI lists
XILINX_IP_LIST_XCI 	= ${XILINX_COMMON_IP_LIST_XCI}
CUSTOM_IP_LIST_XCI	= ${CUSTOM_COMMON_IP_LIST_XCI}

# Selecting flow: HPC or EMBEDDED
ifeq (${SOC_CONFIG}, hpc)
	XILINX_IP_LIST 		+= ${XILINX_HPC_IP_LIST}
	XILINX_IP_LIST_XCI 	+= ${XILINX_HPC_IP_LIST_XCI}
	CUSTOM_IP_LIST 		+= ${CUSTOM_HPC_IP_LIST}
	CUSTOM_IP_LIST_XCI 	+= ${CUSTOM_HPC_IP_LIST_XCI}
else ifeq (${SOC_CONFIG}, embedded)
	XILINX_IP_LIST 		+= ${XILINX_EMBEDDED_IP_LIST}
	XILINX_IP_LIST_XCI 	+= ${XILINX_EMBEDDED_IP_LIST_XCI}
	CUSTOM_IP_LIST 		+= ${CUSTOM_EMBEDDED_IP_LIST}
	CUSTOM_IP_LIST_XCI 	+= ${CUSTOM_EMBEDDED_IP_LIST_XCI}
else
$(error "Unsupported config ${SOC_CONFIG}")
endif

# Concatenate/create the final IP lists
IP_LIST 	= ${XILINX_IP_LIST} ${CUSTOM_IP_LIST}
IP_LIST_XCI = ${XILINX_IP_LIST_XCI} ${CUSTOM_IP_LIST_XCI}

# Runtime optimized run strategies
# SYNTH_STRATEGY 	?= Flow_RuntimeOptimized
# IMPL_STRATEGY 	?= Flow_RuntimeOptimized

SYNTH_STRATEGY 	?= "Vivado Synthesis Defaults"
IMPL_STRATEGY 	?= "Vivado Implementation Defaults"

# Implementation artifacts
XILINX_BITSTREAM   ?= ${XILINX_PROJECT_BUILD_DIR}/${XILINX_PROJECT_NAME}.runs/impl_1/${XILINX_PROJECT_NAME}.bit
XILINX_PROBE_LTX ?= ${XILINX_PROJECT_BUILD_DIR}/${XILINX_PROJECT_NAME}.runs/impl_1/${XILINX_PROJECT_NAME}.ltx

# Whether to use ILA probes (0|1)
XILINX_ILA ?= 0
DEBUG_MODULE ?= 1

# Full environment variables list for Vivado
XILINX_VIVADO_ENV ?=								\
	DEBUG_MODULE=${DEBUG_MODULE}					\
	AXI_DATA_WIDTH=${AXI_DATA_WIDTH}				\
	AXI_ADDR_WIDTH=${AXI_ADDR_WIDTH}				\
	AXI_ID_WIDTH=${AXI_ID_WIDTH}					\
	DEBUG_MODULE=${DEBUG_MODULE}					\
	XILINX_ILA=${XILINX_ILA}						\
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
	XILINX_PROBE_LTX=${XILINX_PROBE_LTX}			\
	IP_LIST_XCI="${IP_LIST_XCI}" 					\
	XILINX_ROOT=${XILINX_ROOT}						\
    QUESTA_PATH=${QUESTA_PATH}   					\
    GCC_PATH=${GCC_PATH}   							\
    XILINX_SIMLIB_PATH=${XILINX_SIMLIB_PATH}

# Package Vivado command in a single variable
XILINX_VIVADO := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode ${XILINX_VIVADO_MODE}
XILINX_VIVADO_BATCH := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode batch

all: bitstream

# Build bitstream from scratch
bitstream: ips
	mkdir -p ${XILINX_PROJECT_REPORTS_DIR}
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO} -source ${XILINX_ROOT}/synth/tcl/build_bitstream.tcl

# Generate ips
IP_NAMES ?= $(addsuffix .xci, ${IP_LIST})
ips: ${IP_NAMES}

# Build single IP
%.xci: IP_NAME=$*
%.xci: IP_DIR=$(firstword $(shell find ${XILINX_IPS_ROOT} -name '$*'))
%.xci: IP_BUILD_DIR=${IP_DIR}/build
%.xci: ips/*/%/config.tcl
	@echo "Generating IP $@"
	mkdir -p ${IP_BUILD_DIR}; 						 		\
	cd       ${IP_BUILD_DIR}; 						 		\
	export IP_DIR=${IP_DIR};								\
	export IP_PRJ_NAME=${IP_NAME}_prj;						\
	export IP_NAME=${IP_NAME}; 								\
	${XILINX_VIVADO_BATCH}									\
		-source ${XILINX_IPS_ROOT}/common/tcl/pre_config.tcl 	\
		-source ${IP_DIR}/config.tcl							\
		-source ${XILINX_IPS_ROOT}/common/tcl/post_config.tcl
	touch $@

#############
# Utilities #
#############

include make/utils.mk

##############
# Simulation #
##############

include make/sim.mk

###############
# Load binary #
###############

include make/load_binary.mk

############
# Cleaning #
############
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
.PHONY:  bitstream ips clean clean_ips

