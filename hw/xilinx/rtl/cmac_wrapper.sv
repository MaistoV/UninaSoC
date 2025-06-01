// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: CMAC wrapper ... TODO
//
//
//
//
//                    ________
//                   |        | AXI4 512b   _____________   AXI4 32b    ___________   AXI Lite 32b                                                         ________
//                   |        |  250 MHz   |             |   250 MHz   |           |    250 MHz                                                           |        |
//                   |        |----------->| Dwidth conv |------------>| Prot conv |--------------------------------------------------------------------->|        |
//                   |        |            |_____________|             |___________|                                                                      |        |
// AXI4 512b 250 MHz |  AXI4  |                                                                                                                           |        | QSFP RX
//  ( from HBUS )    |  XBAR  | AXI4 512b   ____________   AXI4 512b    _____________   AXI4 32b    ___________  AXI Lite 32b   ____________   AXIS RX    |        |<---------
//------------------>|        |  250 MHz   |            |  322.26 MHz  |             | 322.26 MHz  |           |  322.26 MHz   |            | 322.26 MHz  |  CMAC  |
//                   |        |----------->| Clock conv |------------->| Dwidth conv |------------>| Prot conv |-------------->|            |<------------|        | QSFP TX
//                   |        |            |____________|              |_____________|             |___________|               | AXI Stream |             |        |--------->
//                   |        | AXI4 512b   ____________   AXI4 512b                                                           |    FIFO    |  AXIS TX    |        |
//                   |        |  250 MHz   |            |  322.26 MHz                                                          |            | 322.26 MHz  |        |
//                   |        |----------->| Clock conv |--------------------------------------------------------------------->|            |------------>|        |
//                   |________|            |____________|                                                                      |____________|             |________|
//                                                                       __________________                                           |
//                                                                      |                  |          interrupt                       |
//<---------------------------------------------------------------------| CDC Synchronizer |<-----------------------------------------|
//                                                                      |__________________|
//
//



`include "uninasoc_axi.svh"
`include "uninasoc_qsfp.svh"

