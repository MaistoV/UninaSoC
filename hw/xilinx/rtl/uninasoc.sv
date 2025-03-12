// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Description: Basic version of UninaSoC that allows to work with axi transactions to and from slaves (ToBeUpdated)

// System architecture:
//                                                                                    ________
//                                                     __________                    |        |
//                                                    |          |                   |  Main  |
//                                                    |          |------------------>| Memory |
//                                                    |   Main   |                   |________|
//   ____________                                     |   Bus    |                    ______________
//  |            |                                    |          |                   |   (slave)    |
//  | sys_master |----------------------------------->|          |------------------>| Debug Module |
//  |____________|                                    |          |                   |______________|
//   ______________                                   |          |                    ________________
//  |   (master)   |                                  |          |                   |                |
//  | Debug Module |--------------------------------->|          |------------------>| Peripheral bus |---------|
//  |______________|                                  |          |                   |     (PBUS)     |         |
//                                                    |          |                   |________________|         | peripheral
//   _________              ____________              |          |                    ________________          | interrupts
//  |         |            |            |             |          |                   |                |         |
//  |   vio   |----------->| rvm_socket |------------>|          |------------------>|      PLIC      |<--------|
//  |_________|            |____________|             |          |                   |________________|
//                                ^                   |          |                            |
//                                |                   |__________|                            |
//                                |                                                           |
//                                |___________________________________________________________|
//                                                 platform interrupt

/////////////////////
// Import packages //
/////////////////////

import uninasoc_pkg::*;

////////////////////
// Import headers //
////////////////////

`include "uninasoc_axi.svh"

`ifdef HPC
    `include "uninasoc_pcie.svh"
    `include "uninasoc_ddr4.svh"
