// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
// Description: Basic version of UninaSoC that allows to work with axi transactions to and from slaves (ToBeUpdated)

// System architecture:
//                                                                                    ________
//   _________              ____________               __________                    |        |
//  |         |            |            |             |          |                   |  Main  |
//  |   vio   |----------->| rvm_socket |------------>|          |------------------>| Memory |
//  |_________|            |____________|             |   AXI    |                   |________|
//   ____________                                     | crossbar |                    ______________
//  |            |                                    |          |                   |   (slave)    |
//  | sys_master |----------------------------------->|          |------------------>| Debug Module |
//  |____________|                                    |          |                   |______________|
//   ______________                                   |          |                    ________________ 
//  |   (master)   |                                  |          |                   |                |
//  | Debug Module |--------------------------------->|          |------------------>| Peripheral bus |
//  |______________|                                  |          |                   |     (PBUS)     |
//                                                    |          |                   |________________|
//                                                    |__________|
//

// Import packages
import uninasoc_pkg::*;


// Import headers
`include "uninasoc_axi.svh"

`ifdef HPC
    `include "uninasoc_pcie.svh"
    `include "uninasoc_ddr4.svh"
`endif

// Module definition
module uninasoc (

    `ifdef EMBEDDED
        // Clock and reset
        input logic sys_clock_i,
        input logic sys_reset_i,

        // UART interface
        input  logic                        uart_rx_i,
        output logic                        uart_tx_o,

        // GPIOs
        // input  wire [NUM_GPIO_IN  -1 : 0]  gpio_in_i,
        output logic [NUM_GPIO_OUT -1 : 0]  gpio_out_o
    `elsif HPC
        // DDR4 CH0 clock and reset
        input logic clk_300mhz_0_p_i,
        input logic clk_300mhz_0_n_i,

        // DDR4 CH0 interface 
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
    // TBD (if any)

    ///////////////////
    // Local Signals //
    //////////////////

    // Reset negative
    logic sys_resetn;
    // clkwiz -> all
    logic soc_clk;

    // VIO Signals
    logic vio_resetn;

    //////////////////////////
    // AXI interconnections //
    //////////////////////////

    // AXI masters
    // sys_master -> crossbar
    `DECLARE_AXI_BUS(sys_master_to_xbar, AXI_DATA_WIDTH);
    // rvm_socket -> crossbar
    `DECLARE_AXI_BUS(rvm_socket_instr, AXI_DATA_WIDTH);
    `DECLARE_AXI_BUS(rvm_socket_data, AXI_DATA_WIDTH);

    // AXI slaves
    // xbar -> main memory
    `DECLARE_AXI_BUS(xbar_to_main_mem, AXI_DATA_WIDTH);
    
    // XBAR to peripheral bus
    `DECLARE_AXI_BUS(xbar_to_peripheral_bus, AXI_DATA_WIDTH);

    `ifdef HPC
        // xbar -> DDR4
        `DECLARE_AXI_BUS(xbar_to_ddr4, AXI_DATA_WIDTH);
    `endif

    // Concatenate AXI master buses
    `DECLARE_AXI_BUS_ARRAY(xbar_masters, NUM_AXI_MASTERS);
    // NOTE: The order in this macro expansion is must match with xbar slave ports!
    //                      array_name,            bus N,           bus N-1,    ...     bus 0
    `CONCAT_AXI_MASTERS_ARRAY3(xbar_masters, rvm_socket_instr, rvm_socket_data, sys_master_to_xbar);

    // Concatenate AXI slave buses
    `DECLARE_AXI_BUS_ARRAY(xbar_slaves, NUM_AXI_SLAVES);

    // NOTE: The order in this macro expansion must match with xbar master ports!
    //                      array_name,            bus N,           bus N-1,    ...     bus 0
    `ifdef EMBEDDED
        `CONCAT_AXI_SLAVES_ARRAY2(xbar_slaves, xbar_to_peripheral_bus, xbar_to_main_mem);
    `elsif HPC
        `CONCAT_AXI_SLAVES_ARRAY3(xbar_slaves, xbar_to_ddr4, xbar_to_peripheral_bus, xbar_to_main_mem);
    `endif

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
      .probe_out1 ( vio_jtag_trst_n ),
      .probe_in0  ( sys_resetn      )
    );

    // Axi Crossbar
    xlnx_axi_crossbar axi_xbar_u (
        .aclk           ( soc_clk                   ), // input
        .aresetn        ( sys_resetn                ), // input
        .s_axi_awid     ( xbar_masters_axi_awid     ), // input
        .s_axi_awaddr   ( xbar_masters_axi_awaddr   ), // input
        .s_axi_awlen    ( xbar_masters_axi_awlen    ), // input
        .s_axi_awsize   ( xbar_masters_axi_awsize   ), // input
        .s_axi_awburst  ( xbar_masters_axi_awburst  ), // input
        .s_axi_awlock   ( xbar_masters_axi_awlock   ), // input
        .s_axi_awcache  ( xbar_masters_axi_awcache  ), // input
        .s_axi_awprot   ( xbar_masters_axi_awprot   ), // input
        .s_axi_awqos    ( xbar_masters_axi_awqos    ), // input
        .s_axi_awvalid  ( xbar_masters_axi_awvalid  ), // input
        .s_axi_awready  ( xbar_masters_axi_awready  ), // output
        .s_axi_wdata    ( xbar_masters_axi_wdata    ), // input
        .s_axi_wstrb    ( xbar_masters_axi_wstrb    ), // input
        .s_axi_wlast    ( xbar_masters_axi_wlast    ), // input
        .s_axi_wvalid   ( xbar_masters_axi_wvalid   ), // input
        .s_axi_wready   ( xbar_masters_axi_wready   ), // output
        .s_axi_bid      ( xbar_masters_axi_bid      ), // output
        .s_axi_bresp    ( xbar_masters_axi_bresp    ), // output
        .s_axi_bvalid   ( xbar_masters_axi_bvalid   ), // output
        .s_axi_bready   ( xbar_masters_axi_bready   ), // input
        .s_axi_arid     ( xbar_masters_axi_arid     ), // output
        .s_axi_araddr   ( xbar_masters_axi_araddr   ), // input
        .s_axi_arlen    ( xbar_masters_axi_arlen    ), // input
        .s_axi_arsize   ( xbar_masters_axi_arsize   ), // input
        .s_axi_arburst  ( xbar_masters_axi_arburst  ), // input
        .s_axi_arlock   ( xbar_masters_axi_arlock   ), // input
        .s_axi_arcache  ( xbar_masters_axi_arcache  ), // input
        .s_axi_arprot   ( xbar_masters_axi_arprot   ), // input
        .s_axi_arqos    ( xbar_masters_axi_arqos    ), // input
        .s_axi_arvalid  ( xbar_masters_axi_arvalid  ), // input
        .s_axi_arready  ( xbar_masters_axi_arready  ), // output
        .s_axi_rid      ( xbar_masters_axi_rid      ), // output
        .s_axi_rdata    ( xbar_masters_axi_rdata    ), // output
        .s_axi_rresp    ( xbar_masters_axi_rresp    ), // output
        .s_axi_rlast    ( xbar_masters_axi_rlast    ), // output
        .s_axi_rvalid   ( xbar_masters_axi_rvalid   ), // output
        .s_axi_rready   ( xbar_masters_axi_rready   ), // input
        .m_axi_awid     ( xbar_slaves_axi_awid      ), // output
        .m_axi_awaddr   ( xbar_slaves_axi_awaddr    ), // output
        .m_axi_awlen    ( xbar_slaves_axi_awlen     ), // output
        .m_axi_awsize   ( xbar_slaves_axi_awsize    ), // output
        .m_axi_awburst  ( xbar_slaves_axi_awburst   ), // output
        .m_axi_awlock   ( xbar_slaves_axi_awlock    ), // output
        .m_axi_awcache  ( xbar_slaves_axi_awcache   ), // output
        .m_axi_awprot   ( xbar_slaves_axi_awprot    ), // output
        .m_axi_awregion ( xbar_slaves_axi_awregion  ), // output
        .m_axi_awqos    ( xbar_slaves_axi_awqos     ), // output
        .m_axi_awvalid  ( xbar_slaves_axi_awvalid   ), // output
        .m_axi_awready  ( xbar_slaves_axi_awready   ), // input
        .m_axi_wdata    ( xbar_slaves_axi_wdata     ), // output
        .m_axi_wstrb    ( xbar_slaves_axi_wstrb     ), // output
        .m_axi_wlast    ( xbar_slaves_axi_wlast     ), // output
        .m_axi_wvalid   ( xbar_slaves_axi_wvalid    ), // output
        .m_axi_wready   ( xbar_slaves_axi_wready    ), // input
        .m_axi_bid      ( xbar_slaves_axi_bid       ), // input
        .m_axi_bresp    ( xbar_slaves_axi_bresp     ), // input
        .m_axi_bvalid   ( xbar_slaves_axi_bvalid    ), // input
        .m_axi_bready   ( xbar_slaves_axi_bready    ), // output
        .m_axi_arid     ( xbar_slaves_axi_arid      ), // output
        .m_axi_araddr   ( xbar_slaves_axi_araddr    ), // output
        .m_axi_arlen    ( xbar_slaves_axi_arlen     ), // output
        .m_axi_arsize   ( xbar_slaves_axi_arsize    ), // output
        .m_axi_arburst  ( xbar_slaves_axi_arburst   ), // output
        .m_axi_arlock   ( xbar_slaves_axi_arlock    ), // output
        .m_axi_arcache  ( xbar_slaves_axi_arcache   ), // output
        .m_axi_arprot   ( xbar_slaves_axi_arprot    ), // output
        .m_axi_arregion ( xbar_slaves_axi_arregion  ), // output
        .m_axi_arqos    ( xbar_slaves_axi_arqos     ), // output
        .m_axi_arvalid  ( xbar_slaves_axi_arvalid   ), // output
        .m_axi_arready  ( xbar_slaves_axi_arready   ), // input
        .m_axi_rid      ( xbar_slaves_axi_rid       ), // input
        .m_axi_rdata    ( xbar_slaves_axi_rdata     ), // input
        .m_axi_rresp    ( xbar_slaves_axi_rresp     ), // input
        .m_axi_rlast    ( xbar_slaves_axi_rlast     ), // input
        .m_axi_rvalid   ( xbar_slaves_axi_rvalid    ), // input
        .m_axi_rready   ( xbar_slaves_axi_rready    )  // output
    );

    /////////////////
    // AXI masters //
    /////////////////

    sys_master sys_master_u (

        `ifdef EMBEDDED
            .sys_clock_i(sys_clock_i),
            .sys_reset_i(sys_reset_i),
        `elsif HPC
            .pcie_refclk_p_i(pcie_refclk_p_i),
            .pcie_refclk_n_i(pcie_refclk_n_i),
            .pcie_resetn_i(pcie_resetn_i),

            // PCI interface
            .pci_exp_rxn_i(pci_exp_rxn_i),
            .pci_exp_rxp_i(pci_exp_rxp_i),
            .pci_exp_txn_o(pci_exp_txn_o),
            .pci_exp_txp_o(pci_exp_txp_o),
        `endif


        // Output clock
        .soc_clk_o(soc_clk),
        .sys_resetn_o(sys_resetn),

        // AXI Master
        .m_axi_awid     ( sys_master_to_xbar_axi_awid    ),
        .m_axi_awaddr   ( sys_master_to_xbar_axi_awaddr  ),
        .m_axi_awlen    ( sys_master_to_xbar_axi_awlen   ),
        .m_axi_awsize   ( sys_master_to_xbar_axi_awsize  ),
        .m_axi_awburst  ( sys_master_to_xbar_axi_awburst ),
        .m_axi_awlock   ( sys_master_to_xbar_axi_awlock  ),
        .m_axi_awcache  ( sys_master_to_xbar_axi_awcache ),
        .m_axi_awprot   ( sys_master_to_xbar_axi_awprot  ),
        .m_axi_awqos    ( sys_master_to_xbar_axi_awqos   ),
        .m_axi_awvalid  ( sys_master_to_xbar_axi_awvalid ),
        .m_axi_awready  ( sys_master_to_xbar_axi_awready ),
        .m_axi_awregion ( sys_master_to_xbar_axi_awregion ),
        .m_axi_wdata    ( sys_master_to_xbar_axi_wdata   ),
        .m_axi_wstrb    ( sys_master_to_xbar_axi_wstrb   ),
        .m_axi_wlast    ( sys_master_to_xbar_axi_wlast   ),
        .m_axi_wvalid   ( sys_master_to_xbar_axi_wvalid  ),
        .m_axi_wready   ( sys_master_to_xbar_axi_wready  ),
        .m_axi_bid      ( sys_master_to_xbar_axi_bid     ),
        .m_axi_bresp    ( sys_master_to_xbar_axi_bresp   ),
        .m_axi_bvalid   ( sys_master_to_xbar_axi_bvalid  ),
        .m_axi_bready   ( sys_master_to_xbar_axi_bready  ),
        .m_axi_arid     ( sys_master_to_xbar_axi_arid    ),
        .m_axi_araddr   ( sys_master_to_xbar_axi_araddr  ),
        .m_axi_arlen    ( sys_master_to_xbar_axi_arlen   ),
        .m_axi_arsize   ( sys_master_to_xbar_axi_arsize  ),
        .m_axi_arburst  ( sys_master_to_xbar_axi_arburst ),
        .m_axi_arlock   ( sys_master_to_xbar_axi_arlock  ),
        .m_axi_arcache  ( sys_master_to_xbar_axi_arcache ),
        .m_axi_arprot   ( sys_master_to_xbar_axi_arprot  ),
        .m_axi_arqos    ( sys_master_to_xbar_axi_arqos   ),
        .m_axi_arvalid  ( sys_master_to_xbar_axi_arvalid ),
        .m_axi_arready  ( sys_master_to_xbar_axi_arready ),
        .m_axi_arregion ( sys_master_to_xbar_axi_arregion ),
        .m_axi_rid      ( sys_master_to_xbar_axi_rid     ),
        .m_axi_rdata    ( sys_master_to_xbar_axi_rdata   ),
        .m_axi_rresp    ( sys_master_to_xbar_axi_rresp   ),
        .m_axi_rlast    ( sys_master_to_xbar_axi_rlast   ),
        .m_axi_rvalid   ( sys_master_to_xbar_axi_rvalid  ),
        .m_axi_rready   ( sys_master_to_xbar_axi_rready  )
    );

    // RVM Socket
    rvm_socket # (
        .DATA_WIDTH    ( AXI_DATA_WIDTH ),
        .ADDR_WIDTH    ( AXI_ADDR_WIDTH )
        //.DEBUG_MODULE  ( DEBUG_MODULE   )
    ) rvm_socket_u (
        .clk_i          ( soc_clk    ),
        .rst_ni         ( sys_resetn & vio_resetn ),
        .bootaddr_i     ( '0         ),
        .irq_i          ( '0         ),

        // Instruction AXI Port
        .rvm_socket_instr_axi_awid,
        .rvm_socket_instr_axi_awaddr,
        .rvm_socket_instr_axi_awlen,
        .rvm_socket_instr_axi_awsize,
        .rvm_socket_instr_axi_awburst,
        .rvm_socket_instr_axi_awlock,
        .rvm_socket_instr_axi_awcache,
        .rvm_socket_instr_axi_awprot,
        .rvm_socket_instr_axi_awqos,
        .rvm_socket_instr_axi_awvalid,
        .rvm_socket_instr_axi_awready,
        .rvm_socket_instr_axi_awregion,
        .rvm_socket_instr_axi_wdata,
        .rvm_socket_instr_axi_wstrb,
        .rvm_socket_instr_axi_wlast,
        .rvm_socket_instr_axi_wvalid,
        .rvm_socket_instr_axi_wready,
        .rvm_socket_instr_axi_bid ,
        .rvm_socket_instr_axi_bresp,
        .rvm_socket_instr_axi_bvalid,
        .rvm_socket_instr_axi_bready,
        .rvm_socket_instr_axi_arid,
        .rvm_socket_instr_axi_araddr,
        .rvm_socket_instr_axi_arlen,
        .rvm_socket_instr_axi_arsize,
        .rvm_socket_instr_axi_arburst,
        .rvm_socket_instr_axi_arlock,
        .rvm_socket_instr_axi_arcache,
        .rvm_socket_instr_axi_arprot,
        .rvm_socket_instr_axi_arqos,
        .rvm_socket_instr_axi_arvalid,
        .rvm_socket_instr_axi_arready,
        .rvm_socket_instr_axi_arregion,
        .rvm_socket_instr_axi_rid,
        .rvm_socket_instr_axi_rdata,
        .rvm_socket_instr_axi_rresp,
        .rvm_socket_instr_axi_rlast,
        .rvm_socket_instr_axi_rvalid,
        .rvm_socket_instr_axi_rready,

        // Data AXI Port
        .rvm_socket_data_axi_awid,
        .rvm_socket_data_axi_awaddr,
        .rvm_socket_data_axi_awlen,
        .rvm_socket_data_axi_awsize,
        .rvm_socket_data_axi_awburst,
        .rvm_socket_data_axi_awlock,
        .rvm_socket_data_axi_awcache,
        .rvm_socket_data_axi_awprot,
        .rvm_socket_data_axi_awqos,
        .rvm_socket_data_axi_awvalid,
        .rvm_socket_data_axi_awready,
        .rvm_socket_data_axi_awregion,
        .rvm_socket_data_axi_wdata,
        .rvm_socket_data_axi_wstrb,
        .rvm_socket_data_axi_wlast,
        .rvm_socket_data_axi_wvalid,
        .rvm_socket_data_axi_wready,
        .rvm_socket_data_axi_bid ,
        .rvm_socket_data_axi_bresp,
        .rvm_socket_data_axi_bvalid,
        .rvm_socket_data_axi_bready,
        .rvm_socket_data_axi_arid,
        .rvm_socket_data_axi_araddr,
        .rvm_socket_data_axi_arlen,
        .rvm_socket_data_axi_arsize,
        .rvm_socket_data_axi_arburst,
        .rvm_socket_data_axi_arlock,
        .rvm_socket_data_axi_arcache,
        .rvm_socket_data_axi_arprot,
        .rvm_socket_data_axi_arqos,
        .rvm_socket_data_axi_arvalid,
        .rvm_socket_data_axi_arready,
        .rvm_socket_data_axi_arregion,
        .rvm_socket_data_axi_rid,
        .rvm_socket_data_axi_rdata,
        .rvm_socket_data_axi_rresp,
        .rvm_socket_data_axi_rlast,
        .rvm_socket_data_axi_rvalid,
        .rvm_socket_data_axi_rready
    );

    ////////////////
    // AXI slaves //
    ////////////////

    // Main memory
    xlnx_blk_mem_gen main_memory_u (
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

    
    ////////////////////
    // PERIPHERAL BUS //
    //////////////////// 

    peripheral_bus peripheral_bus_u (

        .clock_i        ( soc_clk     ),
        .reset_ni       ( sys_resetn  ),

        `ifdef EMBEDDED
            .uart_rx_i  ( uart_rx_i      ),
            .uart_tx_o  ( uart_tx_o      ),
            .gpio_out_o ( gpio_out_o     ), 
        `endif 

        .s_axi_awid     ( xbar_to_peripheral_bus_axi_awid     ),
        .s_axi_awaddr   ( xbar_to_peripheral_bus_axi_awaddr   ),
        .s_axi_awlen    ( xbar_to_peripheral_bus_axi_awlen    ),
        .s_axi_awsize   ( xbar_to_peripheral_bus_axi_awsize   ), 
        .s_axi_awburst  ( xbar_to_peripheral_bus_axi_awburst  ),
        .s_axi_awlock   ( xbar_to_peripheral_bus_axi_awlock   ), 
        .s_axi_awcache  ( xbar_to_peripheral_bus_axi_awcache  ), 
        .s_axi_awprot   ( xbar_to_peripheral_bus_axi_awprot   ),
        .s_axi_awregion ( xbar_to_peripheral_bus_axi_awregion ), 
        .s_axi_awqos    ( xbar_to_peripheral_bus_axi_awqos    ),  
        .s_axi_awvalid  ( xbar_to_peripheral_bus_axi_awvalid  ),
        .s_axi_awready  ( xbar_to_peripheral_bus_axi_awready  ),
        .s_axi_wdata    ( xbar_to_peripheral_bus_axi_wdata    ),
        .s_axi_wstrb    ( xbar_to_peripheral_bus_axi_wstrb    ),
        .s_axi_wlast    ( xbar_to_peripheral_bus_axi_wlast    ),
        .s_axi_wvalid   ( xbar_to_peripheral_bus_axi_wvalid   ),
        .s_axi_wready   ( xbar_to_peripheral_bus_axi_wready   ),
        .s_axi_bid      ( xbar_to_peripheral_bus_axi_bid      ),
        .s_axi_bresp    ( xbar_to_peripheral_bus_axi_bresp    ),
        .s_axi_bvalid   ( xbar_to_peripheral_bus_axi_bvalid   ),
        .s_axi_bready   ( xbar_to_peripheral_bus_axi_bready   ),
        .s_axi_arid     ( xbar_to_peripheral_bus_axi_arid     ),
        .s_axi_araddr   ( xbar_to_peripheral_bus_axi_araddr   ),
        .s_axi_arlen    ( xbar_to_peripheral_bus_axi_arlen    ),
        .s_axi_arsize   ( xbar_to_peripheral_bus_axi_arsize   ),
        .s_axi_arburst  ( xbar_to_peripheral_bus_axi_arburst  ),
        .s_axi_arlock   ( xbar_to_peripheral_bus_axi_arlock   ),
        .s_axi_arcache  ( xbar_to_peripheral_bus_axi_arcache  ),
        .s_axi_arprot   ( xbar_to_peripheral_bus_axi_arprot   ),
        .s_axi_arregion ( xbar_to_peripheral_bus_axi_arregion ),
        .s_axi_arqos    ( xbar_to_peripheral_bus_axi_arqos    ),
        .s_axi_arvalid  ( xbar_to_peripheral_bus_axi_arvalid  ),
        .s_axi_arready  ( xbar_to_peripheral_bus_axi_arready  ),
        .s_axi_rid      ( xbar_to_peripheral_bus_axi_rid      ),
        .s_axi_rdata    ( xbar_to_peripheral_bus_axi_rdata    ),
        .s_axi_rresp    ( xbar_to_peripheral_bus_axi_rresp    ),
        .s_axi_rlast    ( xbar_to_peripheral_bus_axi_rlast    ),
        .s_axi_rvalid   ( xbar_to_peripheral_bus_axi_rvalid   ),
        .s_axi_rready   ( xbar_to_peripheral_bus_axi_rready   )
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
        .s_axi_awid           ( xbar_to_ddr4_axi_awid     ), 
        .s_axi_awaddr         ( xbar_to_ddr4_axi_awaddr   ), 
        .s_axi_awlen          ( xbar_to_ddr4_axi_awlen    ), 
        .s_axi_awsize         ( xbar_to_ddr4_axi_awsize   ), 
        .s_axi_awburst        ( xbar_to_ddr4_axi_awburst  ), 
        .s_axi_awlock         ( xbar_to_ddr4_axi_awlock   ), 
        .s_axi_awcache        ( xbar_to_ddr4_axi_awcache  ), 
        .s_axi_awprot         ( xbar_to_ddr4_axi_awprot   ), 
        .s_axi_awregion       ( xbar_to_ddr4_axi_awregion ), 
        .s_axi_awqos          ( xbar_to_ddr4_axi_awqos    ), 
        .s_axi_awvalid        ( xbar_to_ddr4_axi_awvalid  ), 
        .s_axi_awready        ( xbar_to_ddr4_axi_awready  ), 
        .s_axi_wdata          ( xbar_to_ddr4_axi_wdata    ), 
        .s_axi_wstrb          ( xbar_to_ddr4_axi_wstrb    ), 
        .s_axi_wlast          ( xbar_to_ddr4_axi_wlast    ), 
        .s_axi_wvalid         ( xbar_to_ddr4_axi_wvalid   ), 
        .s_axi_wready         ( xbar_to_ddr4_axi_wready   ), 
        .s_axi_bid            ( xbar_to_ddr4_axi_bid      ), 
        .s_axi_bresp          ( xbar_to_ddr4_axi_bresp    ), 
        .s_axi_bvalid         ( xbar_to_ddr4_axi_bvalid   ),
        .s_axi_bready         ( xbar_to_ddr4_axi_bready   ), 
        .s_axi_arid           ( xbar_to_ddr4_axi_arid     ), 
        .s_axi_araddr         ( xbar_to_ddr4_axi_araddr   ), 
        .s_axi_arlen          ( xbar_to_ddr4_axi_arlen    ), 
        .s_axi_arsize         ( xbar_to_ddr4_axi_arsize   ), 
        .s_axi_arburst        ( xbar_to_ddr4_axi_arburst  ), 
        .s_axi_arlock         ( xbar_to_ddr4_axi_arlock   ), 
        .s_axi_arcache        ( xbar_to_ddr4_axi_arcache  ), 
        .s_axi_arprot         ( xbar_to_ddr4_axi_arprot   ), 
        .s_axi_arregion       ( xbar_to_ddr4_axi_arregion ), 
        .s_axi_arqos          ( xbar_to_ddr4_axi_arqos    ), 
        .s_axi_arvalid        ( xbar_to_ddr4_axi_arvalid  ), 
        .s_axi_arready        ( xbar_to_ddr4_axi_arready  ), 
        .s_axi_rid            ( xbar_to_ddr4_axi_rid      ), 
        .s_axi_rdata          ( xbar_to_ddr4_axi_rdata    ), 
        .s_axi_rresp          ( xbar_to_ddr4_axi_rresp    ), 
        .s_axi_rlast          ( xbar_to_ddr4_axi_rlast    ), 
        .s_axi_rvalid         ( xbar_to_ddr4_axi_rvalid   ), 
        .s_axi_rready         ( xbar_to_ddr4_axi_rready   ) 

    );


`endif


endmodule : uninasoc

