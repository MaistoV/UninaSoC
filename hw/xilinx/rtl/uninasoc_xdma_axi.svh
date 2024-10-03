// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Utility variables and macros for XDMA AXI interconnections in UninaSoC
// Note: The main rationale behind this macro is to avoid the usage of structs and
//       macros for the widest possible syntax compatibility. The XDMA has different DATA_WIDTH and parameters

`ifndef UNINASOC_XDMA_AXI_SVH__
`define UNINASOC_XDMA_AXI_SVH__

// Import sub-package
import uninasoc_pkg::*;

// XDMA AXI4 parameters
localparam int unsigned XDMA_AXI_DATA_WIDTH   = 64;
localparam int unsigned XDMA_AXI_ADDR_WIDTH   = 32;
localparam int unsigned XDMA_AXI_STRB_WIDTH   = XDMA_AXI_DATA_WIDTH / 8;
localparam int unsigned XDMA_AXI_ID_WIDTH     = 4;
localparam int unsigned XDMA_AXI_LEN_WIDTH    = 8;
localparam int unsigned XDMA_AXI_SIZE_WIDTH   = 3;
localparam int unsigned XDMA_AXI_BURST_WIDTH  = 2;
localparam int unsigned XDMA_AXI_LOCK_WIDTH   = 1;
localparam int unsigned XDMA_AXI_CACHE_WIDTH  = 4;
localparam int unsigned XDMA_AXI_PROT_WIDTH   = 3;
localparam int unsigned XDMA_AXI_QOS_WIDTH    = 4;
localparam int unsigned XDMA_AXI_VALID_WIDTH  = 1;
localparam int unsigned XDMA_AXI_READY_WIDTH  = 1;
localparam int unsigned XDMA_AXI_LAST_WIDTH   = 1;
localparam int unsigned XDMA_AXI_RESP_WIDTH   = 2;
localparam int unsigned XDMA_AXI_REGION_WIDTH = 4;

// XDMA AXI signal types
typedef logic [XDMA_AXI_DATA_WIDTH   -1 : 0] xdma_axi_data_t;
typedef logic [XDMA_AXI_ADDR_WIDTH   -1 : 0] xdma_axi_addr_t;
typedef logic [XDMA_AXI_STRB_WIDTH   -1 : 0] xdma_axi_strb_t;
typedef logic [XDMA_AXI_ID_WIDTH     -1 : 0] xdma_axi_id_t;
typedef logic [XDMA_AXI_LEN_WIDTH    -1 : 0] xdma_axi_len_t;
typedef logic [XDMA_AXI_SIZE_WIDTH   -1 : 0] xdma_axi_size_t;
typedef logic [XDMA_AXI_BURST_WIDTH  -1 : 0] xdma_axi_burst_t;
typedef logic [XDMA_AXI_LOCK_WIDTH   -1 : 0] xdma_axi_lock_t;
typedef logic [XDMA_AXI_CACHE_WIDTH  -1 : 0] xdma_axi_cache_t;
typedef logic [XDMA_AXI_PROT_WIDTH   -1 : 0] xdma_axi_prot_t;
typedef logic [XDMA_AXI_QOS_WIDTH    -1 : 0] xdma_axi_qos_t;
typedef logic [XDMA_AXI_VALID_WIDTH  -1 : 0] xdma_axi_valid_t;
typedef logic [XDMA_AXI_READY_WIDTH  -1 : 0] xdma_axi_ready_t;
typedef logic [XDMA_AXI_LAST_WIDTH   -1 : 0] xdma_axi_last_t;
typedef logic [XDMA_AXI_RESP_WIDTH   -1 : 0] xdma_axi_resp_t;
typedef logic [XDMA_AXI_REGION_WIDTH -1 : 0] xdma_axi_region_t;

// Single define for whole XDMA AXI4 bus
`define DECLARE_XDMA_AXI_BUS(bus_name) \
    // AW channel                                \
    xdma_axi_id_t     ``bus_name``_axi_awid;     \
    xdma_axi_addr_t   ``bus_name``_axi_awaddr;   \
    xdma_axi_len_t    ``bus_name``_axi_awlen;    \
    xdma_axi_size_t   ``bus_name``_axi_awsize;   \
    xdma_axi_burst_t  ``bus_name``_axi_awburst;  \
    xdma_axi_lock_t   ``bus_name``_axi_awlock;   \
    xdma_axi_cache_t  ``bus_name``_axi_awcache;  \
    xdma_axi_prot_t   ``bus_name``_axi_awprot;   \
    xdma_axi_qos_t    ``bus_name``_axi_awqos;    \
    xdma_axi_valid_t  ``bus_name``_axi_awvalid;  \
    xdma_axi_ready_t  ``bus_name``_axi_awready;  \
    xdma_axi_region_t ``bus_name``_axi_awregion; \
    // W channel                                 \
    xdma_axi_data_t   ``bus_name``_axi_wdata;    \
    xdma_axi_strb_t   ``bus_name``_axi_wstrb;    \
    xdma_axi_last_t   ``bus_name``_axi_wlast;    \
    xdma_axi_valid_t  ``bus_name``_axi_wvalid;   \
    xdma_axi_ready_t  ``bus_name``_axi_wready;   \
    // B channel                                 \
    xdma_axi_id_t     ``bus_name``_axi_bid;      \
    xdma_axi_resp_t   ``bus_name``_axi_bresp;    \
    xdma_axi_valid_t  ``bus_name``_axi_bvalid;   \
    xdma_axi_ready_t  ``bus_name``_axi_bready;   \
    // AR channel                                \
    xdma_axi_addr_t   ``bus_name``_axi_araddr;   \
    xdma_axi_len_t    ``bus_name``_axi_arlen;    \
    xdma_axi_size_t   ``bus_name``_axi_arsize;   \
    xdma_axi_burst_t  ``bus_name``_axi_arburst;  \
    xdma_axi_lock_t   ``bus_name``_axi_arlock;   \
    xdma_axi_cache_t  ``bus_name``_axi_arcache;  \
    xdma_axi_prot_t   ``bus_name``_axi_arprot;   \
    xdma_axi_qos_t    ``bus_name``_axi_arqos;    \
    xdma_axi_valid_t  ``bus_name``_axi_arvalid;  \
    xdma_axi_ready_t  ``bus_name``_axi_arready;  \
    xdma_axi_id_t     ``bus_name``_axi_arid;     \
    xdma_axi_region_t ``bus_name``_axi_arregion; \
    // R channel                                 \
    xdma_axi_id_t     ``bus_name``_axi_rid;      \
    xdma_axi_data_t   ``bus_name``_axi_rdata;    \
    xdma_axi_resp_t   ``bus_name``_axi_rresp;    \
    xdma_axi_last_t   ``bus_name``_axi_rlast;    \
    xdma_axi_valid_t  ``bus_name``_axi_rvalid;   \
    xdma_axi_ready_t  ``bus_name``_axi_rready;

`endif