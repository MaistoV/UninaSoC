// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// It might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl

// Definizione della struttura delle interruzioni
typedef struct packed {
    logic software;    // Interruzione software
    logic timer;       // Interruzione timer
    logic external;    // Interruzione esterna
} interrupt_t;

/*typedef struct {
    logic arvalid;
    logic [31:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic [3:0] arcache;
    logic [5:0] arid;
    logic arlock;

    logic rready;

    logic awvalid;
    logic [31:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic [3:0] awcache;
    logic [5:0] awid;
    logic awlock;

    logic wvalid;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    logic wlast;

    logic bready;
} master_axi_interface_output;

typedef struct {
    logic arready;

    logic rvalid;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic [5:0] rid;

    logic awready;
    logic wready;

    logic bvalid;
    logic [1:0] bresp;
    logic [5:0] bid;
} master_axi_interface_input;*/

// Inclusione dei file di configurazione
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"
import cva5_config::*;

// Wrapper per il modulo top-level
module custom_top_wrapper (
    ///////////////////////////////////
    //  IP-related signals
    ///////////////////////////////////
    input logic clk,
    input logic rst,

    // AXI Master interface
    //`DEFINE_AXI_MASTER_PORTS(m_axi),
    input m_axi_arready,
    output m_axi_arvalid,
    output [31:0] m_axi_araddr,

    //R
    output m_axi_rready,
    input m_axi_rvalid,
    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,

    //AW
    input m_axi_awready,
    output m_axi_awvalid,
    output [31:0] m_axi_awaddr,

    //W
    output m_axi_wready,
    output m_axi_wvalid,
    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,

    //B
    output m_axi_bready,
    input m_axi_bvalid,
    input [1:0] m_axi_bresp,
    
    master_axi_interface_output m_axi_output,
    master_axi_interface_input m_axi_input,

    // Interrupts e timer
    input logic [63:0] mtime,
    input interrupt_t s_interrupt,
    input interrupt_t m_interrupt
);
localparam wb_group_config_t WB_CPU_CONFIG = '{
        0 : '{0: ALU_ID, default : NON_WRITEBACK_ID},
        1 : '{0: LS_ID, default : NON_WRITEBACK_ID},
        2 : '{0: MUL_ID, 1: DIV_ID, 2: CSR_ID, 3: FPU_ID, 4: CUSTOM_ID, default : NON_WRITEBACK_ID},
        3 : '{default : NON_WRITEBACK_ID},
        4 : '{default : NON_WRITEBACK_ID},
        5 : '{default : NON_WRITEBACK_ID},
        6 : '{default : NON_WRITEBACK_ID},
        7 : '{default : NON_WRITEBACK_ID},
        8 : '{default : NON_WRITEBACK_ID}
    };

    localparam cpu_config_t CONFIG = '{
        // ISA options
        MODES : M,
        INCLUDE_UNIT : '{
            MUL : 1,
            DIV : 1,
            CSR : 1,
            FPU : 0,
            CUSTOM : 0,
            default: '0
        },
        INCLUDE_IFENCE : 0,
        INCLUDE_AMO : 0,
        INCLUDE_CBO : 0,
        // CSR constants
        CSRS : '{
            MACHINE_IMPLEMENTATION_ID : 0,
            CPU_ID : 0,
            RESET_VEC : 32'h80000000,
            RESET_TVEC : 32'h00000000,
            MCONFIGPTR : '0,
            INCLUDE_ZICNTR : 1,
            INCLUDE_ZIHPM : 0,
            INCLUDE_SSTC : 0,
            INCLUDE_SMSTATEEN : 0
        },
        // Memory Options
        SQ_DEPTH : 4,
        INCLUDE_FORWARDING_TO_STORES : 1,
        AMO_UNIT : '{
            LR_WAIT : 32,
            RESERVATION_WORDS : 8
        },
        INCLUDE_ICACHE : 0,
        ICACHE_ADDR : '{
            L: 32'h80000000,
            H: 32'h8FFFFFFF
        },
        ICACHE : '{
            LINES : 512,
            LINE_W : 4,
            WAYS : 2,
            USE_EXTERNAL_INVALIDATIONS : 0,
            USE_NON_CACHEABLE : 0,
            NON_CACHEABLE : '{
                L: 32'h70000000,
                H: 32'h7FFFFFFF
            }
        },
        ITLB : '{
            WAYS : 2,
            DEPTH : 64
        },
        INCLUDE_DCACHE : 0,
        DCACHE_ADDR : '{
            L: 32'h80000000,
            H: 32'h8FFFFFFF
        },
        DCACHE : '{
            LINES : 512,
            LINE_W : 4,
            WAYS : 2,
            USE_EXTERNAL_INVALIDATIONS : 0,
            USE_NON_CACHEABLE : 0,
            NON_CACHEABLE : '{
                L: 32'h70000000,
                H: 32'h7FFFFFFF
            }
        },
        DTLB : '{
            WAYS : 2,
            DEPTH : 64
        },
        INCLUDE_ILOCAL_MEM : 0,
        ILOCAL_MEM_ADDR : '{
            L : 32'h80000000, 
            H : 32'h80FFFFFF
        },
        INCLUDE_DLOCAL_MEM : 0,
        DLOCAL_MEM_ADDR : '{
            L : 32'h80000000,
            H : 32'h80FFFFFF
        },
        INCLUDE_IBUS : 0,
        IBUS_ADDR : '{
            L : 32'h60000000, 
            H : 32'h6FFFFFFF
        },
        INCLUDE_PERIPHERAL_BUS : 1,
        PERIPHERAL_BUS_ADDR : '{
            L : 32'h00000000,
            H : 32'hFFFFFFFF
        },
        PERIPHERAL_BUS_TYPE : AXI_BUS,
        // Branch Predictor Options
        INCLUDE_BRANCH_PREDICTOR : 1,
        BP : '{
            WAYS : 2,
            ENTRIES : 512,
            RAS_ENTRIES : 8
        },
        // Writeback Options
        NUM_WB_GROUPS : 3,
        WB_GROUP : WB_CPU_CONFIG
    };

    //////////////////////////////
    //  CVA5 Core Instantiation
    //////////////////////////////

    cva5 #(
        .CONFIG(CONFIG)
    ) u_cva5 (
        .clk(clk),
        .rst(rst),

        .m_axi_output(m_axi_output),
        .m_axi_input(m_axi_input),

        .mtime(64'b0),
        .s_interrupt(s_interrupt),
        .m_interrupt(m_interrupt),

        // Disabilitare memorie locali
        .instruction_bram_input(64'b0), 
        .instruction_bram_output(64'b0), 
        .data_bram_input(64'b0),     
        .data_bram_output(64'b0),      
        // Disabilitare interfacce non AXI
        .m_avalon_input(64'b0),
        .m_avalon_output(64'b0),    
        .dwishbone_input(64'b0),        
        .dwishbone_output(64'b0),   
        .iwishbone_input(64'b0),
        .iwishbone_output(64'b0)         
    );

    // AR (Address Read Channel)
    assign m_axi_output.arready = m_axi_arready;
    assign m_axi_arvalid = m_axi_output.arvalid;
    assign m_axi_araddr  = m_axi_output.araddr;
    
    // R (Read Data Channel)
    assign m_axi_rready  = m_axi_input.rready;
    assign m_axi_output.rvalid  = m_axi_rvalid;
    assign m_axi_output.rdata   = m_axi_rdata;
    assign m_axi_output.rresp   = m_axi_rresp;
    assign m_axi_output.rid     = 6'b0; 
    
    // AW (Address Write Channel)
    assign m_axi_output.awready = m_axi_awready;
    assign m_axi_awvalid = m_axi_output.awvalid;
    assign m_axi_awaddr  = m_axi_output.awaddr;
    
    // W (Write Data Channel)
    assign m_axi_wready  = m_axi_wready;
    assign m_axi_wvalid  = m_axi_output.wvalid;
    assign m_axi_wdata   = m_axi_output.wdata;
    assign m_axi_wstrb   = m_axi_output.wstrb;
    
    // B (Write Response Channel)
    assign m_axi_bready  = m_axi_output.bready;
    assign m_axi_output.bvalid  = m_axi_bvalid;
    assign m_axi_output.bresp   = m_axi_bresp;
    assign m_axi_output.bid     = 6'b0;

endmodule : custom_top_wrapper
