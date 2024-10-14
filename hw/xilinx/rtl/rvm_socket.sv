
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Wrapper module for a RVM core


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"

module rvm_socket # (
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_IRQ    = 3
) (
    input  logic                            clk_i,
    input  logic                            rst_ni,
    input  logic [AXI_ADDR_WIDTH -1 : 0 ]   bootaddr_i,
    input  logic [NUM_IRQ        -1 : 0 ]   irq_i,
    /* 
    // Dual-port AXI Master Interface                       
    output  axi_id_t     [1:0]  m_axi_awid,       // Write address ID
    output  axi_addr_t   [1:0]  m_axi_awaddr,     // Write address
    output  axi_len_t    [1:0]  m_axi_awlen,      // Burst length (number of transfers)
    output  axi_size_t   [1:0]  m_axi_awsize,     // Burst size (number of bytes per transfer)
    output  axi_burst_t  [1:0]  m_axi_awburst,    // Burst type
    output  axi_lock_t   [1:0]  m_axi_awlock,     // Lock type
    output  axi_cache_t  [1:0]  m_axi_awcache,    // Cache type
    output  axi_prot_t   [1:0]  m_axi_awprot,     // Protection type
    output  axi_qos_t    [1:0]  m_axi_awqos,      // Quality of service
    output  axi_region_t [1:0]  m_axi_awregion,   // Region identifier
    output  axi_valid_t  [1:0]  m_axi_awvalid,    // Write address valid
    input   axi_ready_t  [1:0]  m_axi_awready,    // Write address ready
    
    output  axi_data_t   [1:0]  m_axi_wdata,      // Write data
    output  axi_strb_t   [1:0]  m_axi_wstrb,      // Write strobe (which byte lanes are valid)
    output  axi_last_t   [1:0]  m_axi_wlast,      // Write last (last transfer in burst)
    output  axi_valid_t  [1:0]  m_axi_wvalid,     // Write data valid
    input   axi_ready_t  [1:0]  m_axi_wready,     // Write data ready
    
    input   axi_id_t     [1:0]  m_axi_bid,        // Response ID
    input   axi_resp_t   [1:0]  m_axi_bresp,      // Write response (OKAY, SLVERR, etc.)
    input   axi_valid_t  [1:0]  m_axi_bvalid,     // Write response valid
    output  axi_ready_t  [1:0]  m_axi_bready,     // Write response ready

    output  axi_addr_t   [1:0]  m_axi_araddr,     // Read address
    output  axi_len_t    [1:0]  m_axi_arlen,      // Burst length (number of transfers)
    output  axi_size_t   [1:0]  m_axi_arsize,     // Burst size (number of bytes per transfer)
    output  axi_burst_t  [1:0]  m_axi_arburst,    // Burst type
    output  axi_lock_t   [1:0]  m_axi_arlock,     // Lock type
    output  axi_cache_t  [1:0]  m_axi_arcache,    // Cache type
    output  axi_prot_t   [1:0]  m_axi_arprot,     // Protection type
    output  axi_qos_t    [1:0]  m_axi_arqos,      // Quality of service
    output  axi_region_t [1:0]  m_axi_arregion,   // Region identifier
    output  axi_valid_t  [1:0]  m_axi_arvalid,    // Read address valid
    input   axi_ready_t  [1:0]  m_axi_arready,    // Read address ready
    input   axi_id_t     [1:0]  m_axi_arid,       // Read ID
    
    input   axi_id_t     [1:0]  m_axi_rid,        // Read ID
    input   axi_data_t   [1:0]  m_axi_rdata,      // Read data
    input   axi_resp_t   [1:0]  m_axi_rresp,      // Read response
    input   axi_last_t   [1:0]  m_axi_rlast,      // Read last (last transfer in burst)
    input   axi_valid_t  [1:0]  m_axi_rvalid,     // Read data valid
    output  axi_ready_t  [1:0]  m_axi_rready      // Read data ready
    */

    `DEFINE_AXI_MASTER_PORTS(rvm_socket_instr),
    `DEFINE_AXI_MASTER_PORTS(rvm_socket_data)
);

  // Declare AXI interfaces for instruction memory port and data memory port
  `DECLARE_AXI_BUS(core_instr_to_socket_instr, DATA_WIDTH);
  `DECLARE_AXI_BUS(core_data_to_socket_data, DATA_WIDTH);

  // Connect memory interfaces to socket output memory ports
  `ASSIGN_AXI_BUS(rvm_socket_instr, core_instr_to_socket_instr);
  `ASSIGN_AXI_BUS(rvm_socket_data, core_data_to_socket_data);

  // Mem signals
  logic         mem_instr_req;
	logic         mem_instr_gnt;
  logic         mem_instr_valid;
  logic [31:0]  mem_instr_addr;
	logic [31:0]  mem_instr_rdata;
  logic         mem_instr_error;
	logic         mem_data_req;
	logic         mem_data_gnt;
  logic         mem_data_valid;
  logic [31:0]  mem_data_addr;
	logic [31:0]  mem_data_rdata;
	logic [31:0]  mem_data_wdata;
	logic [ 3:0]  mem_data_be;
  logic         mem_data_we;
  logic         mem_data_error;

  logic [31:0]  mem_instr_end_rdata;
  logic [31:0]  mem_data_end_rdata;
  logic [31:0]  mem_data_end_wdata;
  logic [3:0]   mem_data_end_be;

	////////////////////////////////////////////////////
	//     ___               ___          _          	//
	//    / __|___ _ _ ___  | _ \___ __ _(_)___ _ _  	//
	//   | (__/ _ \ '_/ -_) |   / -_) _` | / _ \ ' \ 	//
	//    \___\___/_| \___| |_|_\___\__, |_\___/_||_|	//
	//                              |___/            	//
	////////////////////////////////////////////////////

  //////////////////////////
  //      PicoRV32        //
  //////////////////////////

  ///////////////////////////////////////////////////////////////////////////
  //  Pico has a custom interrupt handling mechanisms. I am not sure if    //
  //  it is just an alternative to standard risc-v interrupt handling,     //
  //  or if it is incompatible. Therefore, beware of it and use Pico       //
  //  only for interrupt-less applications.                                //
  ///////////////////////////////////////////////////////////////////////////


	cip_picorv32 picorv32_core (
		.clk_i      	      (clk_i ),
		.rst_ni   	        (rst_ni),
		.trap_o     	      (),

    .mem_instr_req_o    (mem_instr_req),
    .mem_instr_gnt_i    (mem_instr_gnt),
    .mem_instr_valid_i  (mem_instr_valid),
    .mem_instr_addr_o   (mem_instr_addr),
    .mem_instr_rdata_i  (mem_instr_end_rdata),
    .mem_instr_error_i  (mem_instr_error),    // UNUSED IN THIS CORE

    .mem_data_req_o     (mem_data_req),
    .mem_data_gnt_i     (mem_data_gnt),
    .mem_data_valid_i   (mem_data_valid),
    .mem_data_addr_o    (mem_data_addr),
    .mem_data_rdata_i   (mem_data_end_rdata),
    .mem_data_wdata_o   (mem_data_wdata),
    .mem_data_be_o      (mem_data_be),
    .mem_data_we_o      (mem_data_we),
    .mem_data_error_i   (mem_data_error),     // UNUSED IN THIS CORE

		.irq_i		          (irq_i),

    `ifdef RISCV_FORMAL
		.rvfi_valid    (),
		.rvfi_order    (),
		.rvfi_insn     (),
		.rvfi_trap     (),
		.rvfi_halt     (),
		.rvfi_intr     (),
		.rvfi_rs1_addr (),
		.rvfi_rs2_addr (),
		.rvfi_rs1_rdata(),
		.rvfi_rs2_rdata(),
		.rvfi_rd_addr  (),
		.rvfi_rd_wdata (),
		.rvfi_pc_rdata (),
		.rvfi_pc_wdata (),
		.rvfi_mem_addr (),
		.rvfi_mem_rmask(),
		.rvfi_mem_wmask(),
		.rvfi_mem_rdata(),
		.rvfi_mem_wdata(),
    `endif

		.trace_valid_o  (), // Unmapped atm
		.trace_data_o   ()  // Unmapped atm
    );

  // Adapt Data endianess from mem to AXI
  assign mem_data_end_rdata =   {mem_data_rdata[7:0], mem_data_rdata[15:8], mem_data_rdata[23:16], mem_data_rdata[31:24]};
  assign mem_data_end_wdata =   {mem_data_wdata[7:0], mem_data_wdata[15:8], mem_data_wdata[23:16], mem_data_wdata[31:24]};
  assign mem_instr_end_rdata =  {mem_instr_rdata[7:0], mem_instr_rdata[15:8], mem_instr_rdata[23:16], mem_instr_rdata[31:24]};
  assign mem_data_end_be =      {mem_data_be[0], mem_data_be[1], mem_data_be[2], mem_data_be[3]};

  // MEM to AXI-Full converter: Instruction Port
	cip_axi_from_mem /*#(
    .MEM_ADDR_WIDTH		(ADDR_WIDTH),
    .MEM_DATA_WIDTH		(DATA_WIDTH),
    .AXI_DATA_WIDTH		(AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH		(AXI_ADDR_WIDTH),
    .AXI_STRB_WIDTH		(AXI_STRB_WIDTH),
    .AXI_ID_WIDTH		  (AXI_ID_WIDTH),
    .AXI_REGION_WIDTH	(AXI_REGION_WIDTH),
    .AXI_LEN_WIDTH		(AXI_LEN_WIDTH),
    .AXI_SIZE_WIDTH		(AXI_SIZE_WIDTH),
    .AXI_BURST_WIDTH	(AXI_BURST_WIDTH),
    .AXI_LOCK_WIDTH		(AXI_LOCK_WIDTH),
    .AXI_CACHE_WIDTH	(AXI_CACHE_WIDTH),
    .AXI_PROT_WIDTH		(AXI_PROT_WIDTH),
    .AXI_QOS_WIDTH		(AXI_QOS_WIDTH),
    .AXI_VALID_WIDTH	(AXI_VALID_WIDTH),
    .AXI_READY_WIDTH	(AXI_READY_WIDTH),
    .AXI_LAST_WIDTH		(AXI_LAST_WIDTH),
    .AXI_RESP_WIDTH		(AXI_RESP_WIDTH)
	)*/ axi_from_mem_instr_u (
		// AXI side
    .m_axi_awid			(core_instr_to_socket_instr_axi_awid),
    .m_axi_awaddr		(core_instr_to_socket_instr_axi_awaddr),
    .m_axi_awlen		(core_instr_to_socket_instr_axi_awlen),
    .m_axi_awsize		(core_instr_to_socket_instr_axi_awsize),
    .m_axi_awburst	(core_instr_to_socket_instr_axi_awburst),
    .m_axi_awlock		(core_instr_to_socket_instr_axi_awlock),
    .m_axi_awcache	(core_instr_to_socket_instr_axi_awcache),
    .m_axi_awprot		(core_instr_to_socket_instr_axi_awprot),
    .m_axi_awqos		(core_instr_to_socket_instr_axi_awqos),
    .m_axi_awregion (core_instr_to_socket_instr_axi_awregion),
    .m_axi_awvalid  (core_instr_to_socket_instr_axi_awvalid),
    .m_axi_awready  (core_instr_to_socket_instr_axi_awready),
    .m_axi_wdata		(core_instr_to_socket_instr_axi_wdata),
    .m_axi_wstrb		(core_instr_to_socket_instr_axi_wstrb),
    .m_axi_wlast		(core_instr_to_socket_instr_axi_wlast),
    .m_axi_wvalid		(core_instr_to_socket_instr_axi_wvalid),
    .m_axi_wready		(core_instr_to_socket_instr_axi_wready),
    .m_axi_bid			(core_instr_to_socket_instr_axi_bid),
    .m_axi_bresp		(core_instr_to_socket_instr_axi_bresp),
    .m_axi_bvalid		(core_instr_to_socket_instr_axi_bvalid),
    .m_axi_bready		(core_instr_to_socket_instr_axi_bready),
    .m_axi_araddr		(core_instr_to_socket_instr_axi_araddr),
    .m_axi_arlen		(core_instr_to_socket_instr_axi_arlen),
    .m_axi_arsize		(core_instr_to_socket_instr_axi_arsize),
    .m_axi_arburst	(core_instr_to_socket_instr_axi_arburst),
    .m_axi_arlock		(core_instr_to_socket_instr_axi_arlock),
    .m_axi_arcache	(core_instr_to_socket_instr_axi_arcache),
    .m_axi_arprot		(core_instr_to_socket_instr_axi_arprot),
    .m_axi_arqos		(core_instr_to_socket_instr_axi_arqos),
    .m_axi_arregion	(core_instr_to_socket_instr_axi_arregion),
    .m_axi_arvalid	(core_instr_to_socket_instr_axi_arvalid),
    .m_axi_arready	(core_instr_to_socket_instr_axi_arready),
    .m_axi_arid			(core_instr_to_socket_instr_axi_arid),
    .m_axi_rid			(core_instr_to_socket_instr_axi_rid),
    .m_axi_rdata		(core_instr_to_socket_instr_axi_rdata),
    .m_axi_rresp		(core_instr_to_socket_instr_axi_rresp),
    .m_axi_rlast		(core_instr_to_socket_instr_axi_rlast),
    .m_axi_rvalid		(core_instr_to_socket_instr_axi_rvalid),
    .m_axi_rready		(core_instr_to_socket_instr_axi_rready),

		// MEM side
    .clk_i				    (clk_i),
    .rst_ni				    (rst_ni),
    .mem_req_i			  (mem_instr_req),
    .mem_addr_i			  (mem_instr_addr),
    .mem_we_i			    ('0),	// RO Interface
    .mem_wdata_i		  ('0),	// RO Interface
    .mem_be_i			    ('0),	// RO Interface
    .mem_gnt_o			  (mem_instr_gnt),		
    .mem_rsp_valid_o	(mem_instr_valid),
    .mem_rsp_rdata_o	(mem_instr_rdata),
    .mem_rsp_error_o	(mem_instr_error)		
    );

	// MEM to AXI-Full converter: Data Port
	cip_axi_from_mem /*#(
        .MEM_ADDR_WIDTH		(ADDR_WIDTH),
        .MEM_DATA_WIDTH		(DATA_WIDTH),
        .AXI_DATA_WIDTH		(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH		(AXI_ADDR_WIDTH),
        .AXI_STRB_WIDTH		(AXI_STRB_WIDTH),
        .AXI_ID_WIDTH		  (AXI_ID_WIDTH),
        .AXI_REGION_WIDTH	(AXI_REGION_WIDTH),
        .AXI_LEN_WIDTH		(AXI_LEN_WIDTH),
        .AXI_SIZE_WIDTH		(AXI_SIZE_WIDTH),
        .AXI_BURST_WIDTH	(AXI_BURST_WIDTH),
        .AXI_LOCK_WIDTH		(AXI_LOCK_WIDTH),
        .AXI_CACHE_WIDTH	(AXI_CACHE_WIDTH),
        .AXI_PROT_WIDTH		(AXI_PROT_WIDTH),
        .AXI_QOS_WIDTH		(AXI_QOS_WIDTH),
        .AXI_VALID_WIDTH	(AXI_VALID_WIDTH),
        .AXI_READY_WIDTH	(AXI_READY_WIDTH),
        .AXI_LAST_WIDTH		(AXI_LAST_WIDTH),
        .AXI_RESP_WIDTH		(AXI_RESP_WIDTH)
	)*/ axi_from_mem_data_u (
		// AXI side
        .m_axi_awid			(core_data_to_socket_data_axi_awid),
        .m_axi_awaddr		(core_data_to_socket_data_axi_awaddr),
        .m_axi_awlen		(core_data_to_socket_data_axi_awlen),
        .m_axi_awsize		(core_data_to_socket_data_axi_awsize),
        .m_axi_awburst	(core_data_to_socket_data_axi_awburst),
        .m_axi_awlock		(core_data_to_socket_data_axi_awlock),
        .m_axi_awcache	(core_data_to_socket_data_axi_awcache),
        .m_axi_awprot		(core_data_to_socket_data_axi_awprot),
        .m_axi_awqos		(core_data_to_socket_data_axi_awqos),
        .m_axi_awregion	(core_data_to_socket_data_axi_awregion),
        .m_axi_awvalid	(core_data_to_socket_data_axi_awvalid),
        .m_axi_awready	(core_data_to_socket_data_axi_awready),
        .m_axi_wdata		(core_data_to_socket_data_axi_wdata),
        .m_axi_wstrb		(core_data_to_socket_data_axi_wstrb),
        .m_axi_wlast		(core_data_to_socket_data_axi_wlast),
        .m_axi_wvalid		(core_data_to_socket_data_axi_wvalid),
        .m_axi_wready		(core_data_to_socket_data_axi_wready),
        .m_axi_bid			(core_data_to_socket_data_axi_bid),
        .m_axi_bresp		(core_data_to_socket_data_axi_bresp),
        .m_axi_bvalid		(core_data_to_socket_data_axi_bvalid),
        .m_axi_bready		(core_data_to_socket_data_axi_bready),
        .m_axi_araddr		(core_data_to_socket_data_axi_araddr),
        .m_axi_arlen		(core_data_to_socket_data_axi_arlen),
        .m_axi_arsize		(core_data_to_socket_data_axi_arsize),
        .m_axi_arburst	(core_data_to_socket_data_axi_arburst),
        .m_axi_arlock		(core_data_to_socket_data_axi_arlock),
        .m_axi_arcache	(core_data_to_socket_data_axi_arcache),
        .m_axi_arprot		(core_data_to_socket_data_axi_arprot),
        .m_axi_arqos		(core_data_to_socket_data_axi_arqos),
        .m_axi_arregion	(core_data_to_socket_data_axi_arregion),
        .m_axi_arvalid	(core_data_to_socket_data_axi_arvalid),
        .m_axi_arready	(core_data_to_socket_data_axi_arready),
        .m_axi_arid			(core_data_to_socket_data_axi_arid),
        .m_axi_rid			(core_data_to_socket_data_axi_rid),
        .m_axi_rdata		(core_data_to_socket_data_axi_rdata),
        .m_axi_rresp		(core_data_to_socket_data_axi_rresp),
        .m_axi_rlast		(core_data_to_socket_data_axi_rlast),
        .m_axi_rvalid		(core_data_to_socket_data_axi_rvalid),
        .m_axi_rready		(core_data_to_socket_data_axi_rready),

		// MEM side
        .clk_i				    (clk_i),
        .rst_ni				    (rst_ni),
        .mem_req_i		    (mem_data_req),
        .mem_addr_i		    (mem_data_addr),
        .mem_we_i			    (mem_data_we),
        .mem_wdata_i	    (mem_data_end_wdata),	
        .mem_be_i			    (mem_data_end_be),	
        .mem_gnt_o			  (mem_data_gnt),	
        .mem_rsp_valid_o  (mem_data_valid),
        .mem_rsp_rdata_o	(mem_data_rdata),
        .mem_rsp_error_o	(mem_data_error)
    );


endmodule : rvm_socket