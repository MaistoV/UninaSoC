# Description: Generate bitsreams for HLS fast prototyping experiments

# Setup
source settings.sh

# Target RTL source
TARGET_UNINASOC_RTL=hw/xilinx/rtl/uninasoc.sv

HLS_CONFIGS=(
    "conv_naive" # First naive version
    "conv_opt1"  # Memory coalescing (AXI bursts)
    "conv_opt2"  # Double buffering
    "conv_opt3"  # Split r/r/w interfaces
    "conv_opt4"  # Frequency scaling
    # "conv_opt5"  # Lower bit-widths (ap_int)
)

# Preliminary builds
make config sw
make units

# For each config
for config in ${HLS_CONFIGS[*]}; do
    # Edit source file
    sed -i -E "s/    localparam string CUSTOM_HLS_VERSION.+/    localparam string CUSTOM_HLS_VERSION = \"$config\";/g" $TARGET_UNINASOC_RTL

    # Enable ILA
    XILINX_ILA=1

    # Change config (if necessary)
    TARGET_CONFIG=config/configs/embedded/config_main_bus.csv
    if [[ "$config" == "conv_opt3" ]]; then
        cp config/configs/embedded/config_main_bus_hls_3intf.csv $TARGET_CONFIG
        # Disable ILA
        XILINX_ILA=0
    elif [[ "$config" == "conv_opt4" ]]; then
        cp config/configs/embedded/config_main_bus_hls_100MHz.csv $TARGET_CONFIG
    else
        cp config/configs/embedded/config_main_bus_base.csv $TARGET_CONFIG
    fi

    # Re-config
    make config
    # Don't re-build IPs
    # touch hw/xilinx/ips/xlnx_uart_axilite.xci
    # touch hw/xilinx/ips/xlnx_main_crossbar.xci
    # touch hw/xilinx/ips/xlnx_peripheral_crossbar.xci
    # Re-build IPs
    make -C hw/xilinx ips -j 8
    # Re-build bitstream
    make -C hw/xilinx clean bitstream XILIN_ILA=$XILINX_ILA

    # Backup bitstream
    BUILD_DIR=hw/xilinx/build
    BACKUP_DIR=hw/xilinx/build_$config
    cp -r $BUILD_DIR $BACKUP_DIR
done


echo "[BUILD] Done!"
find hw/xilinx -name uninasoc.bit