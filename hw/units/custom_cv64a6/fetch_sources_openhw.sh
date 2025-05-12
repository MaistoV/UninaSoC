#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   TBD

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create rtl dir
RTL_DIR=rtl
mkdir ${RTL_DIR}

#######################################
# Fetch CVA6 sources and depencencies #
#######################################

# clone repo (Release v5.1.0 Jul 11 2024 (including H extension))
GIT_URL=https://github.com/openhwgroup/cva6.git
GIT_TAG=v5.1.0
CLONE_DIR=cva6
BENDER_TARGET=cv64a6_imafdch_sv39
printf "${YELLOW}[FETCH_SOURCES] Cloning source repository${NC}\n"
git clone ${GIT_URL} -b ${GIT_TAG} --depth 1 ${CLONE_DIR}
cd ${CLONE_DIR};

# Clone Bender
printf "${YELLOW}[FETCH_SOURCES] Download Bender${NC}\n"
curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh

# Download dependencies (specify Target RTL and FPGA)
printf "${YELLOW}[FETCH_SOURCES] Resolve dependencies with Bender${NC}\n"
./bender checkout
./bender script flist -t ${BENDER_TARGET} -t fpga > ../flist

# Append to flist files not listed by bender
find "$PWD/common/local/util" -type f -name "*.sv" >> ../flist
find "$PWD/core/cva6_mmu" -type f -name "*.sv" >> ../flist
find "$PWD/vendor/pulp-platform/fpga-support/rtl" -type f -name "*.sv" >> ../flist

# Append to flist all the header files
find "$PWD" -type f -name "*.svh" >> ../flist

# Some files have the same name. In this repo, the only conflict is on AXI headers.
DEP_AXI="$(./bender path axi)"
DEP_COMMON_CELLS="$(./bender path common_cells)"

cd ..;

#########################
# Move files to RTL dir #
#########################

# Copy RTL files specified in flist
printf "${YELLOW}[FETCH_SOURCES] Copy all sources into rtl${NC}\n" s
for rtl_file in $(cat flist) ; do
    cp $rtl_file ${RTL_DIR}
done;

# Move and rename AXI headers
for file in ${DEP_AXI}/include/axi/*.svh; do [ -f "$file" ] && cp "$file" "${RTL_DIR}/axi_$(basename "$file")"; done
# Move common cells headers to ensure they are the last to be added
cp ${DEP_COMMON_CELLS}/include/common_cells/*.svh ${RTL_DIR};


#################
# Patch sources #
#################

# Loop through all files in the rtl directory
echo -e "${YELLOW}[PATCH_SOURCES] Patching include paths for flat includes and specific substitutions${NC}"
for rtl_file in ${RTL_DIR}/*; do
    if [[ -f $rtl_file ]]; then
        # Substitute AXI includes
        sed -i "s|\`include \"axi/typedef.svh\"|\`include \"axi_typedef.svh\"|g" $rtl_file
        sed -i "s|\`include \"axi/assign.svh\"|\`include \"axi_assign.svh\"|g" $rtl_file

        # Flatten remaining includes
        sed -i 's#`include "[^/]*/\([^"]*\.svh\)"#`include "\1"#g' $rtl_file
    fi
done

# Selectively patch exe_stage: superscalarity on forwarding signals is not supported
sed -i '/<=/ s/rs1_forwarding_i/rs1_forwarding_i[0]/g' ${RTL_DIR}/ex_stage.sv
sed -i '/<=/ s/rs2_forwarding_i/rs2_forwarding_i[0]/g' ${RTL_DIR}/ex_stage.sv

# Copy updated config
cp assets/cv64a6_imafdch_sv39_config_pkg.sv ${RTL_DIR}/

# Enable synthesis for xilinx sram (from tech cells)
sed -i 's/translate_off/translate_on/g' ${RTL_DIR}/tc_sram_wrapper.sv

# Patch unread.sv to be used by vivado
sed -i '1i `define TARGET_VIVADO' ${RTL_DIR}/unread.sv

####################
# Remove Artifacts #
####################

sudo rm -r ${CLONE_DIR}
rm flist

echo -e "${GREEN}[FETCH_SOURCES] Completed${NC}"