// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////
    localparam int unsigned NUM_IRQ = 3;
    localparam int unsigned NUM_GPIO_IN  = 0; //TBD
    localparam int unsigned NUM_GPIO_OUT = 1;

    //////////////////
    // AXI crossbar //
    //////////////////
    // Crosbar masters
    // - RVM socket
    // - JTAG2AXI
    // localparam int unsigned NUM_AXI_MASTERS = 2;
    localparam int unsigned NUM_AXI_MASTERS = 1; // Just 1 for verify/jtag2axi

    // Crosbar slaves if EMBEDDED 
    // - GPIOs in input
    // - GPIOs in outputs
    // - Main memory
    `ifdef EMBEDDED
        localparam int unsigned NUM_AXI_SLAVES = NUM_GPIO_IN + NUM_GPIO_OUT + 1;
    
    // Crosbar slaves if HPC
    // - Main memory
    // - Secondary memory
    `elsif HPC
        localparam int unsigned NUM_AXI_SLAVES = 2;
    `endif

endpackage : uninasoc_pkg
