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
    // parameter logic [31:0]        IdcodeValue      = 32'h00000DB3,
    parameter logic [31:0]        IdcodeValue      = 32'h00000093, // TEST, from pg428-mdm-v-en-us-1.0.pdf
    parameter int unsigned        NrHarts          = 1,
    parameter int unsigned        BusWidth         = 32,
    parameter int unsigned        DmBaseAddress    = 'h1000, // default to non-zero page
    // Bitmask to select physically available harts for systems
    // that don't use hart numbers in a contiguous fashion.
    parameter logic [NrHarts-1:0] SelectableHarts  = {NrHarts{1'b1}},
    // toggle new behavior to drive master_be_o during a read
    parameter bit                 ReadByteEnable   = 1

) (

    ///////////////////////
    // IP-related ports  //
    ///////////////////////

    input  logic                  clk_i,            // clock
    input  logic                  rst_ni,           // asynchronous reset active low, connect PoR here, not the system reset
    input  logic                  testmode_i,
    output logic                  ndmreset_o,       // non-debug module reset
    output logic                  dmactive_o,       // debug module is active
    output logic [NrHarts-1:0]    debug_req_o,      // async debug request
    input  logic [NrHarts-1:0]    unavailable_i,    // communicate whether the hart is unavailable (e.g.: power down)

    // Flattened hartinfo_t struct
    input  logic [31:24] hartinfo_i_zero1,
    input  logic [23:20] hartinfo_i_nscratch,
    input  logic [19:17] hartinfo_i_zero0,
    input  logic         hartinfo_i_dataaccess,
    input  logic [15:12] hartinfo_i_datasize,
    input  logic [11:0]  hartinfo_i_dataaddr,

    // JTAG interface
    input  logic         jtag_tck_i,    // JTAG test clock pad
    input  logic         jtag_tms_i,    // JTAG test mode select pad
    input  logic         jtag_trst_ni,  // JTAG test reset pad
    input  logic         jtag_tdi_i,    // JTAG test data input pad
    output logic         jtag_tdo_o,    // JTAG test data output pad
    output logic         jtag_tdo_oe_o, // Data out output enable

    //////////////////////
    //  Bus Interfaces  //
    //////////////////////
    `DEFINE_MEM_MASTER_PORTS(dbg_master),
    `DEFINE_MEM_SLAVE_PORTS(dbg_slave)
);

    // Architecture:
    //                __________              ______________
    //               |   (?)    |            |              |
    //  --- JTAG --> | dmi_jtag |--- DMI --> |    dm_top    | -- debug_req_o -->
    //               |__________|            |______________|
    //                                         |           ^
    //                                         v           |
    //                                    MEM master   MEM slave
    //                                         |           |
    //                                       MEM2AXI    AXI2MEM
    //                                         |           ^
    //                                         v           |

    ///////////////////
    // Local signals //
    ///////////////////

    // Pack hartinfo_t struct
    dm::hartinfo_t hartinfo_struct;
    assign hartinfo_struct.zero1        = hartinfo_i_zero1;
    assign hartinfo_struct.nscratch     = hartinfo_i_nscratch;
    assign hartinfo_struct.zero0        = hartinfo_i_zero0;
    assign hartinfo_struct.dataaccess   = hartinfo_i_dataaccess;
    assign hartinfo_struct.datasize     = hartinfo_i_datasize;
    assign hartinfo_struct.dataaddr     = hartinfo_i_dataaddr;

    // DMI interface
    // DM package-specific structs
    dm::dmi_req_t       dmi_req_struct;
    dm::dmi_resp_t      dmi_resp_struct;
    // Valid/ready
    logic           dmi_req_ready  ;
    logic           dmi_req_valid  ;
    logic           dmi_resp_ready ;
    logic           dmi_resp_valid ;
    // Reset
    logic           dmi_rst_n;

    /////////////////
    // Sub-modules //
    /////////////////

    // JTAG to DMI
    dmi_jtag #(
        .IdcodeValue  ( IdcodeValue )
    ) dmi_jtag_u (
        .clk_i,
        .rst_ni,
        .testmode_i       ( testmode_i      ),
        .dmi_rst_no       ( dmi_rst_n       ),
        .dmi_req_o        ( dmi_req_struct  ),
        .dmi_req_ready_i  ( dmi_req_ready   ),
        .dmi_req_valid_o  ( dmi_req_valid   ),
        .dmi_resp_i       ( dmi_resp_struct ),
        .dmi_resp_ready_o ( dmi_resp_ready  ),
        .dmi_resp_valid_i ( dmi_resp_valid  ),
        .tck_i            ( jtag_tck_i      ),
        .tms_i            ( jtag_tms_i      ),
        .trst_ni          ( jtag_trst_ni    ),
        .td_i             ( jtag_tdi_i      ),
        .td_o             ( jtag_tdo_o      ),
        .tdo_oe_o         ( jtag_tdo_oe_o   )
    );

    // Debug Module
    // Tie-off unconnected signals
    assign dbg_slave_mem_gnt   = '0;
    assign dbg_slave_mem_valid = '0;
    assign dbg_slave_mem_error = '0;
    assign dbg_master_mem_err  = '0;
    dm_top #(
        .NrHarts            ( NrHarts         ),
        .BusWidth           ( BusWidth        ),
        .DmBaseAddress      ( DmBaseAddress   ), // default to non-zero page
        .SelectableHarts    ( SelectableHarts ), // Bitmask to select physically available harts for systems
        .ReadByteEnable     ( ReadByteEnable  )  // toggle new behavior to drive master_be_o during a read
    ) dm_top_u (
        .clk_i                  ( clk_i             ),
        .rst_ni                 ( rst_ni            ),
        .testmode_i             ( testmode_i        ),
        .ndmreset_o             ( ndmreset_o        ), // non-debug module reset
        .dmactive_o             ( dmactive_o        ), // debug module is active
        .debug_req_o            ( debug_req_o       ), // async debug request
        .unavailable_i          ( unavailable_i     ), // communicate whether the hart is unavailable (e.g.: power down)
        .hartinfo_i             ( hartinfo_struct   ), // dm::hartinfo_t [NrHarts-1:0]

        // Slave memory interface
        .slave_req_i            ( dbg_slave_mem_req   ),
        .slave_we_i             ( dbg_slave_mem_we    ),
        .slave_addr_i           ( dbg_slave_mem_addr  ),
        .slave_be_i             ( dbg_slave_mem_be    ),
        .slave_wdata_i          ( dbg_slave_mem_wdata ),
        .slave_rdata_o          ( dbg_slave_mem_rdata ),

        // Master memory interface
        .master_req_o           ( dbg_master_mem_req    ),
        .master_add_o           ( dbg_master_mem_addr   ),
        .master_we_o            ( dbg_master_mem_we     ),
        .master_wdata_o         ( dbg_master_mem_wdata  ),
        .master_be_o            ( dbg_master_mem_be     ),
        .master_gnt_i           ( dbg_master_mem_gnt    ),
        .master_r_valid_i       ( dbg_master_mem_valid  ),
        .master_r_err_i         ( dbg_master_mem_err    ),
        .master_r_rdata_i       ( dbg_master_mem_rdata  ),
        .master_r_other_err_i   ( '0                    ), // *other_err_i has priority over *err_i

        // Connection to DTM - compatible to RocketChip Debug Module
        .dmi_rst_ni             ( dmi_rst_n        ), // Synchronous clear request from
                                                    // the DTM to clear the DMI response
                                                    // FIFO.
        .dmi_req_valid_i        ( dmi_req_valid   ),
        .dmi_req_ready_o        ( dmi_req_ready   ),
        .dmi_req_i              ( dmi_req_struct  ), // dm::dmi_req_t
        .dmi_resp_valid_o       ( dmi_resp_valid  ),
        .dmi_resp_ready_i       ( dmi_resp_ready  ),
        .dmi_resp_o             ( dmi_resp_struct ) // dm::dmi_resp_t
    );

endmodule : custom_top_wrapper


