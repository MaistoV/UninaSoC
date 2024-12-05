// Author: 
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the 
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl


// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"
`include "axi_typedef.svh" 
`include "reg_typedef.svh" 
`include "assertions.svh"  

import axi_pkg::*;

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////
    parameter int unsigned NumSrc = 32,
    parameter int unsigned NumTarget = 1, 
    
    parameter logic [NumSrc-1:0]    LevelEdgeTrig = '0, // 0: level, 1: edge
    parameter int SRCW    = $clog2(NumSrc),

    parameter int unsigned AxiAddrWidth     = 32,
    parameter int unsigned AxiDataWidth     = 32, 
    parameter int unsigned AxiIdWidth       = 2,
    parameter int unsigned AxiUserWidth     = 2,
    parameter int unsigned RegDataWidth     = 32,
    parameter bit          CutMemReqs       = 1'b0,     
    parameter bit          CutMemRsps       = 1'b0,     
    
    parameter AXI_DATA_WIDTH    = 32,
    parameter AXI_ADDR_WIDTH    = 32,
    parameter AXI_STRB_WIDTH    = AXI_ADDR_WIDTH / 8,
    parameter AXI_ID_WIDTH      = 2,
    parameter AXI_REGION_WIDTH  = 4,
    parameter AXI_LEN_WIDTH     = 8,
    parameter AXI_SIZE_WIDTH    = 3,
    parameter AXI_BURST_WIDTH   = 2,
    parameter AXI_LOCK_WIDTH    = 1,
    parameter AXI_CACHE_WIDTH   = 4,
    parameter AXI_PROT_WIDTH    = 3,
    parameter AXI_QOS_WIDTH     = 4,
    parameter AXI_VALID_WIDTH   = 1,
    parameter AXI_READY_WIDTH   = 1,
    parameter AXI_LAST_WIDTH    = 1,
    parameter AXI_RESP_WIDTH    = 2,

    parameter [31:0] PLIC_BASE_ADDR = 32'h4000000


) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////
    
    input  logic    clk_i,            
    input  logic    rst_ni,           
    
    // Interrupt Sources
    input  [NumSrc-1:0] intr_src_i,

    // Interrupt notification to targets
    output [NumTarget-1:0]          irq_o,
    output [SRCW-1:0]               irq_id_o[NumTarget],
    output logic [NumTarget-1:0]    msip_o,

    output logic [AXI_ADDR_WIDTH-1:0] req_addr_o ,
    output logic [AXI_ADDR_WIDTH-1:0] req_write_o,
    output logic [AXI_ADDR_WIDTH-1:0] req_wdata_o,
    output logic [AXI_ADDR_WIDTH-1:0] req_wstrb_o,
    output logic [AXI_ADDR_WIDTH-1:0] req_valid_o,
    output logic [AXI_ADDR_WIDTH-1:0] rsp_rdata_o,
    output logic [AXI_ADDR_WIDTH-1:0] rsp_error_o,
    output logic [AXI_ADDR_WIDTH-1:0] rsp_ready_o,
            
    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI Master Interface Array (Add here as many master as required)
    `DEFINE_AXI_SLAVE_PORTS(s) 
);

     // Define the req_t and resp_t type using axi_typedef.svh macro
    `AXI_TYPEDEF_ALL(
        axi,
        logic [AXI_ADDR_WIDTH-1:0],
        logic [AXI_ID_WIDTH-1:0],
        logic [AXI_DATA_WIDTH-1:0],
        logic [AXI_STRB_WIDTH-1:0],
        logic [0:0]  // This is for the user field, which is missing from our interface (or unused)
    )

    axi_req_t axi_req;
    axi_resp_t axi_rsp;
    
    // Define the req_t and resp_t type using reg_typedef.svh macro
    `REG_BUS_TYPEDEF_ALL(
        reg,
        logic [AXI_ADDR_WIDTH-1:0],
        logic [AXI_DATA_WIDTH-1:0],
        logic [AXI_STRB_WIDTH-1:0]
    )

    reg_req_t reg_req;
    reg_rsp_t reg_rsp;

    // Create the modified_addr signal (shifted and subtracted)
    logic [AXI_ADDR_WIDTH-1:0] modified_addr;

    // Compute modified_addr: shift left by 2 and subtract PLIC_BASE_ADDR, then assign it to the PLIC input addr
    assign modified_addr = (reg_req.addr - {PLIC_BASE_ADDR });
    reg_req_t reg_req_modified;

    assign reg_req_modified.addr   = modified_addr;
    assign reg_req_modified.write  = reg_req.write;
    assign reg_req_modified.wdata  = reg_req.wdata;
    assign reg_req_modified.wstrb  = reg_req.wstrb;
    assign reg_req_modified.valid  = reg_req.valid;

    rv_plic #(
    	.reg_req_t			(reg_req_t),
    	.reg_rsp_t			(reg_rsp_t),
    	.LevelEdgeTrig 		(LevelEdgeTrig)
    
    ) rv_plic_u (
    	// Clock and Reset
    	.clk_i				(clk_i),
    	.rst_ni				(rst_ni),
    	
    	.reg_req_i          (reg_req_modified),
    	.reg_rsp_o			(reg_rsp),
    	
    	// Interrupt Sources
    	.intr_src_i			(intr_src_i),
    	
    	// Interrupt notification to targets
    	.irq_o				(irq_o),
    	.irq_id_o			(irq_id_o),
    	.msip_o				(msip_o)
    	
    );

    axi_to_reg_v2 #(
        .AxiAddrWidth       ( AxiAddrWidth ),
        .AxiDataWidth       ( AxiDataWidth ),
        .AxiIdWidth         ( AxiIdWidth ),
        .AxiUserWidth       ( AxiUserWidth ),
        .RegDataWidth       ( RegDataWidth ) ,
        .CutMemReqs         ( CutMemReqs ) ,
        .CutMemRsps         ( CutMemRsps ) , 
        .axi_req_t          ( axi_req_t), 
        .axi_rsp_t          ( axi_resp_t),
        .reg_req_t          ( reg_req_t),
        .reg_rsp_t          ( reg_rsp_t),
        .id_t               ( logic[AxiIdWidth-1:0] )
    )axi_to_reg_v2_u (  
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .axi_req_i          (axi_req),
        .axi_rsp_o          (axi_rsp),
        .reg_req_o          (reg_req),
        .reg_rsp_i          (reg_rsp),
        .reg_id_o           ( ),
        .busy_o             ( )
    );


    // Map OUTPUT signals 
    assign   axi_req.aw.id        = s_axi_awid;
    assign   axi_req.aw.addr      = s_axi_awaddr;
    assign   axi_req.aw.len       = s_axi_awlen;
    assign   axi_req.aw.size      = s_axi_awsize;
    assign   axi_req.aw.burst     = s_axi_awburst;
    assign   axi_req.aw.lock      = s_axi_awlock;
    assign   axi_req.aw.cache     = s_axi_awcache;
    assign   axi_req.aw.prot      = s_axi_awprot;
    assign   axi_req.aw.qos       = s_axi_awqos;
    assign   axi_req.aw.region    = s_axi_awregion;
    assign   axi_req.aw_valid     = s_axi_awvalid; 
    assign   axi_req.w.data       = s_axi_wdata;
    assign   axi_req.w.strb       = s_axi_wstrb;
    assign   axi_req.w.last       = s_axi_wlast;
    assign   axi_req.w_valid      = s_axi_wvalid;
    assign   axi_req.b_ready      = s_axi_bready;
    assign   axi_req.ar.addr      = s_axi_araddr;
    assign   axi_req.ar.len       = s_axi_arlen;
    assign   axi_req.ar.size      = s_axi_arsize;
    assign   axi_req.ar.burst     = s_axi_arburst;
    assign   axi_req.ar.lock      = s_axi_arlock;
    assign   axi_req.ar.cache     = s_axi_arcache;
    assign   axi_req.ar.prot      = s_axi_arprot;
    assign   axi_req.ar.qos       = s_axi_arqos;
    assign   axi_req.ar.region    = s_axi_arregion;
    assign   axi_req.ar_valid     = s_axi_arvalid;
    assign   axi_req.r_ready      = s_axi_rready;
    assign   axi_req.ar.id        = s_axi_arid;
   
    assign   s_axi_awready        = axi_rsp.aw_ready;  
    assign   s_axi_wready         = axi_rsp.w_ready;    
    assign   s_axi_bid            = axi_rsp.b.id;        
    assign   s_axi_bresp          = axi_rsp.b.resp;      
    assign   s_axi_bvalid         = axi_rsp.b_valid;     
    assign   s_axi_arready        = axi_rsp.ar_ready;    
    assign   s_axi_rid            = axi_rsp.r.id;        
    assign   s_axi_rdata          = axi_rsp.r.data;      
    assign   s_axi_rresp          = axi_rsp.r.resp;      
    assign   s_axi_rlast          = axi_rsp.r.last;      
    assign   s_axi_rvalid         = axi_rsp.r_valid;

    assign  req_addr_o  = reg_req_modified.addr   ; 
    assign  req_write_o = reg_req_modified.write  ; 
    assign  req_wdata_o = reg_req_modified.wdata  ;  
    assign  req_wstrb_o = reg_req_modified.wstrb  ;  
    assign  req_valid_o = reg_req_modified.valid  ;  
    assign  rsp_rdata_o = reg_rsp.rdata  ; 
    assign  rsp_error_o = reg_rsp.error  ;
    assign  rsp_ready_o = reg_rsp.ready  ;

endmodule : custom_top_wrapper