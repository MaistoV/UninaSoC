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
    uint32_t reserved_5 [3];
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
    uint32_t reserved_6 [75];

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
    uint32_t reserved_7 [7];
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

    // TODO: ....
    0x0460 	Reserved

0x0500 	STAT_TX_TOTAL_PACKETS
0x0508 	STAT_TX_TOTAL_GOOD_PACKETS
0x0510 	STAT_TX_TOTAL_BYTES
0x0518 	STAT_TX_TOTAL_GOOD_BYTES
0x0520 	STAT_TX_PACKET_64_BYTES
0x0528 	STAT_TX_PACKET_65_127_BYTES
0x0530 	STAT_TX_PACKET_128_255_BYTES
0x0538 	STAT_TX_PACKET_256_511_BYTES
0x0540 	STAT_TX_PACKET_512_1023_BYTES
0x0548 	STAT_TX_PACKET_1024_1518_BYTES
0x0550 	STAT_TX_PACKET_1519_1522_BYTES
0x0558 	STAT_TX_PACKET_1523_1548_BYTES
0x0560 	STAT_TX_PACKET_1549_2047_BYTES
0x0568 	STAT_TX_PACKET_2048_4095_BYTES
0x0570 	STAT_TX_PACKET_4096_8191_BYTES
0x0578 	STAT_TX_PACKET_8192_9215_BYTES
0x0580 	STAT_TX_PACKET_LARGE
0x0588 	STAT_TX_PACKET_SMALL
0x0590–0x05B0 	Reserved
0x05B8 	STAT_TX_BAD_FCS
0x05C0 	Reserved
0x05C8 	Reserved
0x05D0 	STAT_TX_UNICAST
0x05D8 	STAT_TX_MULTICAST
0x05E0 	STAT_TX_BROADCAST
0x05E8 	STAT_TX_VLAN
0x05F0 	STAT_TX_PAUSE
0x05F8 	STAT_TX_USER_PAUSE
0x0600 	Reserved
0x0608 	STAT_RX_TOTAL_PACKETS
0x0610 	STAT_RX_TOTAL_GOOD_PACKETS
0x0618 	STAT_RX_TOTAL_BYTES
0x0620 	STAT_RX_TOTAL_GOOD_BYTES
0x0628 	STAT_RX_PACKET_64_BYTES
0x0630 	STAT_RX_PACKET_65_127_BYTES
0x0638 	STAT_RX_PACKET_128_255_BYTES
0x0640 	STAT_RX_PACKET_256_511_BYTES
0x0648 	STAT_RX_PACKET_512_1023_BYTES
0x0650 	STAT_RX_PACKET_1024_1518_BYTES
0x0658 	STAT_RX_PACKET_1519_1522_BYTES
0x0660 	STAT_RX_PACKET_1523_1548_BYTES
0x0668 	STAT_RX_PACKET_1549_2047_BYTES
0x0670 	STAT_RX_PACKET_2048_4095_BYTES
0x0678 	STAT_RX_PACKET_4096_8191_BYTES
0x0680 	STAT_RX_PACKET_8192_9215_BYTES
0x0688 	STAT_RX_PACKET_LARGE
0x0690 	STAT_RX_PACKET_SMALL
0x0698 	STAT_RX_UNDERSIZE
0x06A0 	STAT_RX_FRAGMENT
0x06A8 	STAT_RX_OVERSIZE
0x06B0 	STAT_RX_TOOLONG
0x06B8 	STAT_RX_JABBER
0x06C0 	STAT_RX_BAD_FCS
0x06C8 	STAT_RX_PACKET_BAD_FCS
0x06D0 	STAT_RX_STOMPED_FCS
0x06D8 	STAT_RX_UNICAST
0x06E0 	STAT_RX_MULTICAST
0x06E8 	STAT_RX_BROADCAST
0x06F0 	STAT_RX_VLAN
0x06F8 	STAT_RX_PAUSE
0x0700 	STAT_RX_USER_PAUSE
0x0708 	STAT_RX_INRANGEERR
0x0710 	STAT_RX_TRUNCATED
0x0718 	STAT_OTN_TX_JABBER
0x0720 	STAT_OTN_TX_OVERSIZE
0x0728 	STAT_OTN_TX_UNDERSIZE
0x0730 	STAT_OTN_TX_TOOLONG
0x0738 	STAT_OTN_TX_FRAGMENT
0x0740 	STAT_OTN_TX_PACKET_BAD_FCS
0x0748 	STAT_OTN_TX_STOMPED_FCS
0x0750 	STAT_OTN_TX_BAD_CODE
0x0758–0x07FF 	Reserved

// RSFEC Config Address Space
0x1000 	RSFEC_CONFIG_INDICATION_CORRECTION

0x1004 	STAT_RSFEC_STATUS_REG


0x1008 	STAT_RX_RSFEC_CORRECTED_CW_INC
0x1010 	STAT_RX_RSFEC_UNCORRECTED_CW_INC
0x1018 	STAT_RSFEC_LANE_MAPPING_REG
0x101C 	STAT_RX_RSFEC_ERR_COUNT0_INC
0x1024 	STAT_RX_RSFEC_ERR_COUNT1_INC
0x102C 	STAT_RX_RSFEC_ERR_COUNT2_INC
0x1034 	STAT_RX_RSFEC_ERR_COUNT3_INC
0x103C 	STAT_RX_RSFEC_CW_INC

0x1044 	STAT_TX_OTN_RSFEC_STATUS_REG
        Some RESERVED...

0x107C 	RSFEC_CONFIG_ENABLE

} xlnx_cmac_t;

// AXIS FIFO CSR struct
typedef struct {

} xlnx_axis_fifo_t;

#endif // XLNX_CMAC_H
