// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: CMAC wrapper, this module instanciate the CMAC to access the network through the QSFP port
//              This wrapper comprises a complete subsytem (attached to the HBUS) for allowing external modules (the core, an accelerator, etc.) to access network packets.
//              It is structured as in the following diagram.
//              It includes three main paths:
//                  - The CSR CMAC path (AXI Lite)
//                  - The CSR AXI Stream FIFO path (AXI Lite)
//                  - The data AXI Stream FIFO path (AXI4)
//
//              The rationale of this subsystem is to have a module (the AXI Stream FIFO) (connected to the external world)
//              that stores (sends) network packets from (to) the CMAC.
//              However, this buffering module could be, in the future, replaced by an in-network accelerator, or a TCP/IP stack or whatever...
//              It could be connected to a DDR channel too.
//
//
//                     ________
//                    |        | AXI4 512b   _____________   AXI4 32b    ___________   AXI Lite 32b                                                         ________
//                    |        |  HBUS clk  |             |   HBUS clk  |           |    HBUS clk                                                          |        |
//                    |        |----------->| Dwidth conv |------------>| Prot conv |--------------------------------------------------------------------->|        |
//                    |        |            |_____________|             |___________|                                                                      |        |
// AXI4 512b HBUS clk |  AXI4  |                                                                                                                           |        | QSFP RX
//  ( from HBUS )     |  XBAR  | AXI4 512b   ____________   AXI4 512b    _____________   AXI4 32b    ___________  AXI Lite 32b   ____________   AXIS RX    |        |<---------
//------------------->|        |  HBUS clk  |            |  322.26 MHz  |             | 322.26 MHz  |           |  322.26 MHz   |            | 322.26 MHz  |  CMAC  |
//                    |        |----------->| Clock conv |------------->| Dwidth conv |------------>| Prot conv |-------------->|            |<------------|        | QSFP TX
//                    |        |            |____________|              |_____________|             |___________|               | AXI Stream |             |        |--------->
//                    |        | AXI4 512b   ____________   AXI4 512b                                                           |    FIFO    |  AXIS TX    |        |
//                    |        |  HBUS clk  |            |  322.26 MHz                                                          |            | 322.26 MHz  |        |
//                    |        |----------->| Clock conv |--------------------------------------------------------------------->|            |------------>|        |
//                    |________|            |____________|                                                                      |____________|             |________|
//                                                                       __________________                                           |
//                                                          HBUS clk    |                  |   322.26 MHz         interrupt           |
//<---------------------------------------------------------------------| CDC Synchronizer |<-----------------------------------------|
//                                                                      |__________________|
//
//


`include "uninasoc_axi.svh"
`include "uninasoc_qsfp.svh"

