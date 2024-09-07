// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
// Description: Basic version of UninaSoC that allows to work with axi transactions to and from slaves (ToBeUpdated)
// NOTE: vio and rvm_socket are commented off in this version


// System architecture:
//                                                                                    ________
//   _________              ____________               __________                    |        |
//  |  (tbd)  |            |    (tbd)   |             |          |                   |  Main  |
//  |   vio   |----------->| rvm_socket |------------>|          |        /--------->| Memory |
//  |_________|            |____________|             |   AXI    |        |          |________|
//   __________                                       | crossbar |--------|           __________      __________
//  |          |                                      |          |        |          |          |    |          |
//  | jtag_axi |------------------------------------->|          |        |--------->| AXI4 to  |--->| GPIO out |
//  |__________|                                      |__________|        |          | AXI-lite |    |__________|
//                                                                        |          |__________|
//                                                                        |
//                                                                        |           __________      __________
//                                                                        |          |          |    |  (tbd)   |
//                                                                        |--------->| AXI4 to  |--->| GPIO in  |
//                                                                        |          | AXI-lite |    |__________|
//                                                                        |          |__________|
//                                                                        |
//                                                                        |           __________      ________
//                                                                        \--------->|          |    |  (tbd) |
//                                                                                   | AXI4 to  |--->|  UART  |
//                                                                                   | AXI-lite |    |________|
//                                                                                   |__________|

// Import packages
import uninasoc_pkg::*;


