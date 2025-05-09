// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl


// Import headers
`include "uninasoc_mem.svh"
`include "uninasoc_axi.svh"

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////
    parameter int unsigned DATA_WIDTH       = 32,
    parameter int unsigned RV_PIC_TOTAL_INT = 8

) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////

    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        dbg_rst_li,

    // IRQ Interface
    logic                       nmi_int_i,
    logic [31:1]                nmi_vec_i,
    logic                       timer_int_i,
    logic [RV_PIC_TOTAL_INT:1]  extintsrc_req_i,

    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI Master Array
    `DEFINE_AXI_MASTER_PORTS(instr),
    `DEFINE_AXI_MASTER_PORTS(data),
    `DEFINE_AXI_MASTER_PORTS(dbg),
    `DEFINE_AXI_SLAVE_PORTS(dma)
);

    //////////////////
    // Declarations //
    //////////////////

    // DMI (bscan_tap_u -> Veer core)
    logic        dmi_reg_en;
    logic [ 6:0] dmi_reg_addr;
    logic        dmi_reg_wr_en;
    logic [31:0] dmi_reg_wdata;
    logic [31:0] dmi_reg_rdata;
    logic        dmi_hard_reset;

    // From common_deines.vh
    `define RV_DMA_BUS_TAG 1

    /////////////////
    // Assignments //
    /////////////////

    // IFU outputs
    // assign instr_axi_awvalid  = '0;
    // assign instr_axi_awid     = '0;
    // assign instr_axi_awaddr   = '0;
    // assign instr_axi_awregion = '0;
    // assign instr_axi_awlen    = '0;
    // assign instr_axi_awsize   = '0;
    // assign instr_axi_awburst  = '0;
    // assign instr_axi_awlock   = '0;
    // assign instr_axi_awcache  = '0;
    // assign instr_axi_awprot   = '0;
    // assign instr_axi_awqos    = '0;
    // assign instr_axi_wvalid   = '0;
    // assign instr_axi_wdata    = '0;
    // assign instr_axi_wstrb    = '0;
    // assign instr_axi_wlast    = '0;
    // assign instr_axi_bready   = '1;

    /////////////////
    // Sub-modules //
    /////////////////

    // BSCAN DMI TAP
    // (* keep_hierarchy = "TRUE" *)  // DEBUG
    bscan_tap bscan_tap_u (
        .clk            (clk_i),
        .rst            (dbg_rst_l),
        .jtag_id        (31'd0),
        .dmi_reg_wdata  (dmi_reg_wdata),
        .dmi_reg_addr   (dmi_reg_addr),
        .dmi_reg_wr_en  (dmi_reg_wr_en),
        .dmi_reg_en     (dmi_reg_en),
        .dmi_reg_rdata  (dmi_reg_rdata),
        .dmi_hard_reset (dmi_hard_reset),
        .rd_status      (2'd0),
        .idle           (3'd0),
        .dmi_stat       (2'd0),
        .version        (4'd1)
    );

    // Veer core wrapper
    // Unused
    logic address_ip;
    logic valid_ip;
    // veer_wrapper_dmi rvtop_u (
    // (* keep_hierarchy = "TRUE" *)  // DEBUG
    veer_wrapper_dmi veer_wrapper_dmi_u (
        // Clock and resets
        .clk            (clk_i),
        .rst_l          (rst_ni),
        .dbg_rst_l      (dbg_rst_li),
        .rst_vec        (31'h40000000), // input logic [31:1]

        // NMI
        // .nmi_int        (nmi_int_i      ),  // input logic
        // .nmi_vec        (nmi_vec_i[31:1]), // input logic [31:1]
        // // Interrupts
        // .timer_int      (timer_int_i    ), // input logic
        // .extintsrc_req  (extintsrc_req_i), // input logic [`RV_PIC_TOTAL_INT:1]
        .nmi_int        ( '0 ), // input logic
        .nmi_vec        ( '0 ), // input logic [31:1]
        .timer_int      ( '0 ), // input logic
        .extintsrc_req  ( '0 ), // input logic [`RV_PIC_TOTAL_INT:1]

        // Trace
        .trace_rv_i_insn_ip      (), // output logic [63:0]
        .trace_rv_i_address_ip   (address_ip), // output logic [63:0]
        .trace_rv_i_valid_ip     (valid_ip), // output logic [2:0]
        .trace_rv_i_exception_ip (), // output logic [2:0]
        .trace_rv_i_ecause_ip    (), // output logic [4:0]
        .trace_rv_i_interrupt_ip (), // output logic [2:0]
        .trace_rv_i_tval_ip      (), // output logic [31:0]

        // Bus signals
        //-------------------------- LSU AXI signals--------------------------
        .lsu_axi_awvalid  (data_axi_awvalid),
        .lsu_axi_awready  (data_axi_awready),
        .lsu_axi_awid     (data_axi_awid    ),
        .lsu_axi_awaddr   (data_axi_awaddr ),
        .lsu_axi_awregion (data_axi_awregion),
        .lsu_axi_awlen    (data_axi_awlen  ),
        .lsu_axi_awsize   (data_axi_awsize ),
        .lsu_axi_awburst  (data_axi_awburst),
        .lsu_axi_awlock   (data_axi_awlock ),
        .lsu_axi_awcache  (data_axi_awcache),
        .lsu_axi_awprot   (data_axi_awprot ),
        .lsu_axi_awqos    (data_axi_awqos  ),

        .lsu_axi_wvalid   (data_axi_wvalid),
        .lsu_axi_wready   (data_axi_wready),
        .lsu_axi_wdata    (data_axi_wdata),
        .lsu_axi_wstrb    (data_axi_wstrb),
        .lsu_axi_wlast    (data_axi_wlast),

        .lsu_axi_bvalid   (data_axi_bvalid),
        .lsu_axi_bready   (data_axi_bready),
        .lsu_axi_bresp    (data_axi_bresp ),
        .lsu_axi_bid      (data_axi_bid    ),

        .lsu_axi_arvalid  (data_axi_arvalid ),
        .lsu_axi_arready  (data_axi_arready ),
        .lsu_axi_arid     (data_axi_arid    ),
        .lsu_axi_araddr   (data_axi_araddr  ),
        .lsu_axi_arregion (data_axi_arregion),
        .lsu_axi_arlen    (data_axi_arlen   ),
        .lsu_axi_arsize   (data_axi_arsize  ),
        .lsu_axi_arburst  (data_axi_arburst ),
        .lsu_axi_arlock   (data_axi_arlock  ),
        .lsu_axi_arcache  (data_axi_arcache ),
        .lsu_axi_arprot   (data_axi_arprot  ),
        .lsu_axi_arqos    (data_axi_arqos   ),

        .lsu_axi_rvalid   (data_axi_rvalid),
        .lsu_axi_rready   (data_axi_rready),
        .lsu_axi_rid      (data_axi_rid    ),
        .lsu_axi_rdata    (data_axi_rdata ),
        .lsu_axi_rresp    (data_axi_rresp ),
        .lsu_axi_rlast    (data_axi_rlast ),

        //-------------------------- IFU AXI signals--------------------------
        // .ifu_axi_awvalid  (),
        // .ifu_axi_awready  (1'b0),
        // .ifu_axi_awid     (),
        // .ifu_axi_awaddr   (),
        // .ifu_axi_awregion (),
        // .ifu_axi_awlen    (),
        // .ifu_axi_awsize   (),
        // .ifu_axi_awburst  (),
        // .ifu_axi_awlock   (),
        // .ifu_axi_awcache  (),
        // .ifu_axi_awprot   (),
        // .ifu_axi_awqos    (),

        // .ifu_axi_wvalid   (),
        // .ifu_axi_wready   (1'b0),
        // .ifu_axi_wdata    (),
        // .ifu_axi_wstrb    (),
        // .ifu_axi_wlast    (),

        // .ifu_axi_bvalid   (1'b0),
        // .ifu_axi_bready   (),
        // .ifu_axi_bresp    (2'b00),
        // .ifu_axi_bid      (3'd0),

        .ifu_axi_awvalid  ( instr_axi_awvalid  ),
        .ifu_axi_awready  ( instr_axi_awready  ),
        .ifu_axi_awid     ( instr_axi_awid     ),
        .ifu_axi_awaddr   ( instr_axi_awaddr   ),
        .ifu_axi_awregion ( instr_axi_awregion ),
        .ifu_axi_awlen    ( instr_axi_awlen    ),
        .ifu_axi_awsize   ( instr_axi_awsize   ),
        .ifu_axi_awburst  ( instr_axi_awburst  ),
        .ifu_axi_awlock   ( instr_axi_awlock   ),
        .ifu_axi_awcache  ( instr_axi_awcache  ),
        .ifu_axi_awprot   ( instr_axi_awprot   ),
        .ifu_axi_awqos    ( instr_axi_awqos    ),
        .ifu_axi_wvalid   ( instr_axi_wvalid   ),
        .ifu_axi_wready   ( instr_axi_wready   ),
        .ifu_axi_wdata    ( instr_axi_wdata    ),
        .ifu_axi_wstrb    ( instr_axi_wstrb    ),
        .ifu_axi_wlast    ( instr_axi_wlast    ),
        .ifu_axi_bvalid   ( instr_axi_bvalid   ),
        .ifu_axi_bready   ( instr_axi_bready   ),
        .ifu_axi_bresp    ( instr_axi_bresp    ),
        .ifu_axi_bid      ( instr_axi_bid      ),

        .ifu_axi_arvalid  (instr_axi_arvalid ),
        .ifu_axi_arready  (instr_axi_arready ),
        .ifu_axi_arid     (instr_axi_arid    ),
        .ifu_axi_araddr   (instr_axi_araddr  ),
        .ifu_axi_arregion (instr_axi_arregion),
        .ifu_axi_arlen    (instr_axi_arlen   ),
        .ifu_axi_arsize   (instr_axi_arsize  ),
        .ifu_axi_arburst  (instr_axi_arburst ),
        .ifu_axi_arlock   (instr_axi_arlock  ),
        .ifu_axi_arcache  (instr_axi_arcache ),
        .ifu_axi_arprot   (instr_axi_arprot  ),
        .ifu_axi_arqos    (instr_axi_arqos   ),

        .ifu_axi_rvalid   (instr_axi_rvalid),
        .ifu_axi_rready   (instr_axi_rready),
        .ifu_axi_rid      (instr_axi_rid   ),
        .ifu_axi_rdata    (instr_axi_rdata ),
        .ifu_axi_rresp    (instr_axi_rresp ),
        .ifu_axi_rlast    (instr_axi_rlast ),

        //-------------------------- SB AXI signals-------------------------
        .sb_axi_awvalid  (dbg_axi_awvalid ),
        .sb_axi_awready  (dbg_axi_awready ),
        .sb_axi_awid     (dbg_axi_awid    ),
        .sb_axi_awaddr   (dbg_axi_awaddr  ),
        .sb_axi_awregion (dbg_axi_awregion),
        .sb_axi_awlen    (dbg_axi_awlen   ),
        .sb_axi_awsize   (dbg_axi_awsize  ),
        .sb_axi_awburst  (dbg_axi_awburst ),
        .sb_axi_awlock   (dbg_axi_awlock  ),
        .sb_axi_awcache  (dbg_axi_awcache ),
        .sb_axi_awprot   (dbg_axi_awprot  ),
        .sb_axi_awqos    (dbg_axi_awqos   ),
        .sb_axi_wvalid   (dbg_axi_wvalid  ),
        .sb_axi_wready   (dbg_axi_wready  ),
        .sb_axi_wdata    (dbg_axi_wdata   ),
        .sb_axi_wstrb    (dbg_axi_wstrb   ),
        .sb_axi_wlast    (dbg_axi_wlast   ),
        .sb_axi_bvalid   (dbg_axi_bvalid  ),
        .sb_axi_bready   (dbg_axi_bready  ),
        .sb_axi_bresp    (dbg_axi_bresp   ),
        .sb_axi_bid      (dbg_axi_bid     ),
        .sb_axi_arvalid  (dbg_axi_arvalid ),
        .sb_axi_arready  (dbg_axi_arready ),
        .sb_axi_arid     (dbg_axi_arid    ),
        .sb_axi_araddr   (dbg_axi_araddr  ),
        .sb_axi_arregion (dbg_axi_arregion),
        .sb_axi_arlen    (dbg_axi_arlen   ),
        .sb_axi_arsize   (dbg_axi_arsize  ),
        .sb_axi_arburst  (dbg_axi_arburst ),
        .sb_axi_arlock   (dbg_axi_arlock  ),
        .sb_axi_arcache  (dbg_axi_arcache ),
        .sb_axi_arprot   (dbg_axi_arprot  ),
        .sb_axi_arqos    (dbg_axi_arqos   ),
        .sb_axi_rvalid   (dbg_axi_rvalid  ),
        .sb_axi_rready   (dbg_axi_rready  ),
        .sb_axi_rid      (dbg_axi_rid     ),
        .sb_axi_rdata    (dbg_axi_rdata   ),
        .sb_axi_rresp    (dbg_axi_rresp   ),
        .sb_axi_rlast    (dbg_axi_rlast   ),

        //-------------------------- DMA AXI signals--------------------------
        // .dma_axi_awvalid  (1'b0),
        // .dma_axi_awready  (),
        // .dma_axi_awid     (`RV_DMA_BUS_TAG'd0),
        // .dma_axi_awaddr   (32'd0),
        // .dma_axi_awsize   (3'd0),
        // .dma_axi_awprot   (3'd0),
        // .dma_axi_awlen    (8'd0),
        // .dma_axi_awburst  (2'd0),

        // .dma_axi_wvalid   (1'b0),
        // .dma_axi_wready   (),
        // .dma_axi_wdata    (64'd0),
        // .dma_axi_wstrb    (8'd0),
        // .dma_axi_wlast    (1'b0),

        // .dma_axi_bvalid   (),
        // .dma_axi_bready   (1'b0),
        // .dma_axi_bresp    (),
        // .dma_axi_bid      (),

        // .dma_axi_arvalid  (1'b0),
        // .dma_axi_arready  (),
        // .dma_axi_arid     (`RV_DMA_BUS_TAG'd0),
        // .dma_axi_araddr   (32'd0),
        // .dma_axi_arsize   (3'd0),
        // .dma_axi_arprot   (3'd0),
        // .dma_axi_arlen    (8'd0),
        // .dma_axi_arburst  (2'd0),

        // .dma_axi_rvalid   (),
        // .dma_axi_rready   (1'b0),
        // .dma_axi_rid      (),
        // .dma_axi_rdata    (),
        // .dma_axi_rresp    (),
        // .dma_axi_rlast    (),

        .dma_axi_awvalid  ( dma_axi_awvalid  ),
        .dma_axi_awready  ( dma_axi_awready  ),
        .dma_axi_awid     ( dma_axi_awid     ),
        .dma_axi_awaddr   ( dma_axi_awaddr   ),
        .dma_axi_awsize   ( dma_axi_awsize   ),
        .dma_axi_awprot   ( dma_axi_awprot   ),
        .dma_axi_awlen    ( dma_axi_awlen    ),
        .dma_axi_awburst  ( dma_axi_awburst  ),
        .dma_axi_wvalid   ( dma_axi_wvalid   ),
        .dma_axi_wready   ( dma_axi_wready   ),
        .dma_axi_wdata    ( dma_axi_wdata    ),
        .dma_axi_wstrb    ( dma_axi_wstrb    ),
        .dma_axi_wlast    ( dma_axi_wlast    ),
        .dma_axi_bvalid   ( dma_axi_bvalid   ),
        .dma_axi_bready   ( dma_axi_bready   ),
        .dma_axi_bresp    ( dma_axi_bresp    ),
        .dma_axi_bid      ( dma_axi_bid      ),
        .dma_axi_arvalid  ( dma_axi_arvalid  ),
        .dma_axi_arready  ( dma_axi_arready  ),
        .dma_axi_arid     ( dma_axi_arid     ),
        .dma_axi_araddr   ( dma_axi_araddr   ),
        .dma_axi_arsize   ( dma_axi_arsize   ),
        .dma_axi_arprot   ( dma_axi_arprot   ),
        .dma_axi_arlen    ( dma_axi_arlen    ),
        .dma_axi_arburst  ( dma_axi_arburst  ),
        .dma_axi_rvalid   ( dma_axi_rvalid   ),
        .dma_axi_rready   ( dma_axi_rready   ),
        .dma_axi_rid      ( dma_axi_rid      ),
        .dma_axi_rdata    ( dma_axi_rdata    ),
        .dma_axi_rresp    ( dma_axi_rresp    ),
        .dma_axi_rlast    ( dma_axi_rlast    ),

        //---------------------------------------------------------
        // clk ratio signals
        .lsu_bus_clk_en (1'b1),
        .ifu_bus_clk_en (1'b1),
        .dbg_bus_clk_en (1'b1),
        .dma_bus_clk_en (1'b1),

        .dec_tlu_perfcnt0 (),
        .dec_tlu_perfcnt1 (),
        .dec_tlu_perfcnt2 (),
        .dec_tlu_perfcnt3 (),

        // DMI
        .dmi_reg_rdata    (dmi_reg_rdata),
        .dmi_reg_wdata    (dmi_reg_wdata),
        .dmi_reg_addr     (dmi_reg_addr),
        .dmi_reg_en       (dmi_reg_en),
        .dmi_reg_wr_en    (dmi_reg_wr_en),
        .dmi_hard_reset   (dmi_hard_reset),

        // Sunk interfaces
        .mpc_debug_halt_req (1'b0),
        .mpc_debug_run_req  (1'b0),
        .mpc_reset_run_req  (1'b1),
        .mpc_debug_halt_ack (),
        .mpc_debug_run_ack  (),
        .debug_brkpt_status (),

        .i_cpu_halt_req      (1'b0),
        .o_cpu_halt_ack      (),
        .o_cpu_halt_status   (),
        .o_debug_mode_status (),
        .i_cpu_run_req       (1'b0),
        .o_cpu_run_ack       (),

        .scan_mode  (1'b0),
        .mbist_mode (1'b0)
    );



endmodule : custom_top_wrapper


