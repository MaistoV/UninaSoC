// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// It might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl

`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module custom_top_wrapper #(
    parameter cpu_config_t CONFIG = '{
        //ISA options
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
        //CSR constants
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
        //Memory Options
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
            L : 32'h60000000,
            H : 32'h6FFFFFFF
        },
        PERIPHERAL_BUS_TYPE : AXI_BUS,
        //Branch Predictor Options
        INCLUDE_BRANCH_PREDICTOR : 1,
        BP : '{
            WAYS : 2,
            ENTRIES : 512,
            RAS_ENTRIES : 8
        },
        //Writeback Options
        NUM_WB_GROUPS : 3,
        WB_GROUP : WB_CPU_CONFIG
    };
) (
    ///////////////////////////////////
    //  IP-related signals
    ///////////////////////////////////
    input logic clk,
    input logic rst,
    local_memory_interface.master instruction_bram,
    local_memory_interface.master data_bram,

    // AXI Master interface
    `DEFINE_AXI_MASTER_PORTS(m_axi),
    avalon_interface.master m_avalon,
    wishbone_interface.master dwishbone,
    wishbone_interface.master iwishbone,

    // Interrupts e timer
    input logic [63:0] mtime,
    input interrupt_t s_interrupt,
    input interrupt_t m_interrupt
);

    //////////////////////////////
    //  CVA5 Core Instantiation
    //////////////////////////////

    cva5 #(
        .CONFIG(CONFIG)
    ) u_cva5 (
        .clk(clk),
        .rst(rst),

        .m_axi(m_axi),

        .mtime(mtime),
        .s_interrupt(s_interrupt),
        .m_interrupt(m_interrupt),

    
        // Disabilitare memorie locali
        .instruction_bram(64'b0), // Impostato a zero
        .data_bram(64'b0),        // Impostato a zero
        // Disabilitare interfacce non AXI
        .m_avalon(64'b0),         // Impostato a zero
        .dwishbone(64'b0),        // Impostato a zero
        .iwishbone(64'b0)         // Impostato a zero

    );

    // AR (Address Read Channel)
        assign m_axi.arready = m_axi_arready;
        assign m_axi_arvalid = m_axi.arvalid;
        assign m_axi_araddr  = m_axi.araddr;
        
        // R (Read Data Channel)
        assign m_axi_rready  = m_axi.rready;
        assign m_axi.rvalid  = m_axi_rvalid;
        assign m_axi.rdata   = m_axi_rdata;
        assign m_axi.rresp   = m_axi_rresp;
        assign m_axi.rid     = 6'b0; // ID non usato
        
        // AW (Address Write Channel)
        assign m_axi.awready = m_axi_awready;
        assign m_axi_awvalid = m_axi.awvalid;
        assign m_axi_awaddr  = m_axi.awaddr;
        
        // W (Write Data Channel)
        assign m_axi_wready  = m_axi_wready;
        assign m_axi_wvalid  = m_axi.wvalid;
        assign m_axi_wdata   = m_axi.wdata;
        assign m_axi_wstrb   = m_axi.wstrb;
        
        // B (Write Response Channel)
        assign m_axi_bready  = m_axi.bready;
        assign m_axi.bvalid  = m_axi_bvalid;
        assign m_axi.bresp   = m_axi_bresp;
        assign m_axi.bid     = 6'b0; // ID non usato

endmodule : custom_top_wrapper
