#!/bin/bash
# Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
# Description:
# This script downloads specific files and organizes them into an rtl directory structure.

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create the rtl directory structure
# Create rtl dir
RTL_DIR=rtl
mkdir ${RTL_DIR}

echo -e "${YELLOW}[FETCH_SOURCES] Creating the rtl directory structure${NC}"

# List of files to download and their destinations
declare -A FILES=(
    # Top-level rtl files
    ["rtl/axi_pkg.sv"]="https://raw.githubusercontent.com/pulp-platform/axi/master/src/axi_pkg.sv"
    ["rtl/axi_to_reg_v2.sv"]="https://raw.githubusercontent.com/pulp-platform/register_interface/3a7b9e28d671ab646e25338caa89bb0c22dfcae8/src/axi_to_reg_v2.sv"
    ["rtl/periph_to_reg.sv"]="https://raw.githubusercontent.com/pulp-platform/register_interface/3a7b9e28d671ab646e25338caa89bb0c22dfcae8/src/periph_to_reg.sv"
    ["rtl/prim_max_tree.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/cd3153de2783abd3d03d0595e6c4b32413c62f14/src/prim/rtl/prim_max_tree.sv"
    ["rtl/reg_demux.sv"]="https://raw.githubusercontent.com/pulp-platform/register_interface/master/src/reg_demux.sv"
    ["rtl/reg_mux.sv"]="https://raw.githubusercontent.com/pulp-platform/register_interface/master/src/reg_mux.sv"
    ["rtl/rv_plic.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/master/src/rv_plic/rtl/rv_plic.sv"
    ["rtl/rv_plic_gateway.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/master/src/rv_plic/rtl/rv_plic_gateway.sv"
    ["rtl/rv_plic_reg_pkg.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/master/src/rv_plic/rtl/rv_plic_reg_pkg.sv"
    ["rtl/rv_plic_target.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/master/src/rv_plic/rtl/rv_plic_target.sv"
    ["rtl/rv_plic_reg_top.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/master/src/rv_plic/rtl/rv_plic_reg_top.sv"
    ["rtl/stream_arbiter.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/master/src/stream_arbiter.sv"
    ["rtl/stream_arbiter_flushable.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/master/src/stream_arbiter_flushable.sv"
    ["rtl/prim_flop_2sync.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan_peripherals/cd3153de2783abd3d03d0595e6c4b32413c62f14/src/prim/rtl/prim_flop_2sync.sv"
    ["rtl/prim_subreg.sv"]="https://raw.githubusercontent.com/pulp-platform/croc/8636d52bcb5572a74739b95e10d1ddfde9c2547e/rtl/register_interface/lowrisc_opentitan/prim_subreg.sv"
    ["rtl/prim_subreg_ext.sv"]="https://raw.githubusercontent.com/pulp-platform/rv_plic/5b5c5a4c1c15c3d7bb833071d344b2c2bc5f599d/rtl/prim_subreg_ext.sv"
    ["rtl/rr_arb_tree.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/rr_arb_tree.sv"
    ["rtl/axi_to_detailed_mem.sv"]="https://raw.githubusercontent.com/pulp-platform/axi/853ede23b2a9837951b74dbdc6d18c3eef5bac7d/src/axi_to_detailed_mem.sv"
    ["rtl/lzc.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/lzc.sv"
    ["rtl/spill_register.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/spill_register.sv"
    ["rtl/prim_subreg_arb.sv"]="https://raw.githubusercontent.com/pulp-platform/croc/8636d52bcb5572a74739b95e10d1ddfde9c2547e/rtl/register_interface/lowrisc_opentitan/prim_subreg_arb.sv"
    ["rtl/cf_math_pkg.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/cf_math_pkg.sv"
    ["rtl/stream_mux.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_mux.sv"
    ["rtl/stream_fork_dynamic.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_fork_dynamic.sv"
    ["rtl/stream_fork.sv"]="https://raw.githubusercontent.com/pulp-platform/hero/c8481a930a15a385d4f58f519bed83d2e75e2a73/hardware/deps/common_cells/src/stream_fork.sv"
    ["rtl/stream_fifo.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_fifo.sv"
    ["rtl/stream_to_mem.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_to_mem.sv"
    ["rtl/mem_to_banks_detailed.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/mem_to_banks_detailed.sv"
    ["rtl/stream_join.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_join.sv"
    ["rtl/spill_register_flushable.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/spill_register_flushable.sv"
    ["rtl/fifo_v3.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/fifo_v3.sv"
    ["rtl/stream_join_dynamic.sv"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/src/stream_join_dynamic.sv"
    ["rtl/prim_flop.sv"]="https://raw.githubusercontent.com/pulp-platform/ibex/5693d7da3264f96e52b05a496cf447fe532606f7/dv/uvm/core_ibex/common/prim/prim_flop.sv"
    ["rtl/prim_generic_flop.sv"]="https://raw.githubusercontent.com/pulp-platform/opentitan/0755bed76b736148f4149e58500fbadd117972c9/hw/ip/prim_generic/rtl/prim_generic_flop.sv"
    ["rtl/axi_typedef.svh"]="https://raw.githubusercontent.com/pulp-platform/axi/master/include/axi/typedef.svh"
    ["rtl/axi_assign.svh"]="https://raw.githubusercontent.com/pulp-platform/axi/853ede23b2a9837951b74dbdc6d18c3eef5bac7d/include/axi/assign.svh"
    ["rtl/reg_typedef.svh"]="https://raw.githubusercontent.com/pulp-platform/register_interface/master/include/register_interface/typedef.svh"
    ["rtl/reg_assign.svh"]="https://raw.githubusercontent.com/pulp-platform/register_interface/3a7b9e28d671ab646e25338caa89bb0c22dfcae8/include/register_interface/assign.svh"
    ["rtl/assertions.svh"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/include/common_cells/assertions.svh"
    ["rtl/registers.svh"]="https://raw.githubusercontent.com/pulp-platform/common_cells/554ebbcdd3d4d55f9d94dbee47f957af93a835a8/include/common_cells/registers.svh"
            
    )

# Download files
echo -e "${YELLOW}[FETCH_SOURCES] Downloading files${NC}"
for dest in "${!FILES[@]}"; do
    url=${FILES[$dest]}
    echo -e "${YELLOW}[FETCH_SOURCES] Downloading ${url} -> ${dest}${NC}"
    curl -L $url -o $dest
done

# Patch files for flat includes and specific substitutions
echo -e "${YELLOW}[PATCH_SOURCES] Patching include paths for flat includes and specific substitutions${NC}"
for rtl_file in ${RTL_DIR}/*; do
    if [[ -f $rtl_file ]]; then
        echo -e "${YELLOW}[PATCH_SOURCES] Patching file: $rtl_file${NC}"
        # Flatten includes for common_cells
        sed -i "s|\`include \"common_cells\/|\`include \"|g" $rtl_file
        
        # Specific substitutions
        sed -i "s|\`include \"axi/typedef.svh\"|\`include \"axi_typedef.svh\"|g" $rtl_file
        sed -i "s|\`include \"axi/assign.svh\"|\`include \"axi_assign.svh\"|g" $rtl_file
        sed -i "s|\`include \"register_interface/typedef.svh\"|\`include \"reg_typedef.svh\"|g" $rtl_file
        sed -i "s|\`include \"register_interface/assign.svh\"|\`include \"reg_assign.svh\"|g" $rtl_file
        sed -i "s|\`include \"prim_assert.sv\"|\`include \"assertions.svh\"|g" $rtl_file
    fi
done

echo -e "${GREEN}[FETCH_SOURCES] Completed${NC}"
