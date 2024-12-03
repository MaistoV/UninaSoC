// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: AXI4 Uart - This module encapsulates the AXI lite uart and exposes it as AXI4 full. The uart is selected based on the SOC_CONFIG.
//              EMBEDDED -> AXILITE UART 
//              HPC      -> VIRTUAL UART


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"


module axi4_full_uart (
    input logic clock_i,
    input logic reset_ni,

    // Interrupts
    output logic        int_core_o,
    output logic        int_xdma_o,
    input  logic [1:0]  int_ack_i,

    `ifdef EMBEDDED 
    // RX and TX signas (for embedded only)
    output logic        tx_o,
    input  logic        rx_i,
    `endif

    // AXI4 Slave interface
    `DEFINE_AXI_SLAVE_PORTS(s)
);

    `DECLARE_AXILITE_BUS(uart);
    
    // AXI4 to AXI4-Lite protocol converter
    xlnx_axi4_to_axilite_converter axi4_to_axilite_uart_u (
        .aclk           ( clock_i                   ), // input wire s_axi_aclk
        .aresetn        ( reset_ni                  ), // input wire s_axi_aresetn
        // AXI4 slave port (from xbar)
        .s_axi_awid     ( s_axi_awid     ),            // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr   ( s_axi_awaddr   ),            // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( s_axi_awlen    ),            // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( s_axi_awsize   ),            // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( s_axi_awburst  ),            // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( s_axi_awlock   ),            // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( s_axi_awcache  ),            // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( s_axi_awprot   ),            // input wire [2 : 0] s_axi_awprot
        .s_axi_awregion ( s_axi_awregion ),            // input wire [3 : 0] s_axi_awregion
        .s_axi_awqos    ( s_axi_awqos    ),            // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( s_axi_awvalid  ),            // input wire s_axi_awvalid
        .s_axi_awready  ( s_axi_awready  ),            // output wire s_axi_awready
        .s_axi_wdata    ( s_axi_wdata    ),            // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( s_axi_wstrb    ),            // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( s_axi_wlast    ),            // input wire s_axi_wlast
        .s_axi_wvalid   ( s_axi_wvalid   ),            // input wire s_axi_wvalid
        .s_axi_wready   ( s_axi_wready   ),            // output wire s_axi_wready
        .s_axi_bid      ( s_axi_bid      ),            // output wire [1 : 0] s_axi_bid
        .s_axi_bresp    ( s_axi_bresp    ),            // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( s_axi_bvalid   ),            // output wire s_axi_bvalid
        .s_axi_bready   ( s_axi_bready   ),            // input wire s_axi_bready
        .s_axi_arid     ( s_axi_arid     ),            // input wire [1 : 0] s_axi_arid
        .s_axi_araddr   ( s_axi_araddr   ),            // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( s_axi_arlen    ),            // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( s_axi_arsize   ),            // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( s_axi_arburst  ),            // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( s_axi_arlock   ),            // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( s_axi_arcache  ),            // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( s_axi_arprot   ),            // input wire [2 : 0] s_axi_arprot
        .s_axi_arregion ( s_axi_arregion ),            // input wire [3 : 0] s_axi_arregion
        .s_axi_arqos    ( s_axi_arqos    ),            // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( s_axi_arvalid  ),            // input wire s_axi_arvalid
        .s_axi_arready  ( s_axi_arready  ),            // output wire s_axi_arready
        .s_axi_rid      ( s_axi_rid      ),            // output wire [1 : 0] s_axi_rid
        .s_axi_rdata    ( s_axi_rdata    ),            // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( s_axi_rresp    ),            // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( s_axi_rlast    ),            // output wire s_axi_rlast
        .s_axi_rvalid   ( s_axi_rvalid   ),            // output wire s_axi_rvalid
        .s_axi_rready   ( s_axi_rready   ),            // input wire s_axi_rready
        // Master port (to GPIO)
        .m_axi_awaddr   ( uart_axilite_awaddr       ), // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot   ( uart_axilite_awprot       ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid  ( uart_axilite_awvalid      ), // output wire m_axi_awvalid
        .m_axi_awready  ( uart_axilite_awready      ), // input wire m_axi_awready
        .m_axi_wdata    ( uart_axilite_wdata        ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    ( uart_axilite_wstrb        ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid   ( uart_axilite_wvalid       ), // output wire m_axi_wvalid
        .m_axi_wready   ( uart_axilite_wready       ), // input wire m_axi_wready
        .m_axi_bresp    ( uart_axilite_bresp        ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   ( uart_axilite_bvalid       ), // input wire m_axi_bvalid
        .m_axi_bready   ( uart_axilite_bready       ), // output wire m_axi_bready
        .m_axi_araddr   ( uart_axilite_araddr       ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot   ( uart_axilite_arprot       ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid  ( uart_axilite_arvalid      ), // output wire m_axi_arvalid
        .m_axi_arready  ( uart_axilite_arready      ), // input wire m_axi_arready
        .m_axi_rdata    ( uart_axilite_rdata        ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    ( uart_axilite_rresp        ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid   ( uart_axilite_rvalid       ), // input wire m_axi_rvalid
        .m_axi_rready   ( uart_axilite_rready       )  // output wire m_axi_rready
    );


    `ifdef HPC
        virtual_uart virtual_uart_u (
            .clock_i    ( clock_i                       ),
            .reset_ni   ( reset_ni                      ),
            .int_core_o ( int_core_o                    ),
            .int_xdma_o ( int_xdma_o                    ),
            .int_ack_i  ( 2'b00                         ),

            .s_axilite_awaddr   ( uart_axilite_awaddr       ), // output wire [31 : 0] s_axilite_awaddr
            .s_axilite_awprot   ( uart_axilite_awprot       ), // output wire [2 : 0] s_axilite_awprot
            .s_axilite_awvalid  ( uart_axilite_awvalid      ), // output wire s_axilite_awvalid
            .s_axilite_awready  ( uart_axilite_awready      ), // input wire s_axilite_awready
            .s_axilite_wdata    ( uart_axilite_wdata        ), // output wire [31 : 0] s_axilite_wdata
            .s_axilite_wstrb    ( uart_axilite_wstrb        ), // output wire [3 : 0] s_axilite_wstrb
            .s_axilite_wvalid   ( uart_axilite_wvalid       ), // output wire s_axilite_wvalid
            .s_axilite_wready   ( uart_axilite_wready       ), // input wire s_axilite_wready
            .s_axilite_bresp    ( uart_axilite_bresp        ), // input wire [1 : 0] s_axilite_bresp
            .s_axilite_bvalid   ( uart_axilite_bvalid       ), // input wire s_axilite_bvalid
            .s_axilite_bready   ( uart_axilite_bready       ), // output wire s_axilite_bready
            .s_axilite_araddr   ( uart_axilite_araddr       ), // output wire [31 : 0] s_axilite_araddr
            .s_axilite_arprot   ( uart_axilite_arprot       ), // output wire [2 : 0] s_axilite_arprot
            .s_axilite_arvalid  ( uart_axilite_arvalid      ), // output wire s_axilite_arvalid
            .s_axilite_arready  ( uart_axilite_arready      ), // input wire s_axilite_arready
            .s_axilite_rdata    ( uart_axilite_rdata        ), // input wire [31 : 0] s_axilite_rdata
            .s_axilite_rresp    ( uart_axilite_rresp        ), // input wire [1 : 0] s_axilite_rresp
            .s_axilite_rvalid   ( uart_axilite_rvalid       ), // input wire s_axilite_rvalid
            .s_axilite_rready   ( uart_axilite_rready       )  // output wire s_axi_rready

        );

    `elsif EMBEDDED
        xlnx_axi_uartlite uart_u (
            .s_axi_aclk         ( clock_i                           ),      // input wire s_axi_aclk
            .s_axi_aresetn      ( reset_ni                          ),      // input wire s_axi_aresetn
            .interrupt          ( int_core_o                        ),      // output wire interrupt
            .s_axi_awaddr       ( uart_axilite_awaddr               ),      // input wire [3 : 0] s_axi_awaddr
            .s_axi_awvalid      ( uart_axilite_awvalid              ),      // input wire s_axi_awvalid
            .s_axi_awready      ( uart_axilite_awready              ),      // output wire s_axi_awready
            .s_axi_wdata        ( uart_axilite_wdata                ),      // input wire [31 : 0] s_axi_wdata
            .s_axi_wstrb        ( uart_axilite_wstrb                ),      // input wire [3 : 0] s_axi_wstrb
            .s_axi_wvalid       ( uart_axilite_wvalid               ),      // input wire s_axi_wvalid
            .s_axi_wready       ( uart_axilite_wready               ),      // output wire s_axi_wready
            .s_axi_bresp        ( uart_axilite_bresp                ),      // output wire [1 : 0] s_axi_bresp
            .s_axi_bvalid       ( uart_axilite_bvalid               ),      // output wire s_axi_bvalid
            .s_axi_bready       ( uart_axilite_bready               ),      // input wire s_axi_bready
            .s_axi_araddr       ( uart_axilite_araddr               ),      // input wire [3 : 0] s_axi_araddr
            .s_axi_arvalid      ( uart_axilite_arvalid              ),      // input wire s_axi_arvalid
            .s_axi_arready      ( uart_axilite_arready              ),      // output wire s_axi_arready
            .s_axi_rdata        ( uart_axilite_rdata                ),      // output wire [31 : 0] s_axi_rdata
            .s_axi_rresp        ( uart_axilite_rresp                ),      // output wire [1 : 0] s_axi_rresp
            .s_axi_rvalid       ( uart_axilite_rvalid               ),      // output wire s_axi_rvalid
            .s_axi_rready       ( uart_axilite_rready               ),      // input wire s_axi_rready
            .rx                 ( rx_i                              ),      // input wire rx
            .tx                 ( tx_o                              )       // output wire tx
            );

        assign int_xdma_o = '0;

    `endif

endmodule
