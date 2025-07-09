// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description:
//  This file defines the API to adoperate the CMAC subsystem

#ifndef XLNX_CMAC_H
#define XLNX_CMAC_H

#include <stdint.h>

// Import linker script symbols
extern const volatile uint32_t _peripheral_CMAC_CSR_start;
extern const volatile uint32_t _peripheral_m_acc_start;

// Base addresses

// CMAC and FIFO CSR
#define CMAC_CSR_BASEADDR      ((uintptr_t)&_peripheral_CMAC_CSR_start)
#define AXIS_FIFO_CSR_BASEADDR (CMAC_CSR_BASEADDR + 0x10000)

// DATA
#define AXIS_FIFO_WR_DATA      ((uintptr_t)&_peripheral_m_acc_start)
#define AXIS_FIFO_RD_DATA      (AXIS_FIFO_WR_DATA + 0x1000)


// CMAC CSR struct from AMD PG203 (product guide)
typedef struct {
    // General registers
    uint32_t gt_reset_reg;
    uint32_t reset_reg;
    uint32_t switch_core_mode_reg;
    uint32_t configuration_tx_reg1;
    uint32_t reserved_0;
    uint32_t configuration_rx_reg1;
    uint32_t reserved_1 [2];
    uint32_t core_mode_reg;
    uint32_t core_version_reg;
    uint32_t reserved_2;

    // Flow control TX
    uint32_t configuration_tx_bip_override;
    uint32_t configuration_tx_flow_control_control_reg1;
    uint32_t configuration_tx_flow_control_refresh_reg1;
    uint32_t configuration_tx_flow_control_refresh_reg2;
    uint32_t configuration_tx_flow_control_refresh_reg3;
    uint32_t configuration_tx_flow_control_refresh_reg4;
    uint32_t configuration_tx_flow_control_refresh_reg5;
    uint32_t configuration_tx_flow_control_quanta_reg1;
    uint32_t configuration_tx_flow_control_quanta_reg2;
    uint32_t configuration_tx_flow_control_quanta_reg3;
    uint32_t configuration_tx_flow_control_quanta_reg4;
    uint32_t configuration_tx_flow_control_quanta_reg5;
    uint32_t configuration_tx_otn_pkt_len_reg;
    uint32_t configuration_tx_otn_ctl_reg;
    uint32_t reserved_3 [8];

    // Flow control RX
    uint32_t configuration_rx_flow_control_control_reg1;
    uint32_t configuration_rx_flow_control_control_reg2;
    uint32_t reserved_4;

    // Configuration
    uint32_t gt_loopback_reg;
    uint32_t reserved_5 [3];       // TODO: check this
    uint32_t configuration_an_control_reg1;
    uint32_t configuration_an_control_reg2;
    uint32_t configuration_an_ability;
    uint32_t configuration_lt_control_reg1;
    uint32_t configuration_lt_trained_reg;
    uint32_t configuration_lt_preset_reg;
    uint32_t configuration_lt_init_reg;
    uint32_t configuration_lt_seed_reg0;
    uint32_t configuration_lt_seed_reg1;
    uint32_t configuration_lt_coefficient_reg0;
    uint32_t configuration_lt_coefficient_reg1;
    uint32_t user_reg0;
    uint32_t reserved_6 [75];    // TODO check this

    // Statistics and status registers
    uint32_t stat_tx_status_reg;
    uint32_t stat_rx_status_reg;
    uint32_t stat_status_reg1;
    uint32_t stat_rx_block_lock_reg;
    uint32_t stat_rx_lane_sync_reg;
    uint32_t stat_rx_lane_sync_err_reg;
    uint32_t stat_rx_am_err_reg;
    uint32_t stat_rx_am_len_err_reg;
    uint32_t stat_rx_am_repeat_err_reg;
    uint32_t stat_rx_pcsl_demuxed_reg;
    uint32_t stat_rx_pcs_lane_num_reg1;
    uint32_t stat_rx_pcs_lane_num_reg2;
    uint32_t stat_rx_pcs_lane_num_reg3;
    uint32_t stat_rx_pcs_lane_num_reg4;
    uint32_t stat_rx_bip_override_reg;
    uint32_t stat_tx_otn_status_reg;
    uint32_t reserved_7 [7]; // TODO check this
    uint32_t stat_an_status_reg;
    uint32_t stat_an_ability_reg;
    uint32_t stat_an_link_ctl_reg1;
    uint32_t stat_lt_status_reg1;
    uint32_t stat_lt_status_reg2;
    uint32_t stat_lt_status_reg3;
    uint32_t stat_lt_status_reg4;
    uint32_t stat_lt_coefficient0_reg;
    uint32_t stat_lt_coefficient1_reg;
    uint32_t stat_an_link_ctl_reg2;
    uint32_t reserved_8 [12];

    // Histogram/Counter Registers
    uint32_t tick_reg_lsb;
    uint32_t tick_reg_msb;
    uint32_t stat_cycle_count_lsb;
    uint32_t stat_cycle_count_msb;
    uint32_t stat_rx_bip_err_0_lsb;
    uint32_t stat_rx_bip_err_0_msb;
    uint32_t stat_rx_bip_err_1_lsb;
    uint32_t stat_rx_bip_err_1_msb;
    uint32_t stat_rx_bip_err_2_lsb;
    uint32_t stat_rx_bip_err_2_msb;
    uint32_t stat_rx_bip_err_3_lsb;
    uint32_t stat_rx_bip_err_3_msb;
    uint32_t stat_rx_bip_err_4_lsb;
    uint32_t stat_rx_bip_err_4_msb;
    uint32_t stat_rx_bip_err_5_lsb;
    uint32_t stat_rx_bip_err_5_msb;
    uint32_t stat_rx_bip_err_6_lsb;
    uint32_t stat_rx_bip_err_6_msb;
    uint32_t stat_rx_bip_err_7_lsb;
    uint32_t stat_rx_bip_err_7_msb;
    uint32_t stat_rx_bip_err_8_lsb;
    uint32_t stat_rx_bip_err_8_msb;
    uint32_t stat_rx_bip_err_9_lsb;
    uint32_t stat_rx_bip_err_9_msb;
    uint32_t stat_rx_bip_err_10_lsb;
    uint32_t stat_rx_bip_err_10_msb;
    uint32_t stat_rx_bip_err_11_lsb;
    uint32_t stat_rx_bip_err_11_msb;
    uint32_t stat_rx_bip_err_12_lsb;
    uint32_t stat_rx_bip_err_12_msb;
    uint32_t stat_rx_bip_err_13_lsb;
    uint32_t stat_rx_bip_err_13_msb;
    uint32_t stat_rx_bip_err_14_lsb;
    uint32_t stat_rx_bip_err_14_msb;
    uint32_t stat_rx_bip_err_15_lsb;
    uint32_t stat_rx_bip_err_15_msb;
    uint32_t stat_rx_bip_err_16_lsb;
    uint32_t stat_rx_bip_err_16_msb;
    uint32_t stat_rx_bip_err_17_lsb;
    uint32_t stat_rx_bip_err_17_msb;
    uint32_t stat_rx_bip_err_18_lsb;
    uint32_t stat_rx_bip_err_18_msb;
    uint32_t stat_rx_bip_err_19_lsb;
    uint32_t stat_rx_bip_err_19_msb;

    uint32_t stat_rx_framing_err_0_lsb;
    uint32_t stat_rx_framing_err_0_msb;
    uint32_t stat_rx_framing_err_1_lsb;
    uint32_t stat_rx_framing_err_1_msb;
    uint32_t stat_rx_framing_err_2_lsb;
    uint32_t stat_rx_framing_err_2_msb;
    uint32_t stat_rx_framing_err_3_lsb;
    uint32_t stat_rx_framing_err_3_msb;
    uint32_t stat_rx_framing_err_4_lsb;
    uint32_t stat_rx_framing_err_4_msb;
    uint32_t stat_rx_framing_err_5_lsb;
    uint32_t stat_rx_framing_err_5_msb;
    uint32_t stat_rx_framing_err_6_lsb;
    uint32_t stat_rx_framing_err_6_msb;
    uint32_t stat_rx_framing_err_7_lsb;
    uint32_t stat_rx_framing_err_7_msb;
    uint32_t stat_rx_framing_err_8_lsb;
    uint32_t stat_rx_framing_err_8_msb;
    uint32_t stat_rx_framing_err_9_lsb;
    uint32_t stat_rx_framing_err_9_msb;
    uint32_t stat_rx_framing_err_10_lsb;
    uint32_t stat_rx_framing_err_10_msb;
    uint32_t stat_rx_framing_err_11_lsb;
    uint32_t stat_rx_framing_err_11_msb;
    uint32_t stat_rx_framing_err_12_lsb;
    uint32_t stat_rx_framing_err_12_msb;
    uint32_t stat_rx_framing_err_13_lsb;
    uint32_t stat_rx_framing_err_13_msb;
    uint32_t stat_rx_framing_err_14_lsb;
    uint32_t stat_rx_framing_err_14_msb;
    uint32_t stat_rx_framing_err_15_lsb;
    uint32_t stat_rx_framing_err_15_msb;
    uint32_t stat_rx_framing_err_16_lsb;
    uint32_t stat_rx_framing_err_16_msb;
    uint32_t stat_rx_framing_err_17_lsb;
    uint32_t stat_rx_framing_err_17_msb;
    uint32_t stat_rx_framing_err_18_lsb;
    uint32_t stat_rx_framing_err_18_msb;
    uint32_t stat_rx_framing_err_19_lsb;
    uint32_t stat_rx_framing_err_19_msb;
    uint32_t reserved_9 [6];
    uint32_t stat_rx_bad_code_lsb;
    uint32_t stat_rx_bad_code_msb;
    uint32_t reserved_10 [14];
    uint32_t stat_tx_frame_error_lsb;
    uint32_t stat_tx_frame_error_msb;

    uint32_t reserved_11 [40]; // Check this 0x0460 to 0x04FC

    uint32_t stat_tx_total_packets_lsb;
    uint32_t stat_tx_total_packets_msb;
    uint32_t stat_tx_total_good_packets_lsb;
    uint32_t stat_tx_total_good_packets_msb;
    uint32_t stat_tx_total_bytes_lsb;
    uint32_t stat_tx_total_bytes_msb;
    uint32_t stat_tx_total_good_bytes_lsb;
    uint32_t stat_tx_total_good_bytes_msb;
    uint32_t stat_tx_packet_64_bytes_lsb;
    uint32_t stat_tx_packet_64_bytes_msb;
    uint32_t stat_tx_packet_65_127_bytes_lsb;
    uint32_t stat_tx_packet_65_127_bytes_msb;
    uint32_t stat_tx_packet_128_255_bytes_lsb;
    uint32_t stat_tx_packet_128_255_bytes_msb;
    uint32_t stat_tx_packet_256_511_bytes_lsb;
    uint32_t stat_tx_packet_256_511_bytes_msb;
    uint32_t stat_tx_packet_512_1023_bytes_lsb;
    uint32_t stat_tx_packet_512_1023_bytes_msb;
    uint32_t stat_tx_packet_1024_1518_bytes_lsb;
    uint32_t stat_tx_packet_1024_1518_bytes_msb;
    uint32_t stat_tx_packet_1519_1522_bytes_lsb;
    uint32_t stat_tx_packet_1519_1522_bytes_msb;
    uint32_t stat_tx_packet_1523_1548_bytes_lsb;
    uint32_t stat_tx_packet_1523_1548_bytes_msb;
    uint32_t stat_tx_packet_1549_2047_bytes_lsb;
    uint32_t stat_tx_packet_1549_2047_bytes_msb;
    uint32_t stat_tx_packet_2048_4095_bytes_lsb;
    uint32_t stat_tx_packet_2048_4095_bytes_msb;
    uint32_t stat_tx_packet_4096_8191_bytes_lsb;
    uint32_t stat_tx_packet_4096_8191_bytes_msb;
    uint32_t stat_tx_packet_8192_9215_bytes_lsb;
    uint32_t stat_tx_packet_8192_9215_bytes_msb;
    uint32_t stat_tx_packet_large_lsb;
    uint32_t stat_tx_packet_large_msb;
    uint32_t stat_tx_packet_small_lsb;
    uint32_t stat_tx_packet_small_msb;

    uint32_t reserved_12 [10];

    uint32_t stat_tx_bad_fcs_lsb;
    uint32_t stat_tx_bad_fcs_msb;

    uint32_t reserved_13 [4];

    uint32_t stat_tx_unicast_lsb;
    uint32_t stat_tx_unicast_msb;
    uint32_t stat_tx_multicast_lsb;
    uint32_t stat_tx_multicast_msb;
    uint32_t stat_tx_broadcast_lsb;
    uint32_t stat_tx_broadcast_msb;
    uint32_t stat_tx_vlan_lsb;
    uint32_t stat_tx_vlan_msb;
    uint32_t stat_tx_pause_lsb;
    uint32_t stat_tx_pause_msb;
    uint32_t stat_tx_user_pause_lsb;
    uint32_t stat_tx_user_pause_msb;

    uint32_t reserved_14 [2]

    uint32_t stat_rx_total_packets_lsb;
    uint32_t stat_rx_total_packets_msb;
    uint32_t stat_rx_total_good_packets_lsb;
    uint32_t stat_rx_total_good_packets_msb;
    uint32_t stat_rx_total_bytes_lsb;
    uint32_t stat_rx_total_bytes_msb;
    uint32_t stat_rx_total_good_bytes_lsb;
    uint32_t stat_rx_total_good_bytes_msb;
    uint32_t stat_rx_packet_64_bytes_lsb;
    uint32_t stat_rx_packet_64_bytes_msb;
    uint32_t stat_rx_packet_65_127_bytes_lsb;
    uint32_t stat_rx_packet_65_127_bytes_msb;
    uint32_t stat_rx_packet_128_255_bytes_lsb;
    uint32_t stat_rx_packet_128_255_bytes_msb;
    uint32_t stat_rx_packet_256_511_bytes_lsb;
    uint32_t stat_rx_packet_256_511_bytes_msb;
    uint32_t stat_rx_packet_512_1023_bytes_lsb;
    uint32_t stat_rx_packet_512_1023_bytes_msb;
    uint32_t stat_rx_packet_1024_1518_bytes_lsb;
    uint32_t stat_rx_packet_1024_1518_bytes_msb;
    uint32_t stat_rx_packet_1519_1522_bytes_lsb;
    uint32_t stat_rx_packet_1519_1522_bytes_msb;
    uint32_t stat_rx_packet_1523_1548_bytes_lsb;
    uint32_t stat_rx_packet_1523_1548_bytes_msb;
    uint32_t stat_rx_packet_1549_2047_bytes_lsb;
    uint32_t stat_rx_packet_1549_2047_bytes_msb;
    uint32_t stat_rx_packet_2048_4095_bytes_lsb;
    uint32_t stat_rx_packet_2048_4095_bytes_msb;
    uint32_t stat_rx_packet_4096_8191_bytes_lsb;
    uint32_t stat_rx_packet_4096_8191_bytes_msb;
    uint32_t stat_rx_packet_8192_9215_bytes_lsb;
    uint32_t stat_rx_packet_8192_9215_bytes_msb;
    uint32_t stat_rx_packet_large_lsb;
    uint32_t stat_rx_packet_large_msb;
    uint32_t stat_rx_packet_small_lsb;
    uint32_t stat_rx_packet_small_msb;
    uint32_t stat_rx_undersize_lsb;
    uint32_t stat_rx_undersize_msb;
    uint32_t stat_rx_fragment_lsb;
    uint32_t stat_rx_fragment_msb;
    uint32_t stat_rx_oversize_lsb;
    uint32_t stat_rx_oversize_msb;
    uint32_t stat_rx_toolong_lsb;
    uint32_t stat_rx_toolong_msb;
    uint32_t stat_rx_jabber_lsb;
    uint32_t stat_rx_jabber_msb;
    uint32_t stat_rx_bad_fcs_lsb;
    uint32_t stat_rx_bad_fcs_msb;
    uint32_t stat_rx_packet_bad_fcs_lsb;
    uint32_t stat_rx_packet_bad_fcs_msb;
    uint32_t stat_rx_stomped_fcs_lsb;
    uint32_t stat_rx_stomped_fcs_msb;
    uint32_t stat_rx_unicast_lsb;
    uint32_t stat_rx_unicast_msb;
    uint32_t stat_rx_multicast_lsb;
    uint32_t stat_rx_multicast_msb;

    uint32_t stat_rx_broadcast_lsb;
    uint32_t stat_rx_broadcast_msb;
    uint32_t stat_rx_vlan_lsb;
    uint32_t stat_rx_vlan_msb;
    uint32_t stat_rx_pause_lsb;
    uint32_t stat_rx_pause_msb;
    uint32_t stat_rx_user_pause_lsb;
    uint32_t stat_rx_user_pause_msb;
    uint32_t stat_rx_inrangeerr_lsb;
    uint32_t stat_rx_inrangeerr_msb;
    uint32_t stat_rx_truncated_lsb;
    uint32_t stat_rx_truncated_msb;

    uint32_t stat_otn_tx_jabber_lsb;
    uint32_t stat_otn_tx_jabber_msb;
    uint32_t stat_otn_tx_oversize_lsb;
    uint32_t stat_otn_tx_oversize_msb;
    uint32_t stat_otn_tx_undersize_lsb;
    uint32_t stat_otn_tx_undersize_msb;
    uint32_t stat_otn_tx_toolong_lsb;
    uint32_t stat_otn_tx_toolong_msb;
    uint32_t stat_otn_tx_fragment_lsb;
    uint32_t stat_otn_tx_fragment_msb;
    uint32_t stat_otn_tx_packet_bad_fcs_lsb;
    uint32_t stat_otn_tx_packet_bad_fcs_msb;
    uint32_t stat_otn_tx_stomped_fcs_lsb;
    uint32_t stat_otn_tx_stomped_fcs_msb;
    uint32_t stat_otn_tx_bad_code_lsb;
    uint32_t stat_otn_tx_bad_code_msb;

    uint32_t reserved_15 [170]; // 0x0758–0x07FF (0x09FC) TODO check this

    // RSFEC Config Address Space 0x1000
    uint32_t rsfec_config_indication_correction;
    uint32_t stat_rsfect_status_reg;
    uint32_t stat_rx_rsfec_corrected_cw_inc_lsb;
    uint32_t stat_rx_rsfec_corrected_cw_inc_msb;
    uint32_t stat_rx_rsfec_uncorrected_cw_inc_lsb;
    uint32_t stat_rx_rsfec_uncorrected_cw_inc_msb;
    uint32_t stat_rsfec_lane_mapping_reg;
    uint32_t stat_rx_rsfec_err_count0_inc_lsb;
    uint32_t stat_rx_rsfec_err_count0_inc_msb;
    uint32_t stat_rx_rsfec_err_count1_inc_lsb;
    uint32_t stat_rx_rsfec_err_count1_inc_msb;
    uint32_t stat_rx_rsfec_err_count2_inc_lsb;
    uint32_t stat_rx_rsfec_err_count2_inc_msb;
    uint32_t stat_rx_rsfec_err_count3_inc_lsb;
    uint32_t stat_rx_rsfec_err_count3_inc_msb;
    uint32_t stat_rx_rsfec_cw_inc_lsb;
    uint32_t stat_rx_rsfec_cw_inc_msb;
    uint32_t stat_tx_otn_rsfec_status_reg;    // TODO: check the register size. Lsb and msb (64 bit) or just 32 bit

    uint32_t reserved_16 [13];

    uint32_t rsfec_config_enable;

} xlnx_cmac_t;

// AXIS FIFO CSR struct
typedef struct {

} xlnx_axis_fifo_t;

#endif // XLNX_CMAC_H
