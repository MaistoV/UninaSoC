

# Description: Make target to build Xilinx IPs and bitstream

# Build bitstream from scratch
bitstream: ips
	mkdir -p ${XILINX_PROJECT_REPORTS_DIR}
	cd ${XILINX_PROJECT_BUILD_DIR}; \
	${XILINX_VIVADO} -source ${XILINX_SYNTH_TCL_ROOT}/build_bitstream.tcl

# Generate ips
IP_NAMES ?= $(addprefix ips/, $(addsuffix .xci, ${IP_LIST}))
ips: ${IP_NAMES}

# Build single IP
ips/%.xci: IP_NAME=$*
ips/%.xci: IP_DIR=$(firstword $(shell find ${XILINX_IPS_ROOT} -name '$*'))
ips/%.xci: IP_BUILD_DIR=${IP_DIR}/build
# For custom IPs, also depend on RTL wrapper
ips/custom_%.xci: ${HW_UNITS_ROOT}/%/custom_top_wrapper.sv
ips/%.xci: ${XILINX_IPS_ROOT}/*/%/config.tcl
	mkdir -p ${IP_BUILD_DIR};                                \
	cd	   ${IP_BUILD_DIR};                                  \
	export IP_DIR=${IP_DIR};                                 \
	export IP_PRJ_NAME=${IP_NAME}_prj;                       \
	export IP_NAME=${IP_NAME};                               \
	${XILINX_VIVADO_BATCH}                                   \
		-source ${XILINX_IPS_ROOT}/common/tcl/pre_config.tcl \
		-source ${IP_DIR}/config.tcl                         \
		-source ${XILINX_IPS_ROOT}/common/tcl/post_config.tcl
	touch $@