module cmac_wrapper # (
    parameter int unsigned    LOCAL_DATA_WIDTH  = 512,
    parameter int unsigned    LOCAL_ADDR_WIDTH  = 32,
    parameter int unsigned    LOCAL_ID_WIDTH    = 2
)(

    // QSFP clock and reset
    input logic qsfp0_156mhz_clock_pi,    // Positive edge of the clock at 156 MHz for the QSFP port 0
    input logic qsfp0_156mhz_clock_ni,    // Negative edge of the clock at 156 MHz for the QSFP port 0

    // HBUS clock and reset
    input logic clock_i,
    input logic reset_ni,

    // QSFP ports
    `DEFINE_QSFP_PORTS(x),

    // QSFP0 module control
    output logic qsfp0_resetl_no,    // QSFP0 module reset (active low) must be 1
    output logic qsfp0_lpmode_no,    // QSFP0 low power mode (active low) must be 1
    output logic qsfp0_modsell_no,   // QSFP0 module select (active low) must be 0

    // AXI4 ports
    `DEFINE_AXI_SLAVE_PORTS(s, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH),

    // Interrupt out from the AXI Stream FIFO
    output logic interrupt_po

);


    // QSFP0 module control
    assign qsfp0_resetl_no  = 1'b1;
    assign qsfp0_lpmode_no  = 1'b1;
    assign qsfp0_modsell_no = 1'b0;


    // CMAC output clock (322,26 MHz) and reset (Active high)
    logic cmac_output_clock_322MHz;
    logic cmac_output_reset_p;

    // AXI Stream FIFO interrupt signal
    logic fifo_interrupt;

    // CDC Synchronizer for AXI Stream FIFO interrupt
    xpm_cdc_array_single #(
        .DEST_SYNC_FF   ( 4              ),     // Number of sync flip-flops
        .SRC_INPUT_REG  ( 1              ),     // Input register enable
        .WIDTH          ( 1              )      // Width of data to sync
    )
    xpm_cdc_array_single_inst (
        .dest_out       ( interrupt_po             ),
        .dest_clk       ( clock_i                  ),     // Destination clock domain (MAIN_DOMAIN)
        .src_clk        ( cmac_output_clock_322MHz ),     // Source clock domain (PBUS_DOMAIN)
        .src_in         ( fifo_interrupt           )
    );


    ////////////////
    // XBAR buses //
    ////////////////

    // AXI4 bus (512b) from the XBAR to cmac prot conv
    `DECLARE_AXI_BUS(xbar_to_cmac_dwidth_conv, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 bus (512b) from the XBAR to fifo clock conv (CSR path)
    `DECLARE_AXI_BUS(xbar_to_fifo_clock_conv_csr, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 bus (512b) from the XBAR to fifo clock conv (data path)
    `DECLARE_AXI_BUS(xbar_to_fifo_clock_conv, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 xbar slaves bus array
    `DECLARE_AXI_BUS_ARRAY(xbar_slaves, 3, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)
    `CONCAT_AXI_SLAVES_ARRAY3(xbar_slaves, xbar_to_fifo_clock_conv, xbar_to_fifo_clock_conv_csr, xbar_to_cmac_dwidth_conv)


    ////////////////
    // AXI4 buses //
    ////////////////

    // AXI4 bus (512b) from the clock conv to the fifo dwidth conv
    `DECLARE_AXI_BUS(clock_conv_to_fifo_dwidth_conv, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 bus (512b) for read/write data from/to the AXIS FIFO from the clock converter
    `DECLARE_AXI_BUS(clock_conv_to_fifo, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 bus from dwidth conv (AXI Stream FIFO path) to prot conv
    `DECLARE_AXI_BUS(fifo_dwidth_conv_to_prot_conv, 32, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)

    // AXI4 bus from dwidth conv (CMAC path) to prot conv
    `DECLARE_AXI_BUS(cmac_dwidth_conv_to_prot_conv, 32, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)


    ////////////////////
    // AXI Lite buses //
    ////////////////////

    // AXI Lite bus for accessing CSR of the AXIS FIFO
    `DECLARE_AXILITE_BUS(prot_conv_to_fifo, 32, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH) // TODO: check the ID Width

    // AXI Lite bus for accessing control and status registers of the CMAC
    `DECLARE_AXILITE_BUS(prot_conv_to_cmac, 32, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH)


    //////////////////////
    // AXI Stream buses //
    //////////////////////

    // AXIS bus for data transmission from the AXIS FIFO to the CMAC
    `DECLARE_AXIS_BUS(tx_fifo_to_cmac)

    // AXIS bus for data reception from the CMAC to the AXIS FIFO
    `DECLARE_AXIS_BUS(rx_cmac_to_fifo)


    ///////////////////////////
    // Modules instantiation //
    ///////////////////////////


    // CMAC XBAR
    xlnx_cmac_crossbar cmac_xbar_u (
        .aclk           ( clock_i        ),
        .aresetn        ( reset_ni       ),
        .s_axi_awid     ( s_axi_awid     ),
        .s_axi_awaddr   ( s_axi_awaddr   ),
        .s_axi_awlen    ( s_axi_awlen    ),
        .s_axi_awsize   ( s_axi_awsize   ),
        .s_axi_awburst  ( s_axi_awburst  ),
        .s_axi_awlock   ( s_axi_awlock   ),
        .s_axi_awcache  ( s_axi_awcache  ),
        .s_axi_awprot   ( s_axi_awprot   ),
        .s_axi_awqos    ( s_axi_awqos    ),
        .s_axi_awvalid  ( s_axi_awvalid  ),
        .s_axi_awready  ( s_axi_awready  ),
        .s_axi_wdata    ( s_axi_wdata    ),
        .s_axi_wstrb    ( s_axi_wstrb    ),
        .s_axi_wlast    ( s_axi_wlast    ),
        .s_axi_wvalid   ( s_axi_wvalid   ),
        .s_axi_wready   ( s_axi_wready   ),
        .s_axi_bid      ( s_axi_bid      ),
        .s_axi_bresp    ( s_axi_bresp    ),
        .s_axi_bvalid   ( s_axi_bvalid   ),
        .s_axi_bready   ( s_axi_bready   ),
        .s_axi_arid     ( s_axi_arid     ),
        .s_axi_araddr   ( s_axi_araddr   ),
        .s_axi_arlen    ( s_axi_arlen    ),
        .s_axi_arsize   ( s_axi_arsize   ),
        .s_axi_arburst  ( s_axi_arburst  ),
        .s_axi_arlock   ( s_axi_arlock   ),
        .s_axi_arcache  ( s_axi_arcache  ),
        .s_axi_arprot   ( s_axi_arprot   ),
        .s_axi_arqos    ( s_axi_arqos    ),
        .s_axi_arvalid  ( s_axi_arvalid  ),
        .s_axi_arready  ( s_axi_arready  ),
        .s_axi_rid      ( s_axi_rid      ),
        .s_axi_rdata    ( s_axi_rdata    ),
        .s_axi_rresp    ( s_axi_rresp    ),
        .s_axi_rlast    ( s_axi_rlast    ),
        .s_axi_rvalid   ( s_axi_rvalid   ),
        .s_axi_rready   ( s_axi_rready   ),

        .m_axi_awid     ( xbar_slaves_axi_awid      ),
        .m_axi_awaddr   ( xbar_slaves_axi_awaddr    ),
        .m_axi_awlen    ( xbar_slaves_axi_awlen     ),
        .m_axi_awsize   ( xbar_slaves_axi_awsize    ),
        .m_axi_awburst  ( xbar_slaves_axi_awburst   ),
        .m_axi_awlock   ( xbar_slaves_axi_awlock    ),
        .m_axi_awcache  ( xbar_slaves_axi_awcache   ),
        .m_axi_awprot   ( xbar_slaves_axi_awprot    ),
        .m_axi_awregion ( xbar_slaves_axi_awregion  ),
        .m_axi_awqos    ( xbar_slaves_axi_awqos     ),
        .m_axi_awvalid  ( xbar_slaves_axi_awvalid   ),
        .m_axi_awready  ( xbar_slaves_axi_awready   ),
        .m_axi_wdata    ( xbar_slaves_axi_wdata     ),
        .m_axi_wstrb    ( xbar_slaves_axi_wstrb     ),
        .m_axi_wlast    ( xbar_slaves_axi_wlast     ),
        .m_axi_wvalid   ( xbar_slaves_axi_wvalid    ),
        .m_axi_wready   ( xbar_slaves_axi_wready    ),
        .m_axi_bid      ( xbar_slaves_axi_bid       ),
        .m_axi_bresp    ( xbar_slaves_axi_bresp     ),
        .m_axi_bvalid   ( xbar_slaves_axi_bvalid    ),
        .m_axi_bready   ( xbar_slaves_axi_bready    ),
        .m_axi_arid     ( xbar_slaves_axi_arid      ),
        .m_axi_araddr   ( xbar_slaves_axi_araddr    ),
        .m_axi_arlen    ( xbar_slaves_axi_arlen     ),
        .m_axi_arsize   ( xbar_slaves_axi_arsize    ),
        .m_axi_arburst  ( xbar_slaves_axi_arburst   ),
        .m_axi_arlock   ( xbar_slaves_axi_arlock    ),
        .m_axi_arcache  ( xbar_slaves_axi_arcache   ),
        .m_axi_arprot   ( xbar_slaves_axi_arprot    ),
        .m_axi_arregion ( xbar_slaves_axi_arregion  ),
        .m_axi_arqos    ( xbar_slaves_axi_arqos     ),
        .m_axi_arvalid  ( xbar_slaves_axi_arvalid   ),
        .m_axi_arready  ( xbar_slaves_axi_arready   ),
        .m_axi_rid      ( xbar_slaves_axi_rid       ),
        .m_axi_rdata    ( xbar_slaves_axi_rdata     ),
        .m_axi_rresp    ( xbar_slaves_axi_rresp     ),
        .m_axi_rlast    ( xbar_slaves_axi_rlast     ),
        .m_axi_rvalid   ( xbar_slaves_axi_rvalid    ),
        .m_axi_rready   ( xbar_slaves_axi_rready    )

    );


    // Clock converter from xbar to dwidth converter (CSR path)
    axi_clock_converter_wrapper #(
        .LOCAL_DATA_WIDTH ( LOCAL_DATA_WIDTH ),
        .LOCAL_ADDR_WIDTH ( LOCAL_ADDR_WIDTH ),
        .LOCAL_ID_WIDTH   ( LOCAL_ID_WIDTH   )

    ) fifo_clock_conv_csr_u (
        .s_axi_aclk     ( clock_i        ),
        .s_axi_aresetn  ( reset_ni       ),

        .m_axi_aclk     ( cmac_output_clock_322MHz             ),
        .m_axi_aresetn  ( ~cmac_output_reset_p                 ),

        .s_axi_awid     ( xbar_to_fifo_clock_conv_csr_axi_awid     ),
        .s_axi_awaddr   ( xbar_to_fifo_clock_conv_csr_axi_awaddr   ),
        .s_axi_awlen    ( xbar_to_fifo_clock_conv_csr_axi_awlen    ),
        .s_axi_awsize   ( xbar_to_fifo_clock_conv_csr_axi_awsize   ),
        .s_axi_awburst  ( xbar_to_fifo_clock_conv_csr_axi_awburst  ),
        .s_axi_awlock   ( xbar_to_fifo_clock_conv_csr_axi_awlock   ),
        .s_axi_awcache  ( xbar_to_fifo_clock_conv_csr_axi_awcache  ),
        .s_axi_awprot   ( xbar_to_fifo_clock_conv_csr_axi_awprot   ),
        .s_axi_awqos    ( xbar_to_fifo_clock_conv_csr_axi_awqos    ),
        .s_axi_awvalid  ( xbar_to_fifo_clock_conv_csr_axi_awvalid  ),
        .s_axi_awready  ( xbar_to_fifo_clock_conv_csr_axi_awready  ),
        .s_axi_awregion ( xbar_to_fifo_clock_conv_csr_axi_awregion ),
        .s_axi_wdata    ( xbar_to_fifo_clock_conv_csr_axi_wdata    ),
        .s_axi_wstrb    ( xbar_to_fifo_clock_conv_csr_axi_wstrb    ),
        .s_axi_wlast    ( xbar_to_fifo_clock_conv_csr_axi_wlast    ),
        .s_axi_wvalid   ( xbar_to_fifo_clock_conv_csr_axi_wvalid   ),
        .s_axi_wready   ( xbar_to_fifo_clock_conv_csr_axi_wready   ),
        .s_axi_bid      ( xbar_to_fifo_clock_conv_csr_axi_bid      ),
        .s_axi_bresp    ( xbar_to_fifo_clock_conv_csr_axi_bresp    ),
        .s_axi_bvalid   ( xbar_to_fifo_clock_conv_csr_axi_bvalid   ),
        .s_axi_bready   ( xbar_to_fifo_clock_conv_csr_axi_bready   ),
        .s_axi_arid     ( xbar_to_fifo_clock_conv_csr_axi_arid     ),
        .s_axi_araddr   ( xbar_to_fifo_clock_conv_csr_axi_araddr   ),
        .s_axi_arlen    ( xbar_to_fifo_clock_conv_csr_axi_arlen    ),
        .s_axi_arsize   ( xbar_to_fifo_clock_conv_csr_axi_arsize   ),
        .s_axi_arburst  ( xbar_to_fifo_clock_conv_csr_axi_arburst  ),
        .s_axi_arlock   ( xbar_to_fifo_clock_conv_csr_axi_arlock   ),
        .s_axi_arregion ( xbar_to_fifo_clock_conv_csr_axi_arregion ),
        .s_axi_arcache  ( xbar_to_fifo_clock_conv_csr_axi_arcache  ),
        .s_axi_arprot   ( xbar_to_fifo_clock_conv_csr_axi_arprot   ),
        .s_axi_arqos    ( xbar_to_fifo_clock_conv_csr_axi_arqos    ),
        .s_axi_arvalid  ( xbar_to_fifo_clock_conv_csr_axi_arvalid  ),
        .s_axi_arready  ( xbar_to_fifo_clock_conv_csr_axi_arready  ),
        .s_axi_rid      ( xbar_to_fifo_clock_conv_csr_axi_rid      ),
        .s_axi_rdata    ( xbar_to_fifo_clock_conv_csr_axi_rdata    ),
        .s_axi_rresp    ( xbar_to_fifo_clock_conv_csr_axi_rresp    ),
        .s_axi_rlast    ( xbar_to_fifo_clock_conv_csr_axi_rlast    ),
        .s_axi_rvalid   ( xbar_to_fifo_clock_conv_csr_axi_rvalid   ),
        .s_axi_rready   ( xbar_to_fifo_clock_conv_csr_axi_rready   ),

        .m_axi_awid     ( clock_conv_to_fifo_dwidth_conv_axi_awid      ),
        .m_axi_awaddr   ( clock_conv_to_fifo_dwidth_conv_axi_awaddr    ),
        .m_axi_awlen    ( clock_conv_to_fifo_dwidth_conv_axi_awlen     ),
        .m_axi_awsize   ( clock_conv_to_fifo_dwidth_conv_axi_awsize    ),
        .m_axi_awburst  ( clock_conv_to_fifo_dwidth_conv_axi_awburst   ),
        .m_axi_awlock   ( clock_conv_to_fifo_dwidth_conv_axi_awlock    ),
        .m_axi_awcache  ( clock_conv_to_fifo_dwidth_conv_axi_awcache   ),
        .m_axi_awprot   ( clock_conv_to_fifo_dwidth_conv_axi_awprot    ),
        .m_axi_awregion ( clock_conv_to_fifo_dwidth_conv_axi_awregion  ),
        .m_axi_awqos    ( clock_conv_to_fifo_dwidth_conv_axi_awqos     ),
        .m_axi_awvalid  ( clock_conv_to_fifo_dwidth_conv_axi_awvalid   ),
        .m_axi_awready  ( clock_conv_to_fifo_dwidth_conv_axi_awready   ),
        .m_axi_wdata    ( clock_conv_to_fifo_dwidth_conv_axi_wdata     ),
        .m_axi_wstrb    ( clock_conv_to_fifo_dwidth_conv_axi_wstrb     ),
        .m_axi_wlast    ( clock_conv_to_fifo_dwidth_conv_axi_wlast     ),
        .m_axi_wvalid   ( clock_conv_to_fifo_dwidth_conv_axi_wvalid    ),
        .m_axi_wready   ( clock_conv_to_fifo_dwidth_conv_axi_wready    ),
        .m_axi_bid      ( clock_conv_to_fifo_dwidth_conv_axi_bid       ),
        .m_axi_bresp    ( clock_conv_to_fifo_dwidth_conv_axi_bresp     ),
        .m_axi_bvalid   ( clock_conv_to_fifo_dwidth_conv_axi_bvalid    ),
        .m_axi_bready   ( clock_conv_to_fifo_dwidth_conv_axi_bready    ),
        .m_axi_arid     ( clock_conv_to_fifo_dwidth_conv_axi_arid      ),
        .m_axi_araddr   ( clock_conv_to_fifo_dwidth_conv_axi_araddr    ),
        .m_axi_arlen    ( clock_conv_to_fifo_dwidth_conv_axi_arlen     ),
        .m_axi_arsize   ( clock_conv_to_fifo_dwidth_conv_axi_arsize    ),
        .m_axi_arburst  ( clock_conv_to_fifo_dwidth_conv_axi_arburst   ),
        .m_axi_arlock   ( clock_conv_to_fifo_dwidth_conv_axi_arlock    ),
        .m_axi_arcache  ( clock_conv_to_fifo_dwidth_conv_axi_arcache   ),
        .m_axi_arprot   ( clock_conv_to_fifo_dwidth_conv_axi_arprot    ),
        .m_axi_arregion ( clock_conv_to_fifo_dwidth_conv_axi_arregion  ),
        .m_axi_arqos    ( clock_conv_to_fifo_dwidth_conv_axi_arqos     ),
        .m_axi_arvalid  ( clock_conv_to_fifo_dwidth_conv_axi_arvalid   ),
        .m_axi_arready  ( clock_conv_to_fifo_dwidth_conv_axi_arready   ),
        .m_axi_rid      ( clock_conv_to_fifo_dwidth_conv_axi_rid       ),
        .m_axi_rdata    ( clock_conv_to_fifo_dwidth_conv_axi_rdata     ),
        .m_axi_rresp    ( clock_conv_to_fifo_dwidth_conv_axi_rresp     ),
        .m_axi_rlast    ( clock_conv_to_fifo_dwidth_conv_axi_rlast     ),
        .m_axi_rvalid   ( clock_conv_to_fifo_dwidth_conv_axi_rvalid    ),
        .m_axi_rready   ( clock_conv_to_fifo_dwidth_conv_axi_rready    )

    );

    // Clock converter from xbar to dwidth converter (data path)
    axi_clock_converter_wrapper #(
        .LOCAL_DATA_WIDTH ( LOCAL_DATA_WIDTH ),
        .LOCAL_ADDR_WIDTH ( LOCAL_ADDR_WIDTH ),
        .LOCAL_ID_WIDTH   ( LOCAL_ID_WIDTH   )

    ) fifo_clock_conv_u (
        .s_axi_aclk     ( clock_i        ),
        .s_axi_aresetn  ( reset_ni       ),

        .m_axi_aclk     ( cmac_output_clock_322MHz             ),
        .m_axi_aresetn  ( ~cmac_output_reset_p                 ),

        .s_axi_awid     ( xbar_to_fifo_clock_conv_axi_awid     ),
        .s_axi_awaddr   ( xbar_to_fifo_clock_conv_axi_awaddr   ),
        .s_axi_awlen    ( xbar_to_fifo_clock_conv_axi_awlen    ),
        .s_axi_awsize   ( xbar_to_fifo_clock_conv_axi_awsize   ),
        .s_axi_awburst  ( xbar_to_fifo_clock_conv_axi_awburst  ),
        .s_axi_awlock   ( xbar_to_fifo_clock_conv_axi_awlock   ),
        .s_axi_awcache  ( xbar_to_fifo_clock_conv_axi_awcache  ),
        .s_axi_awprot   ( xbar_to_fifo_clock_conv_axi_awprot   ),
        .s_axi_awqos    ( xbar_to_fifo_clock_conv_axi_awqos    ),
        .s_axi_awvalid  ( xbar_to_fifo_clock_conv_axi_awvalid  ),
        .s_axi_awready  ( xbar_to_fifo_clock_conv_axi_awready  ),
        .s_axi_awregion ( xbar_to_fifo_clock_conv_axi_awregion ),
        .s_axi_wdata    ( xbar_to_fifo_clock_conv_axi_wdata    ),
        .s_axi_wstrb    ( xbar_to_fifo_clock_conv_axi_wstrb    ),
        .s_axi_wlast    ( xbar_to_fifo_clock_conv_axi_wlast    ),
        .s_axi_wvalid   ( xbar_to_fifo_clock_conv_axi_wvalid   ),
        .s_axi_wready   ( xbar_to_fifo_clock_conv_axi_wready   ),
        .s_axi_bid      ( xbar_to_fifo_clock_conv_axi_bid      ),
        .s_axi_bresp    ( xbar_to_fifo_clock_conv_axi_bresp    ),
        .s_axi_bvalid   ( xbar_to_fifo_clock_conv_axi_bvalid   ),
        .s_axi_bready   ( xbar_to_fifo_clock_conv_axi_bready   ),
        .s_axi_arid     ( xbar_to_fifo_clock_conv_axi_arid     ),
        .s_axi_araddr   ( xbar_to_fifo_clock_conv_axi_araddr   ),
        .s_axi_arlen    ( xbar_to_fifo_clock_conv_axi_arlen    ),
        .s_axi_arsize   ( xbar_to_fifo_clock_conv_axi_arsize   ),
        .s_axi_arburst  ( xbar_to_fifo_clock_conv_axi_arburst  ),
        .s_axi_arlock   ( xbar_to_fifo_clock_conv_axi_arlock   ),
        .s_axi_arregion ( xbar_to_fifo_clock_conv_axi_arregion ),
        .s_axi_arcache  ( xbar_to_fifo_clock_conv_axi_arcache  ),
        .s_axi_arprot   ( xbar_to_fifo_clock_conv_axi_arprot   ),
        .s_axi_arqos    ( xbar_to_fifo_clock_conv_axi_arqos    ),
        .s_axi_arvalid  ( xbar_to_fifo_clock_conv_axi_arvalid  ),
        .s_axi_arready  ( xbar_to_fifo_clock_conv_axi_arready  ),
        .s_axi_rid      ( xbar_to_fifo_clock_conv_axi_rid      ),
        .s_axi_rdata    ( xbar_to_fifo_clock_conv_axi_rdata    ),
        .s_axi_rresp    ( xbar_to_fifo_clock_conv_axi_rresp    ),
        .s_axi_rlast    ( xbar_to_fifo_clock_conv_axi_rlast    ),
        .s_axi_rvalid   ( xbar_to_fifo_clock_conv_axi_rvalid   ),
        .s_axi_rready   ( xbar_to_fifo_clock_conv_axi_rready   ),

        .m_axi_awid     ( clock_conv_to_fifo_axi_awid      ),
        .m_axi_awaddr   ( clock_conv_to_fifo_axi_awaddr    ),
        .m_axi_awlen    ( clock_conv_to_fifo_axi_awlen     ),
        .m_axi_awsize   ( clock_conv_to_fifo_axi_awsize    ),
        .m_axi_awburst  ( clock_conv_to_fifo_axi_awburst   ),
        .m_axi_awlock   ( clock_conv_to_fifo_axi_awlock    ),
        .m_axi_awcache  ( clock_conv_to_fifo_axi_awcache   ),
        .m_axi_awprot   ( clock_conv_to_fifo_axi_awprot    ),
        .m_axi_awregion ( clock_conv_to_fifo_axi_awregion  ),
        .m_axi_awqos    ( clock_conv_to_fifo_axi_awqos     ),
        .m_axi_awvalid  ( clock_conv_to_fifo_axi_awvalid   ),
        .m_axi_awready  ( clock_conv_to_fifo_axi_awready   ),
        .m_axi_wdata    ( clock_conv_to_fifo_axi_wdata     ),
        .m_axi_wstrb    ( clock_conv_to_fifo_axi_wstrb     ),
        .m_axi_wlast    ( clock_conv_to_fifo_axi_wlast     ),
        .m_axi_wvalid   ( clock_conv_to_fifo_axi_wvalid    ),
        .m_axi_wready   ( clock_conv_to_fifo_axi_wready    ),
        .m_axi_bid      ( clock_conv_to_fifo_axi_bid       ),
        .m_axi_bresp    ( clock_conv_to_fifo_axi_bresp     ),
        .m_axi_bvalid   ( clock_conv_to_fifo_axi_bvalid    ),
        .m_axi_bready   ( clock_conv_to_fifo_axi_bready    ),
        .m_axi_arid     ( clock_conv_to_fifo_axi_arid      ),
        .m_axi_araddr   ( clock_conv_to_fifo_axi_araddr    ),
        .m_axi_arlen    ( clock_conv_to_fifo_axi_arlen     ),
        .m_axi_arsize   ( clock_conv_to_fifo_axi_arsize    ),
        .m_axi_arburst  ( clock_conv_to_fifo_axi_arburst   ),
        .m_axi_arlock   ( clock_conv_to_fifo_axi_arlock    ),
        .m_axi_arcache  ( clock_conv_to_fifo_axi_arcache   ),
        .m_axi_arprot   ( clock_conv_to_fifo_axi_arprot    ),
        .m_axi_arregion ( clock_conv_to_fifo_axi_arregion  ),
        .m_axi_arqos    ( clock_conv_to_fifo_axi_arqos     ),
        .m_axi_arvalid  ( clock_conv_to_fifo_axi_arvalid   ),
        .m_axi_arready  ( clock_conv_to_fifo_axi_arready   ),
        .m_axi_rid      ( clock_conv_to_fifo_axi_rid       ),
        .m_axi_rdata    ( clock_conv_to_fifo_axi_rdata     ),
        .m_axi_rresp    ( clock_conv_to_fifo_axi_rresp     ),
        .m_axi_rlast    ( clock_conv_to_fifo_axi_rlast     ),
        .m_axi_rvalid   ( clock_conv_to_fifo_axi_rvalid    ),
        .m_axi_rready   ( clock_conv_to_fifo_axi_rready    )

    );

    // Dwidth converter from clock converter to protocol converter (AXI Stream FIFO CSR path)
    xlnx_axi_dwidth_from512_to32_converter fifo_dwidth_conv_u (
        .s_axi_aclk     ( cmac_output_clock_322MHz  ),
        .s_axi_aresetn  ( ~cmac_output_reset_p      ),

        // Slave from Clock Conv (lite)
        .s_axi_awid     ( clock_conv_to_fifo_dwidth_conv_axi_awid    ),
        .s_axi_awaddr   ( clock_conv_to_fifo_dwidth_conv_axi_awaddr  ),
        .s_axi_awlen    ( clock_conv_to_fifo_dwidth_conv_axi_awlen   ),
        .s_axi_awsize   ( clock_conv_to_fifo_dwidth_conv_axi_awsize  ),
        .s_axi_awburst  ( clock_conv_to_fifo_dwidth_conv_axi_awburst ),
        .s_axi_awvalid  ( clock_conv_to_fifo_dwidth_conv_axi_awvalid ),
        .s_axi_awready  ( clock_conv_to_fifo_dwidth_conv_axi_awready ),
        .s_axi_wdata    ( clock_conv_to_fifo_dwidth_conv_axi_wdata   ),
        .s_axi_wstrb    ( clock_conv_to_fifo_dwidth_conv_axi_wstrb   ),
        .s_axi_wlast    ( clock_conv_to_fifo_dwidth_conv_axi_wlast   ),
        .s_axi_wvalid   ( clock_conv_to_fifo_dwidth_conv_axi_wvalid  ),
        .s_axi_wready   ( clock_conv_to_fifo_dwidth_conv_axi_wready  ),
        .s_axi_bid      ( clock_conv_to_fifo_dwidth_conv_axi_bid     ),
        .s_axi_bresp    ( clock_conv_to_fifo_dwidth_conv_axi_bresp   ),
        .s_axi_bvalid   ( clock_conv_to_fifo_dwidth_conv_axi_bvalid  ),
        .s_axi_bready   ( clock_conv_to_fifo_dwidth_conv_axi_bready  ),
        .s_axi_arid     ( clock_conv_to_fifo_dwidth_conv_axi_arid    ),
        .s_axi_araddr   ( clock_conv_to_fifo_dwidth_conv_axi_araddr  ),
        .s_axi_arlen    ( clock_conv_to_fifo_dwidth_conv_axi_arlen   ),
        .s_axi_arsize   ( clock_conv_to_fifo_dwidth_conv_axi_arsize  ),
        .s_axi_arburst  ( clock_conv_to_fifo_dwidth_conv_axi_arburst ),
        .s_axi_arvalid  ( clock_conv_to_fifo_dwidth_conv_axi_arvalid ),
        .s_axi_arready  ( clock_conv_to_fifo_dwidth_conv_axi_arready ),
        .s_axi_rid      ( clock_conv_to_fifo_dwidth_conv_axi_rid     ),
        .s_axi_rdata    ( clock_conv_to_fifo_dwidth_conv_axi_rdata   ),
        .s_axi_rresp    ( clock_conv_to_fifo_dwidth_conv_axi_rresp   ),
        .s_axi_rlast    ( clock_conv_to_fifo_dwidth_conv_axi_rlast   ),
        .s_axi_rvalid   ( clock_conv_to_fifo_dwidth_conv_axi_rvalid  ),
        .s_axi_rready   ( clock_conv_to_fifo_dwidth_conv_axi_rready  ),
        .s_axi_awlock   ( clock_conv_to_fifo_dwidth_conv_axi_awlock  ),
        .s_axi_awcache  ( clock_conv_to_fifo_dwidth_conv_axi_awcache ),
        .s_axi_awprot   ( clock_conv_to_fifo_dwidth_conv_axi_awprot  ),
        .s_axi_awqos    ( 0   ),
        .s_axi_awregion ( 0   ),
        .s_axi_arlock   ( clock_conv_to_fifo_dwidth_conv_axi_arlock  ),
        .s_axi_arcache  ( clock_conv_to_fifo_dwidth_conv_axi_arcache ),
        .s_axi_arprot   ( clock_conv_to_fifo_dwidth_conv_axi_arprot  ),
        .s_axi_arqos    ( 0   ),
        .s_axi_arregion ( 0   ),


        // Master to FIFO prot conv
        // .m_axi_awid     ( fifo_dwidth_conv_to_prot_conv_axi_awid    ),
        .m_axi_awaddr   ( fifo_dwidth_conv_to_prot_conv_axi_awaddr  ),
        .m_axi_awlen    ( fifo_dwidth_conv_to_prot_conv_axi_awlen   ),
        .m_axi_awsize   ( fifo_dwidth_conv_to_prot_conv_axi_awsize  ),
        .m_axi_awburst  ( fifo_dwidth_conv_to_prot_conv_axi_awburst ),
        .m_axi_awlock   ( fifo_dwidth_conv_to_prot_conv_axi_awlock  ),
        .m_axi_awcache  ( fifo_dwidth_conv_to_prot_conv_axi_awcache ),
        .m_axi_awprot   ( fifo_dwidth_conv_to_prot_conv_axi_awprot  ),
        .m_axi_awqos    ( fifo_dwidth_conv_to_prot_conv_axi_awqos   ),
        .m_axi_awvalid  ( fifo_dwidth_conv_to_prot_conv_axi_awvalid ),
        .m_axi_awready  ( fifo_dwidth_conv_to_prot_conv_axi_awready ),
        .m_axi_wdata    ( fifo_dwidth_conv_to_prot_conv_axi_wdata   ),
        .m_axi_wstrb    ( fifo_dwidth_conv_to_prot_conv_axi_wstrb   ),
        .m_axi_wlast    ( fifo_dwidth_conv_to_prot_conv_axi_wlast   ),
        .m_axi_wvalid   ( fifo_dwidth_conv_to_prot_conv_axi_wvalid  ),
        .m_axi_wready   ( fifo_dwidth_conv_to_prot_conv_axi_wready  ),
        // .m_axi_bid      ( fifo_dwidth_conv_to_prot_conv_axi_bid     ),
        .m_axi_bresp    ( fifo_dwidth_conv_to_prot_conv_axi_bresp   ),
        .m_axi_bvalid   ( fifo_dwidth_conv_to_prot_conv_axi_bvalid  ),
        .m_axi_bready   ( fifo_dwidth_conv_to_prot_conv_axi_bready  ),
        // .m_axi_arid     ( fifo_dwidth_conv_to_prot_conv_axi_arid    ),
        .m_axi_araddr   ( fifo_dwidth_conv_to_prot_conv_axi_araddr  ),
        .m_axi_arlen    ( fifo_dwidth_conv_to_prot_conv_axi_arlen   ),
        .m_axi_arsize   ( fifo_dwidth_conv_to_prot_conv_axi_arsize  ),
        .m_axi_arburst  ( fifo_dwidth_conv_to_prot_conv_axi_arburst ),
        .m_axi_arlock   ( fifo_dwidth_conv_to_prot_conv_axi_arlock  ),
        .m_axi_arcache  ( fifo_dwidth_conv_to_prot_conv_axi_arcache ),
        .m_axi_arprot   ( fifo_dwidth_conv_to_prot_conv_axi_arprot  ),
        .m_axi_arqos    ( fifo_dwidth_conv_to_prot_conv_axi_arqos   ),
        .m_axi_arvalid  ( fifo_dwidth_conv_to_prot_conv_axi_arvalid ),
        .m_axi_arready  ( fifo_dwidth_conv_to_prot_conv_axi_arready ),
        // .m_axi_rid      ( fifo_dwidth_conv_to_prot_conv_axi_rid     ),
        .m_axi_rdata    ( fifo_dwidth_conv_to_prot_conv_axi_rdata   ),
        .m_axi_rresp    ( fifo_dwidth_conv_to_prot_conv_axi_rresp   ),
        .m_axi_rlast    ( fifo_dwidth_conv_to_prot_conv_axi_rlast   ),
        .m_axi_rvalid   ( fifo_dwidth_conv_to_prot_conv_axi_rvalid  ),
        .m_axi_rready   ( fifo_dwidth_conv_to_prot_conv_axi_rready  )
    );

    // Dwidth converter from XBAR to protocol converter (CMAC CSR path)
    xlnx_axi_dwidth_from512_to32_converter cmac_dwidth_conv_u (
        .s_axi_aclk     ( clock_i   ),
        .s_axi_aresetn  ( reset_ni  ),

        // Slave from XBAR
        .s_axi_awid     ( xbar_to_cmac_dwidth_conv_axi_awid    ),
        .s_axi_awaddr   ( xbar_to_cmac_dwidth_conv_axi_awaddr  ),
        .s_axi_awlen    ( xbar_to_cmac_dwidth_conv_axi_awlen   ),
        .s_axi_awsize   ( xbar_to_cmac_dwidth_conv_axi_awsize  ),
        .s_axi_awburst  ( xbar_to_cmac_dwidth_conv_axi_awburst ),
        .s_axi_awvalid  ( xbar_to_cmac_dwidth_conv_axi_awvalid ),
        .s_axi_awready  ( xbar_to_cmac_dwidth_conv_axi_awready ),
        .s_axi_wdata    ( xbar_to_cmac_dwidth_conv_axi_wdata   ),
        .s_axi_wstrb    ( xbar_to_cmac_dwidth_conv_axi_wstrb   ),
        .s_axi_wlast    ( xbar_to_cmac_dwidth_conv_axi_wlast   ),
        .s_axi_wvalid   ( xbar_to_cmac_dwidth_conv_axi_wvalid  ),
        .s_axi_wready   ( xbar_to_cmac_dwidth_conv_axi_wready  ),
        .s_axi_bid      ( xbar_to_cmac_dwidth_conv_axi_bid     ),
        .s_axi_bresp    ( xbar_to_cmac_dwidth_conv_axi_bresp   ),
        .s_axi_bvalid   ( xbar_to_cmac_dwidth_conv_axi_bvalid  ),
        .s_axi_bready   ( xbar_to_cmac_dwidth_conv_axi_bready  ),
        .s_axi_arid     ( xbar_to_cmac_dwidth_conv_axi_arid    ),
        .s_axi_araddr   ( xbar_to_cmac_dwidth_conv_axi_araddr  ),
        .s_axi_arlen    ( xbar_to_cmac_dwidth_conv_axi_arlen   ),
        .s_axi_arsize   ( xbar_to_cmac_dwidth_conv_axi_arsize  ),
        .s_axi_arburst  ( xbar_to_cmac_dwidth_conv_axi_arburst ),
        .s_axi_arvalid  ( xbar_to_cmac_dwidth_conv_axi_arvalid ),
        .s_axi_arready  ( xbar_to_cmac_dwidth_conv_axi_arready ),
        .s_axi_rid      ( xbar_to_cmac_dwidth_conv_axi_rid     ),
        .s_axi_rdata    ( xbar_to_cmac_dwidth_conv_axi_rdata   ),
        .s_axi_rresp    ( xbar_to_cmac_dwidth_conv_axi_rresp   ),
        .s_axi_rlast    ( xbar_to_cmac_dwidth_conv_axi_rlast   ),
        .s_axi_rvalid   ( xbar_to_cmac_dwidth_conv_axi_rvalid  ),
        .s_axi_rready   ( xbar_to_cmac_dwidth_conv_axi_rready  ),
        .s_axi_awlock   ( xbar_to_cmac_dwidth_conv_axi_awlock  ),
        .s_axi_awcache  ( xbar_to_cmac_dwidth_conv_axi_awcache ),
        .s_axi_awprot   ( xbar_to_cmac_dwidth_conv_axi_awprot  ),
        .s_axi_awqos    ( 0   ),
        .s_axi_awregion ( 0   ),
        .s_axi_arlock   ( xbar_to_cmac_dwidth_conv_axi_arlock  ),
        .s_axi_arcache  ( xbar_to_cmac_dwidth_conv_axi_arcache ),
        .s_axi_arprot   ( xbar_to_cmac_dwidth_conv_axi_arprot  ),
        .s_axi_arqos    ( 0   ),
        .s_axi_arregion ( 0   ),


        // Master to CMAC prot conv
        // .m_axi_awid     ( cmac_dwidth_conv_to_prot_conv_axi_awid    ),
        .m_axi_awaddr   ( cmac_dwidth_conv_to_prot_conv_axi_awaddr  ),
        .m_axi_awlen    ( cmac_dwidth_conv_to_prot_conv_axi_awlen   ),
        .m_axi_awsize   ( cmac_dwidth_conv_to_prot_conv_axi_awsize  ),
        .m_axi_awburst  ( cmac_dwidth_conv_to_prot_conv_axi_awburst ),
        .m_axi_awlock   ( cmac_dwidth_conv_to_prot_conv_axi_awlock  ),
        .m_axi_awcache  ( cmac_dwidth_conv_to_prot_conv_axi_awcache ),
        .m_axi_awprot   ( cmac_dwidth_conv_to_prot_conv_axi_awprot  ),
        .m_axi_awqos    ( cmac_dwidth_conv_to_prot_conv_axi_awqos   ),
        .m_axi_awvalid  ( cmac_dwidth_conv_to_prot_conv_axi_awvalid ),
        .m_axi_awready  ( cmac_dwidth_conv_to_prot_conv_axi_awready ),
        .m_axi_wdata    ( cmac_dwidth_conv_to_prot_conv_axi_wdata   ),
        .m_axi_wstrb    ( cmac_dwidth_conv_to_prot_conv_axi_wstrb   ),
        .m_axi_wlast    ( cmac_dwidth_conv_to_prot_conv_axi_wlast   ),
        .m_axi_wvalid   ( cmac_dwidth_conv_to_prot_conv_axi_wvalid  ),
        .m_axi_wready   ( cmac_dwidth_conv_to_prot_conv_axi_wready  ),
        // .m_axi_bid      ( cmac_dwidth_conv_to_prot_conv_axi_bid     ),
        .m_axi_bresp    ( cmac_dwidth_conv_to_prot_conv_axi_bresp   ),
        .m_axi_bvalid   ( cmac_dwidth_conv_to_prot_conv_axi_bvalid  ),
        .m_axi_bready   ( cmac_dwidth_conv_to_prot_conv_axi_bready  ),
        // .m_axi_arid     ( cmac_dwidth_conv_to_prot_conv_axi_arid    ),
        .m_axi_araddr   ( cmac_dwidth_conv_to_prot_conv_axi_araddr  ),
        .m_axi_arlen    ( cmac_dwidth_conv_to_prot_conv_axi_arlen   ),
        .m_axi_arsize   ( cmac_dwidth_conv_to_prot_conv_axi_arsize  ),
        .m_axi_arburst  ( cmac_dwidth_conv_to_prot_conv_axi_arburst ),
        .m_axi_arlock   ( cmac_dwidth_conv_to_prot_conv_axi_arlock  ),
        .m_axi_arcache  ( cmac_dwidth_conv_to_prot_conv_axi_arcache ),
        .m_axi_arprot   ( cmac_dwidth_conv_to_prot_conv_axi_arprot  ),
        .m_axi_arqos    ( cmac_dwidth_conv_to_prot_conv_axi_arqos   ),
        .m_axi_arvalid  ( cmac_dwidth_conv_to_prot_conv_axi_arvalid ),
        .m_axi_arready  ( cmac_dwidth_conv_to_prot_conv_axi_arready ),
        // .m_axi_rid      ( cmac_dwidth_conv_to_prot_conv_axi_rid     ),
        .m_axi_rdata    ( cmac_dwidth_conv_to_prot_conv_axi_rdata   ),
        .m_axi_rresp    ( cmac_dwidth_conv_to_prot_conv_axi_rresp   ),
        .m_axi_rlast    ( cmac_dwidth_conv_to_prot_conv_axi_rlast   ),
        .m_axi_rvalid   ( cmac_dwidth_conv_to_prot_conv_axi_rvalid  ),
        .m_axi_rready   ( cmac_dwidth_conv_to_prot_conv_axi_rready  )
    );


    // AXI4 to AXI Lite prot conv (from dwidth converter to AXI Stream FIFO CSR)
    xlnx_axi4_to_axilite_d32_converter axi4_to_axilite_d32_converter_to_fifo_u (
        .aclk           ( cmac_output_clock_322MHz  ),
        .aresetn        ( ~cmac_output_reset_p      ),

        // AXI4 slave port (from fifo dwidth converter)
        .s_axi_awid     ( fifo_dwidth_conv_to_prot_conv_axi_awid     ),
        .s_axi_awaddr   ( fifo_dwidth_conv_to_prot_conv_axi_awaddr   ),
        .s_axi_awlen    ( fifo_dwidth_conv_to_prot_conv_axi_awlen    ),
        .s_axi_awsize   ( fifo_dwidth_conv_to_prot_conv_axi_awsize   ),
        .s_axi_awburst  ( fifo_dwidth_conv_to_prot_conv_axi_awburst  ),
        .s_axi_awlock   ( fifo_dwidth_conv_to_prot_conv_axi_awlock   ),
        .s_axi_awcache  ( fifo_dwidth_conv_to_prot_conv_axi_awcache  ),
        .s_axi_awprot   ( fifo_dwidth_conv_to_prot_conv_axi_awprot   ),
        .s_axi_awregion ( fifo_dwidth_conv_to_prot_conv_axi_awregion ),
        .s_axi_awqos    ( fifo_dwidth_conv_to_prot_conv_axi_awqos    ),
        .s_axi_awvalid  ( fifo_dwidth_conv_to_prot_conv_axi_awvalid  ),
        .s_axi_awready  ( fifo_dwidth_conv_to_prot_conv_axi_awready  ),
        .s_axi_wdata    ( fifo_dwidth_conv_to_prot_conv_axi_wdata    ),
        .s_axi_wstrb    ( fifo_dwidth_conv_to_prot_conv_axi_wstrb    ),
        .s_axi_wlast    ( fifo_dwidth_conv_to_prot_conv_axi_wlast    ),
        .s_axi_wvalid   ( fifo_dwidth_conv_to_prot_conv_axi_wvalid   ),
        .s_axi_wready   ( fifo_dwidth_conv_to_prot_conv_axi_wready   ),
        .s_axi_bid      ( fifo_dwidth_conv_to_prot_conv_axi_bid      ),
        .s_axi_bresp    ( fifo_dwidth_conv_to_prot_conv_axi_bresp    ),
        .s_axi_bvalid   ( fifo_dwidth_conv_to_prot_conv_axi_bvalid   ),
        .s_axi_bready   ( fifo_dwidth_conv_to_prot_conv_axi_bready   ),
        .s_axi_arid     ( fifo_dwidth_conv_to_prot_conv_axi_arid     ),
        .s_axi_araddr   ( fifo_dwidth_conv_to_prot_conv_axi_araddr   ),
        .s_axi_arlen    ( fifo_dwidth_conv_to_prot_conv_axi_arlen    ),
        .s_axi_arsize   ( fifo_dwidth_conv_to_prot_conv_axi_arsize   ),
        .s_axi_arburst  ( fifo_dwidth_conv_to_prot_conv_axi_arburst  ),
        .s_axi_arlock   ( fifo_dwidth_conv_to_prot_conv_axi_arlock   ),
        .s_axi_arcache  ( fifo_dwidth_conv_to_prot_conv_axi_arcache  ),
        .s_axi_arprot   ( fifo_dwidth_conv_to_prot_conv_axi_arprot   ),
        .s_axi_arregion ( fifo_dwidth_conv_to_prot_conv_axi_arregion ),
        .s_axi_arqos    ( fifo_dwidth_conv_to_prot_conv_axi_arqos    ),
        .s_axi_arvalid  ( fifo_dwidth_conv_to_prot_conv_axi_arvalid  ),
        .s_axi_arready  ( fifo_dwidth_conv_to_prot_conv_axi_arready  ),
        .s_axi_rid      ( fifo_dwidth_conv_to_prot_conv_axi_rid      ),
        .s_axi_rdata    ( fifo_dwidth_conv_to_prot_conv_axi_rdata    ),
        .s_axi_rresp    ( fifo_dwidth_conv_to_prot_conv_axi_rresp    ),
        .s_axi_rlast    ( fifo_dwidth_conv_to_prot_conv_axi_rlast    ),
        .s_axi_rvalid   ( fifo_dwidth_conv_to_prot_conv_axi_rvalid   ),
        .s_axi_rready   ( fifo_dwidth_conv_to_prot_conv_axi_rready   ),

        // Master port (to AXI Lite fifo interface)
        .m_axi_awaddr   ( prot_conv_to_fifo_axilite_awaddr  ),
        .m_axi_awprot   ( prot_conv_to_fifo_axilite_awprot  ),
        .m_axi_awvalid  ( prot_conv_to_fifo_axilite_awvalid ),
        .m_axi_awready  ( prot_conv_to_fifo_axilite_awready ),
        .m_axi_wdata    ( prot_conv_to_fifo_axilite_wdata   ),
        .m_axi_wstrb    ( prot_conv_to_fifo_axilite_wstrb   ),
        .m_axi_wvalid   ( prot_conv_to_fifo_axilite_wvalid  ),
        .m_axi_wready   ( prot_conv_to_fifo_axilite_wready  ),
        .m_axi_bresp    ( prot_conv_to_fifo_axilite_bresp   ),
        .m_axi_bvalid   ( prot_conv_to_fifo_axilite_bvalid  ),
        .m_axi_bready   ( prot_conv_to_fifo_axilite_bready  ),
        .m_axi_araddr   ( prot_conv_to_fifo_axilite_araddr  ),
        .m_axi_arprot   ( prot_conv_to_fifo_axilite_arprot  ),
        .m_axi_arvalid  ( prot_conv_to_fifo_axilite_arvalid ),
        .m_axi_arready  ( prot_conv_to_fifo_axilite_arready ),
        .m_axi_rdata    ( prot_conv_to_fifo_axilite_rdata   ),
        .m_axi_rresp    ( prot_conv_to_fifo_axilite_rresp   ),
        .m_axi_rvalid   ( prot_conv_to_fifo_axilite_rvalid  ),
        .m_axi_rready   ( prot_conv_to_fifo_axilite_rready  )
    );

    // AXI4 to AXI Lite prot conv (from dwidth converter to cmac CSR)
    xlnx_axi4_to_axilite_d32_converter axi4_to_axilite_d32_converter_to_cmac_u (
        .aclk           ( clock_i       ),
        .aresetn        ( reset_ni      ),

        // AXI4 slave port (from CMAC dwidth converter)
        .s_axi_awid     ( cmac_dwidth_conv_to_prot_conv_axi_awid     ),
        .s_axi_awaddr   ( cmac_dwidth_conv_to_prot_conv_axi_awaddr   ),
        .s_axi_awlen    ( cmac_dwidth_conv_to_prot_conv_axi_awlen    ),
        .s_axi_awsize   ( cmac_dwidth_conv_to_prot_conv_axi_awsize   ),
        .s_axi_awburst  ( cmac_dwidth_conv_to_prot_conv_axi_awburst  ),
        .s_axi_awlock   ( cmac_dwidth_conv_to_prot_conv_axi_awlock   ),
        .s_axi_awcache  ( cmac_dwidth_conv_to_prot_conv_axi_awcache  ),
        .s_axi_awprot   ( cmac_dwidth_conv_to_prot_conv_axi_awprot   ),
        .s_axi_awregion ( cmac_dwidth_conv_to_prot_conv_axi_awregion ),
        .s_axi_awqos    ( cmac_dwidth_conv_to_prot_conv_axi_awqos    ),
        .s_axi_awvalid  ( cmac_dwidth_conv_to_prot_conv_axi_awvalid  ),
        .s_axi_awready  ( cmac_dwidth_conv_to_prot_conv_axi_awready  ),
        .s_axi_wdata    ( cmac_dwidth_conv_to_prot_conv_axi_wdata    ),
        .s_axi_wstrb    ( cmac_dwidth_conv_to_prot_conv_axi_wstrb    ),
        .s_axi_wlast    ( cmac_dwidth_conv_to_prot_conv_axi_wlast    ),
        .s_axi_wvalid   ( cmac_dwidth_conv_to_prot_conv_axi_wvalid   ),
        .s_axi_wready   ( cmac_dwidth_conv_to_prot_conv_axi_wready   ),
        .s_axi_bid      ( cmac_dwidth_conv_to_prot_conv_axi_bid      ),
        .s_axi_bresp    ( cmac_dwidth_conv_to_prot_conv_axi_bresp    ),
        .s_axi_bvalid   ( cmac_dwidth_conv_to_prot_conv_axi_bvalid   ),
        .s_axi_bready   ( cmac_dwidth_conv_to_prot_conv_axi_bready   ),
        .s_axi_arid     ( cmac_dwidth_conv_to_prot_conv_axi_arid     ),
        .s_axi_araddr   ( cmac_dwidth_conv_to_prot_conv_axi_araddr   ),
        .s_axi_arlen    ( cmac_dwidth_conv_to_prot_conv_axi_arlen    ),
        .s_axi_arsize   ( cmac_dwidth_conv_to_prot_conv_axi_arsize   ),
        .s_axi_arburst  ( cmac_dwidth_conv_to_prot_conv_axi_arburst  ),
        .s_axi_arlock   ( cmac_dwidth_conv_to_prot_conv_axi_arlock   ),
        .s_axi_arcache  ( cmac_dwidth_conv_to_prot_conv_axi_arcache  ),
        .s_axi_arprot   ( cmac_dwidth_conv_to_prot_conv_axi_arprot   ),
        .s_axi_arregion ( cmac_dwidth_conv_to_prot_conv_axi_arregion ),
        .s_axi_arqos    ( cmac_dwidth_conv_to_prot_conv_axi_arqos    ),
        .s_axi_arvalid  ( cmac_dwidth_conv_to_prot_conv_axi_arvalid  ),
        .s_axi_arready  ( cmac_dwidth_conv_to_prot_conv_axi_arready  ),
        .s_axi_rid      ( cmac_dwidth_conv_to_prot_conv_axi_rid      ),
        .s_axi_rdata    ( cmac_dwidth_conv_to_prot_conv_axi_rdata    ),
        .s_axi_rresp    ( cmac_dwidth_conv_to_prot_conv_axi_rresp    ),
        .s_axi_rlast    ( cmac_dwidth_conv_to_prot_conv_axi_rlast    ),
        .s_axi_rvalid   ( cmac_dwidth_conv_to_prot_conv_axi_rvalid   ),
        .s_axi_rready   ( cmac_dwidth_conv_to_prot_conv_axi_rready   ),

        // Master port (to AXI Lite CMAC interface)
        .m_axi_awaddr   ( prot_conv_to_cmac_axilite_awaddr  ),
        .m_axi_awprot   ( prot_conv_to_cmac_axilite_awprot  ),
        .m_axi_awvalid  ( prot_conv_to_cmac_axilite_awvalid ),
        .m_axi_awready  ( prot_conv_to_cmac_axilite_awready ),
        .m_axi_wdata    ( prot_conv_to_cmac_axilite_wdata   ),
        .m_axi_wstrb    ( prot_conv_to_cmac_axilite_wstrb   ),
        .m_axi_wvalid   ( prot_conv_to_cmac_axilite_wvalid  ),
        .m_axi_wready   ( prot_conv_to_cmac_axilite_wready  ),
        .m_axi_bresp    ( prot_conv_to_cmac_axilite_bresp   ),
        .m_axi_bvalid   ( prot_conv_to_cmac_axilite_bvalid  ),
        .m_axi_bready   ( prot_conv_to_cmac_axilite_bready  ),
        .m_axi_araddr   ( prot_conv_to_cmac_axilite_araddr  ),
        .m_axi_arprot   ( prot_conv_to_cmac_axilite_arprot  ),
        .m_axi_arvalid  ( prot_conv_to_cmac_axilite_arvalid ),
        .m_axi_arready  ( prot_conv_to_cmac_axilite_arready ),
        .m_axi_rdata    ( prot_conv_to_cmac_axilite_rdata   ),
        .m_axi_rresp    ( prot_conv_to_cmac_axilite_rresp   ),
        .m_axi_rvalid   ( prot_conv_to_cmac_axilite_rvalid  ),
        .m_axi_rready   ( prot_conv_to_cmac_axilite_rready  )
    );

    // AXI Stream FIFO
    xlnx_axis_fifo axis_fifo_u (

        // Clock and reset
        .s_axi_aclk          ( cmac_output_clock_322MHz    ),
        .s_axi_aresetn       ( ~cmac_output_reset_p        ),

        // RX AXI Strem interface
        .axi_str_rxd_tdata   ( rx_cmac_to_fifo_axis_tdata  ),
        .axi_str_rxd_tkeep   ( rx_cmac_to_fifo_axis_tkeep  ),
        .axi_str_rxd_tlast   ( rx_cmac_to_fifo_axis_tlast  ),
        .axi_str_rxd_tready  ( rx_cmac_to_fifo_axis_tready ),    // TODO: check this (could be problematic as CMAC not accept rx tready)
        .axi_str_rxd_tvalid  ( rx_cmac_to_fifo_axis_tvalid ),

        // TX AXI Stream interface
        .axi_str_txd_tdata   ( tx_fifo_to_cmac_axis_tdata  ),
        .axi_str_txd_tkeep   ( tx_fifo_to_cmac_axis_tkeep  ),
        .axi_str_txd_tlast   ( tx_fifo_to_cmac_axis_tlast  ),
        .axi_str_txd_tready  ( tx_fifo_to_cmac_axis_tready ),
        .axi_str_txd_tvalid  ( tx_fifo_to_cmac_axis_tvalid ),

        // AXI Lite (CSR) interface
        .s_axi_araddr        ( prot_conv_to_fifo_axilite_araddr  ),     // 32 bit
        .s_axi_arready       ( prot_conv_to_fifo_axilite_arready ),
        .s_axi_arvalid       ( prot_conv_to_fifo_axilite_arvalid ),
        .s_axi_awaddr        ( prot_conv_to_fifo_axilite_awaddr  ),     // 32 bit
        .s_axi_awready       ( prot_conv_to_fifo_axilite_awready ),
        .s_axi_awvalid       ( prot_conv_to_fifo_axilite_awvalid ),
        .s_axi_bready        ( prot_conv_to_fifo_axilite_bready  ),
        .s_axi_bresp         ( prot_conv_to_fifo_axilite_bresp   ),     // 2 bit
        .s_axi_bvalid        ( prot_conv_to_fifo_axilite_bvalid  ),
        .s_axi_rdata         ( prot_conv_to_fifo_axilite_rdata   ),     // 32 bit
        .s_axi_rready        ( prot_conv_to_fifo_axilite_rready  ),
        .s_axi_rresp         ( prot_conv_to_fifo_axilite_rresp   ),     // 2 bit
        .s_axi_rvalid        ( prot_conv_to_fifo_axilite_rvalid  ),
        .s_axi_wdata         ( prot_conv_to_fifo_axilite_wdata   ),     // 32 bit
        .s_axi_wready        ( prot_conv_to_fifo_axilite_wready  ),
        .s_axi_wstrb         ( prot_conv_to_fifo_axilite_wstrb   ),     // 4 bit
        .s_axi_wvalid        ( prot_conv_to_fifo_axilite_wvalid  ),

        // AXI4 (data) interface
        .s_axi4_araddr       ( clock_conv_to_fifo_axi_araddr     ),
        .s_axi4_arburst      ( clock_conv_to_fifo_axi_arburst    ),
        .s_axi4_arcache      ( clock_conv_to_fifo_axi_arcache    ),
        .s_axi4_arid         ( clock_conv_to_fifo_axi_arid       ),
        .s_axi4_arlen        ( clock_conv_to_fifo_axi_arlen      ),
        .s_axi4_arlock       ( clock_conv_to_fifo_axi_arlock     ),
        .s_axi4_arprot       ( clock_conv_to_fifo_axi_arprot     ),
        .s_axi4_arready      ( clock_conv_to_fifo_axi_arready    ),
        .s_axi4_arsize       ( clock_conv_to_fifo_axi_arsize     ),
        .s_axi4_arvalid      ( clock_conv_to_fifo_axi_arvalid    ),
        .s_axi4_awaddr       ( clock_conv_to_fifo_axi_awaddr     ),
        .s_axi4_awburst      ( clock_conv_to_fifo_axi_awburst    ),
        .s_axi4_awcache      ( clock_conv_to_fifo_axi_awcache    ),
        .s_axi4_awid         ( clock_conv_to_fifo_axi_awid       ),
        .s_axi4_awlen        ( clock_conv_to_fifo_axi_awlen      ),
        .s_axi4_awlock       ( clock_conv_to_fifo_axi_awlock     ),
        .s_axi4_awprot       ( clock_conv_to_fifo_axi_awprot     ),
        .s_axi4_awready      ( clock_conv_to_fifo_axi_awready    ),
        .s_axi4_awsize       ( clock_conv_to_fifo_axi_awsize     ),
        .s_axi4_awvalid      ( clock_conv_to_fifo_axi_awvalid    ),
        .s_axi4_bid          ( clock_conv_to_fifo_axi_bid        ),
        .s_axi4_bready       ( clock_conv_to_fifo_axi_bready     ),
        .s_axi4_bresp        ( clock_conv_to_fifo_axi_bresp      ),
        .s_axi4_bvalid       ( clock_conv_to_fifo_axi_bvalid     ),
        .s_axi4_rdata        ( clock_conv_to_fifo_axi_rdata      ),
        .s_axi4_rid          ( clock_conv_to_fifo_axi_rid        ),
        .s_axi4_rlast        ( clock_conv_to_fifo_axi_rlast      ),
        .s_axi4_rready       ( clock_conv_to_fifo_axi_rready     ),
        .s_axi4_rresp        ( clock_conv_to_fifo_axi_rresp      ),
        .s_axi4_rvalid       ( clock_conv_to_fifo_axi_rvalid     ),
        .s_axi4_wdata        ( clock_conv_to_fifo_axi_wdata      ),
        .s_axi4_wlast        ( clock_conv_to_fifo_axi_wlast      ),
        .s_axi4_wready       ( clock_conv_to_fifo_axi_wready     ),
        .s_axi4_wstrb        ( clock_conv_to_fifo_axi_wstrb      ),
        .s_axi4_wvalid       ( clock_conv_to_fifo_axi_wvalid     ),

        // Resets out
        .mm2s_prmry_reset_out_n ( /*Not connected*/ ),
        .s2mm_prmry_reset_out_n ( /*Not connected*/ ),

        // Interrupt
        .interrupt              ( fifo_interrupt    )
    );


    // CMAC
    xlnx_cmac cmac_u (


        // GT ref clock 156.25 MHz differential
        .gt_ref_clk_n              ( qsfp0_156mhz_clock_n_i      ),
        .gt_ref_clk_p              ( qsfp0_156mhz_clock_p_i      ),

        // GT ports (to the physical pin) 4 differential lanes for each direction (rx and tx)
        .gt_rxn_in                 ( qsfpx_rxn_i                 ),
        .gt_rxp_in                 ( qsfpx_rxp_i                 ),
        .gt_txn_out                ( qsfpx_txn_o                 ),
        .gt_txp_out                ( qsfpx_txp_o                 ),

        // AXIS TX interface
        .tx_axis_tdata             ( tx_fifo_to_cmac_axis_tdata  ),      // 512 bit
        .tx_axis_tkeep             ( tx_fifo_to_cmac_axis_tkeep  ),      //  64 bit
        .tx_axis_tlast             ( tx_fifo_to_cmac_axis_tlast  ),
        .tx_axis_tready            ( tx_fifo_to_cmac_axis_tready ),
        .tx_axis_tuser             ( tx_fifo_to_cmac_axis_tuser  ),
        .tx_axis_tvalid            ( tx_fifo_to_cmac_axis_tvalid ),

        // AXIS RX interface
        .rx_axis_tdata             ( rx_cmac_to_fifo_axis_tdata  ),      // 512 bit
        .rx_axis_tkeep             ( rx_cmac_to_fifo_axis_tkeep  ),      //  64 bit
        .rx_axis_tlast             ( rx_cmac_to_fifo_axis_tlast  ),
        .rx_axis_tuser             ( rx_cmac_to_fifo_axis_tuser  ),
        .rx_axis_tvalid            ( rx_cmac_to_fifo_axis_tvalid ),


        // AXI Lite interface ( CSR space )
        .s_axi_aclk                ( clock_i                           ),
        .s_axi_sreset              ( ~reset_ni                         ),     // Active high  TODO: check this, could need synchronizers or delay...

        .s_axi_araddr              ( prot_conv_to_cmac_axilite_araddr  ),     // 32 bit
        .s_axi_arready             ( prot_conv_to_cmac_axilite_arready ),
        .s_axi_arvalid             ( prot_conv_to_cmac_axilite_arvalid ),
        .s_axi_awaddr              ( prot_conv_to_cmac_axilite_awaddr  ),     // 32 bit
        .s_axi_awready             ( prot_conv_to_cmac_axilite_awready ),
        .s_axi_awvalid             ( prot_conv_to_cmac_axilite_awvalid ),
        .s_axi_bready              ( prot_conv_to_cmac_axilite_bready  ),
        .s_axi_bresp               ( prot_conv_to_cmac_axilite_bresp   ),     // 2 bit
        .s_axi_bvalid              ( prot_conv_to_cmac_axilite_bvalid  ),
        .s_axi_rdata               ( prot_conv_to_cmac_axilite_rdata   ),     // 32 bit
        .s_axi_rready              ( prot_conv_to_cmac_axilite_rready  ),
        .s_axi_rresp               ( prot_conv_to_cmac_axilite_rresp   ),     // 2 bit
        .s_axi_rvalid              ( prot_conv_to_cmac_axilite_rvalid  ),
        .s_axi_wdata               ( prot_conv_to_cmac_axilite_wdata   ),     // 32 bit
        .s_axi_wready              ( prot_conv_to_cmac_axilite_wready  ),
        .s_axi_wstrb               ( prot_conv_to_cmac_axilite_wstrb   ),     // 4 bit
        .s_axi_wvalid              ( prot_conv_to_cmac_axilite_wvalid  ),


        // CMAC output clocks at 322,26 MHz (these two are the same clock, let's use only txusrclk2)
        .gt_txusrclk2              ( cmac_output_clock_322MHz ),
        .gt_rxusrclk2              ( /* Not connected */      ),

        // CMAC output ref clock (this is the same clock as gt_ref_clk, but not differential)
        .gt_ref_clk_out            ( /*Not connected*/ ),

        // CMAC other output clocks (these are other 4 clocks at 322,26 MHz)
        .gt_rxrecclkout            ( /*Not connected*/ ),

        // CMAC output resets (again these are the same reset, let's use only usr_tx_reset)
        .usr_tx_reset              ( cmac_output_reset_p ),   // Active high
        .usr_rx_reset              ( /* Not connected */ ),   // Active high


        // CMAC input clocks and resets
        .init_clk                  ( clock_i      ),
        .sys_reset                 ( ~reset_ni    ),   // Active high  TODO: check this, could need synchronizers or delay...

        .rx_clk                    ( cmac_output_clock_322MHz ),   // 322,26 MHz
        .core_rx_reset             ( 1'b0                     ),   // Active high
        .core_tx_reset             ( 1'b0                     ),   // Active high
        .gtwiz_reset_tx_datapath   ( 1'b0                     ),   // Active high
        .gtwiz_reset_rx_datapath   ( 1'b0                     ),   // Active high

        // DRP (Dynamic Reconfiguration Port ) interface (not needed)
        .core_drp_reset            ( 1'b0              ),   // Active high
        .drp_clk                   ( clock_i           ),   // This should be the same as init_clk
        .drp_addr                  ( '0                ),   // 10 bit
        .drp_di                    ( '0                ),   // 16 bit
        .drp_en                    ( '0                ),
        .drp_we                    ( '0                ),
        .drp_do                    ( /*Not connected*/ ),   // 16 bit
        .drp_rdy                   ( /*Not connected*/ ),

        // Loopback interface (not needed for now)
        .gt_loopback_in            ( '0 ),   // 12 bit

        // TX preamble (not needed for now)
        .tx_preamblein             ( '0                ),   // 56 bit

        // RX preamble (not needed for now)
        .rx_preambleout            ( /*Not connected*/ ),   // 56 bit


        // ctl TX, control interface for tx (not needed as we are using axilite)
        .ctl_tx_send_idle          ( 1'b0 ),
        .ctl_tx_send_lfi           ( 1'b0 ),
        .ctl_tx_send_rfi           ( 1'b0 ),

        // flow control interface for tx (not needed as we are using axilite)
        .ctl_tx_pause_req          ( '0   ),  // 9 bit
        .ctl_tx_resend_pause       ( 1'b0 ),

        // stat TX, status interface for tx (not needed as we are using axilite)
        .stat_tx_bad_fcs                  ( /*Not connected*/ ),
        .stat_tx_broadcast                ( /*Not connected*/ ),
        .stat_tx_frame_error              ( /*Not connected*/ ),
        .stat_tx_local_fault              ( /*Not connected*/ ),
        .stat_tx_multicast                ( /*Not connected*/ ),
        .stat_tx_packet_64_bytes          ( /*Not connected*/ ),
        .stat_tx_packet_65_127_bytes      ( /*Not connected*/ ),
        .stat_tx_packet_128_255_bytes     ( /*Not connected*/ ),
        .stat_tx_packet_256_511_bytes     ( /*Not connected*/ ),
        .stat_tx_packet_512_1023_bytes    ( /*Not connected*/ ),
        .stat_tx_packet_1024_1518_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_1519_1522_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_1523_1548_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_1549_2047_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_2048_4095_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_4096_8191_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_8192_9215_bytes   ( /*Not connected*/ ),
        .stat_tx_packet_large             ( /*Not connected*/ ),
        .stat_tx_packet_small             ( /*Not connected*/ ),
        .stat_tx_total_bytes              ( /*Not connected*/ ),   //  6 bit
        .stat_tx_total_good_bytes         ( /*Not connected*/ ),   // 14 bit
        .stat_tx_total_good_packets       ( /*Not connected*/ ),
        .stat_tx_total_packets            ( /*Not connected*/ ),
        .stat_tx_unicast                  ( /*Not connected*/ ),
        .stat_tx_vlan                     ( /*Not connected*/ ),
        .stat_tx_user_pause               ( /*Not connected*/ ),
        .stat_tx_pause_valid              ( /*Not connected*/ ),   // 9 bit
        .stat_tx_pause                    ( /*Not connected*/ ),

        // stat RX, status interface for rx (not needed as we are using axilite)
        .stat_rx_aligned                  ( /*Not connected*/ ),
        .stat_rx_aligned_err              ( /*Not connected*/ ),
        .stat_rx_bad_code                 ( /*Not connected*/ ),   // 3 bit
        .stat_rx_bad_fcs                  ( /*Not connected*/ ),   // 3 bit
        .stat_rx_bad_preamble             ( /*Not connected*/ ),
        .stat_rx_bad_sfd                  ( /*Not connected*/ ),
        .stat_rx_bip_err_0                ( /*Not connected*/ ),
        .stat_rx_bip_err_1                ( /*Not connected*/ ),
        .stat_rx_bip_err_2                ( /*Not connected*/ ),
        .stat_rx_bip_err_3                ( /*Not connected*/ ),
        .stat_rx_bip_err_4                ( /*Not connected*/ ),
        .stat_rx_bip_err_5                ( /*Not connected*/ ),
        .stat_rx_bip_err_6                ( /*Not connected*/ ),
        .stat_rx_bip_err_7                ( /*Not connected*/ ),
        .stat_rx_bip_err_8                ( /*Not connected*/ ),
        .stat_rx_bip_err_9                ( /*Not connected*/ ),
        .stat_rx_bip_err_10               ( /*Not connected*/ ),
        .stat_rx_bip_err_11               ( /*Not connected*/ ),
        .stat_rx_bip_err_12               ( /*Not connected*/ ),
        .stat_rx_bip_err_13               ( /*Not connected*/ ),
        .stat_rx_bip_err_14               ( /*Not connected*/ ),
        .stat_rx_bip_err_15               ( /*Not connected*/ ),
        .stat_rx_bip_err_16               ( /*Not connected*/ ),
        .stat_rx_bip_err_17               ( /*Not connected*/ ),
        .stat_rx_bip_err_18               ( /*Not connected*/ ),
        .stat_rx_bip_err_19               ( /*Not connected*/ ),
        .stat_rx_block_lock               ( /*Not connected*/ ),   // 20 bit
        .stat_rx_broadcast                ( /*Not connected*/ ),
        .stat_rx_fragment                 ( /*Not connected*/ ),   //  3 bit
        .stat_rx_framing_err_0            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_1            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_2            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_3            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_4            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_5            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_6            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_7            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_8            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_9            ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_10           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_11           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_12           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_13           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_14           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_15           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_16           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_17           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_18           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_19           ( /*Not connected*/ ),   //  2 bit
        .stat_rx_framing_err_valid_0      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_1      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_2      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_3      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_4      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_5      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_6      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_7      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_8      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_9      ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_10     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_11     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_12     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_13     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_14     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_15     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_16     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_17     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_18     ( /*Not connected*/ ),
        .stat_rx_framing_err_valid_19     ( /*Not connected*/ ),
        .stat_rx_got_signal_os            ( /*Not connected*/ ),
        .stat_rx_hi_ber                   ( /*Not connected*/ ),
        .stat_rx_inrangeerr               ( /*Not connected*/ ),
        .stat_rx_internal_local_fault     ( /*Not connected*/ ),
        .stat_rx_jabber                   ( /*Not connected*/ ),
        .stat_rx_local_fault              ( /*Not connected*/ ),
        .stat_rx_mf_err                   ( /*Not connected*/ ),    // 20 bit
        .stat_rx_mf_len_err               ( /*Not connected*/ ),    // 20 bit
        .stat_rx_mf_repeat_err            ( /*Not connected*/ ),    // 20 bit
        .stat_rx_misaligned               ( /*Not connected*/ ),
        .stat_rx_multicast                ( /*Not connected*/ ),
        .stat_rx_oversize                 ( /*Not connected*/ ),
        .stat_rx_packet_64_bytes          ( /*Not connected*/ ),
        .stat_rx_packet_65_127_bytes      ( /*Not connected*/ ),
        .stat_rx_packet_128_255_bytes     ( /*Not connected*/ ),
        .stat_rx_packet_256_511_bytes     ( /*Not connected*/ ),
        .stat_rx_packet_512_1023_bytes    ( /*Not connected*/ ),
        .stat_rx_packet_1024_1518_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_1519_1522_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_1523_1548_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_1549_2047_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_2048_4095_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_4096_8191_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_8192_9215_bytes   ( /*Not connected*/ ),
        .stat_rx_packet_bad_fcs           ( /*Not connected*/ ),
        .stat_rx_packet_large             ( /*Not connected*/ ),
        .stat_rx_packet_small             ( /*Not connected*/ ),   //  3 bit
        .stat_rx_pause                    ( /*Not connected*/ ),
        .stat_rx_pause_quanta0            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta1            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta2            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta3            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta4            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta5            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta6            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta7            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_quanta8            ( /*Not connected*/ ),   // 16 bit
        .stat_rx_pause_req                ( /*Not connected*/ ),   //  9 bit
        .stat_rx_pause_valid              ( /*Not connected*/ ),   //  9 bit
        .stat_rx_user_pause               ( /*Not connected*/ ),
        .stat_rx_received_local_fault     ( /*Not connected*/ ),
        .stat_rx_remote_fault             ( /*Not connected*/ ),
        .stat_rx_status                   ( /*Not connected*/ ),
        .stat_rx_stomped_fcs              ( /*Not connected*/ ),   //  3 bit
        .stat_rx_synced                   ( /*Not connected*/ ),   // 20 bit
        .stat_rx_synced_err               ( /*Not connected*/ ),   // 20 bit
        .stat_rx_test_pattern_mismatch    ( /*Not connected*/ ),   //  3 bit
        .stat_rx_toolong                  ( /*Not connected*/ ),
        .stat_rx_total_bytes              ( /*Not connected*/ ),   //  7 bit
        .stat_rx_total_good_bytes         ( /*Not connected*/ ),   // 14 bit
        .stat_rx_total_good_packets       ( /*Not connected*/ ),
        .stat_rx_total_packets            ( /*Not connected*/ ),   //  3 bit
        .stat_rx_truncated                ( /*Not connected*/ ),
        .stat_rx_undersize                ( /*Not connected*/ ),   //  3 bit
        .stat_rx_unicast                  ( /*Not connected*/ ),
        .stat_rx_vlan                     ( /*Not connected*/ ),
        .stat_rx_pcsl_demuxed             ( /*Not connected*/ ),   // 20 bit
        .stat_rx_pcsl_number_0            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_1            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_2            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_3            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_4            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_5            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_6            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_7            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_8            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_9            ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_10           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_11           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_12           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_13           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_14           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_15           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_16           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_17           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_18           ( /*Not connected*/ ),   //  5 bit
        .stat_rx_pcsl_number_19           ( /*Not connected*/ ),   //  5 bit


        // RS-FEC (Reed Solomon Forward Error Correction) status interface (not needed for now)
        .stat_rx_rsfec_am_lock0               ( /*Not connected*/ ),
        .stat_rx_rsfec_am_lock1               ( /*Not connected*/ ),
        .stat_rx_rsfec_am_lock2               ( /*Not connected*/ ),
        .stat_rx_rsfec_am_lock3               ( /*Not connected*/ ),
        .stat_rx_rsfec_corrected_cw_inc       ( /*Not connected*/ ),
        .stat_rx_rsfec_cw_inc                 ( /*Not connected*/ ),
        .stat_rx_rsfec_err_count0_inc         ( /*Not connected*/ ),   //  3 bit
        .stat_rx_rsfec_err_count1_inc         ( /*Not connected*/ ),   //  3 bit
        .stat_rx_rsfec_err_count2_inc         ( /*Not connected*/ ),   //  3 bit
        .stat_rx_rsfec_err_count3_inc         ( /*Not connected*/ ),   //  3 bit
        .stat_rx_rsfec_hi_ser                 ( /*Not connected*/ ),
        .stat_rx_rsfec_lane_alignment_status  ( /*Not connected*/ ),
        .stat_rx_rsfec_lane_fill_0            ( /*Not connected*/ ),   // 14 bit
        .stat_rx_rsfec_lane_fill_1            ( /*Not connected*/ ),   // 14 bit
        .stat_rx_rsfec_lane_fill_2            ( /*Not connected*/ ),   // 14 bit
        .stat_rx_rsfec_lane_fill_3            ( /*Not connected*/ ),   // 14 bit
        .stat_rx_rsfec_lane_mapping           ( /*Not connected*/ ),   //  8 bit
        .stat_rx_rsfec_uncorrected_cw_inc     ( /*Not connected*/ ),

        // RX OTN (Optical Transport Network)
        .rx_otn_bip8_0                        ( /*Not connected*/ ),   //  8 bit
        .rx_otn_bip8_1                        ( /*Not connected*/ ),   //  8 bit
        .rx_otn_bip8_2                        ( /*Not connected*/ ),   //  8 bit
        .rx_otn_bip8_3                        ( /*Not connected*/ ),   //  8 bit
        .rx_otn_bip8_4                        ( /*Not connected*/ ),   //  8 bit
        .rx_otn_data_0                        ( /*Not connected*/ ),   // 66 bit
        .rx_otn_data_1                        ( /*Not connected*/ ),   // 66 bit
        .rx_otn_data_2                        ( /*Not connected*/ ),   // 66 bit
        .rx_otn_data_3                        ( /*Not connected*/ ),   // 66 bit
        .rx_otn_data_4                        ( /*Not connected*/ ),   // 66 bit
        .rx_otn_ena                           ( /*Not connected*/ ),
        .rx_otn_lane0                         ( /*Not connected*/ ),
        .rx_otn_vlmarker                      ( /*Not connected*/ ),

        // GT power good
        .gt_powergoodout                      ( /*Not connected*/ ),

        // TX overflow and underflow errors (these are for the LBUS interface, we are using the AXIS interface, so not needed)
        .tx_ovfout                            ( /*Not connected*/ ),
        .tx_unfout                            ( /*Not connected*/ )
    );

endmodule
