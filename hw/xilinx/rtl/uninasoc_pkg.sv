// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Basic system variables for UninaSoC

package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////

    localparam int unsigned NUM_GPIO_IN  = 16;
    localparam int unsigned NUM_GPIO_OUT = 16;

    // System widths depending on XLEN
    localparam SYS_DATA_WIDTH = `SYS_DATA_WIDTH;
    localparam SYS_ADDR_WIDTH = `SYS_ADDR_WIDTH;
    localparam SYS_ID_WIDTH = `SYS_ID_WIDTH;

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
        CORE_IBEX,
        CORE_MICROBLAZEV
    } core_selector_t;

    // Select core from macro
    localparam core_selector_t CORE_SELECTOR = `CORE_SELECTOR;

    ///////////////////////
    // System Interrupts //
    ///////////////////////

    // Masters and Buses (Slves) can generate interrupts, which are forwarded to the PLIC (Platform interrupts).
    // The PLIC forwards interrupts to the Masters (e.g. the Socket)

    // RISC-V cores standard interrupts
    localparam int unsigned CORE_SW_INTERRUPT = 3;      // Inter Processor Interrupts
    localparam int unsigned CORE_TIM_INTERRUPT = 7;     // Real-time Clock Timer
    localparam int unsigned CORE_EXT_INTERRUPT = 11;    // PLIC-to-hart interrupts

    // Peripheral Bus interrupts
    localparam int unsigned PBUS_GPIOIN_INTERRUPT = 0;      // GPIO In [embedded only]
    localparam int unsigned PBUS_TIM0_INTERRUPT = 1;        // Timer 0
    localparam int unsigned PBUS_TIM1_INTERRUPT = 2;        // Timer 1
    localparam int unsigned PBUS_UART_INTERRUPT = 3;        // UART

    // PLIC Interrupts mapping
    // We support 32 possible sources of platform interrupts, which are statically mapped
    // regardless of the configuration.
    localparam int unsigned PLIC_RESERVED_INTERRUPT = 0;    // PLIC line 0 is reserved
    localparam int unsigned PLIC_GPIOIN_INTERRUPT = 1;      // GPIO In (From PBUS)[embedded only]
    localparam int unsigned PLIC_TIM0_INTERRUPT = 2;        // Timer 0 (From PBUS)
    localparam int unsigned PLIC_TIM1_INTERRUPT = 3;        // Timer 1 (From PBUS)
    localparam int unsigned PLIC_UART_INTERRUPT = 4;        // UART    (From PBUS)

endpackage : uninasoc_pkg
