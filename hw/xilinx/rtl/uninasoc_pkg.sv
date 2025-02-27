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
    // - RVM socket (instr and data)
    // - JTAG2AXI
    // - DM
    localparam int unsigned NUM_AXI_MASTERS = 4; // {debug_module, socket_instr, socket_data, jtag2axi}

    // Main Crosbar slaves if EMBEDDED
    // - Peripheral bus
    // - DM slave: TODO: figure out if to put this under PBUS
    // - Main memory (BRAM)
    `ifdef EMBEDDED
        // NB: we should find a better and automatic way of count AXI and MASTERs
        localparam int unsigned NUM_AXI_SLAVES = 3;

    // Crosbar slaves if HPC
    // - Main memory (BRAM)
    // - Peripheral bus
    // - DDR4
    // - DM
    `elsif HPC
        localparam int unsigned NUM_AXI_SLAVES = 4;
    `endif


    // AXI Lite peripheral bus
    // Slaves if EMBEDDED
    // - GPIOs in input
    // - GPIOs in outputs
    // - UART (physical)
    `ifdef EMBEDDED
        localparam int unsigned NUM_AXILITE_SLAVES = NUM_GPIO_IN + NUM_GPIO_OUT + 1;
    // Slaves if HPC
    // - SYNC - The xbar must have 2 slaves minimum
    // - UART (Virtual)
    `elsif HPC
        localparam int unsigned NUM_AXILITE_SLAVES = 2;
    `endif


    //////////////////////////
    // Supported Processors //
    //////////////////////////

    typedef enum int unsigned {
        CORE_PICORV32,
        CORE_CV32E40P,
        CORE_MICROBLAZEV
    } core_selector_t;


endpackage : uninasoc_pkg
