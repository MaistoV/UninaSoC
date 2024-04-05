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
    localparam NUM_IRQ         = 3;
    localparam NUM_AXI_MASTERS = 2; // RVM socket + JTAG2AXI
    localparam NUM_AXI_SLAVES  = 2 + NUM_GPIO_IN +  NUM_GPIO_OUT; // Main memory + UART + GPIOs
    localparam AXI_DATA_WIDTH  = 32; // TODO: import from enviroment
    localparam AXI_ADDR_WIDTH  = 32; // TODO: import from enviroment

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
    // TODO: use Xilinx' or PULP's ?
    axi_xbar # (
        .tbd()
    ) axi_xbar_inst (
        .masters,
        .slaves
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
    block_ram_memory # (
        .SIZE_BYTES ( MEMORY_SIZE_BYTES ),
        .DATA_WIDTH ( AXI_DATA_WIDTH    ),
        .ADDR_WIDTH ( AXI_ADDR_WIDTH    )
    ) main_memory_inst (
        .axi_slave_TBD
    );

    // UART
    // TODO: use Xilinx' or PULP's ?
    uart # (
        .tbd()
    ) uart_inst (
        // AXI Slave
        .tbd()
        // UART RX and TX
        .uart_rx_i( uart_rx_i ),
        .uart_tx_o ( uart_tx_o )
    );

    // GPIOs
    generate : gpios_gen
            for ( genvar i = 0; i < NUM_GPIO_IN; i++ ) begin
                axi_gpio_in gpio_in_isnt (
                    .s_axi_aclk     (   soc_clk         ), // input wire s_axi_aclk
                    .s_axi_aresetn  (   vio_reset_n     ), // input wire s_axi_aresetn
                    .s_axi_awaddr   (   s_axi_awaddr    ), // input wire [8 : 0] s_axi_awaddr
                    .s_axi_awvalid  (   s_axi_awvalid   ), // input wire s_axi_awvalid
                    .s_axi_awready  (   s_axi_awready   ), // output wire s_axi_awready
                    .s_axi_wdata    (   s_axi_wdata     ), // input wire [31 : 0] s_axi_wdata
                    .s_axi_wstrb    (   s_axi_wstrb     ), // input wire [3 : 0] s_axi_wstrb
                    .s_axi_wvalid   (   s_axi_wvalid    ), // input wire s_axi_wvalid
                    .s_axi_wready   (   s_axi_wready    ), // output wire s_axi_wready
                    .s_axi_bresp    (   s_axi_bresp     ), // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid   (   s_axi_bvalid    ), // output wire s_axi_bvalid
                    .s_axi_bready   (   s_axi_bready    ), // input wire s_axi_bready
                    .s_axi_araddr   (   s_axi_araddr    ), // input wire [8 : 0] s_axi_araddr
                    .s_axi_arvalid  (   s_axi_arvalid   ), // input wire s_axi_arvalid
                    .s_axi_arready  (   s_axi_arready   ), // output wire s_axi_arready
                    .s_axi_rdata    (   s_axi_rdata     ), // output wire [31 : 0] s_axi_rdata
                    .s_axi_rresp    (   s_axi_rresp     ), // output wire [1 : 0] s_axi_rresp
                    .s_axi_rvalid   (   s_axi_rvalid    ), // output wire s_axi_rvalid
                    .s_axi_rready   (   s_axi_rready    ), // input wire s_axi_rready
                    .gpio_io_i      (   gpio_in [i]      )  // input wire [0 : 0] gpio_io_i
                );
            end
            
            for ( genvar i = 0; i < NUM_GPIO_OUT; i++ ) begin
                axi_gpio_out gpio_out_inst (
                    .s_axi_aclk     (   soc_clk         ),        // input wire s_axi_aclk
                    .s_axi_aresetn  (   vio_reset_n     ),  // input wire s_axi_aresetn
                    .s_axi_awaddr   (   s_axi_awaddr    ),    // input wire [8 : 0] s_axi_awaddr
                    .s_axi_awvalid  (   s_axi_awvalid   ),  // input wire s_axi_awvalid
                    .s_axi_awready  (   s_axi_awready   ),  // output wire s_axi_awready
                    .s_axi_wdata    (   s_axi_wdata     ),      // input wire [31 : 0] s_axi_wdata
                    .s_axi_wstrb    (   s_axi_wstrb     ),      // input wire [3 : 0] s_axi_wstrb
                    .s_axi_wvalid   (   s_axi_wvalid    ),    // input wire s_axi_wvalid
                    .s_axi_wready   (   s_axi_wready    ),    // output wire s_axi_wready
                    .s_axi_bresp    (   s_axi_bresp     ),      // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid   (   s_axi_bvalid    ),    // output wire s_axi_bvalid
                    .s_axi_bready   (   s_axi_bready    ),    // input wire s_axi_bready
                    .s_axi_araddr   (   s_axi_araddr    ),    // input wire [8 : 0] s_axi_araddr
                    .s_axi_arvalid  (   s_axi_arvalid   ),  // input wire s_axi_arvalid
                    .s_axi_arready  (   s_axi_arready   ),  // output wire s_axi_arready
                    .s_axi_rdata    (   s_axi_rdata     ),      // output wire [31 : 0] s_axi_rdata
                    .s_axi_rresp    (   s_axi_rresp     ),      // output wire [1 : 0] s_axi_rresp
                    .s_axi_rvalid   (   s_axi_rvalid    ),    // output wire s_axi_rvalid
                    .s_axi_rready   (   s_axi_rready    ),    // input wire s_axi_rready
                    .gpio_io_i      (   gpio_out [i]    )          // input wire [0 : 0] gpio_io_i
                );
            end
    endgenerate : gpios_gen
    
    ////////////////
    // Assertions //
    ////////////////
    // TBD

endmodule : uninasoc
