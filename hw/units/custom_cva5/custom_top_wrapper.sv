//`include "uninasoc_axi.svh"
//`include "uninasoc_mem.svh"
import cva5_config::*;

typedef struct packed {
    logic software;    // Interruzione software
    logic timer;       // Interruzione timer
    logic external;    // Interruzione esterna
} interrupt_t;


module custom_top_wrapper (
    input logic clk,
    input logic rst,

    // AXI Master interface: segnali singoli
    output logic arvalid,
    output logic [31:0] araddr,
    output logic [7:0] arlen,
    output logic [2:0] arsize,
    output logic [1:0] arburst,
    output logic [3:0] arcache,
    output logic [5:0] arid,
    output logic arlock,
    output logic rready,

    output logic awvalid,
    output logic [31:0] awaddr,
    output logic [7:0] awlen,
    output logic [2:0] awsize,
    output logic [1:0] awburst,
    output logic [3:0] awcache,
    output logic [5:0] awid,
    output logic awlock,

    output logic wvalid,
    output logic [31:0] wdata,
    output logic [3:0] wstrb,
    output logic wlast,

    output logic bready,

    input logic arready,
    input logic rvalid,
    input logic [31:0] rdata,
    input logic [1:0] rresp,
    input logic rlast,
    input logic [5:0] rid,

    input logic awready,
    input logic wready,

    input logic bvalid,
    input logic [1:0] bresp,
    input logic [5:0] bid,

    // Interrupts e timer
    input logic [63:0] mtime,
    //input interrupt_t s_interrupt,
    //input interrupt_t m_interrupt
    input logic s_interrupt_software,
    input logic s_interrupt_timer,
    input logic s_interrupt_external,

    input logic m_interrupt_software,
    input logic m_interrupt_timer,
    input logic m_interrupt_external
);

    // ==== AXI STRUCT INSTANCE ====
    master_axi_interface_output m_axi_output;
    master_axi_interface_input  m_axi_input;
    
    interrupt_t s_interrupt;
    interrupt_t m_interrupt;
    
    assign s_interrupt.software = s_interrupt_software;
    assign s_interrupt.timer = s_interrupt_timer; 
    assign s_interrupt.external = s_interrupt_external;
    
    assign m_interrupt.software = m_interrupt_software;
    assign m_interrupt.timer = m_interrupt_timer; 
    assign m_interrupt.external = m_interrupt_external;

    // ==== ASSIGN OUTPUT STRUCT TO SIGNALS ====
    assign arvalid = m_axi_output.arvalid;
    assign araddr  = m_axi_output.araddr;
    assign arlen   = m_axi_output.arlen;
    assign arsize  = m_axi_output.arsize;
    assign arburst = m_axi_output.arburst;
    assign arcache = m_axi_output.arcache;
    assign arid    = m_axi_output.arid;
    assign arlock  = m_axi_output.arlock;
    assign rready  = m_axi_output.rready;

    assign awvalid = m_axi_output.awvalid;
    assign awaddr  = m_axi_output.awaddr;
    assign awlen   = m_axi_output.awlen;
    assign awsize  = m_axi_output.awsize;
    assign awburst = m_axi_output.awburst;
    assign awcache = m_axi_output.awcache;
    assign awid    = m_axi_output.awid;
    assign awlock  = m_axi_output.awlock;

    assign wvalid  = m_axi_output.wvalid;
    assign wdata   = m_axi_output.wdata;
    assign wstrb   = m_axi_output.wstrb;
    assign wlast   = m_axi_output.wlast;

    assign bready  = m_axi_output.bready;

    // ==== ASSIGN INPUT SIGNALS TO STRUCT ====
    assign m_axi_input.arready = arready;
    assign m_axi_input.rvalid  = rvalid;
    assign m_axi_input.rdata   = rdata;
    assign m_axi_input.rresp   = rresp;
    assign m_axi_input.rlast   = rlast;
    assign m_axi_input.rid     = rid;

    assign m_axi_input.awready = awready;
    assign m_axi_input.wready  = wready;
    assign m_axi_input.bvalid  = bvalid;
    assign m_axi_input.bresp   = bresp;
    assign m_axi_input.bid     = bid;

    // ==== CONFIG PARAM ====
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
        MODES : M,
        INCLUDE_UNIT : '{
            MUL : 1, DIV : 1, CSR : 1,
            FPU : 0, CUSTOM : 0,
            default : 0
        },
        INCLUDE_IFENCE : 0,
        INCLUDE_AMO : 0,
        INCLUDE_CBO : 0,
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
        SQ_DEPTH : 4,
        INCLUDE_FORWARDING_TO_STORES : 1,
        AMO_UNIT : '{
            LR_WAIT : 32,
            RESERVATION_WORDS : 8
        },
        INCLUDE_ICACHE : 0,
        ICACHE_ADDR : '{L: 32'h80000000, H: 32'h8FFFFFFF},
        ICACHE : '{
            LINES : 512, LINE_W : 4, WAYS : 2,
            USE_EXTERNAL_INVALIDATIONS : 0,
            USE_NON_CACHEABLE : 0,
            NON_CACHEABLE : '{L: 32'h70000000, H: 32'h7FFFFFFF}
        },
        ITLB : '{WAYS : 2, DEPTH : 64},
        INCLUDE_DCACHE : 0,
        DCACHE_ADDR : '{L: 32'h80000000, H: 32'h8FFFFFFF},
        DCACHE : '{
            LINES : 512, LINE_W : 4, WAYS : 2,
            USE_EXTERNAL_INVALIDATIONS : 0,
            USE_NON_CACHEABLE : 0,
            NON_CACHEABLE : '{L: 32'h70000000, H: 32'h7FFFFFFF}
        },
        DTLB : '{WAYS : 2, DEPTH : 64},
        INCLUDE_ILOCAL_MEM : 0,
        ILOCAL_MEM_ADDR : '{L : 32'h80000000, H : 32'h80FFFFFF},
        INCLUDE_DLOCAL_MEM : 0,
        DLOCAL_MEM_ADDR : '{L : 32'h80000000, H : 32'h80FFFFFF},
        INCLUDE_IBUS : 0,
        IBUS_ADDR : '{L : 32'h60000000, H : 32'h6FFFFFFF},
        INCLUDE_PERIPHERAL_BUS : 1,
        PERIPHERAL_BUS_ADDR : '{L : 32'h00000000, H : 32'hFFFFFFFF},
        PERIPHERAL_BUS_TYPE : AXI_BUS,
        INCLUDE_BRANCH_PREDICTOR : 1,
        BP : '{WAYS : 2, ENTRIES : 512, RAS_ENTRIES : 8},
        NUM_WB_GROUPS : 3,
        WB_GROUP : WB_CPU_CONFIG
    };

    // ==== CVA5 CORE INSTANTIATION ====
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

        .instruction_bram_input(),
        .instruction_bram_output(),
        .data_bram_input(),
        .data_bram_output(),

        .m_avalon_input(),
        .m_avalon_output(),
        .dwishbone_input(),
        .dwishbone_output(),
        .iwishbone_input(),
        .iwishbone_output(),
        .mem_input(),
        .mem_output()
    );

endmodule
