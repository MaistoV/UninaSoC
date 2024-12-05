// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////
    localparam int unsigned NUM_IRQ = 3;
    localparam int unsigned NUM_GPIO_IN  = 16; 
    localparam int unsigned NUM_GPIO_OUT = 16;

    //////////////////
    // AXI crossbar //
    //////////////////
    // Crosbar masters
    // - RVM socket (instr and data)
    // - JTAG2AXI
    localparam int unsigned NUM_AXI_MASTERS = 3; // {socket_instr, socket_data, jtag2axi}

    // Crosbar slaves if EMBEDDED 
    // - GPIOs in input
    // - GPIOs in outputs
    // - UART (physical)
    // - Main memory
    `ifdef EMBEDDED
        // NB: we should find a better and automatic way of count AXI and MASTERs
        localparam int unsigned NUM_AXI_SLAVES = 6;
    
    // Crosbar slaves if HPC
    // - Main memory (BRAM)
    // - UART (virtual)
    // - DDR4
    `elsif HPC
        localparam int unsigned NUM_AXI_SLAVES = 5;
    `endif

    //////////////////////////
    // Supported Processors //
    //////////////////////////

    localparam int unsigned CORE_PICORV32 = 0;
    localparam int unsigned CORE_CV32E40P = 1;

endpackage : uninasoc_pkg
