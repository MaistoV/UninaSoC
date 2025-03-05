// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl


// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"
`include "typedef.svh"

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////

    // parameter LOCAL_MEM_ADDR_WIDTH    = 32,
    // parameter LOCAL_MEM_DATA_WIDTH    = 32,
    // parameter LOCAL_AXI_DATA_WIDTH    = 32,
    // parameter LOCAL_AXI_ADDR_WIDTH    = 32,
    // parameter LOCAL_AXI_STRB_WIDTH    = 4,
    // parameter LOCAL_AXI_ID_WIDTH      = 2,
    // parameter LOCAL_AXI_REGION_WIDTH  = 4,
    // parameter LOCAL_AXI_LEN_WIDTH     = 8,
    // parameter LOCAL_AXI_SIZE_WIDTH    = 3,
    // parameter LOCAL_AXI_BURST_WIDTH   = 2,
    // parameter LOCAL_AXI_LOCK_WIDTH    = 1,
    // parameter LOCAL_AXI_CACHE_WIDTH   = 4,
    // parameter LOCAL_AXI_PROT_WIDTH    = 3,
    // parameter LOCAL_AXI_QOS_WIDTH     = 4,
    // parameter LOCAL_AXI_VALID_WIDTH   = 1,
    // parameter LOCAL_AXI_READY_WIDTH   = 1,
    // parameter LOCAL_AXI_LAST_WIDTH    = 1,
    // parameter LOCAL_AXI_RESP_WIDTH    = 2

) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////

    input  logic    clk_i,
    input  logic    rst_ni,
    output logic    busy_o,

    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI4 Full slave interface
    `DEFINE_AXI_SLAVE_PORTS (s),
    // Mem master interface
    `DEFINE_MEM_MASTER_PORTS (m)
);

    // Define the axi_req_t and axi_resp_t type using typedef.svh macro
    `AXI_TYPEDEF_ALL(
        axi,
        logic [32-1:0],
        logic [2  -1:0],
        logic [32-1:0],
        logic [4-1:0],
        logic [0:0]  // This is for the user field, which is missing from our interface (or unused)
    )

    // AXI request/response structs
    axi_req_t  axi_req;
    axi_resp_t axi_rsp;

    // Modules parameters
    localparam int unsigned BufDepth   = 1;
    localparam bit          HideStrb   = 1'b0;
    localparam int unsigned OutFifoDepth = 1;
    // Unused ports
    logic m_mem_atop;

    // Instantiation of axi_to_mem module
    axi_to_mem #(
        .axi_req_t    ( axi_req_t      ),
        .axi_resp_t   ( axi_resp_t     ),
        .AddrWidth    ( 32 ),
        .DataWidth    ( 32 ),
        .IdWidth      ( 2   ),
        .NumBanks     ( 1              ),
        .BufDepth     ( BufDepth       ),
        .HideStrb     ( HideStrb       ),
        .OutFifoDepth ( OutFifoDepth   )
    ) axi_to_mem_u (
        // Clock and Reset
        .clk_i          ( clk_i        ),
        .rst_ni         ( rst_ni       ),
        .busy_o         ( busy_o       ),
        .axi_req_i      ( axi_req      ),
        .axi_resp_o     ( axi_rsp      ),
        .mem_req_o      ( m_mem_req    ),
        .mem_gnt_i      ( m_mem_gnt    ),
        .mem_addr_o     ( m_mem_addr   ),
        .mem_wdata_o    ( m_mem_wdata  ),
        .mem_strb_o     ( m_mem_be     ),
        .mem_atop_o     ( m_mem_atop   ), // Unused
        .mem_we_o       ( m_mem_we     ),
        .mem_rvalid_i   ( m_mem_valid  ),
        .mem_rdata_i    ( m_mem_rdata  )
    );

    // Unwrap axi_from_mem structured type

    // AXI request
    assign axi_req.aw.id        = s_axi_awid;
    assign axi_req.aw.addr      = s_axi_awaddr;
    assign axi_req.aw.len       = s_axi_awlen;
    assign axi_req.aw.size      = s_axi_awsize;
    assign axi_req.aw.burst     = s_axi_awburst;
    assign axi_req.aw.lock      = s_axi_awlock;
    assign axi_req.aw.cache     = s_axi_awcache;
    assign axi_req.aw.prot      = s_axi_awprot;
    assign axi_req.aw.qos       = s_axi_awqos;
    assign axi_req.aw.region    = s_axi_awregion;
    assign axi_req.aw_valid     = s_axi_awvalid;
    assign axi_req.w.data       = s_axi_wdata;
    assign axi_req.w.strb       = s_axi_wstrb;
    assign axi_req.w.last       = s_axi_wlast;
    assign axi_req.w_valid      = s_axi_wvalid;
    assign axi_req.b_ready      = s_axi_bready;
    assign axi_req.ar.addr      = s_axi_araddr;
    assign axi_req.ar.len       = s_axi_arlen;
    assign axi_req.ar.size      = s_axi_arsize;
    assign axi_req.ar.burst     = s_axi_arburst;
    assign axi_req.ar.lock      = s_axi_arlock;
    assign axi_req.ar.cache     = s_axi_arcache;
    assign axi_req.ar.prot      = s_axi_arprot;
    assign axi_req.ar.qos       = s_axi_arqos;
    assign axi_req.ar.region    = s_axi_arregion;
    assign axi_req.ar_valid     = s_axi_arvalid;
    assign axi_req.r_ready      = s_axi_rready;
    assign axi_req.ar.id        = s_axi_arid;

    // AXI response
    assign s_axi_awready        = axi_rsp.aw_ready ;
    assign s_axi_wready         = axi_rsp.w_ready  ;
    assign s_axi_bid            = axi_rsp.b.id     ;
    assign s_axi_bresp          = axi_rsp.b.resp   ;
    assign s_axi_bvalid         = axi_rsp.b_valid  ;
    assign s_axi_arready        = axi_rsp.ar_ready ;
    assign s_axi_rid            = axi_rsp.r.id     ;
    assign s_axi_rdata          = axi_rsp.r.data   ;
    assign s_axi_rresp          = axi_rsp.r.resp   ;
    assign s_axi_rlast          = axi_rsp.r.last   ;
    assign s_axi_rvalid         = axi_rsp.r_valid  ;

endmodule : custom_top_wrapper


