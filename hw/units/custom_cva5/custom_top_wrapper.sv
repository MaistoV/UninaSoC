// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl


// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module custom_top_wrapper # (
    parameter cpu_config_t CONFIG = EXAMPLE_CONFIG
) (
    input logic clk,
    input logic rst,
    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////
    // Interfaccia AXI master per memoria (es. m_axi)
    `DEFINE_AXI_MASTER_PORTS(m_axi),

    // Interrupts e timer
    input logic [63:0] mtime,
    input interrupt_t s_interrupt,
    input interrupt_t m_interrupt
    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

);




endmodule : custom_top_wrapper
