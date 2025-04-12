// Author: Vincenzo Merola <vincenzo.merola2@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl


// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////

) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////

    input  logic        clk_i,
    input  logic        rst_ni,
	output logic        interrupt_o,

    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI Slave Interfaces
    `DEFINE_AXILITE_SLAVE_PORTS(control)

);

    // HLS top
    krnl_vdotprod krnl_vdotprod_u (
        .ap_clk     ( clk_i       ),
        .ap_rst_n   ( rst_ni      ),
        .interrupt  ( interrupt_o ),
        // AXI-lite slave
        .s_axi_control_AWVALID  ( control_axilite_awvalid ),
        .s_axi_control_AWREADY  ( control_axilite_awready ),
        .s_axi_control_AWADDR   ( control_axilite_awaddr  ),
        .s_axi_control_WVALID   ( control_axilite_wvalid  ),
        .s_axi_control_WREADY   ( control_axilite_wready  ),
        .s_axi_control_WDATA    ( control_axilite_wdata   ),
        .s_axi_control_WSTRB    ( control_axilite_wstrb   ),
        .s_axi_control_ARVALID  ( control_axilite_arvalid ),
        .s_axi_control_ARREADY  ( control_axilite_arready ),
        .s_axi_control_ARADDR   ( control_axilite_araddr  ),
        .s_axi_control_RVALID   ( control_axilite_rvalid  ),
        .s_axi_control_RREADY   ( control_axilite_rready  ),
        .s_axi_control_RDATA    ( control_axilite_rdata   ),
        .s_axi_control_RRESP    ( control_axilite_rresp   ),
        .s_axi_control_BVALID   ( control_axilite_bvalid  ),
        .s_axi_control_BREADY   ( control_axilite_bready  ),
        .s_axi_control_BRESP    ( control_axilite_bresp   )
    );

endmodule : custom_top_wrapper