// Import headers
`include "uninasoc_axi.svh"

// Module definition
module uninasoc (
    // Clock and reset
    input logic sys_clock_i,
    input logic sys_reset_i,

    // // UART interface
    // input  logic                        uart_rx_i,
    // output logic                        uart_tx_o

    // GPIOs
    // input  wire [NUM_GPIO_IN  -1 : 0]  gpio_in_i,
    output logic [NUM_GPIO_OUT -1 : 0]  gpio_out_o
);

    /////////////////////
    // Local variables //
    /////////////////////
    // TBD (if any)

    ///////////////////////
    // Clocks and resets //
    ///////////////////////
    // Reset negative
    logic sys_resetn;
    // clkwiz -> all
    logic soc_clk;
    // vio -> all
    logic vio_reset_n;

    ///////////
    // Wires //
    ///////////
    // TODO: add RVM socket
    // vio -> rvm_socket
    // logic [AXI_ADDR_WIDTH -1 : 0 ] vio_bootaddr;
    // logic [NUM_IRQ        -1 : 0 ] vio_irq;
    // uart -> rvm_socket
    // logic uart_interrupt;


    //////////////////////////
    // AXI interconnections //
    //////////////////////////

    // AXI masters
    // jtag2axi -> crossbar
    `DECLARE_AXI_BUS(j2a_to_xbar);
    // rvm_socket -> crossbar
    // `DECLARE_AXI_BUS(rvm_socket);

    // AXI slaves
    // xbar -> main memory
    `DECLARE_AXI_BUS(xbar_to_main_mem);
    // xbar -> GPIO out
    `DECLARE_AXI_BUS(xbar_to_gpio_out);
    // xbar -> GPIO in
    // `DECLARE_AXI_BUS(xbar_to_gpio_in);
    // xbar -> UART
    // `DECLARE_AXI_BUS(xbar_to_uart);

    // Concatenate AXI master buses
    `DECLARE_AXI_BUS_ARRAY(xbar_masters, NUM_AXI_MASTERS);
    // NOTE: The order in this macro expansion is must match with xbar slave ports!
    //                       array_name,       bus 0
    `CONCAT_AXI_MASTERS_ARRAY1(xbar_masters, j2a_to_xbar);
    // TODO: add RVM socket
    // //                       array_name,      bus 1,      bus 0
    // `CONCAT_AXI_BUS_ARRAY2(xbar_masters, rvm_socket, j2a_to_xbar);

    // Concatenate AXI slave buses
   `DECLARE_AXI_BUS_ARRAY(xbar_slaves, NUM_AXI_SLAVES);
    // NOTE: The order in this macro expansion must match with xbar master ports!
    //                      array_name,            bus 1,           bus 0
    `CONCAT_AXI_SLAVES_ARRAY2(xbar_slaves, xbar_to_gpio_out, xbar_to_main_mem);
    // TODO: add GPIO in
    // //                      array_name,           bus 2,           bus 1,             bus 0
    // `CONCAT_AXI_BUS_ARRAY3(xbar_slaves, xbar_to_gpio_in, xbar_to_gpio_out, xbar_to_main_mem);
    // TODO: add UART
    // //                      array_name,        bus 3,           bus 2,           bus 1,             bus 0
    // `CONCAT_AXI_BUS_ARRAY4(xbar_slaves, xbar_to_uart, xbar_to_gpio_in, xbar_to_gpio_out, xbar_to_main_mem);


    ///////////////////////
    // Local assignments //
    ///////////////////////
    assign sys_resetn = ~sys_reset_i;

    /////////////
    // Modules //
    /////////////

    // PLL
    xlnx_clk_wiz clkwiz_inst (
        .clk_in1  ( sys_clock_i  ),
        .resetn   ( sys_resetn ),
        .locked   ( ),
        .clk_100  ( ),
        .clk_50   ( soc_clk   ),
        .clk_20   ( ),
        .clk_10   ( )
    );

    // // Virtual I/O
    // xlnx_vio vio_inst (
    //   .clk        ( soc_clk      ),
    //   .probe_out0 ( vio_reset_n  ),
    //   .probe_out1 ( vio_bootaddr ),
    //   .probe_out2 ( vio_irq[0]    ),
    //   .probe_out3 ( vio_irq[1]    ),
    //   .probe_out3 ( vio_irq[2]    )
    // );

    // Axi Crossbar
    xlnx_axi_crossbar axi_xbar_inst (
        .aclk           ( soc_clk                   ), // input wire aclk
        .aresetn        ( sys_resetn                ), // input wire aresetn
        .s_axi_awid     ( xbar_masters_axi_awid     ), // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr   ( xbar_masters_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( xbar_masters_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( xbar_masters_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( xbar_masters_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( xbar_masters_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( xbar_masters_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( xbar_masters_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
        .s_axi_awqos    ( xbar_masters_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( xbar_masters_axi_awvalid  ), // input wire [0 : 0] s_axi_awvalid
        .s_axi_awready  ( xbar_masters_axi_awready  ), // output wire [0 : 0] s_axi_awready
        .s_axi_wdata    ( xbar_masters_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( xbar_masters_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( xbar_masters_axi_wlast    ), // input wire [0 : 0] s_axi_wlast
        .s_axi_wvalid   ( xbar_masters_axi_wvalid   ), // input wire [0 : 0] s_axi_wvalid
        .s_axi_wready   ( xbar_masters_axi_wready   ), // output wire [0 : 0] s_axi_wready
        .s_axi_bid      ( xbar_masters_axi_bid      ), // output wire [1 : 0] s_axi_bid
        .s_axi_bresp    ( xbar_masters_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( xbar_masters_axi_bvalid   ), // output wire [0 : 0] s_axi_bvalid
        .s_axi_bready   ( xbar_masters_axi_bready   ), // input wire [0 : 0] s_axi_bready
        .s_axi_arid     ( xbar_masters_axi_arid     ), // output wire [1 : 0] s_axi_rid
        .s_axi_araddr   ( xbar_masters_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( xbar_masters_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( xbar_masters_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( xbar_masters_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( xbar_masters_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( xbar_masters_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( xbar_masters_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
        .s_axi_arqos    ( xbar_masters_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( xbar_masters_axi_arvalid  ), // input wire [0 : 0] s_axi_arvalid
        .s_axi_arready  ( xbar_masters_axi_arready  ), // output wire [0 : 0] s_axi_arready
        .s_axi_rid      ( xbar_masters_axi_rid      ), // output wire [1 : 0] s_axi_rid
        .s_axi_rdata    ( xbar_masters_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( xbar_masters_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( xbar_masters_axi_rlast    ), // output wire [0 : 0] s_axi_rlast
        .s_axi_rvalid   ( xbar_masters_axi_rvalid   ), // output wire [0 : 0] s_axi_rvalid
        .s_axi_rready   ( xbar_masters_axi_rready   ), // input wire [0 : 0] s_axi_rready
        .m_axi_awid     ( xbar_slaves_axi_awid      ), // output wire [3 : 0] m_axi_awid
        .m_axi_awaddr   ( xbar_slaves_axi_awaddr    ), // output wire [63 : 0] m_axi_awaddr
        .m_axi_awlen    ( xbar_slaves_axi_awlen     ), // output wire [15 : 0] m_axi_awlen
        .m_axi_awsize   ( xbar_slaves_axi_awsize    ), // output wire [5 : 0] m_axi_awsize
        .m_axi_awburst  ( xbar_slaves_axi_awburst   ), // output wire [3 : 0] m_axi_awburst
        .m_axi_awlock   ( xbar_slaves_axi_awlock    ), // output wire [1 : 0] m_axi_awlock
        .m_axi_awcache  ( xbar_slaves_axi_awcache   ), // output wire [7 : 0] m_axi_awcache
        .m_axi_awprot   ( xbar_slaves_axi_awprot    ), // output wire [5 : 0] m_axi_awprot
        .m_axi_awregion ( xbar_slaves_axi_awregion  ), // output wire [7 : 0] m_axi_awregion
        .m_axi_awqos    ( xbar_slaves_axi_awqos     ), // output wire [7 : 0] m_axi_awqos
        .m_axi_awvalid  ( xbar_slaves_axi_awvalid   ), // output wire [1 : 0] m_axi_awvalid
        .m_axi_awready  ( xbar_slaves_axi_awready   ), // input wire [1 : 0] m_axi_awready
        .m_axi_wdata    ( xbar_slaves_axi_wdata     ), // output wire [63 : 0] m_axi_wdata
        .m_axi_wstrb    ( xbar_slaves_axi_wstrb     ), // output wire [7 : 0] m_axi_wstrb
        .m_axi_wlast    ( xbar_slaves_axi_wlast     ), // output wire [1 : 0] m_axi_wlast
        .m_axi_wvalid   ( xbar_slaves_axi_wvalid    ), // output wire [1 : 0] m_axi_wvalid
        .m_axi_wready   ( xbar_slaves_axi_wready    ), // input wire [1 : 0] m_axi_wready
        .m_axi_bid      ( xbar_slaves_axi_bid       ), // input wire [3 : 0] m_axi_bid
        .m_axi_bresp    ( xbar_slaves_axi_bresp     ), // input wire [3 : 0] m_axi_bresp
        .m_axi_bvalid   ( xbar_slaves_axi_bvalid    ), // input wire [1 : 0] m_axi_bvalid
        .m_axi_bready   ( xbar_slaves_axi_bready    ), // output wire [1 : 0] m_axi_bready
        .m_axi_arid     ( xbar_slaves_axi_arid      ), // output wire [3 : 0] m_axi_arid
        .m_axi_araddr   ( xbar_slaves_axi_araddr    ), // output wire [63 : 0] m_axi_araddr
        .m_axi_arlen    ( xbar_slaves_axi_arlen     ), // output wire [15 : 0] m_axi_arlen
        .m_axi_arsize   ( xbar_slaves_axi_arsize    ), // output wire [5 : 0] m_axi_arsize
        .m_axi_arburst  ( xbar_slaves_axi_arburst   ), // output wire [3 : 0] m_axi_arburst
        .m_axi_arlock   ( xbar_slaves_axi_arlock    ), // output wire [1 : 0] m_axi_arlock
        .m_axi_arcache  ( xbar_slaves_axi_arcache   ), // output wire [7 : 0] m_axi_arcache
        .m_axi_arprot   ( xbar_slaves_axi_arprot    ), // output wire [5 : 0] m_axi_arprot
        .m_axi_arregion ( xbar_slaves_axi_arregion  ), // output wire [7 : 0] m_axi_arregion
        .m_axi_arqos    ( xbar_slaves_axi_arqos     ), // output wire [7 : 0] m_axi_arqos
        .m_axi_arvalid  ( xbar_slaves_axi_arvalid   ), // output wire [1 : 0] m_axi_arvalid
        .m_axi_arready  ( xbar_slaves_axi_arready   ), // input wire [1 : 0] m_axi_arready
        .m_axi_rid      ( xbar_slaves_axi_rid       ), // input wire [3 : 0] m_axi_rid
        .m_axi_rdata    ( xbar_slaves_axi_rdata     ), // input wire [63 : 0] m_axi_rdata
        .m_axi_rresp    ( xbar_slaves_axi_rresp     ), // input wire [3 : 0] m_axi_rresp
        .m_axi_rlast    ( xbar_slaves_axi_rlast     ), // input wire [1 : 0] m_axi_rlast
        .m_axi_rvalid   ( xbar_slaves_axi_rvalid    ), // input wire [1 : 0] m_axi_rvalid
        .m_axi_rready   ( xbar_slaves_axi_rready    )  // output wire [1 : 0] m_axi_rready
    );

    /////////////////
    // AXI masters //
    /////////////////

    // JTAG2AXI Master
    xlnx_jtag_axi jtag_axi_inst (
        .aclk           ( soc_clk                   ), // input wire aclk
        .aresetn        ( sys_resetn                ), // input wire aresetn
        .m_axi_awid     ( j2a_to_xbar_axi_awid      ), // output wire [1 : 0] m_axi_awid
        .m_axi_awaddr   ( j2a_to_xbar_axi_awaddr    ), // output wire [31 : 0] m_axi_awid
        .m_axi_awlen    ( j2a_to_xbar_axi_awlen     ), // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize   ( j2a_to_xbar_axi_awsize    ), // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst  ( j2a_to_xbar_axi_awburst   ), // output wire [1 : 0] m_axi_awburst
        .m_axi_awlock   ( j2a_to_xbar_axi_awlock    ), // output wire m_axi_awlock
        .m_axi_awcache  ( j2a_to_xbar_axi_awcache   ), // output wire [3 : 0] m_axi_awcache
        .m_axi_awprot   ( j2a_to_xbar_axi_awprot    ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awqos    ( j2a_to_xbar_axi_awqos     ), // output wire [3 : 0] m_axi_awqos
        .m_axi_awvalid  ( j2a_to_xbar_axi_awvalid   ), // output wire m_axi_awvalid
        .m_axi_awready  ( j2a_to_xbar_axi_awready   ), // input wire m_axi_awready
        .m_axi_wdata    ( j2a_to_xbar_axi_wdata     ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    ( j2a_to_xbar_axi_wstrb     ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wlast    ( j2a_to_xbar_axi_wlast     ), // output wire m_axi_wlast
        .m_axi_wvalid   ( j2a_to_xbar_axi_wvalid    ), // output wire m_axi_wvalid
        .m_axi_wready   ( j2a_to_xbar_axi_wready    ), // input wire m_axi_wready
        .m_axi_bid      ( j2a_to_xbar_axi_bid       ), // input wire [0 : 0] m_axi_bid
        .m_axi_bresp    ( j2a_to_xbar_axi_bresp     ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   ( j2a_to_xbar_axi_bvalid    ), // input wire m_axi_bvalid
        .m_axi_bready   ( j2a_to_xbar_axi_bready    ), // output wire m_axi_bready
        .m_axi_arid     ( j2a_to_xbar_axi_arid      ), // output wire [0 : 0] m_axi_arid
        .m_axi_araddr   ( j2a_to_xbar_axi_araddr    ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arlen    ( j2a_to_xbar_axi_arlen     ), // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize   ( j2a_to_xbar_axi_arsize    ), // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst  ( j2a_to_xbar_axi_arburst   ), // output wire [1 : 0] m_axi_arburst
        .m_axi_arlock   ( j2a_to_xbar_axi_arlock    ), // output wire m_axi_arlock
        .m_axi_arcache  ( j2a_to_xbar_axi_arcache   ), // output wire [3 : 0] m_axi_arcache
        .m_axi_arprot   ( j2a_to_xbar_axi_arprot    ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arqos    ( j2a_to_xbar_axi_arqos     ), // output wire [3 : 0] m_axi_arqos
        .m_axi_arvalid  ( j2a_to_xbar_axi_arvalid   ), // output wire m_axi_arvalid
        .m_axi_arready  ( j2a_to_xbar_axi_arready   ), // input wire m_axi_arready
        .m_axi_rid      ( j2a_to_xbar_axi_rid       ), // input wire [1 : 0] m_axi_rid
        .m_axi_rdata    ( j2a_to_xbar_axi_rdata     ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    ( j2a_to_xbar_axi_rresp     ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast    ( j2a_to_xbar_axi_rlast     ), // input wire m_axi_rlast
        .m_axi_rvalid   ( j2a_to_xbar_axi_rvalid    ), // input wire m_axi_rvalid
        .m_axi_rready   ( j2a_to_xbar_axi_rready    )  // output wire m_axi_rready
    );

    // // RVM Socket
    // rvm_socket # (
    //     .DATA_WIDTH ( AXI_DATA_WIDTH ),
    //     .ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    //     .NUM_IRQ    ( NUM_IRQ        )
    // ) rvm_socket_inst (
    //     .clock_i        ( soc_clk      ),
    //     .reset_ni       ( vio_reset_n  ),
    //     .boot_address_i ( vio_bootaddr ),
    //     .irq_i          ( vio_irq      )
    //     .axi_master
    //     .tbd()
    // );

    ////////////////
    // AXI slaves //
    ////////////////

    // Main memory
    xlnx_blk_mem_gen main_memory_inst (
        .rsta_busy      ( /* open */                   ), // output wire rsta_busy
        .rstb_busy      ( /* open */                   ), // output wire rstb_busy
        .s_aclk         ( soc_clk                      ), // input wire s_aclk
        .s_aresetn      ( sys_resetn                   ), // input wire s_aresetn
        .s_axi_awid     ( xbar_to_main_mem_axi_awid    ), // input wire [3 : 0] s_axi_awid
        .s_axi_awaddr   ( xbar_to_main_mem_axi_awaddr  ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( xbar_to_main_mem_axi_awlen   ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( xbar_to_main_mem_axi_awsize  ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( xbar_to_main_mem_axi_awburst ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid  ( xbar_to_main_mem_axi_awvalid ), // input wire s_axi_awvalid
        .s_axi_awready  ( xbar_to_main_mem_axi_awready ), // output wire s_axi_awready
        .s_axi_wdata    ( xbar_to_main_mem_axi_wdata   ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( xbar_to_main_mem_axi_wstrb   ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( xbar_to_main_mem_axi_wlast   ), // input wire s_axi_wlast
        .s_axi_wvalid   ( xbar_to_main_mem_axi_wvalid  ), // input wire s_axi_wvalid
        .s_axi_wready   ( xbar_to_main_mem_axi_wready  ), // output wire s_axi_wready
        .s_axi_bid      ( xbar_to_main_mem_axi_bid     ), // output wire [3 : 0] s_axi_bid
        .s_axi_bresp    ( xbar_to_main_mem_axi_bresp   ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( xbar_to_main_mem_axi_bvalid  ), // output wire s_axi_bvalid
        .s_axi_bready   ( xbar_to_main_mem_axi_bready  ), // input wire s_axi_bready
        .s_axi_arid     ( xbar_to_main_mem_axi_arid    ), // input wire [3 : 0] s_axi_arid
        .s_axi_araddr   ( xbar_to_main_mem_axi_araddr  ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( xbar_to_main_mem_axi_arlen   ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( xbar_to_main_mem_axi_arsize  ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( xbar_to_main_mem_axi_arburst ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid  ( xbar_to_main_mem_axi_arvalid ), // input wire s_axi_arvalid
        .s_axi_arready  ( xbar_to_main_mem_axi_arready ), // output wire s_axi_arready
        .s_axi_rid      ( xbar_to_main_mem_axi_rid     ), // output wire [3 : 0] s_axi_rid
        .s_axi_rdata    ( xbar_to_main_mem_axi_rdata   ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( xbar_to_main_mem_axi_rresp   ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( xbar_to_main_mem_axi_rlast   ), // output wire s_axi_rlast
        .s_axi_rvalid   ( xbar_to_main_mem_axi_rvalid  ), // output wire s_axi_rvalid
        .s_axi_rready   ( xbar_to_main_mem_axi_rready  )  // input wire s_axi_rready
    );

    //////////
    // UART //
    //////////
    // TODO: integrate and verify UART
    // xbar -> axi4_to_axilite -> uart
    //
    // // axi4_to_axilite -> uart
    // `DECLARE_AXILITE_BUS(uart);
    //
    // // AXI4 to AXI4-Lite protocol converter
    // xlnx_axi4_to_axilite_converter axi4_to_axilite_uart_inst (
    //     .aclk           ( soc_clk                   ), // input wire s_axi_aclk
    //     .aresetn        ( sys_resetn                ), // input wire s_axi_aresetn
    //     // AXI4 slave port (from xbar)
    //     .s_axi_awid     ( xbar_to_uart_axi_awid     ), // input wire [1 : 0] s_axi_awid
    //     .s_axi_awaddr   ( xbar_to_uart_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
    //     .s_axi_awlen    ( xbar_to_uart_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
    //     .s_axi_awsize   ( xbar_to_uart_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
    //     .s_axi_awburst  ( xbar_to_uart_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
    //     .s_axi_awlock   ( xbar_to_uart_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
    //     .s_axi_awcache  ( xbar_to_uart_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
    //     .s_axi_awprot   ( xbar_to_uart_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
    //     .s_axi_awregion ( xbar_to_uart_axi_awregion ), // input wire [3 : 0] s_axi_awregion
    //     .s_axi_awqos    ( xbar_to_uart_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
    //     .s_axi_awvalid  ( xbar_to_uart_axi_awvalid  ), // input wire s_axi_awvalid
    //     .s_axi_awready  ( xbar_to_uart_axi_awready  ), // output wire s_axi_awready
    //     .s_axi_wdata    ( xbar_to_uart_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
    //     .s_axi_wstrb    ( xbar_to_uart_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
    //     .s_axi_wlast    ( xbar_to_uart_axi_wlast    ), // input wire s_axi_wlast
    //     .s_axi_wvalid   ( xbar_to_uart_axi_wvalid   ), // input wire s_axi_wvalid
    //     .s_axi_wready   ( xbar_to_uart_axi_wready   ), // output wire s_axi_wready
    //     .s_axi_bid      ( xbar_to_uart_axi_bid      ), // output wire [1 : 0] s_axi_bid
    //     .s_axi_bresp    ( xbar_to_uart_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
    //     .s_axi_bvalid   ( xbar_to_uart_axi_bvalid   ), // output wire s_axi_bvalid
    //     .s_axi_bready   ( xbar_to_uart_axi_bready   ), // input wire s_axi_bready
    //     .s_axi_arid     ( xbar_to_uart_axi_arid     ), // input wire [1 : 0] s_axi_arid
    //     .s_axi_araddr   ( xbar_to_uart_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
    //     .s_axi_arlen    ( xbar_to_uart_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
    //     .s_axi_arsize   ( xbar_to_uart_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
    //     .s_axi_arburst  ( xbar_to_uart_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
    //     .s_axi_arlock   ( xbar_to_uart_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
    //     .s_axi_arcache  ( xbar_to_uart_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
    //     .s_axi_arprot   ( xbar_to_uart_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
    //     .s_axi_arregion ( xbar_to_uart_axi_arregion ), // input wire [3 : 0] s_axi_arregion
    //     .s_axi_arqos    ( xbar_to_uart_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
    //     .s_axi_arvalid  ( xbar_to_uart_axi_arvalid  ), // input wire s_axi_arvalid
    //     .s_axi_arready  ( xbar_to_uart_axi_arready  ), // output wire s_axi_arready
    //     .s_axi_rid      ( xbar_to_uart_axi_rid      ), // output wire [1 : 0] s_axi_rid
    //     .s_axi_rdata    ( xbar_to_uart_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
    //     .s_axi_rresp    ( xbar_to_uart_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
    //     .s_axi_rlast    ( xbar_to_uart_axi_rlast    ), // output wire s_axi_rlast
    //     .s_axi_rvalid   ( xbar_to_uart_axi_rvalid   ), // output wire s_axi_rvalid
    //     .s_axi_rready   ( xbar_to_uart_axi_rready   ), // input wire s_axi_rready
    //     // Master port (to GPIO)
    //     .m_axi_awaddr   ( uart_axilite_awaddr       ), // output wire [31 : 0] m_axi_awaddr
    //     .m_axi_awprot   ( uart_axilite_awprot       ), // output wire [2 : 0] m_axi_awprot
    //     .m_axi_awvalid  ( uart_axilite_awvalid      ), // output wire m_axi_awvalid
    //     .m_axi_awready  ( uart_axilite_awready      ), // input wire m_axi_awready
    //     .m_axi_wdata    ( uart_axilite_wdata        ), // output wire [31 : 0] m_axi_wdata
    //     .m_axi_wstrb    ( uart_axilite_wstrb        ), // output wire [3 : 0] m_axi_wstrb
    //     .m_axi_wvalid   ( uart_axilite_wvalid       ), // output wire m_axi_wvalid
    //     .m_axi_wready   ( uart_axilite_wready       ), // input wire m_axi_wready
    //     .m_axi_bresp    ( uart_axilite_bresp        ), // input wire [1 : 0] m_axi_bresp
    //     .m_axi_bvalid   ( uart_axilite_bvalid       ), // input wire m_axi_bvalid
    //     .m_axi_bready   ( uart_axilite_bready       ), // output wire m_axi_bready
    //     .m_axi_araddr   ( uart_axilite_araddr       ), // output wire [31 : 0] m_axi_araddr
    //     .m_axi_arprot   ( uart_axilite_arprot       ), // output wire [2 : 0] m_axi_arprot
    //     .m_axi_arvalid  ( uart_axilite_arvalid      ), // output wire m_axi_arvalid
    //     .m_axi_arready  ( uart_axilite_arready      ), // input wire m_axi_arready
    //     .m_axi_rdata    ( uart_axilite_rdata        ), // input wire [31 : 0] m_axi_rdata
    //     .m_axi_rresp    ( uart_axilite_rresp        ), // input wire [1 : 0] m_axi_rresp
    //     .m_axi_rvalid   ( uart_axilite_rvalid       ), // input wire m_axi_rvalid
    //     .m_axi_rready   ( uart_axilite_rready       )  // output wire m_axi_rready
    // );
    //
    // // UART
    // xlnx_axi_uartlite axi_uartlite_inst (
    //     // AXI Slave
    //     .s_axi_aclk     ( s_axi_aclk     ), // input wire s_axi_aclk
    //     .s_axi_aresetn  ( s_axi_aresetn  ), // input wire s_axi_aresetn
    //     .s_axi_awaddr   ( s_axi_awaddr   ), // input wire [3 : 0] s_axi_awaddr
    //     .s_axi_awvalid  ( s_axi_awvalid  ), // input wire s_axi_awvalid
    //     .s_axi_awready  ( s_axi_awready  ), // output wire s_axi_awready
    //     .s_axi_wdata    ( s_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
    //     .s_axi_wstrb    ( s_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
    //     .s_axi_wvalid   ( s_axi_wvalid   ), // input wire s_axi_wvalid
    //     .s_axi_wready   ( s_axi_wready   ), // output wire s_axi_wready
    //     .s_axi_bresp    ( s_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
    //     .s_axi_bvalid   ( s_axi_bvalid   ), // output wire s_axi_bvalid
    //     .s_axi_bready   ( s_axi_bready   ), // input wire s_axi_bready
    //     .s_axi_araddr   ( s_axi_araddr   ), // input wire [3 : 0] s_axi_araddr
    //     .s_axi_arvalid  ( s_axi_arvalid  ), // input wire s_axi_arvalid
    //     .s_axi_arready  ( s_axi_arready  ), // output wire s_axi_arready
    //     .s_axi_rdata    ( s_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
    //     .s_axi_rresp    ( s_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
    //     .s_axi_rvalid   ( s_axi_rvalid   ), // output wire s_axi_rvalid
    //     .s_axi_rready   ( s_axi_rready   ), // input wire s_axi_rready
    //     // Interrupt signal
    //     .interrupt      ( uart_interrupt ), // output wire interrupt
    //     // UART RX and TX
    //     .rx             ( uart_rx_i      ), // input wire rx
    //     .tx             ( uart_tx_o      )  // output wire tx
    // );

    // GPIOs
    generate
        // // GPIO in
        // for ( genvar i = 0; i < NUM_GPIO_IN; i++ ) begin
        //     // axi4_to_axilite -> gpio_in
        //     `DECLARE_AXILITE_BUS(gpio_in);
        //
        //     // AXI4 to AXI4-Lite protocol converter
        //     xlnx_axi4_to_axilite_converter axi4_to_axilite_inst (
        //         .aclk           ( soc_clk                      ), // input wire s_axi_aclk
        //         .aresetn        ( sys_resetn                   ), // input wire s_axi_aresetn
        //         // AXI4 slave port (from xbar)
        //         .s_axi_awid     ( xbar_to_gpio_in_axi_awid     ), // input wire [1 : 0] s_axi_awid
        //         .s_axi_awaddr   ( xbar_to_gpio_in_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
        //         .s_axi_awlen    ( xbar_to_gpio_in_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
        //         .s_axi_awsize   ( xbar_to_gpio_in_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
        //         .s_axi_awburst  ( xbar_to_gpio_in_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
        //         .s_axi_awlock   ( xbar_to_gpio_in_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
        //         .s_axi_awcache  ( xbar_to_gpio_in_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
        //         .s_axi_awprot   ( xbar_to_gpio_in_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
        //         .s_axi_awregion ( xbar_to_gpio_in_axi_awregion ), // input wire [3 : 0] s_axi_awregion
        //         .s_axi_awqos    ( xbar_to_gpio_in_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
        //         .s_axi_awvalid  ( xbar_to_gpio_in_axi_awvalid  ), // input wire s_axi_awvalid
        //         .s_axi_awready  ( xbar_to_gpio_in_axi_awready  ), // output wire s_axi_awready
        //         .s_axi_wdata    ( xbar_to_gpio_in_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        //         .s_axi_wstrb    ( xbar_to_gpio_in_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        //         .s_axi_wlast    ( xbar_to_gpio_in_axi_wlast    ), // input wire s_axi_wlast
        //         .s_axi_wvalid   ( xbar_to_gpio_in_axi_wvalid   ), // input wire s_axi_wvalid
        //         .s_axi_wready   ( xbar_to_gpio_in_axi_wready   ), // output wire s_axi_wready
        //         .s_axi_bid      ( xbar_to_gpio_in_axi_bid      ), // output wire [1 : 0] s_axi_bid
        //         .s_axi_bresp    ( xbar_to_gpio_in_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        //         .s_axi_bvalid   ( xbar_to_gpio_in_axi_bvalid   ), // output wire s_axi_bvalid
        //         .s_axi_bready   ( xbar_to_gpio_in_axi_bready   ), // input wire s_axi_bready
        //         .s_axi_arid     ( xbar_to_gpio_in_axi_arid     ), // input wire [1 : 0] s_axi_arid
        //         .s_axi_araddr   ( xbar_to_gpio_in_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
        //         .s_axi_arlen    ( xbar_to_gpio_in_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
        //         .s_axi_arsize   ( xbar_to_gpio_in_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
        //         .s_axi_arburst  ( xbar_to_gpio_in_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
        //         .s_axi_arlock   ( xbar_to_gpio_in_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
        //         .s_axi_arcache  ( xbar_to_gpio_in_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
        //         .s_axi_arprot   ( xbar_to_gpio_in_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
        //         .s_axi_arregion ( xbar_to_gpio_in_axi_arregion ), // input wire [3 : 0] s_axi_arregion
        //         .s_axi_arqos    ( xbar_to_gpio_in_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
        //         .s_axi_arvalid  ( xbar_to_gpio_in_axi_arvalid  ), // input wire s_axi_arvalid
        //         .s_axi_arready  ( xbar_to_gpio_in_axi_arready  ), // output wire s_axi_arready
        //         .s_axi_rid      ( xbar_to_gpio_in_axi_rid      ), // output wire [1 : 0] s_axi_rid
        //         .s_axi_rdata    ( xbar_to_gpio_in_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        //         .s_axi_rresp    ( xbar_to_gpio_in_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        //         .s_axi_rlast    ( xbar_to_gpio_in_axi_rlast    ), // output wire s_axi_rlast
        //         .s_axi_rvalid   ( xbar_to_gpio_in_axi_rvalid   ), // output wire s_axi_rvalid
        //         .s_axi_rready   ( xbar_to_gpio_in_axi_rready   ), // input wire s_axi_rready
        //         // Master port (to GPIO)
        //         .m_axi_awaddr   ( gpio_in_axilite_awaddr       ), // output wire [31 : 0] m_axi_awaddr
        //         .m_axi_awprot   ( gpio_in_axilite_awprot       ), // output wire [2 : 0] m_axi_awprot
        //         .m_axi_awvalid  ( gpio_in_axilite_awvalid      ), // output wire m_axi_awvalid
        //         .m_axi_awready  ( gpio_in_axilite_awready      ), // input wire m_axi_awready
        //         .m_axi_wdata    ( gpio_in_axilite_wdata        ), // output wire [31 : 0] m_axi_wdata
        //         .m_axi_wstrb    ( gpio_in_axilite_wstrb        ), // output wire [3 : 0] m_axi_wstrb
        //         .m_axi_wvalid   ( gpio_in_axilite_wvalid       ), // output wire m_axi_wvalid
        //         .m_axi_wready   ( gpio_in_axilite_wready       ), // input wire m_axi_wready
        //         .m_axi_bresp    ( gpio_in_axilite_bresp        ), // input wire [1 : 0] m_axi_bresp
        //         .m_axi_bvalid   ( gpio_in_axilite_bvalid       ), // input wire m_axi_bvalid
        //         .m_axi_bready   ( gpio_in_axilite_bready       ), // output wire m_axi_bready
        //         .m_axi_araddr   ( gpio_in_axilite_araddr       ), // output wire [31 : 0] m_axi_araddr
        //         .m_axi_arprot   ( gpio_in_axilite_arprot       ), // output wire [2 : 0] m_axi_arprot
        //         .m_axi_arvalid  ( gpio_in_axilite_arvalid      ), // output wire m_axi_arvalid
        //         .m_axi_arready  ( gpio_in_axilite_arready      ), // input wire m_axi_arready
        //         .m_axi_rdata    ( gpio_in_axilite_rdata        ), // input wire [31 : 0] m_axi_rdata
        //         .m_axi_rresp    ( gpio_in_axilite_rresp        ), // input wire [1 : 0] m_axi_rresp
        //         .m_axi_rvalid   ( gpio_in_axilite_rvalid       ), // input wire m_axi_rvalid
        //         .m_axi_rready   ( gpio_in_axilite_rready       )  // output wire m_axi_rready
        //     );
        //
        //     axi_gpio_in gpio_in_inst (
        //         .s_axi_aclk     ( soc_clk                      ), // input wire s_axi_aclk
        //         .s_axi_aresetn  ( sys_resetn                   ), // input wire s_axi_aresetn
        //         .s_axi_awaddr   ( gpio_in_axilite_awaddr [8:0] ), // input wire [8 : 0] s_axi_awaddr
        //         .s_axi_awvalid  ( gpio_in_axilite_awvalid      ), // input wire s_axi_awvalid
        //         .s_axi_awready  ( gpio_in_axilite_awready      ), // output wire s_axi_awready
        //         .s_axi_wdata    ( gpio_in_axilite_wdata        ), // input wire [31 : 0] s_axi_wdata
        //         .s_axi_wstrb    ( gpio_in_axilite_wstrb        ), // input wire [3 : 0] s_axi_wstrb
        //         .s_axi_wvalid   ( gpio_in_axilite_wvalid       ), // input wire s_axi_wvalid
        //         .s_axi_wready   ( gpio_in_axilite_wready       ), // output wire s_axi_wready
        //         .s_axi_bresp    ( gpio_in_axilite_bresp        ), // output wire [1 : 0] s_axi_bresp
        //         .s_axi_bvalid   ( gpio_in_axilite_bvalid       ), // output wire s_axi_bvalid
        //         .s_axi_bready   ( gpio_in_axilite_bready       ), // input wire s_axi_bready
        //         .s_axi_araddr   ( gpio_in_axilite_araddr [8:0] ), // input wire [8 : 0] s_axi_araddr
        //         .s_axi_arvalid  ( gpio_in_axilite_arvalid      ), // input wire s_axi_arvalid
        //         .s_axi_arready  ( gpio_in_axilite_arready      ), // output wire s_axi_arready
        //         .s_axi_rdata    ( gpio_in_axilite_rdata        ), // output wire [31 : 0] s_axi_rdata
        //         .s_axi_rresp    ( gpio_in_axilite_rresp        ), // output wire [1 : 0] s_axi_rresp
        //         .s_axi_rvalid   ( gpio_in_axilite_rvalid       ), // output wire s_axi_rvalid
        //         .s_axi_rready   ( gpio_in_axilite_rready       ), // input wire s_axi_rready
        //         .gpio_io_i      ( gpio_in_i [i]                )  // input wire [0 : 0] gpio_io_i
        //     );
        // end

        // GPIO out
        for ( genvar i = 0; i < NUM_GPIO_OUT; i++ ) begin
            // axi4_to_axilite -> gpio_out
            `DECLARE_AXILITE_BUS(gpio_out);

            // AXI4 to AXI4-Lite protocol converter
            xlnx_axi4_to_axilite_converter axi4_to_axilite_inst (
                .aclk           ( soc_clk                       ), // input wire s_axi_aclk
                .aresetn        ( sys_resetn                    ), // input wire s_axi_aresetn
                // AXI4 slave port (from xbar)
                .s_axi_awid     ( xbar_to_gpio_out_axi_awid     ), // input wire [1 : 0] s_axi_awid
                .s_axi_awaddr   ( xbar_to_gpio_out_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
                .s_axi_awlen    ( xbar_to_gpio_out_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
                .s_axi_awsize   ( xbar_to_gpio_out_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
                .s_axi_awburst  ( xbar_to_gpio_out_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
                .s_axi_awlock   ( xbar_to_gpio_out_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
                .s_axi_awcache  ( xbar_to_gpio_out_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
                .s_axi_awprot   ( xbar_to_gpio_out_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
                .s_axi_awregion ( xbar_to_gpio_out_axi_awregion ), // input wire [3 : 0] s_axi_awregion
                .s_axi_awqos    ( xbar_to_gpio_out_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
                .s_axi_awvalid  ( xbar_to_gpio_out_axi_awvalid  ), // input wire s_axi_awvalid
                .s_axi_awready  ( xbar_to_gpio_out_axi_awready  ), // output wire s_axi_awready
                .s_axi_wdata    ( xbar_to_gpio_out_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
                .s_axi_wstrb    ( xbar_to_gpio_out_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
                .s_axi_wlast    ( xbar_to_gpio_out_axi_wlast    ), // input wire s_axi_wlast
                .s_axi_wvalid   ( xbar_to_gpio_out_axi_wvalid   ), // input wire s_axi_wvalid
                .s_axi_wready   ( xbar_to_gpio_out_axi_wready   ), // output wire s_axi_wready
                .s_axi_bid      ( xbar_to_gpio_out_axi_bid      ), // output wire [1 : 0] s_axi_bid
                .s_axi_bresp    ( xbar_to_gpio_out_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
                .s_axi_bvalid   ( xbar_to_gpio_out_axi_bvalid   ), // output wire s_axi_bvalid
                .s_axi_bready   ( xbar_to_gpio_out_axi_bready   ), // input wire s_axi_bready
                .s_axi_arid     ( xbar_to_gpio_out_axi_arid     ), // input wire [1 : 0] s_axi_arid
                .s_axi_araddr   ( xbar_to_gpio_out_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
                .s_axi_arlen    ( xbar_to_gpio_out_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
                .s_axi_arsize   ( xbar_to_gpio_out_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
                .s_axi_arburst  ( xbar_to_gpio_out_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
                .s_axi_arlock   ( xbar_to_gpio_out_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
                .s_axi_arcache  ( xbar_to_gpio_out_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
                .s_axi_arprot   ( xbar_to_gpio_out_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
                .s_axi_arregion ( xbar_to_gpio_out_axi_arregion ), // input wire [3 : 0] s_axi_arregion
                .s_axi_arqos    ( xbar_to_gpio_out_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
                .s_axi_arvalid  ( xbar_to_gpio_out_axi_arvalid  ), // input wire s_axi_arvalid
                .s_axi_arready  ( xbar_to_gpio_out_axi_arready  ), // output wire s_axi_arready
                .s_axi_rid      ( xbar_to_gpio_out_axi_rid      ), // output wire [1 : 0] s_axi_rid
                .s_axi_rdata    ( xbar_to_gpio_out_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
                .s_axi_rresp    ( xbar_to_gpio_out_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
                .s_axi_rlast    ( xbar_to_gpio_out_axi_rlast    ), // output wire s_axi_rlast
                .s_axi_rvalid   ( xbar_to_gpio_out_axi_rvalid   ), // output wire s_axi_rvalid
                .s_axi_rready   ( xbar_to_gpio_out_axi_rready   ), // input wire s_axi_rready
                // Master port (to GPIO)
                .m_axi_awaddr   ( gpio_out_axilite_awaddr       ), // output wire [31 : 0] m_axi_awaddr
                .m_axi_awprot   ( gpio_out_axilite_awprot       ), // output wire [2 : 0] m_axi_awprot
                .m_axi_awvalid  ( gpio_out_axilite_awvalid      ), // output wire m_axi_awvalid
                .m_axi_awready  ( gpio_out_axilite_awready      ), // input wire m_axi_awready
                .m_axi_wdata    ( gpio_out_axilite_wdata        ), // output wire [31 : 0] m_axi_wdata
                .m_axi_wstrb    ( gpio_out_axilite_wstrb        ), // output wire [3 : 0] m_axi_wstrb
                .m_axi_wvalid   ( gpio_out_axilite_wvalid       ), // output wire m_axi_wvalid
                .m_axi_wready   ( gpio_out_axilite_wready       ), // input wire m_axi_wready
                .m_axi_bresp    ( gpio_out_axilite_bresp        ), // input wire [1 : 0] m_axi_bresp
                .m_axi_bvalid   ( gpio_out_axilite_bvalid       ), // input wire m_axi_bvalid
                .m_axi_bready   ( gpio_out_axilite_bready       ), // output wire m_axi_bready
                .m_axi_araddr   ( gpio_out_axilite_araddr       ), // output wire [31 : 0] m_axi_araddr
                .m_axi_arprot   ( gpio_out_axilite_arprot       ), // output wire [2 : 0] m_axi_arprot
                .m_axi_arvalid  ( gpio_out_axilite_arvalid      ), // output wire m_axi_arvalid
                .m_axi_arready  ( gpio_out_axilite_arready      ), // input wire m_axi_arready
                .m_axi_rdata    ( gpio_out_axilite_rdata        ), // input wire [31 : 0] m_axi_rdata
                .m_axi_rresp    ( gpio_out_axilite_rresp        ), // input wire [1 : 0] m_axi_rresp
                .m_axi_rvalid   ( gpio_out_axilite_rvalid       ), // input wire m_axi_rvalid
                .m_axi_rready   ( gpio_out_axilite_rready       )  // output wire m_axi_rready
            );

            // GPIO instance
            xlnx_axi_gpio_out gpio_out_inst (
                .s_axi_aclk     ( soc_clk                       ), // input wire s_axi_aclk
                .s_axi_aresetn  ( sys_resetn                    ), // input wire s_axi_aresetn
                .s_axi_awaddr   ( gpio_out_axilite_awaddr [8:0] ), // input wire [8 : 0] s_axi_awaddr
                .s_axi_awvalid  ( gpio_out_axilite_awvalid      ), // input wire s_axi_awvalid
                .s_axi_awready  ( gpio_out_axilite_awready      ), // output wire s_axi_awready
                .s_axi_wdata    ( gpio_out_axilite_wdata        ), // input wire [31 : 0] s_axi_wdata
                .s_axi_wstrb    ( gpio_out_axilite_wstrb        ), // input wire [3 : 0] s_axi_wstrb
                .s_axi_wvalid   ( gpio_out_axilite_wvalid       ), // input wire s_axi_wvalid
                .s_axi_wready   ( gpio_out_axilite_wready       ), // output wire s_axi_wready
                .s_axi_bresp    ( gpio_out_axilite_bresp        ), // output wire [1 : 0] s_axi_bresp
                .s_axi_bvalid   ( gpio_out_axilite_bvalid       ), // output wire s_axi_bvalid
                .s_axi_bready   ( gpio_out_axilite_bready       ), // input wire s_axi_bready
                .s_axi_araddr   ( gpio_out_axilite_araddr [8:0] ), // input wire [8 : 0] s_axi_araddr
                .s_axi_arvalid  ( gpio_out_axilite_arvalid      ), // input wire s_axi_arvalid
                .s_axi_arready  ( gpio_out_axilite_arready      ), // output wire s_axi_arready
                .s_axi_rdata    ( gpio_out_axilite_rdata        ), // output wire [31 : 0] s_axi_rdata
                .s_axi_rresp    ( gpio_out_axilite_rresp        ), // output wire [1 : 0] s_axi_rresp
                .s_axi_rvalid   ( gpio_out_axilite_rvalid       ), // output wire s_axi_rvalid
                .s_axi_rready   ( gpio_out_axilite_rready       ), // input wire s_axi_rready
                .gpio_io_o      ( gpio_out_o [i]                )  // input wire [0 : 0] gpio_io_o
            );
        end

    endgenerate


endmodule : uninasoc

