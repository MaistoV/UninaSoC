// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Sys master - Instantiates the right masetr AXI based on the board (e.g. Jtag2Axi for NEXYS_A7, XDMA for Alveo), and gives the clk and rst to the soc


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"

module sys_master
(

    `ifdef NEXYS_A7
        // Input clock and reset
        input logic sys_clock_i,
        input logic sys_reset_i,
    `elsif AU250
        // Input clock and reset
        input logic pcie_refclk_p_i,
        input logic pcie_refclk_n_i,
        input logic pcie_resetn_i,

        // PCIe interface
        `DEFINE_PCIE_PORTS,
    `endif


    // Output clk and reset
    output logic soc_clk_o,
    output logic sys_resetn_o,

    // AXI Master interface 
    `DEFINE_AXI_MASTER_PORTS(m)

);

`ifdef AU250
    // ALVEO

    logic ibuf_out;
    logic ibuf_os_odiv2;

    IBUFDS_GTE4 #(

    ) IBUFDS_GTE4_inst (
        .O(ibuf_out),
        .ODIV2(ibuf_os_odiv2),
        .CEB(1'b0),
        .I(pcie_refclk_p_i),
        .IB(pcie_refclk_n_i)
    );

    // XDMA Master 
    xlnx_xdma #(

    ) xlnx_xdma_inst (

        // Input clock and reset
        .sys_clk(ibuf_os_odiv2),
        .sys_clk_gt(ibuf_out),
        .sys_rst_n(pcie_resetn_i),

        // Output clock
        .axi_aclk(soc_clk_o),
        .axi_aresetn(sys_resetn_o),

        // PCI interface
        .pci_exp_rxn(pci_exp_rxn_i), // [NUM_PCIE_LANES-1:0]
        .pci_exp_rxp(pci_exp_rxp_i), // [NUM_PCIE_LANES-1:0] 
        .pci_exp_txn(pci_exp_txn_o), // [NUM_PCIE_LANES-1:0]
        .pci_exp_txp(pci_exp_txp_o), // [NUM_PCIE_LANES-1:0]

        // Interrupts interface
        .usr_irq_req    ( 0      ),

        // AXI Master
        .m_axib_awid     ( m_axi_awid    ), 
        .m_axib_awaddr   ( m_axi_awaddr  ), 
        .m_axib_awlen    ( m_axi_awlen   ), 
        .m_axib_awsize   ( m_axi_awsize  ), 
        .m_axib_awburst  ( m_axi_awburst ), 
        .m_axib_awlock   ( m_axi_awlock  ), 
        .m_axib_awcache  ( m_axi_awcache ), 
        .m_axib_awprot   ( m_axi_awprot  ), 
        // .m_axib_awqos    ( m_axi_awqos   ), 
        .m_axib_awvalid  ( m_axi_awvalid ), 
        .m_axib_awready  ( m_axi_awready ), 
        .m_axib_wdata    ( m_axi_wdata   ), 
        .m_axib_wstrb    ( m_axi_wstrb   ), 
        .m_axib_wlast    ( m_axi_wlast   ), 
        .m_axib_wvalid   ( m_axi_wvalid  ), 
        .m_axib_wready   ( m_axi_wready  ), 
        .m_axib_bid      ( m_axi_bid     ), 
        .m_axib_bresp    ( m_axi_bresp   ), 
        .m_axib_bvalid   ( m_axi_bvalid  ), 
        .m_axib_bready   ( m_axi_bready  ), 
        .m_axib_arid     ( m_axi_arid    ), 
        .m_axib_araddr   ( m_axi_araddr  ), 
        .m_axib_arlen    ( m_axi_arlen   ), 
        .m_axib_arsize   ( m_axi_arsize  ), 
        .m_axib_arburst  ( m_axi_arburst ), 
        .m_axib_arlock   ( m_axi_arlock  ), 
        .m_axib_arcache  ( m_axi_arcache ), 
        .m_axib_arprot   ( m_axi_arprot  ), 
        // .m_axib_arqos    ( m_axi_arqos   ), 
        .m_axib_arvalid  ( m_axi_arvalid ), 
        .m_axib_arready  ( m_axi_arready ), 
        .m_axib_rid      ( m_axi_rid     ), 
        .m_axib_rdata    ( m_axi_rdata   ), 
        .m_axib_rresp    ( m_axi_rresp   ), 
        .m_axib_rlast    ( m_axi_rlast   ), 
        .m_axib_rvalid   ( m_axi_rvalid  ), 
        .m_axib_rready   ( m_axi_rready  ),

        .s_axil_awaddr	(12'b0),
        .s_axil_awvalid	(1'b0),
        .s_axil_awready	(),
        .s_axil_wdata	(32'b0),
        .s_axil_wstrb	(4'b0),
        .s_axil_wvalid	(1'b0),
        .s_axil_wready	(),
        .s_axil_bresp	(),
        .s_axil_bvalid	(),
        .s_axil_bready	(1'b0),
        .s_axil_araddr	(12'b0),
        .s_axil_arvalid	(1'b0),
        .s_axil_arready	(),
        .s_axil_rdata	(),
        .s_axil_rresp	(),
        .s_axil_rvalid	(),
        .s_axil_rready	(1'b0),
        .s_axil_awprot  (3'b0),
        .s_axil_arprot  (3'b0)
    );
`elsif  NEXYS_A7
    // NEXYS_A7
    
    assign sys_resetn_o = ~sys_reset_i;
    // PLL

    xlnx_clk_wiz clkwiz_inst (
        .clk_in1  ( sys_clock_i  ),
        .resetn   ( sys_resetn_o ),
        .locked   ( ),
        .clk_100  ( ),
        .clk_50   ( soc_clk_o   ),
        .clk_20   ( ),
        .clk_10   ( )
    );

    // JTAG2AXI Master

    xlnx_jtag_axi jtag_axi_inst (
        .aclk           ( soc_clk_o       ), // input wire aclk
        .aresetn        ( sys_resetn_o    ), // input wire aresetn
        .m_axi_awid     ( m_axi_awid    ), // output wire [1 : 0] m_axi_awid
        .m_axi_awaddr   ( m_axi_awaddr  ), // output wire [31 : 0] m_axi_awid
        .m_axi_awlen    ( m_axi_awlen   ), // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize   ( m_axi_awsize  ), // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst  ( m_axi_awburst ), // output wire [1 : 0] m_axi_awburst
        .m_axi_awlock   ( m_axi_awlock  ), // output wire m_axi_awlock
        .m_axi_awcache  ( m_axi_awcache ), // output wire [3 : 0] m_axi_awcache
        .m_axi_awprot   ( m_axi_awprot  ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awqos    ( m_axi_awqos   ), // output wire [3 : 0] m_axi_awqos
        .m_axi_awvalid  ( m_axi_awvalid ), // output wire m_axi_awvalid
        .m_axi_awready  ( m_axi_awready ), // input wire m_axi_awready
        .m_axi_wdata    ( m_axi_wdata   ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    ( m_axi_wstrb   ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wlast    ( m_axi_wlast   ), // output wire m_axi_wlast
        .m_axi_wvalid   ( m_axi_wvalid  ), // output wire m_axi_wvalid
        .m_axi_wready   ( m_axi_wready  ), // input wire m_axi_wready
        .m_axi_bid      ( m_axi_bid     ), // input wire [0 : 0] m_axi_bid
        .m_axi_bresp    ( m_axi_bresp   ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   ( m_axi_bvalid  ), // input wire m_axi_bvalid
        .m_axi_bready   ( m_axi_bready  ), // output wire m_axi_bready
        .m_axi_arid     ( m_axi_arid    ), // output wire [0 : 0] m_axi_arid
        .m_axi_araddr   ( m_axi_araddr  ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arlen    ( m_axi_arlen   ), // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize   ( m_axi_arsize  ), // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst  ( m_axi_arburst ), // output wire [1 : 0] m_axi_arburst
        .m_axi_arlock   ( m_axi_arlock  ), // output wire m_axi_arlock
        .m_axi_arcache  ( m_axi_arcache ), // output wire [3 : 0] m_axi_arcache
        .m_axi_arprot   ( m_axi_arprot  ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arqos    ( m_axi_arqos   ), // output wire [3 : 0] m_axi_arqos
        .m_axi_arvalid  ( m_axi_arvalid ), // output wire m_axi_arvalid
        .m_axi_arready  ( m_axi_arready ), // input wire m_axi_arready
        .m_axi_rid      ( m_axi_rid     ), // input wire [1 : 0] m_axi_rid
        .m_axi_rdata    ( m_axi_rdata   ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    ( m_axi_rresp   ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast    ( m_axi_rlast   ), // input wire m_axi_rlast
        .m_axi_rvalid   ( m_axi_rvalid  ), // input wire m_axi_rvalid
        .m_axi_rready   ( m_axi_rready  )  // output wire m_axi_rready 
    );
`endif

endmodule : sys_master