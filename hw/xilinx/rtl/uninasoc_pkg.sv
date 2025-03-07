// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////

    localparam int unsigned NUM_GPIO_IN  = 16;
    localparam int unsigned NUM_GPIO_OUT = 16;

    //////////////////
    // AXI crossbar //
    //////////////////
    // Crosbar masters
    // - RVM socket (instr and data)
    // - Sys Master
    localparam int unsigned NUM_AXI_MASTERS = 3; // {socket_instr, socket_data, jtag2axi}

    // Main Crosbar slaves if EMBEDDED
    // - Peripheral bus
    // - Main memory (BRAM)
    // - PLIC
    `ifdef EMBEDDED
        // NB: we should find a better and automatic way of count AXI and MASTERs
        localparam int unsigned NUM_AXI_SLAVES = 3;

    // Crosbar slaves if HPC
    // - Main memory (BRAM)
    // - Peripheral bus
    // - DDR4
    // - PLIC
    `elsif HPC
        localparam int unsigned NUM_AXI_SLAVES = 4;
    `endif


    // AXI Lite peripheral bus
    // Slaves if EMBEDDED
    // - UART (physical)
    // - GPIOs in outputs
    // - GPIOs in input
    // - Timer 0
    // - Timer 1
    `ifdef EMBEDDED
        localparam int unsigned NUM_AXILITE_SLAVES = 5;
    // Slaves if HPC
    // - UART (Virtual)
    // - Timer 0
    // - Timer 1
    `elsif HPC
        localparam int unsigned NUM_AXILITE_SLAVES = 3;
    `endif


    //////////////////////////
    // Supported Processors //
    //////////////////////////

    typedef enum int unsigned {
        CORE_PICORV32,
        CORE_CV32E40P,
        CORE_MICROBLAZEV
    } core_selector_t;

    // Select core from macro
    localparam core_selector_t CORE_SELECTOR = `CORE_SELECTOR;


endpackage : uninasoc_pkg
