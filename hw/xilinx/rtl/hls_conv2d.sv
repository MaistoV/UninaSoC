// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description:
//  Wrapper module for HLS CONV2D IP with clock bridges an AXI adapters.
// Note:
//  This is static for now, but could be extended to a generic shell for HLS IP, with CDC support, multiple interfaces, etc.
//
// Architecture: HLS IP integration (with CDC)
//    _________________________________________
//   |                                         |
//   |  xlnx_axi_clock_converter_hls_control_u |<--- HLS_CONTROL
//   |_________________________________________|
//                     | HLS_CONTROL
//    _________________v_______________________
//   |                                         |
//   |   xlnx_axi4_to_axilite_converter_hls_u  |
//   |_________________________________________|
//                     | HLS_CONTROL_axilite
//                  ___v____
//                 |        |  HLS_gmem0_d512
//                 | HLS IP |-----------------------------> to HBUS
//                 |________|
//

module hls_conv2d_wrapper # (
    // MBUS parameters
    paraemter MBUS_AXI_ADDR_WIDTH = 32,
    paraemter MBUS_AXI_DATA_WIDTH = 32,
    paraemter MBUS_AXI_ID_WIDTH   = 4,
    // HBUS parameters
    paraemter HBUS_AXI_DATA_WIDTH = 512,
    paraemter HBUS_AXI_ADDR_WIDTH = 32,
    paraemter HBUS_AXI_ID_WIDTH   = 4
) (
    // MBUS clock and reset
    input  logic main_clk_i,
    input  logic main_rstn_i,

    // HLS IP clock and reset (from HBUS)
    input  logic HLS_CONTROL_clk_i,
    input  logic HLS_CONTROL_rstn_i,

    // Slave for control
    `DEFINE_AXI_SLAVE(s_HLS_CONTROL, AXI_DATA_WIDTH),

    // Master to HBUS
    `DEFINE_AXI_MASTER(m_HLS_gmem0_d512, HBUS_AXI_DATA_WIDTH)

);

    //////////////////
    // Declarations //
    //////////////////

    // HLS_DOTPROD_CONTROL AXI-lite
    `DECLARE_AXILITE_BUS(HLS_CONTROL);

    /////////////
    // Modules //
    /////////////

    // Add clock bridges for HLS_CONTROL
    `ifdef HLS_CONTROL_HAS_CLOCK_DOMAIN
        // HLS_CONTROL <- HLS_CONTROL
        xlnx_axi_clock_converter xlnx_axi_clock_converter_hls_control_u (
            // AXI4 Slave from MBUS
            .s_axi_aclk     ( main_clk_i  ),
            .s_axi_aresetn  ( main_rstn_i ),
            .s_axi_awid     ( HLS_CONTROL_axi_awid     ),
            .s_axi_awaddr   ( HLS_CONTROL_axi_awaddr   ),
            .s_axi_awlen    ( HLS_CONTROL_axi_awlen    ),
            .s_axi_awsize   ( HLS_CONTROL_axi_awsize   ),
            .s_axi_awburst  ( HLS_CONTROL_axi_awburst  ),
            .s_axi_awlock   ( HLS_CONTROL_axi_awlock   ),
            .s_axi_awcache  ( HLS_CONTROL_axi_awcache  ),
            .s_axi_awprot   ( HLS_CONTROL_axi_awprot   ),
            .s_axi_awqos    ( HLS_CONTROL_axi_awqos    ),
            .s_axi_awvalid  ( HLS_CONTROL_axi_awvalid  ),
            .s_axi_awready  ( HLS_CONTROL_axi_awready  ),
            .s_axi_awregion ( HLS_CONTROL_axi_awregion ),
            .s_axi_wdata    ( HLS_CONTROL_axi_wdata    ),
            .s_axi_wstrb    ( HLS_CONTROL_axi_wstrb    ),
            .s_axi_wlast    ( HLS_CONTROL_axi_wlast    ),
            .s_axi_wvalid   ( HLS_CONTROL_axi_wvalid   ),
            .s_axi_wready   ( HLS_CONTROL_axi_wready   ),
            .s_axi_bid      ( HLS_CONTROL_axi_bid      ),
            .s_axi_bresp    ( HLS_CONTROL_axi_bresp    ),
            .s_axi_bvalid   ( HLS_CONTROL_axi_bvalid   ),
            .s_axi_bready   ( HLS_CONTROL_axi_bready   ),
            .s_axi_arid     ( HLS_CONTROL_axi_arid     ),
            .s_axi_araddr   ( HLS_CONTROL_axi_araddr   ),
            .s_axi_arlen    ( HLS_CONTROL_axi_arlen    ),
            .s_axi_arsize   ( HLS_CONTROL_axi_arsize   ),
            .s_axi_arburst  ( HLS_CONTROL_axi_arburst  ),
            .s_axi_arlock   ( HLS_CONTROL_axi_arlock   ),
            .s_axi_arregion ( HLS_CONTROL_axi_arregion ),
            .s_axi_arcache  ( HLS_CONTROL_axi_arcache  ),
            .s_axi_arprot   ( HLS_CONTROL_axi_arprot   ),
            .s_axi_arqos    ( HLS_CONTROL_axi_arqos    ),
            .s_axi_arvalid  ( HLS_CONTROL_axi_arvalid  ),
            .s_axi_arready  ( HLS_CONTROL_axi_arready  ),
            .s_axi_rid      ( HLS_CONTROL_axi_rid      ),
            .s_axi_rdata    ( HLS_CONTROL_axi_rdata    ),
            .s_axi_rresp    ( HLS_CONTROL_axi_rresp    ),
            .s_axi_rlast    ( HLS_CONTROL_axi_rlast    ),
            .s_axi_rvalid   ( HLS_CONTROL_axi_rvalid   ),
            .s_axi_rready   ( HLS_CONTROL_axi_rready   ),

            // ALI-lite master to HLS IP
            .m_axi_aclk     ( HLS_CONTROL_clk  ),
            .m_axi_aresetn  ( HLS_CONTROL_rstn ),
            .m_axi_awid     ( HLS_CONTROL_axi_awid      ),
            .m_axi_awaddr   ( HLS_CONTROL_axi_awaddr    ),
            .m_axi_awlen    ( HLS_CONTROL_axi_awlen     ),
            .m_axi_awsize   ( HLS_CONTROL_axi_awsize    ),
            .m_axi_awburst  ( HLS_CONTROL_axi_awburst   ),
            .m_axi_awlock   ( HLS_CONTROL_axi_awlock    ),
            .m_axi_awcache  ( HLS_CONTROL_axi_awcache   ),
            .m_axi_awprot   ( HLS_CONTROL_axi_awprot    ),
            .m_axi_awregion ( HLS_CONTROL_axi_awregion  ),
            .m_axi_awqos    ( HLS_CONTROL_axi_awqos     ),
            .m_axi_awvalid  ( HLS_CONTROL_axi_awvalid   ),
            .m_axi_awready  ( HLS_CONTROL_axi_awready   ),
            .m_axi_wdata    ( HLS_CONTROL_axi_wdata     ),
            .m_axi_wstrb    ( HLS_CONTROL_axi_wstrb     ),
            .m_axi_wlast    ( HLS_CONTROL_axi_wlast     ),
            .m_axi_wvalid   ( HLS_CONTROL_axi_wvalid    ),
            .m_axi_wready   ( HLS_CONTROL_axi_wready    ),
            .m_axi_bid      ( HLS_CONTROL_axi_bid       ),
            .m_axi_bresp    ( HLS_CONTROL_axi_bresp     ),
            .m_axi_bvalid   ( HLS_CONTROL_axi_bvalid    ),
            .m_axi_bready   ( HLS_CONTROL_axi_bready    ),
            .m_axi_arid     ( HLS_CONTROL_axi_arid      ),
            .m_axi_araddr   ( HLS_CONTROL_axi_araddr    ),
            .m_axi_arlen    ( HLS_CONTROL_axi_arlen     ),
            .m_axi_arsize   ( HLS_CONTROL_axi_arsize    ),
            .m_axi_arburst  ( HLS_CONTROL_axi_arburst   ),
            .m_axi_arlock   ( HLS_CONTROL_axi_arlock    ),
            .m_axi_arcache  ( HLS_CONTROL_axi_arcache   ),
            .m_axi_arprot   ( HLS_CONTROL_axi_arprot    ),
            .m_axi_arregion ( HLS_CONTROL_axi_arregion  ),
            .m_axi_arqos    ( HLS_CONTROL_axi_arqos     ),
            .m_axi_arvalid  ( HLS_CONTROL_axi_arvalid   ),
            .m_axi_arready  ( HLS_CONTROL_axi_arready   ),
            .m_axi_rid      ( HLS_CONTROL_axi_rid       ),
            .m_axi_rdata    ( HLS_CONTROL_axi_rdata     ),
            .m_axi_rresp    ( HLS_CONTROL_axi_rresp     ),
            .m_axi_rlast    ( HLS_CONTROL_axi_rlast     ),
            .m_axi_rvalid   ( HLS_CONTROL_axi_rvalid    ),
            .m_axi_rready   ( HLS_CONTROL_axi_rready    )
        );
    `else // notdefined(HLS_CONTROL_HAS_CLOCK_DOMAIN)
        // Error out for now
        $error("This version of HLS CONV2D IP must be in HBUS clock domain")
    `endif

    // AXI converter for HLS_DOTPROD_CONTROL
    xlnx_axi4_to_axilite_converter xlnx_axi4_to_axilite_converter_hls_u (
        // Clock and reset
        .aclk               ( HLS_CONTROL_clk_i         ), // input wire s_aclk
        .aresetn            ( HLS_CONTROL_rstn_i        ), // input wire s_aresetn
        // Slave interface
        .s_axi_awid         ( HLS_CONTROL_axi_awid      ), // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr       ( HLS_CONTROL_axi_awaddr    ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen        ( HLS_CONTROL_axi_awlen     ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize       ( HLS_CONTROL_axi_awsize    ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst      ( HLS_CONTROL_axi_awburst   ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock       ( HLS_CONTROL_axi_awlock    ), // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache      ( HLS_CONTROL_axi_awcache   ), // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot       ( HLS_CONTROL_axi_awprot    ), // input wire [2 : 0] s_axi_awprot
        .s_axi_awregion     ( HLS_CONTROL_axi_awregion  ), // input wire [3 : 0] s_axi_awregion
        .s_axi_awqos        ( HLS_CONTROL_axi_awqos     ), // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid      ( HLS_CONTROL_axi_awvalid   ), // input wire s_axi_awvalid
        .s_axi_awready      ( HLS_CONTROL_axi_awready   ), // output wire s_axi_awready
        .s_axi_wdata        ( HLS_CONTROL_axi_wdata     ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb        ( HLS_CONTROL_axi_wstrb     ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast        ( HLS_CONTROL_axi_wlast     ), // input wire s_axi_wlast
        .s_axi_wvalid       ( HLS_CONTROL_axi_wvalid    ), // input wire s_axi_wvalid
        .s_axi_wready       ( HLS_CONTROL_axi_wready    ), // output wire s_axi_wready
        .s_axi_bid          ( HLS_CONTROL_axi_bid       ), // output wire [1 : 0] s_axi_bid
        .s_axi_bresp        ( HLS_CONTROL_axi_bresp     ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid       ( HLS_CONTROL_axi_bvalid    ), // output wire s_axi_bvalid
        .s_axi_bready       ( HLS_CONTROL_axi_bready    ), // input wire s_axi_bready
        .s_axi_arid         ( HLS_CONTROL_axi_arid      ), // input wire [1 : 0] s_axi_arid
        .s_axi_araddr       ( HLS_CONTROL_axi_araddr    ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen        ( HLS_CONTROL_axi_arlen     ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize       ( HLS_CONTROL_axi_arsize    ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst      ( HLS_CONTROL_axi_arburst   ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock       ( HLS_CONTROL_axi_arlock    ), // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache      ( HLS_CONTROL_axi_arcache   ), // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot       ( HLS_CONTROL_axi_arprot    ), // input wire [2 : 0] s_axi_arprot
        .s_axi_arregion     ( HLS_CONTROL_axi_arregion  ), // input wire [3 : 0] s_axi_arregion
        .s_axi_arqos        ( HLS_CONTROL_axi_arqos     ), // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid      ( HLS_CONTROL_axi_arvalid   ), // input wire s_axi_arvalid
        .s_axi_arready      ( HLS_CONTROL_axi_arready   ), // output wire s_axi_arready
        .s_axi_rid          ( HLS_CONTROL_axi_rid       ), // output wire [1 : 0] s_axi_rid
        .s_axi_rdata        ( HLS_CONTROL_axi_rdata     ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp        ( HLS_CONTROL_axi_rresp     ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast        ( HLS_CONTROL_axi_rlast     ), // output wire s_axi_rlast
        .s_axi_rvalid       ( HLS_CONTROL_axi_rvalid    ), // output wire s_axi_rvalid
        .s_axi_rready       ( HLS_CONTROL_axi_rready    ), // input wire s_axi_rready
        // Master interface
        .m_axi_awaddr       ( HLS_CONTROL_axilite_awaddr        ), // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot       ( HLS_CONTROL_axilite_awprot        ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid      ( HLS_CONTROL_axilite_awvalid       ), // output wire m_axi_awvalid
        .m_axi_awready      ( HLS_CONTROL_axilite_awready       ), // input wire m_axi_awready
        .m_axi_wdata        ( HLS_CONTROL_axilite_wdata         ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb        ( HLS_CONTROL_axilite_wstrb         ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid       ( HLS_CONTROL_axilite_wvalid        ), // output wire m_axi_wvalid
        .m_axi_wready       ( HLS_CONTROL_axilite_wready        ), // input wire m_axi_wready
        .m_axi_bresp        ( HLS_CONTROL_axilite_bresp         ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid       ( HLS_CONTROL_axilite_bvalid        ), // input wire m_axi_bvalid
        .m_axi_bready       ( HLS_CONTROL_axilite_bready        ), // output wire m_axi_bready
        .m_axi_araddr       ( HLS_CONTROL_axilite_araddr        ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot       ( HLS_CONTROL_axilite_arprot        ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid      ( HLS_CONTROL_axilite_arvalid       ), // output wire m_axi_arvalid
        .m_axi_arready      ( HLS_CONTROL_axilite_arready       ), // input wire m_axi_arready
        .m_axi_rdata        ( HLS_CONTROL_axilite_rdata         ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp        ( HLS_CONTROL_axilite_rresp         ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid       ( HLS_CONTROL_axilite_rvalid        ), // input wire m_axi_rvalid
        .m_axi_rready       ( HLS_CONTROL_axilite_rready        )  // output wire m_axi_rready
    );

    // DEBUG
    (* mark_debug = 1 *) logic hls_interrupt_o;
    // TODO: sychronize hls_interrupt_o to main clock domain
    // logic hls_interrupt_sync_main;

    // NOTE: AXI_DATA_WITDH=512 for this one, and should only be connected to HBUS
    // HLS core instance
    custom_hls_conv_opt6 custom_hls_conv_opt6_u (
        .clk_i                      ( HLS_CONTROL_clk_i            ), // input wire clk_i
        .rst_ni                     ( HLS_CONTROL_rstn_i           ), // input wire rst_ni
        .interrupt_o                ( hls_interrupt_o              ), // output wire interrupt_o
        .gmem0_axi_awid             ( HLS_gmem0_d512_axi_awid      ),
        .gmem0_axi_awaddr           ( HLS_gmem0_d512_axi_awaddr    ),
        .gmem0_axi_awlen            ( HLS_gmem0_d512_axi_awlen     ),
        .gmem0_axi_awsize           ( HLS_gmem0_d512_axi_awsize    ),
        .gmem0_axi_awburst          ( HLS_gmem0_d512_axi_awburst   ),
        .gmem0_axi_awlock           ( HLS_gmem0_d512_axi_awlock    ),
        .gmem0_axi_awcache          ( HLS_gmem0_d512_axi_awcache   ),
        .gmem0_axi_awprot           ( HLS_gmem0_d512_axi_awprot    ),
        .gmem0_axi_awqos            ( HLS_gmem0_d512_axi_awqos     ),
        .gmem0_axi_awvalid          ( HLS_gmem0_d512_axi_awvalid   ),
        .gmem0_axi_awready          ( HLS_gmem0_d512_axi_awready   ),
        .gmem0_axi_awregion         ( HLS_gmem0_d512_axi_awregion  ),
        .gmem0_axi_wdata            ( HLS_gmem0_d512_axi_wdata     ),
        .gmem0_axi_wstrb            ( HLS_gmem0_d512_axi_wstrb     ),
        .gmem0_axi_wlast            ( HLS_gmem0_d512_axi_wlast     ),
        .gmem0_axi_wvalid           ( HLS_gmem0_d512_axi_wvalid    ),
        .gmem0_axi_wready           ( HLS_gmem0_d512_axi_wready    ),
        .gmem0_axi_bid              ( HLS_gmem0_d512_axi_bid       ),
        .gmem0_axi_bresp            ( HLS_gmem0_d512_axi_bresp     ),
        .gmem0_axi_bvalid           ( HLS_gmem0_d512_axi_bvalid    ),
        .gmem0_axi_bready           ( HLS_gmem0_d512_axi_bready    ),
        .gmem0_axi_araddr           ( HLS_gmem0_d512_axi_araddr    ),
        .gmem0_axi_arlen            ( HLS_gmem0_d512_axi_arlen     ),
        .gmem0_axi_arsize           ( HLS_gmem0_d512_axi_arsize    ),
        .gmem0_axi_arburst          ( HLS_gmem0_d512_axi_arburst   ),
        .gmem0_axi_arlock           ( HLS_gmem0_d512_axi_arlock    ),
        .gmem0_axi_arcache          ( HLS_gmem0_d512_axi_arcache   ),
        .gmem0_axi_arprot           ( HLS_gmem0_d512_axi_arprot    ),
        .gmem0_axi_arqos            ( HLS_gmem0_d512_axi_arqos     ),
        .gmem0_axi_arvalid          ( HLS_gmem0_d512_axi_arvalid   ),
        .gmem0_axi_arready          ( HLS_gmem0_d512_axi_arready   ),
        .gmem0_axi_arid             ( HLS_gmem0_d512_axi_arid      ),
        .gmem0_axi_arregion         ( HLS_gmem0_d512_axi_arregion  ),
        .gmem0_axi_rid              ( HLS_gmem0_d512_axi_rid       ),
        .gmem0_axi_rdata            ( HLS_gmem0_d512_axi_rdata     ),
        .gmem0_axi_rresp            ( HLS_gmem0_d512_axi_rresp     ),
        .gmem0_axi_rlast            ( HLS_gmem0_d512_axi_rlast     ),
        .gmem0_axi_rvalid           ( HLS_gmem0_d512_axi_rvalid    ),
        .gmem0_axi_rready           ( HLS_gmem0_d512_axi_rready    ),
        .control_axilite_awaddr     ( HLS_CONTROL_axilite_awaddr   ), // input wire [31 : 0] control_axilite_awaddr
        .control_axilite_awprot     ( HLS_CONTROL_axilite_awprot   ), // input wire [2 : 0] control_axilite_awprot
        .control_axilite_awvalid    ( HLS_CONTROL_axilite_awvalid  ), // input wire control_axilite_awvalid
        .control_axilite_awready    ( HLS_CONTROL_axilite_awready  ), // output wire control_axilite_awready
        .control_axilite_wdata      ( HLS_CONTROL_axilite_wdata    ), // input wire [31 : 0] control_axilite_wdata
        .control_axilite_wstrb      ( HLS_CONTROL_axilite_wstrb    ), // input wire [3 : 0] control_axilite_wstrb
        .control_axilite_wvalid     ( HLS_CONTROL_axilite_wvalid   ), // input wire control_axilite_wvalid
        .control_axilite_wready     ( HLS_CONTROL_axilite_wready   ), // output wire control_axilite_wready
        .control_axilite_bresp      ( HLS_CONTROL_axilite_bresp    ), // output wire [1 : 0] control_axilite_bresp
        .control_axilite_bvalid     ( HLS_CONTROL_axilite_bvalid   ), // output wire control_axilite_bvalid
        .control_axilite_bready     ( HLS_CONTROL_axilite_bready   ), // input wire control_axilite_bready
        .control_axilite_araddr     ( HLS_CONTROL_axilite_araddr   ), // input wire [31 : 0] control_axilite_araddr
        .control_axilite_arprot     ( HLS_CONTROL_axilite_arprot   ), // input wire [2 : 0] control_axilite_arprot
        .control_axilite_arvalid    ( HLS_CONTROL_axilite_arvalid  ), // input wire control_axilite_arvalid
        .control_axilite_arready    ( HLS_CONTROL_axilite_arready  ), // output wire control_axilite_arready
        .control_axilite_rdata      ( HLS_CONTROL_axilite_rdata    ), // output wire [31 : 0] control_axilite_rdata
        .control_axilite_rresp      ( HLS_CONTROL_axilite_rresp    ), // output wire [1 : 0] control_axilite_rresp
        .control_axilite_rvalid     ( HLS_CONTROL_axilite_rvalid   ), // output wire control_axilite_rvalid
        .control_axilite_rready     ( HLS_CONTROL_axilite_rready   )  // input wire control_axilite_rready
    );

endmodule