// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// It might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl

`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module custom_top_wrapper #(
    parameter cpu_config_t CONFIG = EXAMPLE_CONFIG
) (
    ///////////////////////////////////
    //  IP-related signals
    ///////////////////////////////////
    input logic clk,
    input logic rst,

    // AXI Master interface
    `DEFINE_AXI_MASTER_PORTS(m_axi),

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

        // Disattivi le interfacce non usate (se AXI-only)
        .instruction_bram(),
        .data_bram(),
        .m_avalon(),
        .dwishbone(),
        .iwishbone(),
        .mem()
    );

endmodule : custom_top_wrapper
