package uninasoc_pkg;

    ///////////////////////
    // SoC-level defines //
    ///////////////////////
    // TBD
    localparam NUM_IRQ = 3;

    /////////////////
    // AXI defines //
    /////////////////
    // RVM socket + JTAG2AXI
    localparam int unsigned NUM_AXI_MASTERS = 2; 
    // Main memory + UART + GPIOs
   // localparam int unsigned NUM_AXI_SLAVES  = 2 + NUM_GPIO_IN +  NUM_GPIO_OUT;
    localparam int unsigned NUM_AXI_SLAVES  = 2 //ONLY VALID FOR THIS VERSION
    localparam int unsigned AXI_DATA_WIDTH  = 32;
    localparam int unsigned AXI_ADDR_WIDTH  = 32;

    // TODO: define wrapper structs/interfaces for Xilinx-generated AXI interface

    /////////
    // TBD //
    /////////

endpackage : uninasoc_pkg
