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
    parameter int unsigned        NrHarts          = 1,
    parameter int unsigned        BusWidth         = 32,
    parameter logic [31:0]        DmBaseAddress    = 32'h10000, // TODO: match from config
    // parameter int unsigned        DmBaseAddress    = 'h1000, // default to non-zero page
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
    input  logic                  rst_ni,           // System reset
    // input  logic                  debug_reset_ni,   // Power-on-reset, not the system reset
    output logic                  ndmreset_o,       // non-debug module reset
    output logic                  dmactive_o,       // debug module is active
    output logic [NrHarts-1:0]    debug_req_o,      // async debug request
    input  logic [NrHarts-1:0]    unavailable_i,    // communicate whether the hart is unavailable (e.g.: power down)

    //////////////////////
    //  Bus Interfaces  //
    //////////////////////
    `DEFINE_MEM_MASTER_PORTS(dbg_master),
    `DEFINE_MEM_SLAVE_PORTS(dbg_slave)
);

    // Architecture:
    //   __________              ______________
    //  | (bscane) |            |              |
    //  | dmi_jtag | -- DMI --> |    dm_top    | -- debug_req_o -->
    //  |__________|            |______________|
    //                            |           ^
    //                            v           |
    //                       MEM master   MEM slave
    //

    ///////////////////
    // Local signals //
    ///////////////////

    // Pack hartinfo_t struct
    dm::hartinfo_t hartinfo;
    // From ariane_pkg::DebugHartInfo
    // Same as https://github.com/lowRISC/ibex-demo-system/blob/main/rtl/system/dm_top.sv
    assign hartinfo.zero1        = '0;
    assign hartinfo.nscratch     = 2;  // Debug module needs at least two scratch regs
    assign hartinfo.zero0        = '0;
    assign hartinfo.dataaccess   = 1'b1;  // data registers are memory mapped in the debugger
    assign hartinfo.datasize     = dm::DataCount;
    assign hartinfo.dataaddr     = dm::DataAddr;

    // DMI interface
    // DM package-specific structs
    dm::dmi_req_t   dmi_req;
    dm::dmi_resp_t  dmi_resp;
    // Valid/ready
    logic           dmi_req_ready  ;
    logic           dmi_req_valid  ;
    logic           dmi_resp_ready ;
    logic           dmi_resp_valid ;
    // Reset
    logic           dmi_rst_n;

    // Synchronized debug reset
    // logic debug_reset_n_sync;
    // Number of synchronizer stages
    localparam int unsigned SYNCH_STAGES = 4;
    // Synchronize debug reset
    logic [SYNCH_STAGES-1:0] shiftreg;

    ///////////////
    // Registers //
    ///////////////

    // Shift out
    // assign debug_reset_n_sync = debug_reset_ni;
    // assign debug_reset_n_sync = shiftreg[0];
    // // Shift register
    // always_ff @(posedge clk_i or negedge rst_ni) begin
    //     if ( ~rst_ni ) begin
    //         shiftreg <= '0;
    //     end
    //     else begin
    //         // Shift down
    //         shiftreg <= {debug_reset_ni, shiftreg[SYNCH_STAGES-1:1]};
    //     end
    // end

    // Read response is valid one cycle after request
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if ( !rst_ni ) begin
            dbg_slave_mem_valid <= '0;
        end
        else begin
            dbg_slave_mem_valid <= dbg_slave_mem_req;
        end
    end

    /////////////////
    // Sub-modules //
    /////////////////

    // Tie-off unconnected signals
    assign dbg_slave_mem_gnt   = '0;
    assign dbg_slave_mem_error = '0;

    // Debug Module
    dm_top #(
        .NrHarts        ( NrHarts       ),
        .BusWidth       ( BusWidth      ),
        .DmBaseAddress  ( DmBaseAddress )
    ) dm_top_u (
        .clk_i,
        .rst_ni, // Power-on-reset, not the system reset
        // .rst_ni               ( debug_reset_n_sync    ), // Power-on-reset, not the system reset
        // Deug ports
        .testmode_i           ( '0                    ),
        .ndmreset_o           ( ndmreset_o            ),
        .dmactive_o           ( dmactive_o            ),
        .unavailable_i        ( unavailable_i         ),
        .hartinfo_i           ( hartinfo              ),
        // To RV core
        .debug_req_o          ( debug_req_o           ),
        // Slave mem
        .slave_req_i          ( dbg_slave_mem_req     ),
        .slave_we_i           ( dbg_slave_mem_we      ),
        .slave_addr_i         ( dbg_slave_mem_addr    ),
        .slave_be_i           ( dbg_slave_mem_be      ),
        .slave_wdata_i        ( dbg_slave_mem_wdata   ),
        .slave_rdata_o        ( dbg_slave_mem_rdata   ),
        // Master mem
        .master_req_o         ( dbg_master_mem_req    ),
        .master_add_o         ( dbg_master_mem_addr   ),
        .master_we_o          ( dbg_master_mem_we     ),
        .master_wdata_o       ( dbg_master_mem_wdata  ),
        .master_be_o          ( dbg_master_mem_be     ),
        .master_gnt_i         ( dbg_master_mem_gnt    ),
        .master_r_valid_i     ( dbg_master_mem_valid  ),
        .master_r_rdata_i     ( dbg_master_mem_rdata  ),
        .master_r_err_i       ( dbg_master_mem_error  ),
        .master_r_other_err_i ( 1'b0                  ),
        // From DTM
        .dmi_rst_ni           ( dmi_rst_n             ),
        .dmi_req_valid_i      ( dmi_req_valid         ),
        .dmi_req_ready_o      ( dmi_req_ready         ),
        .dmi_req_i            ( dmi_req               ),
        .dmi_resp_valid_o     ( dmi_resp_valid        ),
        .dmi_resp_ready_i     ( dmi_resp_ready        ),
        .dmi_resp_o           ( dmi_resp              )
    );

    // Debug Transfer Module and JTAG interface
    dmi_jtag dtm_u (
        .clk_i,
        .rst_ni,
        // To DM
        .dmi_rst_no       ( dmi_rst_n      ),
        .dmi_req_o        ( dmi_req        ),
        .dmi_req_ready_i  ( dmi_req_ready  ),
        .dmi_req_valid_o  ( dmi_req_valid  ),
        .dmi_resp_i       ( dmi_resp       ),
        .dmi_resp_ready_o ( dmi_resp_ready ),
        .dmi_resp_valid_i ( dmi_resp_valid ),
        .testmode_i       ( '0             ), // Unused
        // From JTAG
        // .tck_i            ( clk_i          ), // Necessary for internal CDC
        .tck_i            ( '0 ), // Necessary for internal CDC
        .tms_i            ( '0 ), // Unused, Floating
        .trst_ni          ( '1 ), // Necessary for reset and CDC
        // .trst_ni          ( debug_reset_n_sync ), // Necessary for reset and CDC
        .td_i             ( '0             ), // Unused, Floating
        .td_o             (                ), // Open
        .tdo_oe_o         (                )  // Open
    );


endmodule : custom_top_wrapper


