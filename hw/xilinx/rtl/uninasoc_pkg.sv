// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////

    localparam int unsigned NUM_GPIO_IN  = 16;
    localparam int unsigned NUM_GPIO_OUT = 16;

    ///////////////////////
    // AXI main crossbar //
    ///////////////////////

    // Main Crosbar masters
    localparam int unsigned NUM_SI = `NUM_SI;
    // Main Crosbar slaves
    localparam int unsigned NUM_MI = `NUM_MI;

    /////////////////////////////
    // AXI Lite peripheral bus //
    /////////////////////////////

    // Always assume 1 master
    // Peripheral bus slaves
    localparam int unsigned PBUS_NUM_MI = `PBUS_NUM_MI;


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
