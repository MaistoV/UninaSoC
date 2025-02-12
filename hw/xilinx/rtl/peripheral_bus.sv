// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: This module is a wrapper for the xlnx_axilite_crossbar
//              it adds a AXI protocol converter before the axilite crossbar
//
//                                             
//            _______________                  ____________             _______
//   AXI4    |   AXI Prot    |   AXI Lite     |            |           |       |
// --------->|   Converter   |--------------->|            |---------->| UART  |
//           |_______________|                |  AXI Lite  |           |_______|
//                                            |    XBAR    |                    
//                                            |            |            _______       
//                                            |            |           |       |
//                                            |            |---------->| GPIO  |
//                                            |____________|           |_______| 
//
//
//

// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"

module peripheral_bus (
    input logic clock_i,
    input logic reset_ni,

    `ifdef EMBEDDED
        // UART interface
        input  logic                        uart_rx_i,
        output logic                        uart_tx_o,

        // GPIOs
        // input  wire [NUM_GPIO_IN  -1 : 0]  gpio_in_i,
        output logic [NUM_GPIO_OUT -1 : 0]  gpio_out_o
    `endif 
    
    // AXI4 Slave interface from the main xbar
    `DEFINE_AXI_SLAVE_PORTS(s)
);

    // AXI Lite bus from the protocol converter to the axilite crossbar
    `DECLARE_AXILITE_BUS(prot_conv_to_xbar);

    // AXI Lite bus array from the axilite crossbar to the slaves (peripherals)
    `DECLARE_AXILITE_BUS_ARRAY(xbar_slaves, NUM_AXILITE_SLAVES);

    // AXI Lite bus from the axilite crossbar to the UART
    `DECLARE_AXILITE_BUS(xbar_to_uart);

    `ifdef HPC
        `DECLARE_AXILITE_BUS(xbar_to_sync); 
        `CONCAT_AXILITE_SLAVES_ARRAY2(xbar_slaves, xbar_to_sync, xbar_to_uart);
    `elsif EMBEDDED
        `CONCAT_AXILITE_SLAVES_ARRAY2(xbar_slaves, xbar_to_gpio, xbar_to_uart);
    `endif

    // AXI4 to AXI4-Lite protocol converter
    xlnx_axi4_to_axilite_converter axi4_to_axilite_u (
        .aclk           ( clock_i                   ), // input wire s_axi_aclk
        .aresetn        ( reset_ni                  ), // input wire s_axi_aresetn
        // AXI4 slave port (from main xbar)
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
        // Master port (to AXI Lite crossbar)
        .m_axi_awaddr   ( prot_conv_to_xbar_axilite_awaddr       ), // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot   ( prot_conv_to_xbar_axilite_awprot       ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid  ( prot_conv_to_xbar_axilite_awvalid      ), // output wire m_axi_awvalid
        .m_axi_awready  ( prot_conv_to_xbar_axilite_awready      ), // input wire m_axi_awready
        .m_axi_wdata    ( prot_conv_to_xbar_axilite_wdata        ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    ( prot_conv_to_xbar_axilite_wstrb        ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid   ( prot_conv_to_xbar_axilite_wvalid       ), // output wire m_axi_wvalid
        .m_axi_wready   ( prot_conv_to_xbar_axilite_wready       ), // input wire m_axi_wready
        .m_axi_bresp    ( prot_conv_to_xbar_axilite_bresp        ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   ( prot_conv_to_xbar_axilite_bvalid       ), // input wire m_axi_bvalid
        .m_axi_bready   ( prot_conv_to_xbar_axilite_bready       ), // output wire m_axi_bready
        .m_axi_araddr   ( prot_conv_to_xbar_axilite_araddr       ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot   ( prot_conv_to_xbar_axilite_arprot       ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid  ( prot_conv_to_xbar_axilite_arvalid      ), // output wire m_axi_arvalid
        .m_axi_arready  ( prot_conv_to_xbar_axilite_arready      ), // input wire m_axi_arready
        .m_axi_rdata    ( prot_conv_to_xbar_axilite_rdata        ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    ( prot_conv_to_xbar_axilite_rresp        ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid   ( prot_conv_to_xbar_axilite_rvalid       ), // input wire m_axi_rvalid
        .m_axi_rready   ( prot_conv_to_xbar_axilite_rready       )  // output wire m_axi_rready
    );

    // AXI Lite crossbar
    xlnx_axilite_crossbar axilite_xbar_u (
        .aclk           ( clock_i  ), 
        .aresetn        ( reset_ni ), 

        .s_axi_awaddr   ( prot_conv_to_xbar_axilite_awaddr       ),
        .s_axi_awprot   ( prot_conv_to_xbar_axilite_awprot       ),
        .s_axi_awvalid  ( prot_conv_to_xbar_axilite_awvalid      ),
        .s_axi_awready  ( prot_conv_to_xbar_axilite_awready      ),
        .s_axi_wdata    ( prot_conv_to_xbar_axilite_wdata        ),
        .s_axi_wstrb    ( prot_conv_to_xbar_axilite_wstrb        ),
        .s_axi_wvalid   ( prot_conv_to_xbar_axilite_wvalid       ),
        .s_axi_wready   ( prot_conv_to_xbar_axilite_wready       ),
        .s_axi_bresp    ( prot_conv_to_xbar_axilite_bresp        ),
        .s_axi_bvalid   ( prot_conv_to_xbar_axilite_bvalid       ),
        .s_axi_bready   ( prot_conv_to_xbar_axilite_bready       ),
        .s_axi_araddr   ( prot_conv_to_xbar_axilite_araddr       ),
        .s_axi_arprot   ( prot_conv_to_xbar_axilite_arprot       ),
        .s_axi_arvalid  ( prot_conv_to_xbar_axilite_arvalid      ),
        .s_axi_arready  ( prot_conv_to_xbar_axilite_arready      ),
        .s_axi_rdata    ( prot_conv_to_xbar_axilite_rdata        ),
        .s_axi_rresp    ( prot_conv_to_xbar_axilite_rresp        ),
        .s_axi_rvalid   ( prot_conv_to_xbar_axilite_rvalid       ),
        .s_axi_rready   ( prot_conv_to_xbar_axilite_rready       ), 

        .m_axi_awaddr   ( xbar_slaves_axilite_awaddr             ),
        .m_axi_awprot   ( xbar_slaves_axilite_awprot             ),
        .m_axi_awvalid  ( xbar_slaves_axilite_awvalid            ),
        .m_axi_awready  ( xbar_slaves_axilite_awready            ),
        .m_axi_wdata    ( xbar_slaves_axilite_wdata              ),
        .m_axi_wstrb    ( xbar_slaves_axilite_wstrb              ),
        .m_axi_wvalid   ( xbar_slaves_axilite_wvalid             ),
        .m_axi_wready   ( xbar_slaves_axilite_wready             ),
        .m_axi_bresp    ( xbar_slaves_axilite_bresp              ),
        .m_axi_bvalid   ( xbar_slaves_axilite_bvalid             ),
        .m_axi_bready   ( xbar_slaves_axilite_bready             ),
        .m_axi_araddr   ( xbar_slaves_axilite_araddr             ),
        .m_axi_arprot   ( xbar_slaves_axilite_arprot             ),
        .m_axi_arvalid  ( xbar_slaves_axilite_arvalid            ),
        .m_axi_arready  ( xbar_slaves_axilite_arready            ),
        .m_axi_rdata    ( xbar_slaves_axilite_rdata              ),
        .m_axi_rresp    ( xbar_slaves_axilite_rresp              ),
        .m_axi_rvalid   ( xbar_slaves_axilite_rvalid             ),
        .m_axi_rready   ( xbar_slaves_axilite_rready             )

    ); 

    // AXI4 Lite UART
    axilite_uart axilite_uart_u (
        .clock_i        ( clock_i                   ), // input wire s_axi_aclk
        .reset_ni       ( reset_ni                  ), // input wire s_axi_aresetn
        .int_core_o     (                           ), // TBD
        .int_xdma_o     (                           ), // TBD
        .int_ack_i      ( '0                        ), // TBD
    `ifdef EMBEDDED
        .tx_o           ( uart_tx_o                 ), // Transmission signal (SoC output signal)
        .rx_i           ( uart_rx_i                 ), // Receive signal (SoC input signal)
    `endif

        // AXI4 lite slave port (from xbar lite)
        .s_axilite_awaddr   ( xbar_to_uart_axilite_awaddr       ), 
        .s_axilite_awprot   ( xbar_to_uart_axilite_awprot       ), 
        .s_axilite_awvalid  ( xbar_to_uart_axilite_awvalid      ), 
        .s_axilite_awready  ( xbar_to_uart_axilite_awready      ), 
        .s_axilite_wdata    ( xbar_to_uart_axilite_wdata        ),
        .s_axilite_wstrb    ( xbar_to_uart_axilite_wstrb        ),
        .s_axilite_wvalid   ( xbar_to_uart_axilite_wvalid       ),
        .s_axilite_wready   ( xbar_to_uart_axilite_wready       ),
        .s_axilite_bresp    ( xbar_to_uart_axilite_bresp        ),
        .s_axilite_bvalid   ( xbar_to_uart_axilite_bvalid       ), 
        .s_axilite_bready   ( xbar_to_uart_axilite_bready       ), 
        .s_axilite_araddr   ( xbar_to_uart_axilite_araddr       ), 
        .s_axilite_arprot   ( xbar_to_uart_axilite_arprot       ), 
        .s_axilite_arvalid  ( xbar_to_uart_axilite_arvalid      ), 
        .s_axilite_arready  ( xbar_to_uart_axilite_arready      ), 
        .s_axilite_rdata    ( xbar_to_uart_axilite_rdata        ),
        .s_axilite_rresp    ( xbar_to_uart_axilite_rresp        ),
        .s_axilite_rvalid   ( xbar_to_uart_axilite_rvalid       ),
        .s_axilite_rready   ( xbar_to_uart_axilite_rready       )
    );

`ifdef HPC
    // Sync the second AXI slave of the crossbar. 
    assign xbar_to_sync_axilite_awready = 1; 
    assign xbar_to_sync_axilite_wready  = 1; 
    assign xbar_to_sync_axilite_bvalid  = 1;
    assign xbar_to_sync_axilite_bresp   = 2'b00;
    assign xbar_to_sync_axilite_arready = 1; 
    assign xbar_to_sync_axilite_rdata   = '0; 
    assign xbar_to_sync_axilite_rvalid  = 1;
    assign xbar_to_sync_axilite_rresp   = 2'b00;

`elsif EMBEDDED
    // GPIOs
    generate
        // GPIO out
        for ( genvar i = 0; i < NUM_GPIO_OUT; i++ ) begin
            // axi4_to_axilite -> gpio_out
            `DECLARE_AXILITE_BUS(xbar_to_gpio);

            // GPIO instance
            xlnx_axi_gpio_out gpio_out_u (
                .s_axi_aclk     ( clock_i                           ), // input wire s_axi_aclk
                .s_axi_aresetn  ( reset_ni                          ), // input wire s_axi_aresetn
                .s_axi_awaddr   ( xbar_to_gpio_axilite_awaddr [8:0] ), // input wire [8 : 0] s_axi_awaddr
                .s_axi_awvalid  ( xbar_to_gpio_axilite_awvalid      ), // input wire s_axi_awvalid
                .s_axi_awready  ( xbar_to_gpio_axilite_awready      ), // output wire s_axi_awready
                .s_axi_wdata    ( xbar_to_gpio_axilite_wdata        ), // input wire [31 : 0] s_axi_wdata
                .s_axi_wstrb    ( xbar_to_gpio_axilite_wstrb        ), // input wire [3 : 0] s_axi_wstrb
                .s_axi_wvalid   ( xbar_to_gpio_axilite_wvalid       ), // input wire s_axi_wvalid
                .s_axi_wready   ( xbar_to_gpio_axilite_wready       ), // output wire s_axi_wready
                .s_axi_bresp    ( xbar_to_gpio_axilite_bresp        ), // output wire [1 : 0] s_axi_bresp
                .s_axi_bvalid   ( xbar_to_gpio_axilite_bvalid       ), // output wire s_axi_bvalid
                .s_axi_bready   ( xbar_to_gpio_axilite_bready       ), // input wire s_axi_bready
                .s_axi_araddr   ( xbar_to_gpio_axilite_araddr [8:0] ), // input wire [8 : 0] s_axi_araddr
                .s_axi_arvalid  ( xbar_to_gpio_axilite_arvalid      ), // input wire s_axi_arvalid
                .s_axi_arready  ( xbar_to_gpio_axilite_arready      ), // output wire s_axi_arready
                .s_axi_rdata    ( xbar_to_gpio_axilite_rdata        ), // output wire [31 : 0] s_axi_rdata
                .s_axi_rresp    ( xbar_to_gpio_axilite_rresp        ), // output wire [1 : 0] s_axi_rresp
                .s_axi_rvalid   ( xbar_to_gpio_axilite_rvalid       ), // output wire s_axi_rvalid
                .s_axi_rready   ( xbar_to_gpio_axilite_rready       ), // input wire s_axi_rready
                .gpio_io_o      ( gpio_out_o [i]                    )  // input wire [0 : 0] gpio_io_o
            );
        end
    endgenerate

`endif

endmodule : peripheral_bus