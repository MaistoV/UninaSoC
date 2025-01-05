#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   TBD

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir
mkdir rtl

# clone repo (Release v5.1.0 Jul 11 2024 (including H extension))
GIT_URL=https://github.com/openhwgroup/cva6.git
GIT_TAG=v5.1.0
CLONE_DIR=cva6
printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} --depth 1 ${CLONE_DIR}
cd ${CLONE_DIR};

# Clone Bender
printf "${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

# Download dependencies (specify Target RTL and FPGA)
printf "${YELLOW}[FETCH_SOURCES] Resolve dependencies with Bender${NC}\n"
./bender checkout
./bender script flist > ../remote.flist
cp Flist.ariane ../local.flist

# Process remote.flist (contains external dependencies)
printf "${YELLOW}[FETCH_SOURCES] Create final rtl file list${NC}\n"
mv ../remote.flist ../rtl.flist

# Add local source that are not included in remote.flist
DIR=$(pwd)
cd ..;

echo "$DIR/core/include/cv64a6_imafdch_sv39_config_pkg.sv" >> rtl.flist
echo "$DIR/core/include/rvfi_types.svh" >> rtl.flist
echo "$DIR/core/include/config_pkg.sv" >> rtl.flist
echo "$DIR/core/cva6_mmu/cva6_mmu.sv" >> rtl.flist
echo "$DIR/core/cva6_mmu/cva6_ptw.sv" >> rtl.flist
echo "$DIR/core/cva6_mmu/cva6_shared_tlb.sv" >> rtl.flist
echo "$DIR/core/cva6_mmu/cva6_tlb.sv" >> rtl.flist
echo "$DIR/common/local/util/ex_trace_item.svh" >> rtl.flist
echo "$DIR/common/local/util/find_first_one.sv" >> rtl.flist
echo "$DIR/common/local/util/hpdcache_sram_1rw.sv" >> rtl.flist
echo "$DIR/common/local/util/hpdcache_sram_wbyteenable_1rw.sv" >> rtl.flist
echo "$DIR/common/local/util/instr_trace_item.svh" >> rtl.flist
echo "$DIR/common/local/util/instr_tracer.sv" >> rtl.flist
echo "$DIR/common/local/util/sram.sv" >> rtl.flist
echo "$DIR/common/local/util/sram_cache.sv" >> rtl.flist
echo "$DIR/common/local/util/tc_sram_fpga_wrapper.sv" >> rtl.flist
echo "$DIR/common/local/util/tc_sram_wrapper.sv" >> rtl.flist
echo "$DIR/common/local/util/tc_sram_wrapper_cache_techno.sv" >> rtl.flist


# Add AXI headers from remote git
remote_line=$(grep -m 1 '\.bender/git/checkouts/axi-' "rtl.flist")
remote_prefix=$(echo "$remote_line" | sed -E 's#(.*\.bender/git/checkouts/axi-[^/]+)/.*#\1#')

echo "$remote_prefix/include/axi/typedef.svh" >> rtl.flist
echo "$remote_prefix/include/axi/assign.svh" >> rtl.flist

# Add Common Cells headers from remote git
remote_line=$(grep -m 1 '\.bender/git/checkouts/common_cells-' "rtl.flist")
remote_prefix=$(echo "$remote_line" | sed -E 's#(.*\.bender/git/checkouts/common_cells-[^/]+)/.*#\1#')

echo "$remote_prefix/include/common_cells/registers.svh" >> rtl.flist
echo "$remote_prefix/include/common_cells/assertions.svh" >> rtl.flist

# Copy all RTL files into rtl dir
printf "${YELLOW}[FETCH_SOURCES] Copy all sources into rtl${NC}\n" s
for rtl_file in $(cat rtl.flist) ; do
    cp $rtl_file rtl
done;

# Loop through all files in the rtl directory
find "rtl" -type f | while read -r FILE; do
    # Use sed to perform replacements
    sed -i \
        -e 's|`include "axi/assign\.svh"|`include "assign.svh"|g' \
        -e 's|`include "axi/typedef\.svh"|`include "typedef.svh"|g' \
        -e 's|`include "common_cells/registers\.svh"|`include "registers.svh"|g' \
        -e 's|`include "common_cells/assertions\.svh"|`include "assertions.svh"|g' \
        "$FILE"
done

# Delete the cloned repo and temporary flist
printf "${YELLOW}[FETCH_SOURCES] Clean all artifacts${NC}\n"
sudo rm -r ${CLONE_DIR}
#rm *.flist
printf "${GREEN}[FETCH_SOURCES] Completed${NC}\n"

#######################################################################



# Needing cva6 configuration file
# Needing axi_typedef.svh?
# Notes on NoC: CVA6 defines the NoC both in the top module parameters AND the top module configuration string. fuck them.
# CVA6 only has one master port?

# Modify Includes
# `include "axi/assign.svh" -> `include "axi_assign.svh"
# `include "axi/typedef.svh -> `include "axi_typedef.svh"
# `include "common_cells/registers.svh -> `include "common_cells_registers.svh"
# `include "common_cells/assertions.svh -> `include "common_cells_assertions.svh"

# AXI `include "axi/assign.svh