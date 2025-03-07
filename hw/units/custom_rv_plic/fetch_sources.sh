#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>, Valerio Di Domenico <valer.didomenico@studenti.unina.it>
# Description:
#   This script fetches risc-v compliant PLIC sources.
#   Files are mostly fetched from open-titan ips.

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#######################################
# Fetch PLIC sources and depencencies #
#######################################

# Check Python dependencies (hjson requires Python 3.3+). If you need more info, heck OpenTitan doc: https://opentitan.org/book/doc/contributing/style_guides/hjson_usage_style.html
echo -e "${YELLOW}[FETCH_SOURCES] Checking for Python Module hjson ... ${NC}"
python3 -c "import hjson" &>/dev/null || { echo "${RED}hjson module not found, please install it${NC}"; exit 1; }

# Create the rtl directory structure
# Create rtl dir
echo -e "${YELLOW}[FETCH_SOURCES] Creating the rtl directory structure${NC}"
RTL_DIR=rtl
mkdir ${RTL_DIR}

echo -e "${YELLOW}[FETCH_SOURCES] Fetching Open-Titan Peripherals (aiming to PLIC) sources${NC}"

# clone repo (Release v1.8.3 Jul 15 2024)
GIT_URL=https://github.com/pulp-platform/opentitan_peripherals.git
GIT_TAG=v0.4.0
CLONE_DIR=otp
git clone ${GIT_URL} -b ${GIT_TAG} --depth 1 ${CLONE_DIR}
cd ${CLONE_DIR};

# Patch bender file to download latest register_interface version
# This is required as axi_to_reg_v1 is broken, and we need version 2
sed -i 's/version: 0.3.9/version: 0.4.5/' Bender.yml

# Open-Titan peripherals (by PULP) requires a preliminar configuration and patching
# Apply hjson configurations and patches
echo -e "${YELLOW}[FETCH_SOURCES] Configure and Patch${NC}"
make check;
./bender checkout;
DEP_REGISTER_INTERFACE="$(./bender path register_interface)"
DEP_AXI="$(./bender path axi)"
DEP_COMMON_CELLS="$(./bender path common_cells)"
cd ..;

# Move Source Files
echo -e "${YELLOW}[FETCH_SOURCES] Move all RTL files${NC}"
cp ${CLONE_DIR}/src/rv_plic/rtl/* ${RTL_DIR};
cp ${CLONE_DIR}/src/prim/rtl/* ${RTL_DIR};
cp ${CLONE_DIR}/src/prim/prim_pulp_platform/* ${RTL_DIR};

cp ${DEP_REGISTER_INTERFACE}/src/*.sv ${RTL_DIR};
cp ${DEP_REGISTER_INTERFACE}/vendor/lowrisc_opentitan/src/*.sv ${RTL_DIR};
cp ${DEP_AXI}/src/*.sv ${RTL_DIR};
cp ${DEP_COMMON_CELLS}/src/*.sv ${RTL_DIR};

# Move Header Files into flatten representation in rtl
cp ${DEP_COMMON_CELLS}/include/common_cells/*.svh ${RTL_DIR};
for file in ${DEP_REGISTER_INTERFACE}/include/register_interface/*.svh; do [ -f "$file" ] && cp "$file" "${RTL_DIR}/reg_$(basename "$file")"; done
for file in ${DEP_AXI}/include/axi/*.svh; do [ -f "$file" ] && cp "$file" "${RTL_DIR}/axi_$(basename "$file")"; done

sudo rm -rf ${CLONE_DIR};

#################
# Patch sources #
#################

# We need a second step of local patching
# 1 - Remove absolute path in source files in order to allow a flatten source code organization
# 2 . Remove interface definitions as vivado complaints even if interfaces are not instantiated at all
echo -e "${YELLOW}[PATCH_SOURCES] Patching include paths for flat includes and specific substitutions${NC}"
for rtl_file in ${RTL_DIR}/*; do
    if [[ -f $rtl_file ]]; then
        # Flatten includes for common_cells
        sed -i "s|\`include \"common_cells\/|\`include \"|g" $rtl_file

        # Specific substitutions
        sed -i "s|\`include \"axi/typedef.svh\"|\`include \"axi_typedef.svh\"|g" $rtl_file
        sed -i "s|\`include \"axi/assign.svh\"|\`include \"axi_assign.svh\"|g" $rtl_file
        sed -i "s|\`include \"register_interface/typedef.svh\"|\`include \"reg_typedef.svh\"|g" $rtl_file
        sed -i "s|\`include \"register_interface/assign.svh\"|\`include \"reg_assign.svh\"|g" $rtl_file
        sed -i "s|\`include \"prim_assert.sv\"|\`include \"assertions.svh\"|g" $rtl_file

        # Remove interfaces
        sed -i '/module .*_intf/,$d' "$rtl_file"
    fi
done

echo -e "${GREEN}[FETCH_SOURCES] Completed${NC}"
