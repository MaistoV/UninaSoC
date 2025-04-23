#!/bin/bash
# Description: Build and run HLS host code

# HLS_COMPONENT=custom_hls_gemm_v1_0
# HLS_COMPONENT=custom_hls_gemm_v1_1
# HLS_COMPONENT=custom_hls_conv_naive
# HLS_COMPONENT=custom_hls_conv_opt1
# HLS_COMPONENT=custom_hls_conv_opt2
HLS_COMPONENT=custom_hls_conv_opt3

# Force re-build
# make -C config/ config_ld
make -C sw/SoC/examples/${HLS_COMPONENT}/ clean all && \
make -C hw/xilinx/ xsdb_run_elf ELF_PATH=$(realpath sw/SoC/examples/${HLS_COMPONENT}/bin/${HLS_COMPONENT}.elf)
# # make -C hw/xilinx/ xsdb_run_elf ELF_PATH=$(realpath sw/SoC/examples/blinky/bin/blinky.elf)
# # make -C hw/xilinx/ xsdb_run_elf ELF_PATH=$(realpath sw/SoC/examples/hello_world/bin/hello_world.elf)
# # make -C hw/xilinx/ gdb_run ELF_PATH=$(realpath sw/SoC/examples/${HLS_COMPONENT}/bin/${HLS_COMPONENT}.elf)

# sleep 2
# # Stop
# make -C hw/xilinx/ xsdb_run