module cmac_wrapper (

    // QSFP clock and reset
    input logic qsfp0_156mhz_clock_p_i,    // Positive edge of the clock at 156 MHz for the QSFP port 0
    input logic qsfp0_156mhz_clock_n_i,    // Negative edge of the clock at 156 MHz for the QSFP port 0



    `DEFINE_QSFP_PORTS(x)

);





    // AXIS bus for data transmission from the AXIS FIFO to the CMAC
    `DECLARE_AXIS_BUS(tx_fifo_to_cmac);

    // AXIS bus for data reception from the CMAC to the AXIS FIFO
    `DECLARE_AXIS_BUS(rx_cmac_to_fifo);

    // AXI Lite bus for accessing control and status registers of the CMAC
    `DECLARE_AXILITE_BUS(csr_cmac_prot_conv_to_cmac);


    xlnx_cmac cmac_u (


        // GT ref clock 156.25 MHz differential
        .gt_ref_clk_n                        ( qsfp0_156mhz_clock_n_i      ),
        .gt_ref_clk_p                        ( qsfp0_156mhz_clock_p_i      ),

        // GT ports (to the physical pin) 4 differential lines for each direction (rx and tx)
        .gt_rxn_in                           ( qsfpx_rxp_i                 ),
        .gt_rxp_in                           ( qsfpx_rxp_i                 ),
        .gt_txn_out                          ( qsfpx_txn_o                 ),
        .gt_txp_out                          ( qsfpx_txp_o                 ),

        // AXIS TX interface
        .tx_axis_tdata                       ( tx_fifo_to_cmac_axis_tdata  ),
        .tx_axis_tkeep                       ( tx_fifo_to_cmac_axis_tkeep  ),
        .tx_axis_tlast                       ( tx_fifo_to_cmac_axis_tlast  ),
        .tx_axis_tready                      ( tx_fifo_to_cmac_axis_tready ),
        .tx_axis_tuser                       ( tx_fifo_to_cmac_axis_tuser  ),
        .tx_axis_tvalid                      ( tx_fifo_to_cmac_axis_tvalid ),

        // AXIS RX interface
        .rx_axis_tdata                       ( rx_cmac_to_fifo_axis_tdata  ),
        .rx_axis_tkeep                       ( rx_cmac_to_fifo_axis_tkeep  ),
        .rx_axis_tlast                       ( rx_cmac_to_fifo_axis_tlast  ),
        .rx_axis_tuser                       ( rx_cmac_to_fifo_axis_tuser  ),
        .rx_axis_tvalid                      ( rx_cmac_to_fifo_axis_tvalid ),


        // AXI Lite interface ( CSR space )




        // ctl (flow control) interface
        .ctl_tx_enable                       (1),
        .ctl_tx_test_pattern                 (0),
        .ctl_tx_send_idle                    (0),
        .ctl_tx_send_lfi                     (0),
        .ctl_tx_send_rfi                     (0),

        .ctl_rx_enable                       (1),
        .ctl_rx_force_resync                 (0),
        .ctl_rx_test_pattern                  (0),

        .ctl_tx_pause_enable                 (0),
        .ctl_tx_pause_quanta0                (16'hffff),
        .ctl_tx_pause_quanta1                (16'hffff),
        .ctl_tx_pause_quanta2                (16'hffff),
        .ctl_tx_pause_quanta3                (16'hffff),
        .ctl_tx_pause_quanta4                (16'hffff),
        .ctl_tx_pause_quanta5                (16'hffff),
        .ctl_tx_pause_quanta6                (16'hffff),
        .ctl_tx_pause_quanta7                (16'hffff),
        .ctl_tx_pause_quanta8                (16'hffff),
        .ctl_tx_pause_refresh_timer0         (16'h7fff),
        .ctl_tx_pause_refresh_timer1         (16'h7fff),
        .ctl_tx_pause_refresh_timer2         (16'h7fff),
        .ctl_tx_pause_refresh_timer3         (16'h7fff),
        .ctl_tx_pause_refresh_timer4         (16'h7fff),
        .ctl_tx_pause_refresh_timer5         (16'h7fff),
        .ctl_tx_pause_refresh_timer6         (16'h7fff),
        .ctl_tx_pause_refresh_timer7         (16'h7fff),
        .ctl_tx_pause_refresh_timer8         (16'h7fff),
        .ctl_tx_pause_req                    (0),
        .ctl_tx_resend_pause                 (1'b0),

        .ctl_rx_check_etype_gcp              (1'b0),
        .ctl_rx_check_etype_gpp              (1'b0),
        .ctl_rx_check_etype_pcp              (1'b0),
        .ctl_rx_check_etype_ppp              (1'b0),
        .ctl_rx_check_mcast_gcp              (1'b0),
        .ctl_rx_check_mcast_gpp              (1'b0),
        .ctl_rx_check_mcast_pcp              (1'b0),
        .ctl_rx_check_mcast_ppp              (1'b0),
        .ctl_rx_check_opcode_gcp             (1'b0),
        .ctl_rx_check_opcode_gpp             (1'b0),
        .ctl_rx_check_opcode_pcp             (1'b0),
        .ctl_rx_check_opcode_ppp             (1'b0),
        .ctl_rx_check_sa_gcp                 (1'b0),
        .ctl_rx_check_sa_gpp                 (1'b0),
        .ctl_rx_check_sa_pcp                 (1'b0),
        .ctl_rx_check_sa_ppp                 (1'b0),
        .ctl_rx_check_ucast_gcp              (1'b0),
        .ctl_rx_check_ucast_gpp              (1'b0),
        .ctl_rx_check_ucast_pcp              (1'b0),
        .ctl_rx_check_ucast_ppp              (1'b0),
        .ctl_rx_enable_gcp                   (0),
        .ctl_rx_enable_gpp                   (0),
        .ctl_rx_enable_pcp                   (0),
        .ctl_rx_enable_ppp                   (0),
        .ctl_rx_pause_ack                    (0),
        .ctl_rx_pause_enable                 (0),

        // DRP (dynamic reconfiguration port) interface
        .drp_clk                             (0),
        .drp_addr                            (0),
        .drp_di                              (0),
        .drp_en                              (0),
        .drp_we                              (0),
        .drp_do                              ( /*Not connected*/ ),
        .drp_rdy                             ( /*Not connected*/),

        // gt loopback
        .gt_loopback_in                      (0),
        .gtwiz_reset_tx_datapath             ( 0 ),
        .gtwiz_reset_rx_datapath             ( 0 ),

        .sys_reset                           ( rx_reset_3 /*!reset_n*/   ),
        .init_clk                            ( qsfp0_usr_rx_clock/* clock */   ),
        .core_rx_reset                       ( rx_reset_3 ),
        .rx_clk                              ( qsfp0_usr_rx_clock ),
        .core_tx_reset                       ( 0 ),
        .tx_preamblein                        (56'd0),
        .core_drp_reset                      (0),




        // Stat TX
        .stat_tx_bad_fcs                     ( /*Not connected*/ ),
        .stat_tx_broadcast                   ( /*Not connected*/ ),
        .stat_tx_frame_error                 ( /*Not connected*/ ),
        .stat_tx_local_fault                 ( /*Not connected*/ ),
        .stat_tx_multicast                   ( /*Not connected*/ ),
        .stat_tx_packet_64_bytes             ( /*Not connected*/ ),
        .stat_tx_packet_65_127_bytes         ( /*Not connected*/ ),
        .stat_tx_packet_128_255_bytes        ( /*Not connected*/ ),
        .stat_tx_packet_256_511_bytes        ( /*Not connected*/ ),
        .stat_tx_packet_512_1023_bytes       ( /*Not connected*/ ),
        .stat_tx_packet_1024_1518_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_1519_1522_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_1523_1548_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_1549_2047_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_2048_4095_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_4096_8191_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_8192_9215_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_large                ( /*Not connected*/ ),
        .stat_tx_packet_small                ( /*Not connected*/ ),
        .stat_tx_total_bytes                 ( /*Not connected*/ ),
        .stat_tx_total_good_bytes            ( /*Not connected*/ ),
        .stat_tx_total_good_packets          ( /*Not connected*/ ),
        .stat_tx_total_packets               ( /*Not connected*/ ),
        .stat_tx_unicast                     ( /*Not connected*/ ),
        .stat_tx_vlan                        ( /*Not connected*/ ),
        .stat_tx_user_pause                  ( /*Not connected*/ ),
        .stat_tx_pause_valid                 ( /*Not connected*/ ),
        .stat_tx_pause                       ( /*Not connected*/ ),

        // Stat RX
        .stat_rx_aligned                     ( /*Not connected*/ ),
        .stat_rx_aligned_err                 ( /*Not connected*/ ),
        .stat_rx_bad_code                    ( /*Not connected*/ ),
        .stat_rx_bad_fcs                     ( /*Not connected*/ ),
        .stat_rx_bad_preamble                ( /*Not connected*/ ),
        .stat_rx_bad_sfd                     ( /*Not connected*/ ),
        .stat_rx_bip_err_0                   ( /*Not connected*/ ),
        .stat_rx_bip_err_1                   ( /*Not connected*/ ),
        .stat_rx_bip_err_2                   ( /*Not connected*/ ),
        .stat_rx_bip_err_3                   ( /*Not connected*/ ),
        .stat_rx_bip_err_4                   ( /*Not connected*/ ),
        .stat_rx_bip_err_5                   ( /*Not connected*/ ),
        .stat_rx_bip_err_6                   ( /*Not connected*/ ),
        .stat_rx_bip_err_7                   ( /*Not connected*/ ),
        .stat_rx_bip_err_8                   ( /*Not connected*/ ),
        .stat_rx_bip_err_9                   ( /*Not connected*/ ),
        .stat_rx_bip_err_10                  ( /*Not connected*/ ),
        .stat_rx_bip_err_11                  ( /*Not connected*/ ),
        .stat_rx_bip_err_12                  ( /*Not connected*/ ),
        .stat_rx_bip_err_13                  ( /*Not connected*/ ),
        .stat_rx_bip_err_14                  ( /*Not connected*/ ),
        .stat_rx_bip_err_15                  ( /*Not connected*/ ),
        .stat_rx_bip_err_16                  ( /*Not connected*/ ),
        .stat_rx_bip_err_17                  ( /*Not connected*/ ),
        .stat_rx_bip_err_18                  ( /*Not connected*/ ),
        .stat_rx_bip_err_19                  ( /*Not connected*/ ),
        .stat_rx_block_lock                  ( /*Not connected*/ ),
        .stat_rx_broadcast                   ( /*Not connected*/ ),
        .stat_rx_fragment                    ( /*Not connected*/ ),
        .stat_rx_framing_err_0               ( /*Not connected*/ ),
        .stat_rx_framing_err_1               ( /*Not connected*/ ),
        .stat_rx_framing_err_2               ( /*Not connected*/ ),
        .stat_rx_framing_err_3               ( /*Not connected*/ ),
        .stat_rx_framing_err_4               ( /*Not connected*/ ),
        .stat_rx_framing_err_5               ( /*Not connected*/ ),
        .stat_rx_framing_err_6               ( /*Not connected*/ ),
        .stat_rx_framing_err_7               ( /*Not connected*/ ),
        .stat_rx_framing_err_8               ( /*Not connected*/ ),
        .stat_rx_framing_err_9               ( /*Not connected*/ ),
        .stat_rx_framing_err_10              ( /*Not connected*/ ),
        .stat_rx_framing_err_11              ( /*Not connected*/ ),
        .stat_rx_framing_err_12              ( /*Not connected*/ ),
        .stat_rx_framing_err_13              ( /*Not connected*/ ),
        .stat_rx_framing_err_14              ( /*Not connected*/ ),
        .stat_rx_framing_err_15              ( /*Not connected*/ ),
        .stat_rx_framing_err_16              ( /*Not connected*/ ),
        .stat_rx_framing_err_17              ( /*Not connected*/ ),
        .stat_rx_framing_err_18              ( /*Not connected*/ ),
        .stat_rx_framing_err_19              ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_0         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_1         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_2         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_3         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_4         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_5         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_6         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_7         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_8         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_9         ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_10        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_11        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_12        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_13        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_14        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_15        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_16        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_17        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_18        ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_19        ( /*Not connected*/ ),
        .stat_rx_got_signal_os               ( /*Not connected*/ ),
        .stat_rx_hi_ber                      ( /*Not connected*/ ),
        .stat_rx_inrangeerr                  ( /*Not connected*/ ),
        .stat_rx_internal_local_fault        ( /*Not connected*/ ),
        .stat_rx_jabber                      ( /*Not connected*/ ),
        .stat_rx_local_fault                 ( /*Not connected*/ ),
        .stat_rx_mf_err                      ( /*Not connected*/ ),
        .stat_rx_mf_len_err                  ( /*Not connected*/ ),
        .stat_rx_mf_repeat_err               ( /*Not connected*/ ),
        .stat_rx_misaligned                  ( /*Not connected*/ ),
        .stat_rx_multicast                   ( /*Not connected*/ ),
        .stat_rx_oversize                    ( /*Not connected*/ ),
        .stat_rx_packet_64_bytes             ( /*Not connected*/ ),
        .stat_rx_packet_65_127_bytes         ( /*Not connected*/ ),
        .stat_rx_packet_128_255_bytes        ( /*Not connected*/ ),
        .stat_rx_packet_256_511_bytes        ( /*Not connected*/ ),
        .stat_rx_packet_512_1023_bytes       ( /*Not connected*/ ),
        .stat_rx_packet_1024_1518_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_1519_1522_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_1523_1548_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_1549_2047_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_2048_4095_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_4096_8191_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_8192_9215_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_bad_fcs              ( /*Not connected*/ ),
        .stat_rx_packet_large                ( /*Not connected*/ ),
        .stat_rx_packet_small                ( /*Not connected*/ ),
        .stat_rx_pause                       ( /*Not connected*/ ),
        .stat_rx_pause_quanta0               ( /*Not connected*/ ),
        .stat_rx_pause_quanta1               ( /*Not connected*/ ),
        .stat_rx_pause_quanta2               ( /*Not connected*/ ),
        .stat_rx_pause_quanta3               ( /*Not connected*/ ),
        .stat_rx_pause_quanta4               ( /*Not connected*/ ),
        .stat_rx_pause_quanta5               ( /*Not connected*/ ),
        .stat_rx_pause_quanta6               ( /*Not connected*/ ),
        .stat_rx_pause_quanta7               ( /*Not connected*/ ),
        .stat_rx_pause_quanta8               ( /*Not connected*/ ),
        .stat_rx_pause_req                   ( /*Not connected*/ ),
        .stat_rx_pause_valid                 ( /*Not connected*/ ),
        .stat_rx_user_pause                  ( /*Not connected*/ ),
        .stat_rx_received_local_fault        ( /*Not connected*/ ),
        .stat_rx_remote_fault                ( /*Not connected*/ ),
        .stat_rx_status                      ( /*Not connected*/ ),
        .stat_rx_stomped_fcs                 ( /*Not connected*/ ),
        .stat_rx_synced                      ( /*Not connected*/ ),
        .stat_rx_synced_err                  ( /*Not connected*/ ),
        .stat_rx_test_pattern_mismatch       ( /*Not connected*/ ),
        .stat_rx_toolong                     ( /*Not connected*/ ),
        .stat_rx_total_bytes                 ( /*Not connected*/ ),
        .stat_rx_total_good_bytes            ( /*Not connected*/ ),
        .stat_rx_total_good_packets          ( /*Not connected*/ ),
        .stat_rx_total_packets               ( /*Not connected*/ ),
        .stat_rx_truncated                   ( /*Not connected*/ ),
        .stat_rx_undersize                   ( /*Not connected*/ ),
        .stat_rx_unicast                     ( /*Not connected*/ ),
        .stat_rx_vlan                        ( /*Not connected*/ ),
        .stat_rx_pcsl_demuxed                ( /*Not connected*/ ),
        .stat_rx_pcsl_number_0               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_1               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_2               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_3               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_4               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_5               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_6               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_7               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_8               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_9               ( /*Not connected*/ ),
        .stat_rx_pcsl_number_10              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_11              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_12              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_13              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_14              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_15              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_16              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_17              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_18              ( /*Not connected*/ ),
        .stat_rx_pcsl_number_19              ( /*Not connected*/ ),

        .rx_otn_bip8_0                       ( /*Not connected*/ ),
        .rx_otn_bip8_1                       ( /*Not connected*/ ),
        .rx_otn_bip8_2                       ( /*Not connected*/ ),
        .rx_otn_bip8_3                       ( /*Not connected*/ ),
        .rx_otn_bip8_4                       ( /*Not connected*/ ),
        .rx_otn_data_0                       ( /*Not connected*/ ),
        .rx_otn_data_1                       ( /*Not connected*/ ),
        .rx_otn_data_2                       ( /*Not connected*/ ),
        .rx_otn_data_3                       ( /*Not connected*/ ),
        .rx_otn_data_4                       ( /*Not connected*/ ),
        .rx_otn_ena                          ( /*Not connected*/ ),
        .rx_otn_lane0                        ( /*Not connected*/ ),
        .rx_otn_vlmarker                     ( /*Not connected*/ ),
        .rx_preambleout                      ( /*Not connected*/ ),

        .gt_txusrclk2                        ( qsfp0_usr_tx_clock ),
        .gt_rxusrclk2                        ( qsfp0_usr_rx_clock ),

        .gt_ref_clk_out                      ( /*Not connected*/ ),
        .gt_rxrecclkout                      ( /*Not connected*/ ),
        .gt_powergoodout                     ( /*Not connected*/ ),

        .usr_rx_reset                        ( qsfp0_usr_rx_reset ),
        .usr_tx_reset                        ( qsfp0_usr_tx_reset ),

        .tx_ovfout                           ( /*Not connected*/ ),
        .tx_unfout                           ( /*Not connected*/ )

    );





endmodule
