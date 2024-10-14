// This wrapper is required to convert the axi_from_mem.sv module to a Vivado IP compatible one.
// Only standard logic types are allowed as interface signals.

// Authors:
// - Stefano Mercogliano <stefano.mercogliano@unina.it>

`include "typedef.svh"

module axi_from_mem_wrapper # (
    parameter MEM_ADDR_WIDTH = 32,
    parameter MEM_DATA_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_STRB_WIDTH = AXI_ADDR_WIDTH / 8,
    parameter AXI_ID_WIDTH   = 2,
    parameter AXI_REGION_WIDTH = 4,
    parameter AXI_LEN_WIDTH    = 8,
    parameter AXI_SIZE_WIDTH   = 3,
    parameter AXI_BURST_WIDTH  = 2,
    parameter AXI_LOCK_WIDTH   = 1,
    parameter AXI_CACHE_WIDTH  = 4,
    parameter AXI_PROT_WIDTH   = 3,
    parameter AXI_QOS_WIDTH    = 4,
    parameter AXI_VALID_WIDTH  = 1,
    parameter AXI_READY_WIDTH  = 1,
    parameter AXI_LAST_WIDTH   = 1,
    parameter AXI_RESP_WIDTH   = 2

) (

    // AXI4 Full Master interface from SRAM protocol (mem)
    output  logic [AXI_ID_WIDTH     -1 : 0] m_axi_awid,       // Write address ID
    output  logic [AXI_ADDR_WIDTH   -1 : 0] m_axi_awaddr,     // Write address
    output  logic [AXI_LEN_WIDTH    -1 : 0] m_axi_awlen,      // Burst length (number of transfers)
    output  logic [AXI_SIZE_WIDTH   -1 : 0] m_axi_awsize,     // Burst size (number of bytes per transfer)
    output  logic [AXI_BURST_WIDTH  -1 : 0] m_axi_awburst,    // Burst type
    output  logic [AXI_LOCK_WIDTH   -1 : 0] m_axi_awlock,     // Lock type
    output  logic [AXI_CACHE_WIDTH  -1 : 0] m_axi_awcache,    // Cache type
    output  logic [AXI_PROT_WIDTH   -1 : 0] m_axi_awprot,     // Protection type
    output  logic [AXI_QOS_WIDTH    -1 : 0] m_axi_awqos,      // Quality of service
    output  logic [AXI_REGION_WIDTH -1 : 0] m_axi_awregion,   // Region identifier
    output  logic [AXI_VALID_WIDTH  -1 : 0] m_axi_awvalid,    // Write address valid
    input   logic [AXI_READY_WIDTH  -1 : 0] m_axi_awready,    // Write address ready

    output  logic [AXI_DATA_WIDTH   -1 : 0] m_axi_wdata,      // Write data
    output  logic [AXI_STRB_WIDTH   -1 : 0] m_axi_wstrb,      // Write strobe (which byte lanes are valid)
    output  logic [AXI_LAST_WIDTH   -1 : 0] m_axi_wlast,      // Write last (last transfer in burst)
    output  logic [AXI_VALID_WIDTH  -1 : 0] m_axi_wvalid,     // Write data valid
    input   logic [AXI_READY_WIDTH  -1 : 0] m_axi_wready,     // Write data ready

    input   logic [AXI_ID_WIDTH     -1 : 0] m_axi_bid,        // Response ID
    input   logic [AXI_RESP_WIDTH   -1 : 0] m_axi_bresp,      // Write response (OKAY, SLVERR, etc.)
    input   logic [AXI_VALID_WIDTH  -1 : 0] m_axi_bvalid,     // Write response valid
    output  logic [AXI_READY_WIDTH  -1 : 0] m_axi_bready,     // Write response ready

    output  logic [AXI_ADDR_WIDTH   -1 : 0] m_axi_araddr,     // Read address
    output  logic [AXI_LEN_WIDTH    -1 : 0] m_axi_arlen,      // Burst length (number of transfers)
    output  logic [AXI_SIZE_WIDTH   -1 : 0] m_axi_arsize,     // Burst size (number of bytes per transfer)
    output  logic [AXI_BURST_WIDTH  -1 : 0] m_axi_arburst,    // Burst type
    output  logic [AXI_LOCK_WIDTH   -1 : 0] m_axi_arlock,     // Lock type
    output  logic [AXI_CACHE_WIDTH  -1 : 0] m_axi_arcache,    // Cache type
    output  logic [AXI_PROT_WIDTH   -1 : 0] m_axi_arprot,     // Protection type
    output  logic [AXI_QOS_WIDTH    -1 : 0] m_axi_arqos,      // Quality of service
    output  logic [AXI_REGION_WIDTH -1 : 0] m_axi_arregion,   // Region identifier
    output  logic [AXI_VALID_WIDTH  -1 : 0] m_axi_arvalid,    // Read address valid
    input   logic [AXI_READY_WIDTH  -1 : 0] m_axi_arready,    // Read address ready
    output  logic [AXI_ID_WIDTH     -1 : 0] m_axi_arid,       // Read ID

    input   logic [AXI_ID_WIDTH     -1 : 0] m_axi_rid,        // Read ID
    input   logic [AXI_DATA_WIDTH   -1 : 0] m_axi_rdata,      // Read data
    input   logic [AXI_RESP_WIDTH   -1 : 0] m_axi_rresp,      // Read response
    input   logic [AXI_LAST_WIDTH   -1 : 0] m_axi_rlast,      // Read last (last transfer in burst)
    input   logic [AXI_VALID_WIDTH  -1 : 0] m_axi_rvalid,     // Read data valid
    output  logic [AXI_READY_WIDTH  -1 : 0] m_axi_rready,     // Read data ready

    // Mem interface
    input  logic                            clk_i,            // Clock input, positive edge triggered.
    input  logic                            rst_ni,           // Clock input, positive edge triggered.           
    input  logic                            mem_req_i,        // Clock input, positive edge triggered.
    input  logic [MEM_ADDR_WIDTH-1:0]       mem_addr_i,       // Clock input, positive edge triggered.
    input  logic                            mem_we_i,         // Clock input, positive edge triggered.
    input  logic [MEM_DATA_WIDTH-1:0]       mem_wdata_i,      // Clock input, positive edge triggered.
    input  logic [MEM_DATA_WIDTH/8-1:0]     mem_be_i,         // Clock input, positive edge triggered.
    output logic                            mem_gnt_o,        // Clock input, positive edge triggered.
    output logic                            mem_rsp_valid_o,  // Clock input, positive edge triggered.
    output logic [MEM_DATA_WIDTH-1:0]       mem_rsp_rdata_o,  // Clock input, positive edge triggered.
    output logic                            mem_rsp_error_o   // Clock input, positive edge triggered.
);

    // Define the req_t and resp_t type using typedef.svh macro
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

    // Define internal Cache signals (just a passthrough for clarity)
    logic [AXI_CACHE_WIDTH  -1 : 0] slv_aw_cache;
    logic [AXI_CACHE_WIDTH  -1 : 0] slv_ar_cache;


    // Instantiation of axi_from_mem module
    axi_from_mem #(
        .MemAddrWidth   (MEM_ADDR_WIDTH),        // Memory request address width
        .AxiAddrWidth   (AXI_ADDR_WIDTH),        // AXI4-Lite address width
        .DataWidth      (AXI_DATA_WIDTH),        // Data width of memory and AXI4-Lite
        .MaxRequests    (1),                     // Max number of in-flight requests
        .AxiProt        (3'b000),                // Protection signal for AXI4 transactions
        .axi_req_t      (axi_req_t),             // AXI4 request struct type
        .axi_rsp_t      (axi_resp_t)             // AXI4 response struct type
    ) axi_from_mem_u (
        // Clock and Reset
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),

        // Memory Slave Port Inputs
        .mem_req_i      (mem_req_i),
        .mem_addr_i     (mem_addr_i),
        .mem_we_i       (mem_we_i),
        .mem_wdata_i    (mem_wdata_i),
        .mem_be_i       (mem_be_i),

        // Memory Slave Port Outputs
        .mem_gnt_o       (mem_gnt_o),
        .mem_rsp_valid_o (mem_rsp_valid_o),
        .mem_rsp_rdata_o (mem_rsp_rdata_o),
        .mem_rsp_error_o (mem_rsp_error_o),

        // AXI4 Master Port Inputs
        .slv_aw_cache_i (slv_aw_cache),
        .slv_ar_cache_i (slv_ar_cache),

        // AXI4 Master Port Outputs
        .axi_req_o      (axi_req),

        // AXI4 Master Port Inputs
        .axi_rsp_i      (axi_rsp)
    );

    // Unwrap axi_from_mem structured type

    // Map Cache signals
    assign slv_aw_cache = m_axi_awcache;
    assign slv_ar_cache = m_axi_arcache;

    // Map OUTPUT signals
    assign m_axi_awid      = axi_req.aw.id;
    assign m_axi_awaddr    = axi_req.aw.addr;
    assign m_axi_awlen     = axi_req.aw.len;
    assign m_axi_awsize    = axi_req.aw.size;
    assign m_axi_awburst   = axi_req.aw.burst;
    assign m_axi_awlock    = axi_req.aw.lock;
    assign m_axi_awcache   = axi_req.aw.cache;
    assign m_axi_awprot    = axi_req.aw.prot;
    assign m_axi_awqos     = axi_req.aw.qos;
    assign m_axi_awregion  = axi_req.aw.region;
    assign m_axi_awvalid   = axi_req.aw_valid; 
    assign m_axi_wdata     = axi_req.w.data;
    assign m_axi_wstrb     = axi_req.w.strb;
    assign m_axi_wlast     = axi_req.w.last;
    assign m_axi_wvalid    = axi_req.w_valid;
    assign m_axi_bready    = axi_req.b_ready;
    assign m_axi_araddr    = axi_req.ar.addr;
    assign m_axi_arlen     = axi_req.ar.len;
    assign m_axi_arsize    = axi_req.ar.size;
    assign m_axi_arburst   = axi_req.ar.burst;
    assign m_axi_arlock    = axi_req.ar.lock;
    assign m_axi_arcache   = axi_req.ar.cache;
    assign m_axi_arprot    = axi_req.ar.prot;
    assign m_axi_arqos     = axi_req.ar.qos;
    assign m_axi_arregion  = axi_req.ar.region;
    assign m_axi_arvalid   = axi_req.ar_valid;
    assign m_axi_rready    = axi_req.r_ready;
    assign m_axi_arid      = axi_req.ar.id;

    assign axi_rsp.aw_ready = m_axi_awready;  
    assign axi_rsp.w_ready  = m_axi_wready;    
    assign axi_rsp.b.id     = m_axi_bid;        
    assign axi_rsp.b.resp     = m_axi_bresp;      
    assign axi_rsp.b_valid  = m_axi_bvalid;     
    assign axi_rsp.ar_ready = m_axi_arready;    
    assign axi_rsp.r.id     = m_axi_rid;        
    assign axi_rsp.r.data   = m_axi_rdata;      
    assign axi_rsp.r.resp   = m_axi_rresp;      
    assign axi_rsp.r.last   = m_axi_rlast;      
    assign axi_rsp.r_valid  = m_axi_rvalid;     



endmodule : axi_from_mem_wrapper