`endif

///////////////////////
// Module definition //
///////////////////////

module uninasoc (

    `ifdef EMBEDDED
        // Clock and reset
        input logic sys_clock_i,
        input logic sys_reset_i,

        // UART interface
        input  logic                        uart_rx_i,
        output logic                        uart_tx_o,

        // GPIOs
        input  logic [NUM_GPIO_IN  -1 : 0]  gpio_in_i,
        output logic [NUM_GPIO_OUT -1 : 0]  gpio_out_o
    `elsif HPC
        // DDR4 Channel 0 clock and reset
        input logic clk_300mhz_0_p_i,
        input logic clk_300mhz_0_n_i,

        // DDR4 Channel 0 interface
        `DEFINE_DDR4_PORTS(0),

        // PCIe clock and reset
        input logic pcie_refclk_p_i,
        input logic pcie_refclk_n_i,
        input logic pcie_resetn_i,

        // PCIe interface
        `DEFINE_PCIE_PORTS
    `endif

);

    /////////////////////
    // Local variables //
    /////////////////////

    localparam peripherals_interrupts_num = 4;

    ///////////////////
    // Local Signals //
    //////////////////

    // Reset negative
    logic sys_resetn;
    logic vio_debug_resetn;
    // clkwiz -> all
    logic soc_clk;

    // VIO Signals
    logic vio_resetn;

    // Socket interrupts
    logic [31:0] rvm_socket_interrupt_line;

    // Peripheral bus interrupts
    logic [peripherals_interrupts_num-1:0] pbus_int_line;

    /////////////////////////////////////////
    // Buses declaration and concatenation //
    /////////////////////////////////////////
    `include "mbus_buses.txt"

    ///////////////////////
    // Local assignments //
    ///////////////////////

    /////////////
    // Modules //
    /////////////

    // Virtual I/O

    xlnx_vio vio_inst (
      .clk        ( soc_clk         ),
      .probe_out0 ( vio_resetn      ),
      .probe_out1 (                 ),
      .probe_in0  ( sys_resetn      )
    );

    // Axi Crossbar
    xlnx_main_crossbar main_xbar_u (
        .aclk           ( soc_clk                   ), // input
        .aresetn        ( sys_resetn                ), // input
        .s_axi_awid     ( MBUS_masters_axi_awid     ), // input
        .s_axi_awaddr   ( MBUS_masters_axi_awaddr   ), // input
        .s_axi_awlen    ( MBUS_masters_axi_awlen    ), // input
        .s_axi_awsize   ( MBUS_masters_axi_awsize   ), // input
        .s_axi_awburst  ( MBUS_masters_axi_awburst  ), // input
        .s_axi_awlock   ( MBUS_masters_axi_awlock   ), // input
        .s_axi_awcache  ( MBUS_masters_axi_awcache  ), // input
        .s_axi_awprot   ( MBUS_masters_axi_awprot   ), // input
        .s_axi_awqos    ( MBUS_masters_axi_awqos    ), // input
        .s_axi_awvalid  ( MBUS_masters_axi_awvalid  ), // input
        .s_axi_awready  ( MBUS_masters_axi_awready  ), // output
        .s_axi_wdata    ( MBUS_masters_axi_wdata    ), // input
        .s_axi_wstrb    ( MBUS_masters_axi_wstrb    ), // input
        .s_axi_wlast    ( MBUS_masters_axi_wlast    ), // input
        .s_axi_wvalid   ( MBUS_masters_axi_wvalid   ), // input
        .s_axi_wready   ( MBUS_masters_axi_wready   ), // output
        .s_axi_bid      ( MBUS_masters_axi_bid      ), // output
        .s_axi_bresp    ( MBUS_masters_axi_bresp    ), // output
        .s_axi_bvalid   ( MBUS_masters_axi_bvalid   ), // output
        .s_axi_bready   ( MBUS_masters_axi_bready   ), // input
        .s_axi_arid     ( MBUS_masters_axi_arid     ), // output
        .s_axi_araddr   ( MBUS_masters_axi_araddr   ), // input
        .s_axi_arlen    ( MBUS_masters_axi_arlen    ), // input
        .s_axi_arsize   ( MBUS_masters_axi_arsize   ), // input
        .s_axi_arburst  ( MBUS_masters_axi_arburst  ), // input
        .s_axi_arlock   ( MBUS_masters_axi_arlock   ), // input
        .s_axi_arcache  ( MBUS_masters_axi_arcache  ), // input
        .s_axi_arprot   ( MBUS_masters_axi_arprot   ), // input
        .s_axi_arqos    ( MBUS_masters_axi_arqos    ), // input
        .s_axi_arvalid  ( MBUS_masters_axi_arvalid  ), // input
        .s_axi_arready  ( MBUS_masters_axi_arready  ), // output
        .s_axi_rid      ( MBUS_masters_axi_rid      ), // output
        .s_axi_rdata    ( MBUS_masters_axi_rdata    ), // output
        .s_axi_rresp    ( MBUS_masters_axi_rresp    ), // output
        .s_axi_rlast    ( MBUS_masters_axi_rlast    ), // output
        .s_axi_rvalid   ( MBUS_masters_axi_rvalid   ), // output
        .s_axi_rready   ( MBUS_masters_axi_rready   ), // input
        .m_axi_awid     ( MBUS_slaves_axi_awid      ), // output
        .m_axi_awaddr   ( MBUS_slaves_axi_awaddr    ), // output
        .m_axi_awlen    ( MBUS_slaves_axi_awlen     ), // output
        .m_axi_awsize   ( MBUS_slaves_axi_awsize    ), // output
        .m_axi_awburst  ( MBUS_slaves_axi_awburst   ), // output
        .m_axi_awlock   ( MBUS_slaves_axi_awlock    ), // output
        .m_axi_awcache  ( MBUS_slaves_axi_awcache   ), // output
        .m_axi_awprot   ( MBUS_slaves_axi_awprot    ), // output
        .m_axi_awregion ( MBUS_slaves_axi_awregion  ), // output
        .m_axi_awqos    ( MBUS_slaves_axi_awqos     ), // output
        .m_axi_awvalid  ( MBUS_slaves_axi_awvalid   ), // output
        .m_axi_awready  ( MBUS_slaves_axi_awready   ), // input
        .m_axi_wdata    ( MBUS_slaves_axi_wdata     ), // output
        .m_axi_wstrb    ( MBUS_slaves_axi_wstrb     ), // output
        .m_axi_wlast    ( MBUS_slaves_axi_wlast     ), // output
        .m_axi_wvalid   ( MBUS_slaves_axi_wvalid    ), // output
        .m_axi_wready   ( MBUS_slaves_axi_wready    ), // input
        .m_axi_bid      ( MBUS_slaves_axi_bid       ), // input
        .m_axi_bresp    ( MBUS_slaves_axi_bresp     ), // input
        .m_axi_bvalid   ( MBUS_slaves_axi_bvalid    ), // input
        .m_axi_bready   ( MBUS_slaves_axi_bready    ), // output
        .m_axi_arid     ( MBUS_slaves_axi_arid      ), // output
        .m_axi_araddr   ( MBUS_slaves_axi_araddr    ), // output
        .m_axi_arlen    ( MBUS_slaves_axi_arlen     ), // output
        .m_axi_arsize   ( MBUS_slaves_axi_arsize    ), // output
        .m_axi_arburst  ( MBUS_slaves_axi_arburst   ), // output
        .m_axi_arlock   ( MBUS_slaves_axi_arlock    ), // output
        .m_axi_arcache  ( MBUS_slaves_axi_arcache   ), // output
        .m_axi_arprot   ( MBUS_slaves_axi_arprot    ), // output
        .m_axi_arregion ( MBUS_slaves_axi_arregion  ), // output
        .m_axi_arqos    ( MBUS_slaves_axi_arqos     ), // output
        .m_axi_arvalid  ( MBUS_slaves_axi_arvalid   ), // output
        .m_axi_arready  ( MBUS_slaves_axi_arready   ), // input
        .m_axi_rid      ( MBUS_slaves_axi_rid       ), // input
        .m_axi_rdata    ( MBUS_slaves_axi_rdata     ), // input
        .m_axi_rresp    ( MBUS_slaves_axi_rresp     ), // input
        .m_axi_rlast    ( MBUS_slaves_axi_rlast     ), // input
        .m_axi_rvalid   ( MBUS_slaves_axi_rvalid    ), // input
        .m_axi_rready   ( MBUS_slaves_axi_rready    )  // output
    );

    /////////////////
    // AXI masters //
    /////////////////

    sys_master sys_master_u (

        // EMBEDDED ONLY
        .sys_clock_i(sys_clock_i),
        .sys_reset_i(sys_reset_i),

        // HPC ONLY
        .pcie_refclk_p_i(pcie_refclk_p_i),
        .pcie_refclk_n_i(pcie_refclk_n_i),
        .pcie_resetn_i(pcie_resetn_i),
        // PCI interface
        .pci_exp_rxn_i(pci_exp_rxn_i),
        .pci_exp_rxp_i(pci_exp_rxp_i),
        .pci_exp_txn_o(pci_exp_txn_o),
        .pci_exp_txp_o(pci_exp_txp_o),

        // Output clock
        .soc_clk_o(soc_clk),
        .sys_resetn_o(sys_resetn),

        // AXI Master
        .m_axi_awid     ( SYS_MASTER_to_MBUS_axi_awid     ),
        .m_axi_awaddr   ( SYS_MASTER_to_MBUS_axi_awaddr   ),
        .m_axi_awlen    ( SYS_MASTER_to_MBUS_axi_awlen    ),
        .m_axi_awsize   ( SYS_MASTER_to_MBUS_axi_awsize   ),
        .m_axi_awburst  ( SYS_MASTER_to_MBUS_axi_awburst  ),
        .m_axi_awlock   ( SYS_MASTER_to_MBUS_axi_awlock   ),
        .m_axi_awcache  ( SYS_MASTER_to_MBUS_axi_awcache  ),
        .m_axi_awprot   ( SYS_MASTER_to_MBUS_axi_awprot   ),
        .m_axi_awqos    ( SYS_MASTER_to_MBUS_axi_awqos    ),
        .m_axi_awvalid  ( SYS_MASTER_to_MBUS_axi_awvalid  ),
        .m_axi_awready  ( SYS_MASTER_to_MBUS_axi_awready  ),
        .m_axi_awregion ( SYS_MASTER_to_MBUS_axi_awregion ),
        .m_axi_wdata    ( SYS_MASTER_to_MBUS_axi_wdata    ),
        .m_axi_wstrb    ( SYS_MASTER_to_MBUS_axi_wstrb    ),
        .m_axi_wlast    ( SYS_MASTER_to_MBUS_axi_wlast    ),
        .m_axi_wvalid   ( SYS_MASTER_to_MBUS_axi_wvalid   ),
        .m_axi_wready   ( SYS_MASTER_to_MBUS_axi_wready   ),
        .m_axi_bid      ( SYS_MASTER_to_MBUS_axi_bid      ),
        .m_axi_bresp    ( SYS_MASTER_to_MBUS_axi_bresp    ),
        .m_axi_bvalid   ( SYS_MASTER_to_MBUS_axi_bvalid   ),
        .m_axi_bready   ( SYS_MASTER_to_MBUS_axi_bready   ),
        .m_axi_arid     ( SYS_MASTER_to_MBUS_axi_arid     ),
        .m_axi_araddr   ( SYS_MASTER_to_MBUS_axi_araddr   ),
        .m_axi_arlen    ( SYS_MASTER_to_MBUS_axi_arlen    ),
        .m_axi_arsize   ( SYS_MASTER_to_MBUS_axi_arsize   ),
        .m_axi_arburst  ( SYS_MASTER_to_MBUS_axi_arburst  ),
        .m_axi_arlock   ( SYS_MASTER_to_MBUS_axi_arlock   ),
        .m_axi_arcache  ( SYS_MASTER_to_MBUS_axi_arcache  ),
        .m_axi_arprot   ( SYS_MASTER_to_MBUS_axi_arprot   ),
        .m_axi_arqos    ( SYS_MASTER_to_MBUS_axi_arqos    ),
        .m_axi_arvalid  ( SYS_MASTER_to_MBUS_axi_arvalid  ),
        .m_axi_arready  ( SYS_MASTER_to_MBUS_axi_arready  ),
        .m_axi_arregion ( SYS_MASTER_to_MBUS_axi_arregion ),
        .m_axi_rid      ( SYS_MASTER_to_MBUS_axi_rid      ),
        .m_axi_rdata    ( SYS_MASTER_to_MBUS_axi_rdata    ),
        .m_axi_rresp    ( SYS_MASTER_to_MBUS_axi_rresp    ),
        .m_axi_rlast    ( SYS_MASTER_to_MBUS_axi_rlast    ),
        .m_axi_rvalid   ( SYS_MASTER_to_MBUS_axi_rvalid   ),
        .m_axi_rready   ( SYS_MASTER_to_MBUS_axi_rready   )
    );

    // RVM Socket
    rvm_socket # (
        .DATA_WIDTH    ( AXI_DATA_WIDTH ),
        .ADDR_WIDTH    ( AXI_ADDR_WIDTH ),
        .CORE_SELECTOR ( CORE_SELECTOR  )
    ) rvm_socket_u (
        .clk_i          ( soc_clk    ),
        .rst_ni         ( sys_resetn ),
        .core_resetn_i  ( vio_resetn ),
        .bootaddr_i     ( '0         ),
        .irq_i          ( rvm_socket_interrupt_line ),

        // Instruction AXI Port
        .rvm_socket_instr_axi_awid      ( RVM_SOCKET_INSTR_to_MBUS_axi_awid     ),
        .rvm_socket_instr_axi_awaddr    ( RVM_SOCKET_INSTR_to_MBUS_axi_awaddr   ),
        .rvm_socket_instr_axi_awlen     ( RVM_SOCKET_INSTR_to_MBUS_axi_awlen    ),
        .rvm_socket_instr_axi_awsize    ( RVM_SOCKET_INSTR_to_MBUS_axi_awsize   ),
        .rvm_socket_instr_axi_awburst   ( RVM_SOCKET_INSTR_to_MBUS_axi_awburst  ),
        .rvm_socket_instr_axi_awlock    ( RVM_SOCKET_INSTR_to_MBUS_axi_awlock   ),
        .rvm_socket_instr_axi_awcache   ( RVM_SOCKET_INSTR_to_MBUS_axi_awcache  ),
        .rvm_socket_instr_axi_awprot    ( RVM_SOCKET_INSTR_to_MBUS_axi_awprot   ),
        .rvm_socket_instr_axi_awqos     ( RVM_SOCKET_INSTR_to_MBUS_axi_awqos    ),
        .rvm_socket_instr_axi_awvalid   ( RVM_SOCKET_INSTR_to_MBUS_axi_awvalid  ),
        .rvm_socket_instr_axi_awready   ( RVM_SOCKET_INSTR_to_MBUS_axi_awready  ),
        .rvm_socket_instr_axi_awregion  ( RVM_SOCKET_INSTR_to_MBUS_axi_awregion ),
        .rvm_socket_instr_axi_wdata     ( RVM_SOCKET_INSTR_to_MBUS_axi_wdata    ),
        .rvm_socket_instr_axi_wstrb     ( RVM_SOCKET_INSTR_to_MBUS_axi_wstrb    ),
        .rvm_socket_instr_axi_wlast     ( RVM_SOCKET_INSTR_to_MBUS_axi_wlast    ),
        .rvm_socket_instr_axi_wvalid    ( RVM_SOCKET_INSTR_to_MBUS_axi_wvalid   ),
        .rvm_socket_instr_axi_wready    ( RVM_SOCKET_INSTR_to_MBUS_axi_wready   ),
        .rvm_socket_instr_axi_bid       ( RVM_SOCKET_INSTR_to_MBUS_axi_bid      ),
        .rvm_socket_instr_axi_bresp     ( RVM_SOCKET_INSTR_to_MBUS_axi_bresp    ),
        .rvm_socket_instr_axi_bvalid    ( RVM_SOCKET_INSTR_to_MBUS_axi_bvalid   ),
        .rvm_socket_instr_axi_bready    ( RVM_SOCKET_INSTR_to_MBUS_axi_bready   ),
        .rvm_socket_instr_axi_arid      ( RVM_SOCKET_INSTR_to_MBUS_axi_arid     ),
        .rvm_socket_instr_axi_araddr    ( RVM_SOCKET_INSTR_to_MBUS_axi_araddr   ),
        .rvm_socket_instr_axi_arlen     ( RVM_SOCKET_INSTR_to_MBUS_axi_arlen    ),
        .rvm_socket_instr_axi_arsize    ( RVM_SOCKET_INSTR_to_MBUS_axi_arsize   ),
        .rvm_socket_instr_axi_arburst   ( RVM_SOCKET_INSTR_to_MBUS_axi_arburst  ),
        .rvm_socket_instr_axi_arlock    ( RVM_SOCKET_INSTR_to_MBUS_axi_arlock   ),
        .rvm_socket_instr_axi_arcache   ( RVM_SOCKET_INSTR_to_MBUS_axi_arcache  ),
        .rvm_socket_instr_axi_arprot    ( RVM_SOCKET_INSTR_to_MBUS_axi_arprot   ),
        .rvm_socket_instr_axi_arqos     ( RVM_SOCKET_INSTR_to_MBUS_axi_arqos    ),
        .rvm_socket_instr_axi_arvalid   ( RVM_SOCKET_INSTR_to_MBUS_axi_arvalid  ),
        .rvm_socket_instr_axi_arready   ( RVM_SOCKET_INSTR_to_MBUS_axi_arready  ),
        .rvm_socket_instr_axi_arregion  ( RVM_SOCKET_INSTR_to_MBUS_axi_arregion ),
        .rvm_socket_instr_axi_rid       ( RVM_SOCKET_INSTR_to_MBUS_axi_rid      ),
        .rvm_socket_instr_axi_rdata     ( RVM_SOCKET_INSTR_to_MBUS_axi_rdata    ),
        .rvm_socket_instr_axi_rresp     ( RVM_SOCKET_INSTR_to_MBUS_axi_rresp    ),
        .rvm_socket_instr_axi_rlast     ( RVM_SOCKET_INSTR_to_MBUS_axi_rlast    ),
        .rvm_socket_instr_axi_rvalid    ( RVM_SOCKET_INSTR_to_MBUS_axi_rvalid   ),
        .rvm_socket_instr_axi_rready    ( RVM_SOCKET_INSTR_to_MBUS_axi_rready   ),

        // Data AXI Port
        .rvm_socket_data_axi_awid      ( RVM_SOCKET_DATA_to_MBUS_axi_awid     ),
        .rvm_socket_data_axi_awaddr    ( RVM_SOCKET_DATA_to_MBUS_axi_awaddr   ),
        .rvm_socket_data_axi_awlen     ( RVM_SOCKET_DATA_to_MBUS_axi_awlen    ),
        .rvm_socket_data_axi_awsize    ( RVM_SOCKET_DATA_to_MBUS_axi_awsize   ),
        .rvm_socket_data_axi_awburst   ( RVM_SOCKET_DATA_to_MBUS_axi_awburst  ),
        .rvm_socket_data_axi_awlock    ( RVM_SOCKET_DATA_to_MBUS_axi_awlock   ),
        .rvm_socket_data_axi_awcache   ( RVM_SOCKET_DATA_to_MBUS_axi_awcache  ),
        .rvm_socket_data_axi_awprot    ( RVM_SOCKET_DATA_to_MBUS_axi_awprot   ),
        .rvm_socket_data_axi_awqos     ( RVM_SOCKET_DATA_to_MBUS_axi_awqos    ),
        .rvm_socket_data_axi_awvalid   ( RVM_SOCKET_DATA_to_MBUS_axi_awvalid  ),
        .rvm_socket_data_axi_awready   ( RVM_SOCKET_DATA_to_MBUS_axi_awready  ),
        .rvm_socket_data_axi_awregion  ( RVM_SOCKET_DATA_to_MBUS_axi_awregion ),
        .rvm_socket_data_axi_wdata     ( RVM_SOCKET_DATA_to_MBUS_axi_wdata    ),
        .rvm_socket_data_axi_wstrb     ( RVM_SOCKET_DATA_to_MBUS_axi_wstrb    ),
        .rvm_socket_data_axi_wlast     ( RVM_SOCKET_DATA_to_MBUS_axi_wlast    ),
        .rvm_socket_data_axi_wvalid    ( RVM_SOCKET_DATA_to_MBUS_axi_wvalid   ),
        .rvm_socket_data_axi_wready    ( RVM_SOCKET_DATA_to_MBUS_axi_wready   ),
        .rvm_socket_data_axi_bid       ( RVM_SOCKET_DATA_to_MBUS_axi_bid      ),
        .rvm_socket_data_axi_bresp     ( RVM_SOCKET_DATA_to_MBUS_axi_bresp    ),
        .rvm_socket_data_axi_bvalid    ( RVM_SOCKET_DATA_to_MBUS_axi_bvalid   ),
        .rvm_socket_data_axi_bready    ( RVM_SOCKET_DATA_to_MBUS_axi_bready   ),
        .rvm_socket_data_axi_arid      ( RVM_SOCKET_DATA_to_MBUS_axi_arid     ),
        .rvm_socket_data_axi_araddr    ( RVM_SOCKET_DATA_to_MBUS_axi_araddr   ),
        .rvm_socket_data_axi_arlen     ( RVM_SOCKET_DATA_to_MBUS_axi_arlen    ),
        .rvm_socket_data_axi_arsize    ( RVM_SOCKET_DATA_to_MBUS_axi_arsize   ),
        .rvm_socket_data_axi_arburst   ( RVM_SOCKET_DATA_to_MBUS_axi_arburst  ),
        .rvm_socket_data_axi_arlock    ( RVM_SOCKET_DATA_to_MBUS_axi_arlock   ),
        .rvm_socket_data_axi_arcache   ( RVM_SOCKET_DATA_to_MBUS_axi_arcache  ),
        .rvm_socket_data_axi_arprot    ( RVM_SOCKET_DATA_to_MBUS_axi_arprot   ),
        .rvm_socket_data_axi_arqos     ( RVM_SOCKET_DATA_to_MBUS_axi_arqos    ),
        .rvm_socket_data_axi_arvalid   ( RVM_SOCKET_DATA_to_MBUS_axi_arvalid  ),
        .rvm_socket_data_axi_arready   ( RVM_SOCKET_DATA_to_MBUS_axi_arready  ),
        .rvm_socket_data_axi_arregion  ( RVM_SOCKET_DATA_to_MBUS_axi_arregion ),
        .rvm_socket_data_axi_rid       ( RVM_SOCKET_DATA_to_MBUS_axi_rid      ),
        .rvm_socket_data_axi_rdata     ( RVM_SOCKET_DATA_to_MBUS_axi_rdata    ),
        .rvm_socket_data_axi_rresp     ( RVM_SOCKET_DATA_to_MBUS_axi_rresp    ),
        .rvm_socket_data_axi_rlast     ( RVM_SOCKET_DATA_to_MBUS_axi_rlast    ),
        .rvm_socket_data_axi_rvalid    ( RVM_SOCKET_DATA_to_MBUS_axi_rvalid   ),
        .rvm_socket_data_axi_rready    ( RVM_SOCKET_DATA_to_MBUS_axi_rready   ),

        // Debug AXI master
        .dbg_master_axi_awid       ( DBG_MASTER_to_MBUS_axi_awid     ),
        .dbg_master_axi_awaddr     ( DBG_MASTER_to_MBUS_axi_awaddr   ),
        .dbg_master_axi_awlen      ( DBG_MASTER_to_MBUS_axi_awlen    ),
        .dbg_master_axi_awsize     ( DBG_MASTER_to_MBUS_axi_awsize   ),
        .dbg_master_axi_awburst    ( DBG_MASTER_to_MBUS_axi_awburst  ),
        .dbg_master_axi_awlock     ( DBG_MASTER_to_MBUS_axi_awlock   ),
        .dbg_master_axi_awcache    ( DBG_MASTER_to_MBUS_axi_awcache  ),
        .dbg_master_axi_awprot     ( DBG_MASTER_to_MBUS_axi_awprot   ),
        .dbg_master_axi_awqos      ( DBG_MASTER_to_MBUS_axi_awqos    ),
        .dbg_master_axi_awvalid    ( DBG_MASTER_to_MBUS_axi_awvalid  ),
        .dbg_master_axi_awready    ( DBG_MASTER_to_MBUS_axi_awready  ),
        .dbg_master_axi_awregion   ( DBG_MASTER_to_MBUS_axi_awregion ),
        .dbg_master_axi_wdata      ( DBG_MASTER_to_MBUS_axi_wdata    ),
        .dbg_master_axi_wstrb      ( DBG_MASTER_to_MBUS_axi_wstrb    ),
        .dbg_master_axi_wlast      ( DBG_MASTER_to_MBUS_axi_wlast    ),
        .dbg_master_axi_wvalid     ( DBG_MASTER_to_MBUS_axi_wvalid   ),
        .dbg_master_axi_wready     ( DBG_MASTER_to_MBUS_axi_wready   ),
        .dbg_master_axi_bid        ( DBG_MASTER_to_MBUS_axi_bid      ),
        .dbg_master_axi_bresp      ( DBG_MASTER_to_MBUS_axi_bresp    ),
        .dbg_master_axi_bvalid     ( DBG_MASTER_to_MBUS_axi_bvalid   ),
        .dbg_master_axi_bready     ( DBG_MASTER_to_MBUS_axi_bready   ),
        .dbg_master_axi_arid       ( DBG_MASTER_to_MBUS_axi_arid     ),
        .dbg_master_axi_araddr     ( DBG_MASTER_to_MBUS_axi_araddr   ),
        .dbg_master_axi_arlen      ( DBG_MASTER_to_MBUS_axi_arlen    ),
        .dbg_master_axi_arsize     ( DBG_MASTER_to_MBUS_axi_arsize   ),
        .dbg_master_axi_arburst    ( DBG_MASTER_to_MBUS_axi_arburst  ),
        .dbg_master_axi_arlock     ( DBG_MASTER_to_MBUS_axi_arlock   ),
        .dbg_master_axi_arcache    ( DBG_MASTER_to_MBUS_axi_arcache  ),
        .dbg_master_axi_arprot     ( DBG_MASTER_to_MBUS_axi_arprot   ),
        .dbg_master_axi_arqos      ( DBG_MASTER_to_MBUS_axi_arqos    ),
        .dbg_master_axi_arvalid    ( DBG_MASTER_to_MBUS_axi_arvalid  ),
        .dbg_master_axi_arready    ( DBG_MASTER_to_MBUS_axi_arready  ),
        .dbg_master_axi_arregion   ( DBG_MASTER_to_MBUS_axi_arregion ),
        .dbg_master_axi_rid        ( DBG_MASTER_to_MBUS_axi_rid      ),
        .dbg_master_axi_rdata      ( DBG_MASTER_to_MBUS_axi_rdata    ),
        .dbg_master_axi_rresp      ( DBG_MASTER_to_MBUS_axi_rresp    ),
        .dbg_master_axi_rlast      ( DBG_MASTER_to_MBUS_axi_rlast    ),
        .dbg_master_axi_rvalid     ( DBG_MASTER_to_MBUS_axi_rvalid   ),
        .dbg_master_axi_rready     ( DBG_MASTER_to_MBUS_axi_rready   ),

        // Debug AXI slave
        .dbg_slave_axi_awid        ( MBUS_to_DM_mem_axi_awid     ),
        .dbg_slave_axi_awaddr      ( MBUS_to_DM_mem_axi_awaddr   ),
        .dbg_slave_axi_awlen       ( MBUS_to_DM_mem_axi_awlen    ),
        .dbg_slave_axi_awsize      ( MBUS_to_DM_mem_axi_awsize   ),
        .dbg_slave_axi_awburst     ( MBUS_to_DM_mem_axi_awburst  ),
        .dbg_slave_axi_awlock      ( MBUS_to_DM_mem_axi_awlock   ),
        .dbg_slave_axi_awcache     ( MBUS_to_DM_mem_axi_awcache  ),
        .dbg_slave_axi_awprot      ( MBUS_to_DM_mem_axi_awprot   ),
        .dbg_slave_axi_awqos       ( MBUS_to_DM_mem_axi_awqos    ),
        .dbg_slave_axi_awvalid     ( MBUS_to_DM_mem_axi_awvalid  ),
        .dbg_slave_axi_awready     ( MBUS_to_DM_mem_axi_awready  ),
        .dbg_slave_axi_awregion    ( MBUS_to_DM_mem_axi_awregion ),
        .dbg_slave_axi_wdata       ( MBUS_to_DM_mem_axi_wdata    ),
        .dbg_slave_axi_wstrb       ( MBUS_to_DM_mem_axi_wstrb    ),
        .dbg_slave_axi_wlast       ( MBUS_to_DM_mem_axi_wlast    ),
        .dbg_slave_axi_wvalid      ( MBUS_to_DM_mem_axi_wvalid   ),
        .dbg_slave_axi_wready      ( MBUS_to_DM_mem_axi_wready   ),
        .dbg_slave_axi_bid         ( MBUS_to_DM_mem_axi_bid      ),
        .dbg_slave_axi_bresp       ( MBUS_to_DM_mem_axi_bresp    ),
        .dbg_slave_axi_bvalid      ( MBUS_to_DM_mem_axi_bvalid   ),
        .dbg_slave_axi_bready      ( MBUS_to_DM_mem_axi_bready   ),
        .dbg_slave_axi_arid        ( MBUS_to_DM_mem_axi_arid     ),
        .dbg_slave_axi_araddr      ( MBUS_to_DM_mem_axi_araddr   ),
        .dbg_slave_axi_arlen       ( MBUS_to_DM_mem_axi_arlen    ),
        .dbg_slave_axi_arsize      ( MBUS_to_DM_mem_axi_arsize   ),
        .dbg_slave_axi_arburst     ( MBUS_to_DM_mem_axi_arburst  ),
        .dbg_slave_axi_arlock      ( MBUS_to_DM_mem_axi_arlock   ),
        .dbg_slave_axi_arcache     ( MBUS_to_DM_mem_axi_arcache  ),
        .dbg_slave_axi_arprot      ( MBUS_to_DM_mem_axi_arprot   ),
        .dbg_slave_axi_arqos       ( MBUS_to_DM_mem_axi_arqos    ),
        .dbg_slave_axi_arvalid     ( MBUS_to_DM_mem_axi_arvalid  ),
        .dbg_slave_axi_arready     ( MBUS_to_DM_mem_axi_arready  ),
        .dbg_slave_axi_arregion    ( MBUS_to_DM_mem_axi_arregion ),
        .dbg_slave_axi_rid         ( MBUS_to_DM_mem_axi_rid      ),
        .dbg_slave_axi_rdata       ( MBUS_to_DM_mem_axi_rdata    ),
        .dbg_slave_axi_rresp       ( MBUS_to_DM_mem_axi_rresp    ),
        .dbg_slave_axi_rlast       ( MBUS_to_DM_mem_axi_rlast    ),
        .dbg_slave_axi_rvalid      ( MBUS_to_DM_mem_axi_rvalid   ),
        .dbg_slave_axi_rready      ( MBUS_to_DM_mem_axi_rready   )
    );

    ////////////////
    // AXI slaves //
    ////////////////

    // Main memory
    xlnx_blk_mem_gen main_memory_u (
        .rsta_busy      ( /* open */                ), // output wire rsta_busy
        .rstb_busy      ( /* open */                ), // output wire rstb_busy
        .s_aclk         ( soc_clk                   ), // input wire s_aclk
        .s_aresetn      ( sys_resetn                ), // input wire s_aresetn
        .s_axi_awid     ( MBUS_to_BRAM_axi_awid     ), // input wire [3 : 0] s_axi_awid
        .s_axi_awaddr   ( MBUS_to_BRAM_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( MBUS_to_BRAM_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( MBUS_to_BRAM_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( MBUS_to_BRAM_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid  ( MBUS_to_BRAM_axi_awvalid  ), // input wire s_axi_awvalid
        .s_axi_awready  ( MBUS_to_BRAM_axi_awready  ), // output wire s_axi_awready
        .s_axi_wdata    ( MBUS_to_BRAM_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( MBUS_to_BRAM_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( MBUS_to_BRAM_axi_wlast    ), // input wire s_axi_wlast
        .s_axi_wvalid   ( MBUS_to_BRAM_axi_wvalid   ), // input wire s_axi_wvalid
        .s_axi_wready   ( MBUS_to_BRAM_axi_wready   ), // output wire s_axi_wready
        .s_axi_bid      ( MBUS_to_BRAM_axi_bid      ), // output wire [3 : 0] s_axi_bid
        .s_axi_bresp    ( MBUS_to_BRAM_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( MBUS_to_BRAM_axi_bvalid   ), // output wire s_axi_bvalid
        .s_axi_bready   ( MBUS_to_BRAM_axi_bready   ), // input wire s_axi_bready
        .s_axi_arid     ( MBUS_to_BRAM_axi_arid     ), // input wire [3 : 0] s_axi_arid
        .s_axi_araddr   ( MBUS_to_BRAM_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( MBUS_to_BRAM_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( MBUS_to_BRAM_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( MBUS_to_BRAM_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid  ( MBUS_to_BRAM_axi_arvalid  ), // input wire s_axi_arvalid
        .s_axi_arready  ( MBUS_to_BRAM_axi_arready  ), // output wire s_axi_arready
        .s_axi_rid      ( MBUS_to_BRAM_axi_rid      ), // output wire [3 : 0] s_axi_rid
        .s_axi_rdata    ( MBUS_to_BRAM_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( MBUS_to_BRAM_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( MBUS_to_BRAM_axi_rlast    ), // output wire s_axi_rlast
        .s_axi_rvalid   ( MBUS_to_BRAM_axi_rvalid   ), // output wire s_axi_rvalid
        .s_axi_rready   ( MBUS_to_BRAM_axi_rready   )  // input wire s_axi_rready
    );


    // Platform-Level Interrupt Controller (PLIC)
    logic [31:0] plic_int_line;
    logic plic_int_irq_o;

    // Line 11 corresponds to EXT interrupt in RISC-V specification
    assign rvm_socket_interrupt_line = {21'h0, plic_int_irq_o, 10'h0};

    // Currently, this is the interrupt line mapping (from PLIC perspective/registers)
    // 0 - RESERVED
    // 1 - GPIO_IN Interrupt (From PBUS) (Embedded Only)
    // 2 - Timer 0 Interrupt (From PBUS)
    // 3 - Timer 1 Interrupt (From PBUS)
    // 4 - UART Interrupt    (From PBUS) (HPC implementation does not support this yet)
    // others - reserved

    assign plic_int_line = {'0, pbus_int_line, 1'b0};

    custom_rv_plic custom_rv_plic_u (
        .clk_i          ( soc_clk                       ), // input wire s_axi_aclk
        .rst_ni         ( sys_resetn                    ), // input wire s_axi_aresetn
        // AXI4 slave port (from xbar)
        .intr_src_i     ( plic_int_line                 ), // Input interrupt lines (Sources)
        .irq_o          ( plic_int_irq_o                ), // Output Interrupts (Targets -> Socket)
        .irq_id_o       (                               ), // Unused (non standard signal)
        .msip_o         (                               ), // Unused (non standard signal)
        .s_axi_awid     ( MBUS_to_PLIC_axi_awid         ), // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr   ( MBUS_to_PLIC_axi_awaddr       ), // input wire [25 : 0] s_axi_awaddr
        .s_axi_awlen    ( MBUS_to_PLIC_axi_awlen        ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( MBUS_to_PLIC_axi_awsize       ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( MBUS_to_PLIC_axi_awburst      ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( MBUS_to_PLIC_axi_awlock       ), // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( MBUS_to_PLIC_axi_awcache      ), // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( MBUS_to_PLIC_axi_awprot       ), // input wire [2 : 0] s_axi_awprot
        .s_axi_awregion ( MBUS_to_PLIC_axi_awregion     ), // input wire [3 : 0] s_axi_awregion
        .s_axi_awqos    ( MBUS_to_PLIC_axi_awqos        ), // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( MBUS_to_PLIC_axi_awvalid      ), // input wire s_axi_awvalid
        .s_axi_awready  ( MBUS_to_PLIC_axi_awready      ), // output wire s_axi_awready
        .s_axi_wdata    ( MBUS_to_PLIC_axi_wdata        ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( MBUS_to_PLIC_axi_wstrb        ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( MBUS_to_PLIC_axi_wlast        ), // input wire s_axi_wlast
        .s_axi_wvalid   ( MBUS_to_PLIC_axi_wvalid       ), // input wire s_axi_wvalid
        .s_axi_wready   ( MBUS_to_PLIC_axi_wready       ), // output wire s_axi_wready
        .s_axi_bid      ( MBUS_to_PLIC_axi_bid          ), // output wire [1 : 0] s_axi_bid
        .s_axi_bresp    ( MBUS_to_PLIC_axi_bresp        ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( MBUS_to_PLIC_axi_bvalid       ), // output wire s_axi_bvalid
        .s_axi_bready   ( MBUS_to_PLIC_axi_bready       ), // input wire s_axi_bready
        .s_axi_arid     ( MBUS_to_PLIC_axi_arid         ), // input wire [1 : 0] s_axi_arid
        .s_axi_araddr   ( MBUS_to_PLIC_axi_araddr       ), // input wire [25 : 0] s_axi_araddr
        .s_axi_arlen    ( MBUS_to_PLIC_axi_arlen        ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( MBUS_to_PLIC_axi_arsize       ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( MBUS_to_PLIC_axi_arburst      ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( MBUS_to_PLIC_axi_arlock       ), // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( MBUS_to_PLIC_axi_arcache      ), // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( MBUS_to_PLIC_axi_arprot       ), // input wire [2 : 0] s_axi_arprot
        .s_axi_arregion ( MBUS_to_PLIC_axi_arregion     ), // input wire [3 : 0] s_axi_arregion
        .s_axi_arqos    ( MBUS_to_PLIC_axi_arqos        ), // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( MBUS_to_PLIC_axi_arvalid      ), // input wire s_axi_arvalid
        .s_axi_arready  ( MBUS_to_PLIC_axi_arready      ), // output wire s_axi_arready
        .s_axi_rid      ( MBUS_to_PLIC_axi_rid          ), // output wire [1 : 0] s_axi_rid
        .s_axi_rdata    ( MBUS_to_PLIC_axi_rdata        ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( MBUS_to_PLIC_axi_rresp        ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( MBUS_to_PLIC_axi_rlast        ), // output wire s_axi_rlast
        .s_axi_rvalid   ( MBUS_to_PLIC_axi_rvalid       ), // output wire s_axi_rvalid
        .s_axi_rready   ( MBUS_to_PLIC_axi_rready       )
    );

    ////////////////////
    // PERIPHERAL BUS //
    ////////////////////

    peripheral_bus peripheral_bus_u (

        .clock_i        ( soc_clk     ),
        .reset_ni       ( sys_resetn  ),

        // EMBEDDED ONLY
        .uart_rx_i      ( uart_rx_i      ),
        .uart_tx_o      ( uart_tx_o      ),
        .gpio_out_o     ( gpio_out_o     ),
        .gpio_in_i      ( gpio_in_i      ),

        .int_o          ( pbus_int_line  ),

        .s_axi_awid     ( MBUS_to_PBUS_axi_awid     ),
        .s_axi_awaddr   ( MBUS_to_PBUS_axi_awaddr   ),
        .s_axi_awlen    ( MBUS_to_PBUS_axi_awlen    ),
        .s_axi_awsize   ( MBUS_to_PBUS_axi_awsize   ),
        .s_axi_awburst  ( MBUS_to_PBUS_axi_awburst  ),
        .s_axi_awlock   ( MBUS_to_PBUS_axi_awlock   ),
        .s_axi_awcache  ( MBUS_to_PBUS_axi_awcache  ),
        .s_axi_awprot   ( MBUS_to_PBUS_axi_awprot   ),
        .s_axi_awregion ( MBUS_to_PBUS_axi_awregion ),
        .s_axi_awqos    ( MBUS_to_PBUS_axi_awqos    ),
        .s_axi_awvalid  ( MBUS_to_PBUS_axi_awvalid  ),
        .s_axi_awready  ( MBUS_to_PBUS_axi_awready  ),
        .s_axi_wdata    ( MBUS_to_PBUS_axi_wdata    ),
        .s_axi_wstrb    ( MBUS_to_PBUS_axi_wstrb    ),
        .s_axi_wlast    ( MBUS_to_PBUS_axi_wlast    ),
        .s_axi_wvalid   ( MBUS_to_PBUS_axi_wvalid   ),
        .s_axi_wready   ( MBUS_to_PBUS_axi_wready   ),
        .s_axi_bid      ( MBUS_to_PBUS_axi_bid      ),
        .s_axi_bresp    ( MBUS_to_PBUS_axi_bresp    ),
        .s_axi_bvalid   ( MBUS_to_PBUS_axi_bvalid   ),
        .s_axi_bready   ( MBUS_to_PBUS_axi_bready   ),
        .s_axi_arid     ( MBUS_to_PBUS_axi_arid     ),
        .s_axi_araddr   ( MBUS_to_PBUS_axi_araddr   ),
        .s_axi_arlen    ( MBUS_to_PBUS_axi_arlen    ),
        .s_axi_arsize   ( MBUS_to_PBUS_axi_arsize   ),
        .s_axi_arburst  ( MBUS_to_PBUS_axi_arburst  ),
        .s_axi_arlock   ( MBUS_to_PBUS_axi_arlock   ),
        .s_axi_arcache  ( MBUS_to_PBUS_axi_arcache  ),
        .s_axi_arprot   ( MBUS_to_PBUS_axi_arprot   ),
        .s_axi_arregion ( MBUS_to_PBUS_axi_arregion ),
        .s_axi_arqos    ( MBUS_to_PBUS_axi_arqos    ),
        .s_axi_arvalid  ( MBUS_to_PBUS_axi_arvalid  ),
        .s_axi_arready  ( MBUS_to_PBUS_axi_arready  ),
        .s_axi_rid      ( MBUS_to_PBUS_axi_rid      ),
        .s_axi_rdata    ( MBUS_to_PBUS_axi_rdata    ),
        .s_axi_rresp    ( MBUS_to_PBUS_axi_rresp    ),
        .s_axi_rlast    ( MBUS_to_PBUS_axi_rlast    ),
        .s_axi_rvalid   ( MBUS_to_PBUS_axi_rvalid   ),
        .s_axi_rready   ( MBUS_to_PBUS_axi_rready   )
    );


`ifdef HPC

    // DDR4 Channel 0
    ddr4_channel_wrapper  ddr4_channel_0_wrapper_u (
        .clock_i              ( soc_clk           ),
        .reset_ni             ( sys_resetn        ),

        // DDR4 differential clock
        .clk_300mhz_0_p_i     ( clk_300mhz_0_p_i  ),
        .clk_300mhz_0_n_i     ( clk_300mhz_0_n_i  ),

        // Connect DDR4 channel 0
        .cx_ddr4_adr          ( c0_ddr4_adr       ),
        .cx_ddr4_ba           ( c0_ddr4_ba        ),
        .cx_ddr4_cke          ( c0_ddr4_cke       ),
        .cx_ddr4_cs_n         ( c0_ddr4_cs_n      ),
        .cx_ddr4_dq           ( c0_ddr4_dq        ),
        .cx_ddr4_dqs_t        ( c0_ddr4_dqs_t     ),
        .cx_ddr4_dqs_c        ( c0_ddr4_dqs_c     ),
        .cx_ddr4_odt          ( c0_ddr4_odt       ),
        .cx_ddr4_par          ( c0_ddr4_par       ),
        .cx_ddr4_bg           ( c0_ddr4_bg        ),
        .cx_ddr4_act_n        ( c0_ddr4_act_n     ),
        .cx_ddr4_reset_n      ( c0_ddr4_reset_n   ),
        .cx_ddr4_ck_t         ( c0_ddr4_ck_t      ),
        .cx_ddr4_ck_c         ( c0_ddr4_ck_c      ),

        // AXILITE interface - for ECC status and control - not connected
        .s_ctrl_axilite_awvalid  ( 1'b0  ),
        .s_ctrl_axilite_awready  (       ),
        .s_ctrl_axilite_awaddr   ( 32'd0 ),
        .s_ctrl_axilite_wvalid   ( 1'b0  ),
        .s_ctrl_axilite_wready   (       ),
        .s_ctrl_axilite_wdata    ( 32'd0 ),
        .s_ctrl_axilite_bvalid   (       ),
        .s_ctrl_axilite_bready   ( 1'b1  ),
        .s_ctrl_axilite_bresp    (       ),
        .s_ctrl_axilite_arvalid  ( 1'b0  ),
        .s_ctrl_axilite_arready  (       ),
        .s_ctrl_axilite_araddr   ( 31'd0 ),
        .s_ctrl_axilite_rvalid   (       ),
        .s_ctrl_axilite_rready   ( 1'b1  ),
        .s_ctrl_axilite_rdata    (       ),
        .s_ctrl_axilite_rresp    (       ),

        // Slave interface
        .s_axi_awid           ( MBUS_to_DDR_axi_awid     ),
        .s_axi_awaddr         ( MBUS_to_DDR_axi_awaddr   ),
        .s_axi_awlen          ( MBUS_to_DDR_axi_awlen    ),
        .s_axi_awsize         ( MBUS_to_DDR_axi_awsize   ),
        .s_axi_awburst        ( MBUS_to_DDR_axi_awburst  ),
        .s_axi_awlock         ( MBUS_to_DDR_axi_awlock   ),
        .s_axi_awcache        ( MBUS_to_DDR_axi_awcache  ),
        .s_axi_awprot         ( MBUS_to_DDR_axi_awprot   ),
        .s_axi_awregion       ( MBUS_to_DDR_axi_awregion ),
        .s_axi_awqos          ( MBUS_to_DDR_axi_awqos    ),
        .s_axi_awvalid        ( MBUS_to_DDR_axi_awvalid  ),
        .s_axi_awready        ( MBUS_to_DDR_axi_awready  ),
        .s_axi_wdata          ( MBUS_to_DDR_axi_wdata    ),
        .s_axi_wstrb          ( MBUS_to_DDR_axi_wstrb    ),
        .s_axi_wlast          ( MBUS_to_DDR_axi_wlast    ),
        .s_axi_wvalid         ( MBUS_to_DDR_axi_wvalid   ),
        .s_axi_wready         ( MBUS_to_DDR_axi_wready   ),
        .s_axi_bid            ( MBUS_to_DDR_axi_bid      ),
        .s_axi_bresp          ( MBUS_to_DDR_axi_bresp    ),
        .s_axi_bvalid         ( MBUS_to_DDR_axi_bvalid   ),
        .s_axi_bready         ( MBUS_to_DDR_axi_bready   ),
        .s_axi_arid           ( MBUS_to_DDR_axi_arid     ),
        .s_axi_araddr         ( MBUS_to_DDR_axi_araddr   ),
        .s_axi_arlen          ( MBUS_to_DDR_axi_arlen    ),
        .s_axi_arsize         ( MBUS_to_DDR_axi_arsize   ),
        .s_axi_arburst        ( MBUS_to_DDR_axi_arburst  ),
        .s_axi_arlock         ( MBUS_to_DDR_axi_arlock   ),
        .s_axi_arcache        ( MBUS_to_DDR_axi_arcache  ),
        .s_axi_arprot         ( MBUS_to_DDR_axi_arprot   ),
        .s_axi_arregion       ( MBUS_to_DDR_axi_arregion ),
        .s_axi_arqos          ( MBUS_to_DDR_axi_arqos    ),
        .s_axi_arvalid        ( MBUS_to_DDR_axi_arvalid  ),
        .s_axi_arready        ( MBUS_to_DDR_axi_arready  ),
        .s_axi_rid            ( MBUS_to_DDR_axi_rid      ),
        .s_axi_rdata          ( MBUS_to_DDR_axi_rdata    ),
        .s_axi_rresp          ( MBUS_to_DDR_axi_rresp    ),
        .s_axi_rlast          ( MBUS_to_DDR_axi_rlast    ),
        .s_axi_rvalid         ( MBUS_to_DDR_axi_rvalid   ),
        .s_axi_rready         ( MBUS_to_DDR_axi_rready   )

    );


`endif


endmodule : uninasoc
