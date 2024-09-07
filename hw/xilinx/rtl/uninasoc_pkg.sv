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

    // Crosbar slaves
    // - GPIOs in input
    // - GPIOs in outputs
    // - Main memory
    localparam int unsigned NUM_AXI_SLAVES = NUM_GPIO_IN + NUM_GPIO_OUT + 1;

endpackage : uninasoc_pkg
