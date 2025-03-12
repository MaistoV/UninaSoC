# Description: Make target for simulation
# TODO: The simulation flow is not yet supported, this file is just a placeholder

sim_compile_simlib:
    ${XILINX_VIVADO_BATCH} -source ${XILINX_SIM_TCL_ROOT}/compile_simlib.tcl

sim_export_%: ${XILINX_IPS_ROOT}/%/questa/compile.do
${XILINX_IPS_ROOT}/%/questa/compile.do: ${XILINX_SIM_IP_ROOT}
    cd ${XILINX_SIMLIB_PATH}; \
    VIVADO_PROJECT=${XILINX_IPS_ROOT}/$*/build/$*.xpr \
    ${XILINX_VIVADO_BATCH} -source ${XILINX_SIM_TCL_ROOT}/export_simulation.tcl

${XILINX_SIM_IP_ROOT}/ips:
    mkdir -p $@


# PHONIES
.PHONY: sim_compile_simlib
