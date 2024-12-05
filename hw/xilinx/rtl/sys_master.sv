// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Sys master - Instantiates the right masetr AXI based on the SoC Configuration and gives the clk and rst to the soc
//              EMBEDDED -> Jtag2Axi 
//              HPC      -> XDMA


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"

`ifdef HPC
    `include "uninasoc_pcie.svh"
`endif

module sys_master
(

    `ifdef EMBEDDED
        // Input clock and reset
        input logic sys_clock_i,
        input logic sys_reset_i,
    `elsif HPC
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

`ifdef HPC
    // ALVEO

    localparam int unsigned XDMA_DATA_WIDTH = 64;

    logic ibuf_out;
    logic ibuf_os_odiv2;

    IBUFDS_GTE4 IBUFDS_GTE4_u (
        .O(ibuf_out),
        .ODIV2(ibuf_os_odiv2),
        .CEB(1'b0),
        .I(pcie_refclk_p_i),
        .IB(pcie_refclk_n_i)
    );

    logic axi_aclk;
    logic axi_aresetn;

    assign soc_clk_o    = axi_aclk;
    assign sys_resetn_o = axi_aresetn;

    `DECLARE_AXI_BUS(xdma_to_axi_dwidth_converter, XDMA_DATA_WIDTH);

    // XDMA Master 
    xlnx_xdma xlnx_xdma_u (
        // Input clock and reset
        .sys_clk      ( ibuf_os_odiv2 ),
        .sys_clk_gt   ( ibuf_out      ),
        .sys_rst_n    ( pcie_resetn_i ),

        // Output clock
        .axi_aclk     ( axi_aclk      ),
        .axi_aresetn  ( axi_aresetn   ),

        // PCI interface
        .pci_exp_rxn  ( pci_exp_rxn_i ),
        .pci_exp_rxp  ( pci_exp_rxp_i ), 
        .pci_exp_txn  ( pci_exp_txn_o ),
        .pci_exp_txp  ( pci_exp_txp_o ),

        // Interrupts interface
        .usr_irq_req    ( 0      ),

        // AXI Master
        .m_axib_awid     ( xdma_to_axi_dwidth_converter_axi_awid    ), 
        .m_axib_awaddr   ( xdma_to_axi_dwidth_converter_axi_awaddr  ), 
        .m_axib_awlen    ( xdma_to_axi_dwidth_converter_axi_awlen   ), 
        .m_axib_awsize   ( xdma_to_axi_dwidth_converter_axi_awsize  ), 
        .m_axib_awburst  ( xdma_to_axi_dwidth_converter_axi_awburst ), 
        .m_axib_awlock   ( xdma_to_axi_dwidth_converter_axi_awlock  ), 
        .m_axib_awcache  ( xdma_to_axi_dwidth_converter_axi_awcache ), 
        .m_axib_awprot   ( xdma_to_axi_dwidth_converter_axi_awprot  ), 
        // .m_axib_awqos    ( xdma_to_axi_dwidth_converter_axi_awqos   ), 
        .m_axib_awvalid  ( xdma_to_axi_dwidth_converter_axi_awvalid ), 
        .m_axib_awready  ( xdma_to_axi_dwidth_converter_axi_awready ), 
        .m_axib_wdata    ( xdma_to_axi_dwidth_converter_axi_wdata   ), 
        .m_axib_wstrb    ( xdma_to_axi_dwidth_converter_axi_wstrb   ), 
        .m_axib_wlast    ( xdma_to_axi_dwidth_converter_axi_wlast   ), 
        .m_axib_wvalid   ( xdma_to_axi_dwidth_converter_axi_wvalid  ), 
        .m_axib_wready   ( xdma_to_axi_dwidth_converter_axi_wready  ), 
        .m_axib_bid      ( xdma_to_axi_dwidth_converter_axi_bid     ), 
        .m_axib_bresp    ( xdma_to_axi_dwidth_converter_axi_bresp   ), 
        .m_axib_bvalid   ( xdma_to_axi_dwidth_converter_axi_bvalid  ), 
        .m_axib_bready   ( xdma_to_axi_dwidth_converter_axi_bready  ), 
        .m_axib_arid     ( xdma_to_axi_dwidth_converter_axi_arid    ), 
        .m_axib_araddr   ( xdma_to_axi_dwidth_converter_axi_araddr  ), 
        .m_axib_arlen    ( xdma_to_axi_dwidth_converter_axi_arlen   ), 
        .m_axib_arsize   ( xdma_to_axi_dwidth_converter_axi_arsize  ), 
        .m_axib_arburst  ( xdma_to_axi_dwidth_converter_axi_arburst ), 
        .m_axib_arlock   ( xdma_to_axi_dwidth_converter_axi_arlock  ), 
        .m_axib_arcache  ( xdma_to_axi_dwidth_converter_axi_arcache ), 
        .m_axib_arprot   ( xdma_to_axi_dwidth_converter_axi_arprot  ), 
        // .m_axib_arqos    ( xdma_to_axi_dwidth_converter_axi_arqos   ), 
        .m_axib_arvalid  ( xdma_to_axi_dwidth_converter_axi_arvalid ), 
        .m_axib_arready  ( xdma_to_axi_dwidth_converter_axi_arready ), 
        .m_axib_rid      ( xdma_to_axi_dwidth_converter_axi_rid     ), 
        .m_axib_rdata    ( xdma_to_axi_dwidth_converter_axi_rdata   ), 
        .m_axib_rresp    ( xdma_to_axi_dwidth_converter_axi_rresp   ), 
        .m_axib_rlast    ( xdma_to_axi_dwidth_converter_axi_rlast   ), 
        .m_axib_rvalid   ( xdma_to_axi_dwidth_converter_axi_rvalid  ), 
        .m_axib_rready   ( xdma_to_axi_dwidth_converter_axi_rready  ),

        // AXI lite (configuration channel)
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

    xlnx_axi_dwidth_64to32_converter xlnx_axi_dwidth_64to32_converter_u (
        .s_axi_aclk     ( axi_aclk    ),
        .s_axi_aresetn  ( axi_aresetn ),

        // Slave from XDMA
        .s_axi_awid     ( xdma_to_axi_dwidth_converter_axi_awid    ),
        .s_axi_awaddr   ( xdma_to_axi_dwidth_converter_axi_awaddr  ),
        .s_axi_awlen    ( xdma_to_axi_dwidth_converter_axi_awlen   ),
        .s_axi_awsize   ( xdma_to_axi_dwidth_converter_axi_awsize  ),
        .s_axi_awburst  ( xdma_to_axi_dwidth_converter_axi_awburst ),
        .s_axi_awvalid  ( xdma_to_axi_dwidth_converter_axi_awvalid ),
        .s_axi_awready  ( xdma_to_axi_dwidth_converter_axi_awready ),
        .s_axi_wdata    ( xdma_to_axi_dwidth_converter_axi_wdata   ),
        .s_axi_wstrb    ( xdma_to_axi_dwidth_converter_axi_wstrb   ),
        .s_axi_wlast    ( xdma_to_axi_dwidth_converter_axi_wlast   ),
        .s_axi_wvalid   ( xdma_to_axi_dwidth_converter_axi_wvalid  ),
        .s_axi_wready   ( xdma_to_axi_dwidth_converter_axi_wready  ),
        .s_axi_bid      ( xdma_to_axi_dwidth_converter_axi_bid     ),
        .s_axi_bresp    ( xdma_to_axi_dwidth_converter_axi_bresp   ),
        .s_axi_bvalid   ( xdma_to_axi_dwidth_converter_axi_bvalid  ),
        .s_axi_bready   ( xdma_to_axi_dwidth_converter_axi_bready  ),
        .s_axi_arid     ( xdma_to_axi_dwidth_converter_axi_arid    ),
        .s_axi_araddr   ( xdma_to_axi_dwidth_converter_axi_araddr  ),
        .s_axi_arlen    ( xdma_to_axi_dwidth_converter_axi_arlen   ),
        .s_axi_arsize   ( xdma_to_axi_dwidth_converter_axi_arsize  ),
        .s_axi_arburst  ( xdma_to_axi_dwidth_converter_axi_arburst ),
        .s_axi_arvalid  ( xdma_to_axi_dwidth_converter_axi_arvalid ),
        .s_axi_arready  ( xdma_to_axi_dwidth_converter_axi_arready ),
        .s_axi_rid      ( xdma_to_axi_dwidth_converter_axi_rid     ),
        .s_axi_rdata    ( xdma_to_axi_dwidth_converter_axi_rdata   ),
        .s_axi_rresp    ( xdma_to_axi_dwidth_converter_axi_rresp   ),
        .s_axi_rlast    ( xdma_to_axi_dwidth_converter_axi_rlast   ),
        .s_axi_rvalid   ( xdma_to_axi_dwidth_converter_axi_rvalid  ),
        .s_axi_rready   ( xdma_to_axi_dwidth_converter_axi_rready  ),
        .s_axi_awlock   ( xdma_to_axi_dwidth_converter_axi_awlock  ),
        .s_axi_awcache  ( xdma_to_axi_dwidth_converter_axi_awcache ),
        .s_axi_awprot   ( xdma_to_axi_dwidth_converter_axi_awprot  ),
        .s_axi_awqos    ( 0   ),
        .s_axi_awregion ( 0   ),
        .s_axi_arlock   ( xdma_to_axi_dwidth_converter_axi_arlock  ),
        .s_axi_arcache  ( xdma_to_axi_dwidth_converter_axi_arcache ),
        .s_axi_arprot   ( xdma_to_axi_dwidth_converter_axi_arprot  ),
        .s_axi_arqos    ( 0   ),
        .s_axi_arregion ( 0   ),

        
        // Master to output port
        // .m_axi_awid     ( m_axi_awid    ),
        .m_axi_awaddr   ( m_axi_awaddr  ),
        .m_axi_awlen    ( m_axi_awlen   ),
        .m_axi_awsize   ( m_axi_awsize  ),
        .m_axi_awburst  ( m_axi_awburst ),
        .m_axi_awlock   ( m_axi_awlock  ),
        .m_axi_awcache  ( m_axi_awcache ),
        .m_axi_awprot   ( m_axi_awprot  ),
        .m_axi_awqos    ( m_axi_awqos   ),
        .m_axi_awvalid  ( m_axi_awvalid ),
        .m_axi_awready  ( m_axi_awready ),
        .m_axi_wdata    ( m_axi_wdata   ),
        .m_axi_wstrb    ( m_axi_wstrb   ),
        .m_axi_wlast    ( m_axi_wlast   ),
        .m_axi_wvalid   ( m_axi_wvalid  ),
        .m_axi_wready   ( m_axi_wready  ),
        // .m_axi_bid      ( m_axi_bid     ),
        .m_axi_bresp    ( m_axi_bresp   ),
        .m_axi_bvalid   ( m_axi_bvalid  ),
        .m_axi_bready   ( m_axi_bready  ),
        // .m_axi_arid     ( m_axi_arid    ),
        .m_axi_araddr   ( m_axi_araddr  ),
        .m_axi_arlen    ( m_axi_arlen   ),
        .m_axi_arsize   ( m_axi_arsize  ),
        .m_axi_arburst  ( m_axi_arburst ),
        .m_axi_arlock   ( m_axi_arlock  ),
        .m_axi_arcache  ( m_axi_arcache ),
        .m_axi_arprot   ( m_axi_arprot  ),
        .m_axi_arqos    ( m_axi_arqos   ),
        .m_axi_arvalid  ( m_axi_arvalid ),
        .m_axi_arready  ( m_axi_arready ),
        // .m_axi_rid      ( m_axi_rid     ),
        .m_axi_rdata    ( m_axi_rdata   ),
        .m_axi_rresp    ( m_axi_rresp   ),
        .m_axi_rlast    ( m_axi_rlast   ),
        .m_axi_rvalid   ( m_axi_rvalid  ),
        .m_axi_rready   ( m_axi_rready  ) 
    );

`elsif  EMBEDDED
    // EMBEDDED
    
    assign sys_resetn_o = ~sys_reset_i;
    assign m_axi_awregion = '0;
    assign m_axi_arregion = '0;
    // PLL

    xlnx_clk_wiz clkwiz_u (
        .clk_in1  ( sys_clock_i  ),
        .resetn   ( sys_resetn_o ),
        .locked   ( ),
        .clk_100  ( ),
        .clk_50   ( ),
        .clk_20   ( soc_clk_o ),
        .clk_10   (  )
    );

    // JTAG2AXI Master

    xlnx_jtag_axi jtag_axi_u (
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
