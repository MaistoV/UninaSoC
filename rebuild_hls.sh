
# HLS_COMPONENT=custom_hls_vdotprod
# HLS_COMPONENT=custom_hls_gemm_v1_0
HLS_COMPONENT=custom_hls_gemm_v1_1

# Clean generated sources
make -C hw/units/ clean_${HLS_COMPONENT}
# Rebuild
source hw/units/${HLS_COMPONENT}/assets/rebuild_hls.sh

# Clean IP
make -C hw/xilinx/ clean_ips/${HLS_COMPONENT}.xci
# Rebuild IP
make -C hw/xilinx/ ips/${HLS_COMPONENT}.xci

# Rebuild whole bitstream
# NOTE: Keep -j in case config has been updated
make -C hw/xilinx/ clean bitstream -j 8
