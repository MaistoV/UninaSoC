# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description:
#    Hold all the environment variables for Xilinx tools.

# Basic variables for Vivado
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
XILINX_COMMON_IP_LIST   = $(shell basename --multiple ${XILINX_IPS_ROOT}/common/xlnx_*)
XILINX_HPC_IP_LIST      = $(shell basename --multiple ${XILINX_IPS_ROOT}/hpc/xlnx_*)
XILINX_EMBEDDED_IP_LIST = $(shell basename --multiple ${XILINX_IPS_ROOT}/embedded/xlnx_*)

# List of the Custom IPs to build and import in the design
# Parsing from directory ips/
CUSTOM_COMMON_IP_LIST   = $(shell if ls ${XILINX_IPS_ROOT}/common/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/common/custom_*; else echo ""; fi)
CUSTOM_HPC_IP_LIST      = $(shell if ls ${XILINX_IPS_ROOT}/hpc/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/hpc/custom_*; else echo ""; fi)
CUSTOM_EMBEDDED_IP_LIST = $(shell if ls ${XILINX_IPS_ROOT}/embedded/custom_* 1>/dev/null 2>&1; then basename --multiple ${XILINX_IPS_ROOT}/embedded/custom_*; else echo ""; fi)

# Board-independent IP lists
XILINX_IP_LIST = ${XILINX_COMMON_IP_LIST}
CUSTOM_IP_LIST = ${CUSTOM_COMMON_IP_LIST}

