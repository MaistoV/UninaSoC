// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Basic version of UninaSoC

// System architecture:
//                                                                                    ________
//   _________              ____________               __________                    |        |
//  |         |            |            |             |          |                   |  Main  |
//  |   vio   |----------->| rvm_socket |------------>|          |        /--------->| Memory |
//  |_________|            |____________|             |   AXI    |        |          |________|
//   __________                                       | crossbar |--------|           ________
//  |          |                                      |          |        |          |        |
//  | jtag_axi |------------------------------------->|          |        |--------->|  UART  |
//  |__________|                                      |__________|        |          |________|
//                                                                        |           ________
//                                                                        |          |        |
//                                                                        \--------->|  GPIO  |
//                                                                                   |________|
//

import uniasoc_pkg::*;

module uninasoc # (
    parameter NUM_GPIO_IN       = 2,
    parameter NUM_GPIO_OUT      = 2,
    parameter MEMORY_SIZE_BYTES = 1024
) (
    // UART interface
    input  logic                        uart_rx_i,
    output logic                        uart_tx_o

    // GPIO interface
    input  logic [NUM_GPIO_IN  -1 : 0]  gpio_in,
    output logic [NUM_GPIO_OUT -1 : 0]  gpio_out
);

    //////////////////////
    // Local parameters //
    //////////////////////
    // TBD (if any)

    ///////////////////
    // Local signals //
    ///////////////////

    // clkwiz -> all
    logic soc_clk;
    // vio -> all
    logic vio_reset_n;
    // vio -> rvm_socket
    logic [AXI_ADDR_WIDTH -1 : 0 ] vio_bootaddr;
    logic [NUM_IRQ        -1 : 0 ] vio_irq;
    // uart -> rvm_socket
    logic uart_interrupt;
    // AXI masters
    TBD
    // AXI slaves
    TBD

    /////////////
    // Modules //
    /////////////

    // PLL
    xlnx_clkwiz clkwiz_inst (
        .clk_in1  ( sys_clk ),
        .reset    ( '0 ),
        .locked   ( ),
        .clk_100  ( ),
        .clk_50   ( soc_clk  ),
        .clk_20   ( ),
        .clk_10   ( )
    );

    // Virtual I/O
    xlnx_vio vio_inst (
      .clk        ( soc_clk      ),
      .probe_out0 ( vio_reset_n  ),
      .probe_out1 ( vio_bootaddr ),
      .probe_out2 ( vio_irq[0]    ),
      .probe_out3 ( vio_irq[1]    ),
      .probe_out3 ( vio_irq[2]    )
    );

    // AXI crossbar
    xlnx_axi_crossbar axi_xbar_inst (
        .aclk           ( soc_clk        ), // input wire aclk
        .aresetn        ( vio_reset_n    ), // input wire aresetn
        .s_axi_awaddr   ( s_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( s_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( s_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( s_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( s_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( s_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( s_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
        .s_axi_awqos    ( s_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( s_axi_awvalid  ), // input wire [0 : 0] s_axi_awvalid
        .s_axi_awready  ( s_axi_awready  ), // output wire [0 : 0] s_axi_awready
        .s_axi_wdata    ( s_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( s_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( s_axi_wlast    ), // input wire [0 : 0] s_axi_wlast
        .s_axi_wvalid   ( s_axi_wvalid   ), // input wire [0 : 0] s_axi_wvalid
        .s_axi_wready   ( s_axi_wready   ), // output wire [0 : 0] s_axi_wready
        .s_axi_bresp    ( s_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( s_axi_bvalid   ), // output wire [0 : 0] s_axi_bvalid
        .s_axi_bready   ( s_axi_bready   ), // input wire [0 : 0] s_axi_bready
        .s_axi_araddr   ( s_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( s_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( s_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( s_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( s_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( s_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( s_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
        .s_axi_arqos    ( s_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( s_axi_arvalid  ), // input wire [0 : 0] s_axi_arvalid
        .s_axi_arready  ( s_axi_arready  ), // output wire [0 : 0] s_axi_arready
        .s_axi_rdata    ( s_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( s_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( s_axi_rlast    ), // output wire [0 : 0] s_axi_rlast
        .s_axi_rvalid   ( s_axi_rvalid   ), // output wire [0 : 0] s_axi_rvalid
        .s_axi_rready   ( s_axi_rready   ), // input wire [0 : 0] s_axi_rready
        .m_axi_awaddr   ( m_axi_awaddr   ), // output wire [63 : 0] m_axi_awaddr
        .m_axi_awlen    ( m_axi_awlen    ), // output wire [15 : 0] m_axi_awlen
        .m_axi_awsize   ( m_axi_awsize   ), // output wire [5 : 0] m_axi_awsize
        .m_axi_awburst  ( m_axi_awburst  ), // output wire [3 : 0] m_axi_awburst
        .m_axi_awlock   ( m_axi_awlock   ), // output wire [1 : 0] m_axi_awlock
        .m_axi_awcache  ( m_axi_awcache  ), // output wire [7 : 0] m_axi_awcache
        .m_axi_awprot   ( m_axi_awprot   ), // output wire [5 : 0] m_axi_awprot
        .m_axi_awregion ( m_axi_awregion ), // output wire [7 : 0] m_axi_awregion
        .m_axi_awqos    ( m_axi_awqos    ), // output wire [7 : 0] m_axi_awqos
        .m_axi_awvalid  ( m_axi_awvalid  ), // output wire [1 : 0] m_axi_awvalid
        .m_axi_awready  ( m_axi_awready  ), // input wire [1 : 0] m_axi_awready
        .m_axi_wdata    ( m_axi_wdata    ), // output wire [63 : 0] m_axi_wdata
        .m_axi_wstrb    ( m_axi_wstrb    ), // output wire [7 : 0] m_axi_wstrb
        .m_axi_wlast    ( m_axi_wlast    ), // output wire [1 : 0] m_axi_wlast
        .m_axi_wvalid   ( m_axi_wvalid   ), // output wire [1 : 0] m_axi_wvalid
        .m_axi_wready   ( m_axi_wready   ), // input wire [1 : 0] m_axi_wready
        .m_axi_bresp    ( m_axi_bresp    ), // input wire [3 : 0] m_axi_bresp
        .m_axi_bvalid   ( m_axi_bvalid   ), // input wire [1 : 0] m_axi_bvalid
        .m_axi_bready   ( m_axi_bready   ), // output wire [1 : 0] m_axi_bready
        .m_axi_araddr   ( m_axi_araddr   ), // output wire [63 : 0] m_axi_araddr
        .m_axi_arlen    ( m_axi_arlen    ), // output wire [15 : 0] m_axi_arlen
        .m_axi_arsize   ( m_axi_arsize   ), // output wire [5 : 0] m_axi_arsize
        .m_axi_arburst  ( m_axi_arburst  ), // output wire [3 : 0] m_axi_arburst
        .m_axi_arlock   ( m_axi_arlock   ), // output wire [1 : 0] m_axi_arlock
        .m_axi_arcache  ( m_axi_arcache  ), // output wire [7 : 0] m_axi_arcache
        .m_axi_arprot   ( m_axi_arprot   ), // output wire [5 : 0] m_axi_arprot
        .m_axi_arregion ( m_axi_arregion ), // output wire [7 : 0] m_axi_arregion
        .m_axi_arqos    ( m_axi_arqos    ), // output wire [7 : 0] m_axi_arqos
        .m_axi_arvalid  ( m_axi_arvalid  ), // output wire [1 : 0] m_axi_arvalid
        .m_axi_arready  ( m_axi_arready  ), // input wire [1 : 0] m_axi_arready
        .m_axi_rdata    ( m_axi_rdata    ), // input wire [63 : 0] m_axi_rdata
        .m_axi_rresp    ( m_axi_rresp    ), // input wire [3 : 0] m_axi_rresp
        .m_axi_rlast    ( m_axi_rlast    ), // input wire [1 : 0] m_axi_rlast
        .m_axi_rvalid   ( m_axi_rvalid   ), // input wire [1 : 0] m_axi_rvalid
        .m_axi_rready   ( m_axi_rready   ) // output wire [1 : 0] m_axi_rready
    );

    // JTAG2AXI Master
    xlnx_jtag_axi jtag_axi_inst (
        .aclk           (   soc_clk         ), // input wire aclk
        .aresetn        (   vio_reset_n     ), // input wire aresetn
        .m_axi_awid     (   m_axi_awid      ), // output wire [0 : 0] m_axi_awid
        .m_axi_awaddr   (   m_axi_awaddr    ), // output wire [31 : 0] m_axi_awaddr
        .m_axi_awlen    (   m_axi_awlen     ), // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize   (   m_axi_awsize    ), // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst  (   m_axi_awburst   ), // output wire [1 : 0] m_axi_awburst
        .m_axi_awlock   (   m_axi_awlock    ), // output wire m_axi_awlock
        .m_axi_awcache  (   m_axi_awcache   ), // output wire [3 : 0] m_axi_awcache
        .m_axi_awprot   (   m_axi_awprot    ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awqos    (   m_axi_awqos     ), // output wire [3 : 0] m_axi_awqos
        .m_axi_awvalid  (   m_axi_awvalid   ), // output wire m_axi_awvalid
        .m_axi_awready  (   m_axi_awready   ), // input wire m_axi_awready
        .m_axi_wdata    (   m_axi_wdata     ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    (   m_axi_wstrb     ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wlast    (   m_axi_wlast     ), // output wire m_axi_wlast
        .m_axi_wvalid   (   m_axi_wvalid    ), // output wire m_axi_wvalid
        .m_axi_wready   (   m_axi_wready    ), // input wire m_axi_wready
        .m_axi_bid      (   m_axi_bid       ), // input wire [0 : 0] m_axi_bid
        .m_axi_bresp    (   m_axi_bresp     ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   (   m_axi_bvalid    ), // input wire m_axi_bvalid
        .m_axi_bready   (   m_axi_bready    ), // output wire m_axi_bready
        .m_axi_arid     (   m_axi_arid      ), // output wire [0 : 0] m_axi_arid
        .m_axi_araddr   (   m_axi_araddr    ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arlen    (   m_axi_arlen     ), // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize   (   m_axi_arsize    ), // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst  (   m_axi_arburst   ), // output wire [1 : 0] m_axi_arburst
        .m_axi_arlock   (   m_axi_arlock    ), // output wire m_axi_arlock
        .m_axi_arcache  (   m_axi_arcache   ), // output wire [3 : 0] m_axi_arcache
        .m_axi_arprot   (   m_axi_arprot    ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arqos    (   m_axi_arqos     ), // output wire [3 : 0] m_axi_arqos
        .m_axi_arvalid  (   m_axi_arvalid   ), // output wire m_axi_arvalid
        .m_axi_arready  (   m_axi_arready   ), // input wire m_axi_arready
        .m_axi_rid      (   m_axi_rid       ), // input wire [0 : 0] m_axi_rid
        .m_axi_rdata    (   m_axi_rdata     ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    (   m_axi_rresp     ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast    (   m_axi_rlast     ), // input wire m_axi_rlast
        .m_axi_rvalid   (   m_axi_rvalid    ), // input wire m_axi_rvalid
        .m_axi_rready   (   m_axi_rready    )  // output wire m_axi_rready
    );

    // RVM Socket
    rvm_socket # (
        .DATA_WIDTH ( AXI_DATA_WIDTH ),
        .ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .NUM_IRQ    ( NUM_IRQ        )
    ) rvm_socket_inst (
        .clock_i        ( soc_clk      ),
        .reset_ni       ( vio_reset_n  ),
        .boot_address_i ( vio_bootaddr ),
        .irq_i          ( vio_irq      )
        .axi_master
        .tbd()
    );

    // Main memory
    xlnx_blk_mem_gen main_memory_inst (
        .rsta_busy      ( rsta_busy     ), // output wire rsta_busy
        .rstb_busy      ( rstb_busy     ), // output wire rstb_busy
        .s_aclk         ( s_aclk        ), // input wire s_aclk
        .s_aresetn      ( s_aresetn     ), // input wire s_aresetn
        .s_axi_awid     ( s_axi_awid    ), // input wire [3 : 0] s_axi_awid
        .s_axi_awaddr   ( s_axi_awaddr  ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( s_axi_awlen   ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( s_axi_awsize  ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( s_axi_awburst ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid  ( s_axi_awvalid ), // input wire s_axi_awvalid
        .s_axi_awready  ( s_axi_awready ), // output wire s_axi_awready
        .s_axi_wdata    ( s_axi_wdata   ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( s_axi_wstrb   ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( s_axi_wlast   ), // input wire s_axi_wlast
        .s_axi_wvalid   ( s_axi_wvalid  ), // input wire s_axi_wvalid
        .s_axi_wready   ( s_axi_wready  ), // output wire s_axi_wready
        .s_axi_bid      ( s_axi_bid     ), // output wire [3 : 0] s_axi_bid
        .s_axi_bresp    ( s_axi_bresp   ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( s_axi_bvalid  ), // output wire s_axi_bvalid
        .s_axi_bready   ( s_axi_bready  ), // input wire s_axi_bready
        .s_axi_arid     ( s_axi_arid    ), // input wire [3 : 0] s_axi_arid
        .s_axi_araddr   ( s_axi_araddr  ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( s_axi_arlen   ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( s_axi_arsize  ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( s_axi_arburst ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid  ( s_axi_arvalid ), // input wire s_axi_arvalid
        .s_axi_arready  ( s_axi_arready ), // output wire s_axi_arready
        .s_axi_rid      ( s_axi_rid     ), // output wire [3 : 0] s_axi_rid
        .s_axi_rdata    ( s_axi_rdata   ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( s_axi_rresp   ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( s_axi_rlast   ), // output wire s_axi_rlast
        .s_axi_rvalid   ( s_axi_rvalid  ), // output wire s_axi_rvalid
        .s_axi_rready   ( s_axi_rready  )  // input wire s_axi_rready
    );

    // UART
    xlnx_axi_uartlite axi_uartlite_inst (
        // AXI Slave
        .s_axi_aclk     ( s_axi_aclk     ), // input wire s_axi_aclk
        .s_axi_aresetn  ( s_axi_aresetn  ), // input wire s_axi_aresetn
        .s_axi_awaddr   ( s_axi_awaddr   ), // input wire [3 : 0] s_axi_awaddr
        .s_axi_awvalid  ( s_axi_awvalid  ), // input wire s_axi_awvalid
        .s_axi_awready  ( s_axi_awready  ), // output wire s_axi_awready
        .s_axi_wdata    ( s_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( s_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid   ( s_axi_wvalid   ), // input wire s_axi_wvalid
        .s_axi_wready   ( s_axi_wready   ), // output wire s_axi_wready
        .s_axi_bresp    ( s_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( s_axi_bvalid   ), // output wire s_axi_bvalid
        .s_axi_bready   ( s_axi_bready   ), // input wire s_axi_bready
        .s_axi_araddr   ( s_axi_araddr   ), // input wire [3 : 0] s_axi_araddr
        .s_axi_arvalid  ( s_axi_arvalid  ), // input wire s_axi_arvalid
        .s_axi_arready  ( s_axi_arready  ), // output wire s_axi_arready
        .s_axi_rdata    ( s_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( s_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid   ( s_axi_rvalid   ), // output wire s_axi_rvalid
        .s_axi_rready   ( s_axi_rready   ), // input wire s_axi_rready
        // Interrupt signal
        .interrupt      ( uart_interrupt ), // output wire interrupt
        // UART RX and TX
        .rx             ( uart_rx_i      ), // input wire rx
        .tx             ( uart_tx_o      )  // output wire tx
    );
    // GPIOs
    generate : gpios_gen
            for ( genvar i = 0; i < NUM_GPIO_IN; i++ ) begin
                axi_gpio_in gpio_in_isnt (
                    .s_axi_aclk     ( s_axi_aclk    ), // input wire s_axi_aclk
                    .s_axi_aresetn  ( s_axi_aresetn ), // input wire s_axi_aresetn
                    .s_axi_awaddr   ( s_axi_awaddr  ), // input wire [8 : 0] s_axi_awaddr
                    .s_axi_awvalid  ( s_axi_awvalid ), // input wire s_axi_awvalid
                    .s_axi_awready  ( s_axi_awready ), // output wire s_axi_awready
                    .s_axi_wdata    ( s_axi_wdata   ), // input wire [31 : 0] s_axi_wdata
                    .s_axi_wstrb    ( s_axi_wstrb   ), // input wire [3 : 0] s_axi_wstrb
                    .s_axi_wvalid   ( s_axi_wvalid  ), // input wire s_axi_wvalid
                    .s_axi_wready   ( s_axi_wready  ), // output wire s_axi_wready
                    .s_axi_bresp    ( s_axi_bresp   ), // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid   ( s_axi_bvalid  ), // output wire s_axi_bvalid
                    .s_axi_bready   ( s_axi_bready  ), // input wire s_axi_bready
                    .s_axi_araddr   ( s_axi_araddr  ), // input wire [8 : 0] s_axi_araddr
                    .s_axi_arvalid  ( s_axi_arvalid ), // input wire s_axi_arvalid
                    .s_axi_arready  ( s_axi_arready ), // output wire s_axi_arready
                    .s_axi_rdata    ( s_axi_rdata   ), // output wire [31 : 0] s_axi_rdata
                    .s_axi_rresp    ( s_axi_rresp   ), // output wire [1 : 0] s_axi_rresp
                    .s_axi_rvalid   ( s_axi_rvalid  ), // output wire s_axi_rvalid
                    .s_axi_rready   ( s_axi_rready  ), // input wire s_axi_rready
                    .gpio_io_i      ( gpio_in [i]   )  // input wire [0 : 0] gpio_io_i
                );
            end
            
            for ( genvar i = 0; i < NUM_GPIO_OUT; i++ ) begin
                axi_gpio_out gpio_out_inst (
                    .s_axi_aclk     ( s_axi_aclk    ), // input wire s_axi_aclk
                    .s_axi_aresetn  ( s_axi_aresetn ), // input wire s_axi_aresetn
                    .s_axi_awaddr   ( s_axi_awaddr  ), // input wire [8 : 0] s_axi_awaddr
                    .s_axi_awvalid  ( s_axi_awvalid ), // input wire s_axi_awvalid
                    .s_axi_awready  ( s_axi_awready ), // output wire s_axi_awready
                    .s_axi_wdata    ( s_axi_wdata   ), // input wire [31 : 0] s_axi_wdata
                    .s_axi_wstrb    ( s_axi_wstrb   ), // input wire [3 : 0] s_axi_wstrb
                    .s_axi_wvalid   ( s_axi_wvalid  ), // input wire s_axi_wvalid
                    .s_axi_wready   ( s_axi_wready  ), // output wire s_axi_wready
                    .s_axi_bresp    ( s_axi_bresp   ), // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid   ( s_axi_bvalid  ), // output wire s_axi_bvalid
                    .s_axi_bready   ( s_axi_bready  ), // input wire s_axi_bready
                    .s_axi_araddr   ( s_axi_araddr  ), // input wire [8 : 0] s_axi_araddr
                    .s_axi_arvalid  ( s_axi_arvalid ), // input wire s_axi_arvalid
                    .s_axi_arready  ( s_axi_arready ), // output wire s_axi_arready
                    .s_axi_rdata    ( s_axi_rdata   ), // output wire [31 : 0] s_axi_rdata
                    .s_axi_rresp    ( s_axi_rresp   ), // output wire [1 : 0] s_axi_rresp
                    .s_axi_rvalid   ( s_axi_rvalid  ), // output wire s_axi_rvalid
                    .s_axi_rready   ( s_axi_rready  ), // input wire s_axi_rready
                    .gpio_io_i      ( gpio_out [i]  )  // input wire [0 : 0] gpio_io_i
                );
            end
    endgenerate : gpios_gen
    
    ////////////////
    // Assertions //
    ////////////////
    // TODO: assert on correct and consistent AXI interfaces bit-width

endmodule : uninasoc
