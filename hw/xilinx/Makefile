all: bitstream

# Build bitstream from scratch
XILINX_IP_LIST_XCI := $(foreach IP,${XILINX_IP_LIST},${XILINX_IPS_ROOT}/${IP}/build/${IP}.srcs/sources_1/ip/${IP}/${IP}.xci)
bitstream: ips
	mkdir -p build/${XILINX_PROJECT_NAME}
	mkdir -p build/${XILINX_PROJECT_REPORTS_DIR}
	export XILINX_IP_LIST_XCI=${XILINX_IP_LIST_XCI}; \
	cd build/${XILINX_PROJECT_NAME};	 	\
		${XILINX_VIVADO} 					\
		-mode ${XILINX_VIVADO_MODE} 		\
		-source ${XILIN_ROOT}/build_bitstream.tcl

# Generate ips
XILINX_IP_NAMES ?= $(addsuffix .xci, ${XILINX_IP_LIST})
ips: ${XILINX_IP_NAMES}

# Build single IP
%.xci: ips/%/run.tcl
	@echo "Generating IP $@"
	export IP_BUILD_DIR=${XILINX_IP_ROOT}/$*/build; \
	export IP_NAME=$*;					\
	mkdir -p ${IP_BUILD_DIR}; 			\
	rm -rf   ${IP_BUILD_DIR}/*;			\
	cd 	 	 ${IP_BUILD_DIR}; 			\
	${XILINX_VIVADO} -mode batch \
		-source ../../common/pre_config.tcl \
		-source ../config.tcl				\
		-source ../../common/post_config.tcl

# Open Vivado hardware manager
open_hw_manager:
	${XILINX_VIVADO} -mode ${XILINX_VIVADO_MODE}  \
		-source ${XILINX_TCL_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_TCL_ROOT}/set_ila_trigger.tcl

# Clean up project
clean:
	rm -rf ${XILINX_PROJECT_NAME}

clean_ips:
	rm -rf ${XILIN_ROOT}/ips/*/build