# List of IPs' xci files
XILINX_COMMON_IP_LIST_XCI   := $(foreach ip,${XILINX_COMMON_IP_LIST},${XILINX_IPS_ROOT}/common/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_HPC_IP_LIST_XCI      := $(foreach ip,${XILINX_HPC_IP_LIST},${XILINX_IPS_ROOT}/hpc/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
XILINX_EMBEDDED_IP_LIST_XCI := $(foreach ip,${XILINX_EMBEDDED_IP_LIST},${XILINX_IPS_ROOT}/embedded/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_COMMON_IP_LIST_XCI   :=  $(foreach ip,${CUSTOM_COMMON_IP_LIST},${XILINX_IPS_ROOT}/common/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_HPC_IP_LIST_XCI      := $(foreach ip,${CUSTOM_HPC_IP_LIST},${XILINX_IPS_ROOT}/hpc/${ip}/build/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)
CUSTOM_EMBEDDED_IP_LIST_XCI := $(foreach ip,${CUSTOM_EMBEDDED_IP_LIST},${XILINX_IPS_ROOT}/embedded/${ip}/build/${ip}/build/${ip}_prj.srcs/sources_1/ip/${ip}/${ip}.xci)

# Board-independent XCI lists
XILINX_IP_LIST_XCI := ${XILINX_COMMON_IP_LIST_XCI}
CUSTOM_IP_LIST_XCI := ${CUSTOM_COMMON_IP_LIST_XCI}

# Selecting flow: HPC or EMBEDDED
ifeq (${SOC_PROFILE}, hpc)
    XILINX_IP_LIST         += ${XILINX_HPC_IP_LIST}
    XILINX_IP_LIST_XCI     += ${XILINX_HPC_IP_LIST_XCI}
    CUSTOM_IP_LIST         += ${CUSTOM_HPC_IP_LIST}
    CUSTOM_IP_LIST_XCI     += ${CUSTOM_HPC_IP_LIST_XCI}
else ifeq (${SOC_PROFILE}, embedded)
    XILINX_IP_LIST         += ${XILINX_EMBEDDED_IP_LIST}
    XILINX_IP_LIST_XCI     += ${XILINX_EMBEDDED_IP_LIST_XCI}
    CUSTOM_IP_LIST         += ${CUSTOM_EMBEDDED_IP_LIST}
    CUSTOM_IP_LIST_XCI     += ${CUSTOM_EMBEDDED_IP_LIST_XCI}
else
$(error "Unsupported config ${SOC_PROFILE}")
endif

# Concatenate/create the final IP lists
IP_LIST     = ${XILINX_IP_LIST} ${CUSTOM_IP_LIST}
IP_LIST_XCI = ${XILINX_IP_LIST_XCI} ${CUSTOM_IP_LIST_XCI}

#########################
# Vivado run strategies #
#########################
# Vivado defaults
# SYNTH_STRATEGY    ?= "Vivado Synthesis Defaults"
# IMPL_STRATEGY     ?= "Vivado Implementation Defaults"
# Runtime optimized  (shorter runtime)
# SYNTH_STRATEGY    ?= Flow_RuntimeOptimized
# IMPL_STRATEGY     ?= Flow_RuntimeOptimized
# High-performace (longer runtime)
SYNTH_STRATEGY     ?= "Flow_PerfOptimized_high"
IMPL_STRATEGY      ?= "Performance_ExtraTimingOpt"

# Implementation artifacts
XILINX_BITSTREAM ?= ${XILINX_PROJECT_BUILD_DIR}/${XILINX_PROJECT_NAME}.runs/impl_1/${XILINX_PROJECT_NAME}.bit
XILINX_PROBE_LTX ?= ${XILINX_PROJECT_BUILD_DIR}/${XILINX_PROJECT_NAME}.runs/impl_1/${XILINX_PROJECT_NAME}.ltx

# Whether to use ILA probes (0|1)
XILINX_ILA ?= 0

# Full environment variables list for Vivado
XILINX_VIVADO_ENV ?=                                \
    DATA_WIDTH=${DATA_WIDTH}                        \
    ADDR_WIDTH=${ADDR_WIDTH}                        \
    ID_WIDTH=${ID_WIDTH}                            \
    CORE_SELECTOR=${CORE_SELECTOR}                  \
    VIO_RESETN_DEFAULT=${VIO_RESETN_DEFAULT}        \
    NUM_SI=${NUM_SI}                                \
    NUM_MI=${NUM_MI}                                \
    BRAM_DEPTHS="${BRAM_DEPTHS}"                    \
    MAIN_CLOCK_FREQ_MHZ=${MAIN_CLOCK_FREQ_MHZ}      \
    RANGE_CLOCK_DOMAINS="${RANGE_CLOCK_DOMAINS}"    \
    PBUS_NUM_MI=${PBUS_NUM_MI}                      \
    XILINX_ILA=${XILINX_ILA}                        \
    SYNTH_STRATEGY=${SYNTH_STRATEGY}                \
    IMPL_STRATEGY=${IMPL_STRATEGY}                  \
    XILINX_PART_NUMBER=${XILINX_PART_NUMBER}        \
    XILINX_PROJECT_NAME=${XILINX_PROJECT_NAME}      \
    SOC_PROFILE=${SOC_PROFILE}                        \
    XILINX_BOARD_PART=${XILINX_BOARD_PART}          \
    XILINX_HW_SERVER_HOST=${XILINX_HW_SERVER_HOST}  \
    XILINX_HW_SERVER_PORT=${XILINX_HW_SERVER_PORT}  \
    XILINX_FPGA_DEVICE=${XILINX_FPGA_DEVICE}        \
    XILINX_BITSTREAM=${XILINX_BITSTREAM}            \
    XILINX_PROBE_LTX=${XILINX_PROBE_LTX}            \
    IP_LIST_XCI="${IP_LIST_XCI}"                    \
    XILINX_ROOT=${XILINX_ROOT}                      \
    QUESTA_PATH=${QUESTA_PATH}                      \
    GCC_PATH=${GCC_PATH}                            \
    XILINX_SIMLIB_PATH=${XILINX_SIMLIB_PATH}

# Package Vivado command in a single variable
XILINX_VIVADO := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode ${XILINX_VIVADO_MODE}
XILINX_VIVADO_BATCH := ${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode batch
