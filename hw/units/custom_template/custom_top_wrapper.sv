
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the
// simplyv_axi and simplyv_mem svh files in hw/xilinx/rtl


// Import headers
`include "simplyv_axi.svh"
`include "simplyv_mem.svh"

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////

    // AXI/MEM macros parameter
    parameter LOCAL_DATA_WIDTH  = 32,
    parameter LOCAL_ADDR_WIDTH  = 32,
    parameter LOCAL_ID_WIDTH  = 2

) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////

    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI Master Interface Array (Add here as many master as required)
    `DEFINE_AXI_MASTER_PORTS(name, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH),
    // AXI Slave Interface Array
    `DEFINE_AXI_SLAVE_PORTS(name, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH, LOCAL_ID_WIDTH),
    // MEM Interface Array
    `DEFINE_MEM_PORTS(name, LOCAL_DATA_WIDTH, LOCAL_ADDR_WIDTH)
);




endmodule : custom_top_wrapper


