// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////
    localparam int unsigned NUM_IRQ = 3;
    localparam int unsigned NUM_GPIO_IN  = 0; //TBD
    localparam int unsigned NUM_GPIO_OUT = 1;
    localparam int unsigned DEBUG_MODULE = `DEBUG_MODULE;

    //////////////////
    // AXI crossbar //
    //////////////////
    // Crosbar masters
    // - RVM socket (instr and data)
    // - JTAG2AXI
    // - (Optionally) Debug module master
    localparam int unsigned NUM_AXI_MASTERS = 3 + DEBUG_MODULE;

    // Crosbar slaves if EMBEDDED
    // - GPIOs in input
    // - GPIOs in outputs
    // - Main memory
    // - (Optionally) Debug module slave
    `ifdef EMBEDDED
        localparam int unsigned NUM_AXI_SLAVES = NUM_GPIO_IN + NUM_GPIO_OUT + 1 + DEBUG_MODULE;

    // Crosbar slaves if HPC
    // - Main memory
    // - Secondary memory
    `elsif HPC
        localparam int unsigned NUM_AXI_SLAVES = 2 + DEBUG_MODULE;
    `endif

    //////////////////////////
    // Supported Processors //
    //////////////////////////

    localparam int unsigned CORE_PICORV32 = 0;
    localparam int unsigned CORE_CV32E40P = 1;

endpackage : uninasoc_pkg
