// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description:
// This module is intended as a top-level wrapper for the code in ./rtl
// IT might support either MEM protocol or AXI protocol, using the
// uninasoc_axi and uninasoc_mem svh files in hw/xilinx/rtl


// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module custom_top_wrapper # (

    //////////////////////////////////////
    //  Add here IP-related parameters  //
    //////////////////////////////////////

) (

    ///////////////////////////////////
    //  Add here IP-related signals  //
    ///////////////////////////////////

    ////////////////////////////
    //  Bus Array Interfaces  //
    ////////////////////////////

    // AXI Master Interface Array (Add here as many master as required)
    `DEFINE_AXI_MASTER_PORTS(name),
    // AXI Slave Interface Array
    `DEFINE_AXI_SLAVE_PORTS(name),
    // MEM Interface Array
    `DEFINE_MEM_PORTS(name)
);




endmodule : custom_top_wrapper
