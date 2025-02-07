// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Cesare Pulcrano <ce.pulcrano@studenti.unina.it>
// Description: Wrapper module for a RVM core


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module rvm_socket # (
    parameter core_selector_t CORE_SELECTOR = CORE_CV32E40P, // Change default only for development, while waiting for the core selection flow
    parameter int unsigned    DATA_WIDTH    = 32,
    parameter int unsigned    ADDR_WIDTH    = 32,
    parameter int unsigned    DEBUG_MODULE  = 1,
    parameter int unsigned    NUM_IRQ       = 3
) (
    input  logic                            clk_i,
    input  logic                            rst_ni,
    input  logic [AXI_ADDR_WIDTH -1 : 0 ]   bootaddr_i,
    input  logic [NUM_IRQ        -1 : 0 ]   irq_i,

    // // DEBUG
    // input  logic                            jtag_trst_ni,

    // Core
    `DEFINE_AXI_MASTER_PORTS(rvm_socket_instr),
    `DEFINE_AXI_MASTER_PORTS(rvm_socket_data),

    // Debug module
    `DEFINE_AXI_MASTER_PORTS(dbg_master),
    `DEFINE_AXI_SLAVE_PORTS(dbg_slave)
);

    //////////////////////////////////////
    //    ___ _                _        //
    //   / __(_)__ _ _ _  __ _| |___    //
    //   \__ | / _` | ' \/ _` | (_-<    //
    //   |___|_\__, |_||_\__,_|_/__/    //
    //         |___/                    //
    //////////////////////////////////////

    // Declare AXI interfaces for instruction memory port and data memory port
    `DECLARE_AXI_BUS(core_instr_to_socket_instr, DATA_WIDTH);
    `DECLARE_AXI_BUS(core_data_to_socket_data, DATA_WIDTH);

    // Declare MEM ports
    `DECLARE_MEM_BUS(core_instr, DATA_WIDTH);
    `DECLARE_MEM_BUS(core_data, DATA_WIDTH);
    `DECLARE_MEM_BUS(dbg_master, DATA_WIDTH);
    `DECLARE_MEM_BUS(dbg_slave, DATA_WIDTH);

    // Debug request
    logic debug_req_core;

    //////////////////////////////////////////////////////
    //     ___               ___          _             //
    //    / __|___ _ _ ___  | _ \___ __ _(_)___ _ _     //
    //   | (__/ _ \ '_/ -_) |   / -_) _` | / _ \ ' \    //
    //    \___\___/_| \___| |_|_\___\__, |_\___/_||_|   //
    //                              |___/               //
    //////////////////////////////////////////////////////

    generate
        if (CORE_SELECTOR == CORE_PICORV32) begin: core_picorv32

            //////////////////////////
            //      PicoRV32        //
            //////////////////////////

            ///////////////////////////////////////////////////////////////////////////
            //  Pico has a custom interrupt handling mechanisms. I am not sure if    //
            //  it is just an alternative to standard risc-v interrupt handling,     //
            //  or if it is incompatible. Therefore, beware of it and use Pico       //
            //  only for interrupt-less applications.                                //
            ///////////////////////////////////////////////////////////////////////////

            custom_picorv32 picorv32_core (
                .clk_i              ( clk_i                     ),
                .rst_ni             ( rst_ni                    ),
                .trap_o             (                           ),

                .instr_mem_req      ( core_instr_mem_req        ),
                .instr_mem_gnt      ( core_instr_mem_gnt        ),
                .instr_mem_valid    ( core_instr_mem_valid      ),
                .instr_mem_addr     ( core_instr_mem_addr       ),
                .instr_mem_rdata    ( core_instr_mem_rdata      ),
                .instr_mem_error    ( core_instr_mem_error      ), // Although unused

                .data_mem_req       ( core_data_mem_req         ),
                .data_mem_valid     ( core_data_mem_valid       ),
                .data_mem_gnt       ( core_data_mem_gnt         ),
                .data_mem_we        ( core_data_mem_we          ),
                .data_mem_be        ( core_data_mem_be          ),
                .data_mem_addr      ( core_data_mem_addr        ),
                .data_mem_wdata     ( core_data_mem_wdata       ),
                .data_mem_rdata     ( core_data_mem_rdata       ),
                .data_mem_error     ( core_data_mem_error       ), // Although unused

                .irq_i              ( irq_i                     ),

            `ifdef RISCV_FORMAL
                .rvfi_valid         (                           ),
                .rvfi_order         (                           ),
                .rvfi_insn          (                           ),
                .rvfi_trap          (                           ),
                .rvfi_halt          (                           ),
                .rvfi_intr          (                           ),
                .rvfi_rs1_addr      (                           ),
                .rvfi_rs2_addr      (                           ),
                .rvfi_rs1_rdata     (                           ),
                .rvfi_rs2_rdata     (                           ),
                .rvfi_rd_addr       (                           ),
                .rvfi_rd_wdata      (                           ),
                .rvfi_pc_rdata      (                           ),
                .rvfi_pc_wdata      (                           ),
                .rvfi_mem_addr      (                           ),
                .rvfi_mem_rmask     (                           ),
                .rvfi_mem_wmask     (                           ),
                .rvfi_mem_rdata     (                           ),
                .rvfi_mem_wdata     (                           ),
            `endif

                .trace_valid_o      (                           ), // Unmapped atm
                .trace_data_o       (                           )  // Unmapped atm
            );

        end
        else if (CORE_SELECTOR == CORE_CV32E40P) begin: core_cv32e40p

            //////////////////////////
            //      CV32E40P        //
            //////////////////////////

            custom_cv32e40p cv32e40p_core (
                // Clock and Reset
                .clk_i                  ( clk_i                     ),
                .rst_ni                 ( rst_ni                    ),

                .pulp_clock_en_i        ( '0                        ),  // PULP clock enable (only used if COREV_CLUSTER = 1)
                .scan_cg_en_i           ( '0                        ),  // Enable all clock gates for testing

                // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
                .boot_addr_i            ( bootaddr_i                ),
                .mtvec_addr_i           ( '0                        ),  // TBD
                .dm_halt_addr_i         ( '0                        ),  // TBD
                .hart_id_i              ( '0                        ),  // TBD
                .dm_exception_addr_i    ( '0                        ),  // TBD

                // Instruction memory interface
                .instr_mem_req          ( core_instr_mem_req        ),
                .instr_mem_gnt          ( core_instr_mem_gnt        ),
                .instr_mem_valid        ( core_instr_mem_valid      ),
                .instr_mem_addr         ( core_instr_mem_addr       ),
                .instr_mem_rdata        ( core_instr_mem_rdata      ),
                .instr_mem_error        ( core_instr_mem_error      ), // Although unused

                // Data memory interface
                .data_mem_req           ( core_data_mem_req         ),
                .data_mem_valid         ( core_data_mem_valid       ),
                .data_mem_gnt           ( core_data_mem_gnt         ),
                .data_mem_we            ( core_data_mem_we          ),
                .data_mem_be            ( core_data_mem_be          ),
                .data_mem_addr          ( core_data_mem_addr        ),
                .data_mem_wdata         ( core_data_mem_wdata       ),
                .data_mem_rdata         ( core_data_mem_rdata       ),
                .data_mem_error         ( core_data_mem_error       ), // Although unused

                // Interrupt inputs
                .irq_i                  ( irq_i                     ),  // CLINT interrupts + CLINT extension interrupts
                .irq_ack_o              (                           ),  // TBD
                .irq_id_o               (                           ),  // TBD

                // Debug Interface
                .debug_req_i            ( debug_req_core            ),  // From Debug Module
                .debug_havereset_o      (                           ),  // TBD
                .debug_running_o        (                           ),  // TBD
                .debug_halted_o         (                           ),  // TBD

                // CPU Control Signals
                .fetch_enable_i         ( 1'b1                      ),
                .core_sleep_o           (                           )   // TBD
            );

        end
        else if (CORE_SELECTOR == CORE_MICROBLAZEV) begin : xlnx_microblaze_riscv

            //////////////////////////
            //      MICROBLAZE      //
            //////////////////////////

            // Debug interface connections definition
            logic       dbg_sys_rst;
            logic       Dbg_Clk;      // wire Dbg_Clk_0
            logic       Dbg_TDI;      // wire Dbg_TDI_0
            logic       Dbg_TDO;      // wire Dbg_TDO_0
            logic [0:7] Dbg_Reg_En;   // wire [0 : 7] Dbg_Reg_En_0
            logic       Dbg_Capture;  // wire Dbg_Capture_0
            logic       Dbg_Shift;    // wire Dbg_Shift_0
            logic       Dbg_Update;   // wire Dbg_Update_0
            logic       Dbg_Rst;      // wire Dbg_Rst_0
            logic       Dbg_Disable;  // wire Dbg_Disable_0


            // Declare AXI interfaces for instruction memory port and data memory port for MicroblazeV
            `DECLARE_AXI_BUS(microblaze_data,DATA_WIDTH);
            `DECLARE_AXILITE_BUS(microblaze_instr);

            // Declare AXI interface for Protocol Converter
            `DECLARE_AXI_BUS(converter_instr,DATA_WIDTH);

            // Microblaze V instance
            xlnx_microblaze_riscv microblazev_u (
                // Clock and reset
                .Clk                ( clk_i       ), // input wire Clk
                .Reset              ( dbg_sys_rst ), // input wire Reset

                // Interrupts
                .Interrupt          ( irq_i[0]    ), // input wire Interrupt
                .Interrupt_Address  ('0           ), // input wire [0 : 31] Interrupt_Address
                .Interrupt_Ack      (             ), // output wire [0 : 1] Interrupt_Ack

                // Debug port to MDMV
                .Dbg_Clk            ( Dbg_Clk     ), // input wire Dbg_Clk
                .Dbg_TDI            ( Dbg_TDI     ), // input wire Dbg_TDI
                .Dbg_TDO            ( Dbg_TDO     ), // output wire Dbg_TDO
                .Dbg_Reg_En         ( Dbg_Reg_En  ), // input wire [0 : 7] Dbg_Reg_En
                .Dbg_Shift          ( Dbg_Shift   ), // input wire Dbg_Shift
                .Dbg_Capture        ( Dbg_Capture ), // input wire Dbg_Capture
                .Dbg_Update         ( Dbg_Update  ), // input wire Dbg_Update
                .Debug_Rst          ( Dbg_Rst     ), // input wire Debug_Rst
                .Dbg_Disable        ( Dbg_Disable ), // input wire Dbg_Disable

                // Data port (AXI)
                .M_AXI_DP_AWADDR    ( microblaze_data_axi_awaddr    ), // output wire [31 : 0] M_AXI_DP_AWADDR
                .M_AXI_DP_AWLEN     ( microblaze_data_axi_awlen     ), // output wire [7 : 0] M_AXI_DP_AWLEN
                .M_AXI_DP_AWSIZE    ( microblaze_data_axi_awsize    ), // output wire [2 : 0] M_AXI_DP_AWSIZE
                .M_AXI_DP_AWBURST   ( microblaze_data_axi_awburst   ), // output wire [1 : 0] M_AXI_DP_AWBURST
                .M_AXI_DP_AWLOCK    ( microblaze_data_axi_awlock    ), // output wire M_AXI_DP_AWLOCK
                .M_AXI_DP_AWCACHE   ( microblaze_data_axi_awcache   ), // output wire [3 : 0] M_AXI_DP_AWCACHE
                .M_AXI_DP_AWPROT    ( microblaze_data_axi_awprot    ), // output wire [2 : 0] M_AXI_DP_AWPROT
                .M_AXI_DP_AWQOS     ( microblaze_data_axi_awqos     ), // output wire [3 : 0] M_AXI_DP_AWQOS
                .M_AXI_DP_AWVALID   ( microblaze_data_axi_awvalid   ), // output wire M_AXI_DP_AWVALID
                .M_AXI_DP_AWREADY   ( microblaze_data_axi_awready   ), // input wire M_AXI_DP_AWREADY
                .M_AXI_DP_WDATA     ( microblaze_data_axi_wdata     ), // output wire [31 : 0] M_AXI_DP_WDATA
                .M_AXI_DP_WSTRB     ( microblaze_data_axi_wstrb     ), // output wire [3 : 0] M_AXI_DP_WSTRB
                .M_AXI_DP_WLAST     ( microblaze_data_axi_wlast     ), // output wire M_AXI_DP_WLAST
                .M_AXI_DP_WVALID    ( microblaze_data_axi_wvalid    ), // output wire M_AXI_DP_WVALID
                .M_AXI_DP_WREADY    ( microblaze_data_axi_wready    ), // input wire M_AXI_DP_WREADY
                .M_AXI_DP_BRESP     ( microblaze_data_axi_bresp     ), // input wire [1 : 0] M_AXI_DP_BRESP
                .M_AXI_DP_BVALID    ( microblaze_data_axi_bvalid    ), // input wire M_AXI_DP_BVALID
                .M_AXI_DP_BREADY    ( microblaze_data_axi_bready    ), // output wire M_AXI_DP_BREADY
                .M_AXI_DP_ARADDR    ( microblaze_data_axi_araddr    ), // output wire [31 : 0] M_AXI_DP_ARADDR
                .M_AXI_DP_ARLEN     ( microblaze_data_axi_arlen     ), // output wire [7 : 0] M_AXI_DP_ARLEN
                .M_AXI_DP_ARSIZE    ( microblaze_data_axi_arsize    ), // output wire [2 : 0] M_AXI_DP_ARSIZE
                .M_AXI_DP_ARBURST   ( microblaze_data_axi_arburst   ), // output wire [1 : 0] M_AXI_DP_ARBURST
                .M_AXI_DP_ARLOCK    ( microblaze_data_axi_arlock    ), // output wire M_AXI_DP_ARLOCK
                .M_AXI_DP_ARCACHE   ( microblaze_data_axi_arcache   ), // output wire [3 : 0] M_AXI_DP_ARCACHE
                .M_AXI_DP_ARPROT    ( microblaze_data_axi_arprot    ), // output wire [2 : 0] M_AXI_DP_ARPROT
                .M_AXI_DP_ARQOS     ( microblaze_data_axi_arqos     ), // output wire [3 : 0] M_AXI_DP_ARQOS
                .M_AXI_DP_ARVALID   ( microblaze_data_axi_arvalid   ), // output wire M_AXI_DP_ARVALID
                .M_AXI_DP_ARREADY   ( microblaze_data_axi_arready   ), // input wire M_AXI_DP_ARREADY
                .M_AXI_DP_RDATA     ( microblaze_data_axi_rdata     ), // input wire [31 : 0] M_AXI_DP_RDATA
                .M_AXI_DP_RRESP     ( microblaze_data_axi_rresp     ), // input wire [1 : 0] M_AXI_DP_RRESP
                .M_AXI_DP_RLAST     ( microblaze_data_axi_rlast     ), // input wire M_AXI_DP_RLAST
                .M_AXI_DP_RVALID    ( microblaze_data_axi_rvalid    ), // input wire M_AXI_DP_RVALID
                .M_AXI_DP_RREADY    ( microblaze_data_axi_rready    ), // output wire M_AXI_DP_RREADY

                // Instruction port (AXI-lite)
                .M_AXI_IP_AWADDR    ( microblaze_instr_axilite_awaddr   ), // output wire [31 : 0] M_AXI_IP_AWADDR
                .M_AXI_IP_AWPROT    ( microblaze_instr_axilite_awprot   ), // output wire [2 : 0] M_AXI_IP_AWPROT
                .M_AXI_IP_AWVALID   ( microblaze_instr_axilite_awvalid  ), // output wire M_AXI_IP_AWVALID
                .M_AXI_IP_AWREADY   ( microblaze_instr_axilite_awready  ), // input wire M_AXI_IP_AWREADY
                .M_AXI_IP_WDATA     ( microblaze_instr_axilite_wdata    ), // output wire [31 : 0] M_AXI_IP_WDATA
                .M_AXI_IP_WSTRB     ( microblaze_instr_axilite_wstrb    ), // output wire [3 : 0] M_AXI_IP_WSTRB
                .M_AXI_IP_WVALID    ( microblaze_instr_axilite_wvalid   ), // output wire M_AXI_IP_WVALID
                .M_AXI_IP_WREADY    ( microblaze_instr_axilite_wready   ), // input wire M_AXI_IP_WREADY
                .M_AXI_IP_BRESP     ( microblaze_instr_axilite_bresp    ), // input wire [1 : 0] M_AXI_IP_BRESP
                .M_AXI_IP_BVALID    ( microblaze_instr_axilite_bvalid   ), // input wire M_AXI_IP_BVALID
                .M_AXI_IP_BREADY    ( microblaze_instr_axilite_bready   ), // output wire M_AXI_IP_BREADY
                .M_AXI_IP_ARADDR    ( microblaze_instr_axilite_araddr   ), // output wire [31 : 0] M_AXI_IP_ARADDR
                .M_AXI_IP_ARPROT    ( microblaze_instr_axilite_arprot   ), // output wire [2 : 0] M_AXI_IP_ARPROT
                .M_AXI_IP_ARVALID   ( microblaze_instr_axilite_arvalid  ), // output wire M_AXI_IP_ARVALID
                .M_AXI_IP_ARREADY   ( microblaze_instr_axilite_arready  ), // input wire M_AXI_IP_ARREADY
                .M_AXI_IP_RDATA     ( microblaze_instr_axilite_rdata    ), // input wire [31 : 0] M_AXI_IP_RDATA
                .M_AXI_IP_RRESP     ( microblaze_instr_axilite_rresp    ), // input wire [1 : 0] M_AXI_IP_RRESP
                .M_AXI_IP_RVALID    ( microblaze_instr_axilite_rvalid   ), // input wire M_AXI_IP_RVALID
                .M_AXI_IP_RREADY    ( microblaze_instr_axilite_rready   )  // output wire M_AXI_IP_RREADY
            );

            // Microblaze Debug Module V
            xlnx_microblaze_debug_module_v mdmv_u (
                .Debug_SYS_Rst  ( dbg_sys_rst   ), // output wire Debug_SYS_Rst
                .Dbg_Clk_0      ( Dbg_Clk       ), // output wire Dbg_Clk_0
                .Dbg_TDI_0      ( Dbg_TDI       ), // output wire Dbg_TDI_0
                .Dbg_TDO_0      ( Dbg_TDO       ), // input wire Dbg_TDO_0
                .Dbg_Reg_En_0   ( Dbg_Reg_En    ), // output wire [0 : 7] Dbg_Reg_En_0
                .Dbg_Capture_0  ( Dbg_Capture   ), // output wire Dbg_Capture_0
                .Dbg_Shift_0    ( Dbg_Shift     ), // output wire Dbg_Shift_0
                .Dbg_Update_0   ( Dbg_Update    ), // output wire Dbg_Update_0
                .Dbg_Rst_0      ( Dbg_Rst       ), // output wire Dbg_Rst_0
                .Dbg_Disable_0  ( Dbg_Disable   )  // output wire Dbg_Disable_0
            );


            // Attach to socket
            `ASSIGN_AXI_BUS( rvm_socket_data , microblaze_data );
            `ASSIGN_AXI_BUS( rvm_socket_instr , converter_instr);

            // Tie-off undriven ID signals
            // ID's are set to zero since they are not present in microblaze, while the crossbar have ID's of size 2.
            // Instruction
            assign converter_instr_axi_awid = '0;
            assign converter_instr_axi_bid  = '0;
            assign converter_instr_axi_arid = '0;
            assign converter_instr_axi_rid  = '0;
            // Data
            assign microblaze_data_axi_awid = '0;
            assign microblaze_data_axi_bid  = '0;
            assign microblaze_data_axi_arid = '0;
            assign microblaze_data_axi_rid  = '0;

            // Regions are not present in microblaze data implementation so they are set to 0.
            assign microblaze_data_axi_awregion ='0;
            assign microblaze_data_axi_arregion ='0;

            // Convert from Microblaze V (AXI-lite) to socket (AXI)
            // Only instruction port (AXI-lite), data port is socket compliant (AXI)
            xlnx_axilite_to_axi4_converter axilite_to_axi4_converter_u (
                .aclk           ( clk_i                             ), // input wire aclk
                .aresetn        ( rst_ni                            ), // input wire aresetn
                // From Microblaze (AXI-lite)
                .s_axi_awaddr   ( microblaze_instr_axilite_awaddr   ), // input wire [31 : 0] s_axi_awaddr
                .s_axi_awprot   ( microblaze_instr_axilite_awprot   ), // input wire [2 : 0] s_axi_awprot
                .s_axi_awvalid  ( microblaze_instr_axilite_awvalid  ), // input wire s_axi_awvalid
                .s_axi_awready  ( microblaze_instr_axilite_awready  ), // output wire s_axi_awready
                .s_axi_wdata    ( microblaze_instr_axilite_wdata    ), // input wire [31 : 0] s_axi_wdata
                .s_axi_wstrb    ( microblaze_instr_axilite_wstrb    ), // input wire [3 : 0] s_axi_wstrb
                .s_axi_wvalid   ( microblaze_instr_axilite_wvalid   ), // input wire s_axi_wvalid
                .s_axi_wready   ( microblaze_instr_axilite_wready   ), // output wire s_axi_wready
                .s_axi_bresp    ( microblaze_instr_axilite_bresp    ), // output wire [1 : 0] s_axi_bresp
                .s_axi_bvalid   ( microblaze_instr_axilite_bvalid   ), // output wire s_axi_bvalid
                .s_axi_bready   ( microblaze_instr_axilite_bready   ), // input wire s_axi_bready
                .s_axi_araddr   ( microblaze_instr_axilite_araddr   ), // input wire [31 : 0] s_axi_araddr
                .s_axi_arprot   ( microblaze_instr_axilite_arprot   ), // input wire [2 : 0] s_axi_arprot
                .s_axi_arvalid  ( microblaze_instr_axilite_arvalid  ), // input wire s_axi_arvalid
                .s_axi_arready  ( microblaze_instr_axilite_arready  ), // output wire s_axi_arready
                .s_axi_rdata    ( microblaze_instr_axilite_rdata    ), // output wire [31 : 0] s_axi_rdata
                .s_axi_rresp    ( microblaze_instr_axilite_rresp    ), // output wire [1 : 0] s_axi_rresp
                .s_axi_rvalid   ( microblaze_instr_axilite_rvalid   ), // output wire s_axi_rvalid
                .s_axi_rready   ( microblaze_instr_axilite_rready   ), // input wire s_axi_rready
                // To socket (AXI)
                .m_axi_awaddr   ( converter_instr_axi_awaddr        ), // output wire [31 : 0] m_axi_awaddr
                .m_axi_awlen    ( converter_instr_axi_awlen         ), // output wire [7 : 0] m_axi_awlen
                .m_axi_awsize   ( converter_instr_axi_awsize        ), // output wire [2 : 0] m_axi_awsize
                .m_axi_awburst  ( converter_instr_axi_awburst       ), // output wire [1 : 0] m_axi_awburst
                .m_axi_awlock   ( converter_instr_axi_awlock        ), // output wire [0 : 0] m_axi_awlock
                .m_axi_awcache  ( converter_instr_axi_awcache       ), // output wire [3 : 0] m_axi_awcache
                .m_axi_awprot   ( converter_instr_axi_awprot        ), // output wire [2 : 0] m_axi_awprot
                .m_axi_awregion ( converter_instr_axi_awregion      ), // output wire [3 : 0] m_axi_awregion
                .m_axi_awqos    ( converter_instr_axi_awqos         ), // output wire [3 : 0] m_axi_awqos
                .m_axi_awvalid  ( converter_instr_axi_awvalid       ), // output wire m_axi_awvalid
                .m_axi_awready  ( converter_instr_axi_awready       ), // input wire m_axi_awready
                .m_axi_wdata    ( converter_instr_axi_wdata         ), // output wire [31 : 0] m_axi_wdata
                .m_axi_wstrb    ( converter_instr_axi_wstrb         ), // output wire [3 : 0] m_axi_wstrb
                .m_axi_wlast    ( converter_instr_axi_wlast         ), // output wire m_axi_wlast
                .m_axi_wvalid   ( converter_instr_axi_wvalid        ), // output wire m_axi_wvalid
                .m_axi_wready   ( converter_instr_axi_wready        ), // input wire m_axi_wready
                .m_axi_bresp    ( converter_instr_axi_bresp         ), // input wire [1 : 0] m_axi_bresp
                .m_axi_bvalid   ( converter_instr_axi_bvalid        ), // input wire m_axi_bvalid
                .m_axi_bready   ( converter_instr_axi_bready        ), // output wire m_axi_bready
                .m_axi_araddr   ( converter_instr_axi_araddr        ), // output wire [31 : 0] m_axi_araddr
                .m_axi_arlen    ( converter_instr_axi_arlen         ), // output wire [7 : 0] m_axi_arlen
                .m_axi_arsize   ( converter_instr_axi_arsize        ), // output wire [2 : 0] m_axi_arsize
                .m_axi_arburst  ( converter_instr_axi_arburst       ), // output wire [1 : 0] m_axi_arburst
                .m_axi_arlock   ( converter_instr_axi_arlock        ), // output wire [0 : 0] m_axi_arlock
                .m_axi_arcache  ( converter_instr_axi_arcache       ), // output wire [3 : 0] m_axi_arcache
                .m_axi_arprot   ( converter_instr_axi_arprot        ), // output wire [2 : 0] m_axi_arprot
                .m_axi_arregion ( converter_instr_axi_arregion      ), // output wire [3 : 0] m_axi_arregion
                .m_axi_arqos    ( converter_instr_axi_arqos         ), // output wire [3 : 0] m_axi_arqos
                .m_axi_arvalid  ( converter_instr_axi_arvalid       ), // output wire m_axi_arvalid
                .m_axi_arready  ( converter_instr_axi_arready       ), // input wire m_axi_arready
                .m_axi_rdata    ( converter_instr_axi_rdata         ), // input wire [31 : 0] m_axi_rdata
                .m_axi_rresp    ( converter_instr_axi_rresp         ), // input wire [1 : 0] m_axi_rresp
                .m_axi_rlast    ( converter_instr_axi_rlast         ), // input wire m_axi_rlast
                .m_axi_rvalid   ( converter_instr_axi_rvalid        ), // input wire m_axi_rvalid
                .m_axi_rready   ( converter_instr_axi_rready        )  // output wire m_axi_rready
            );

        end


    endgenerate


    //////////////////////////////////////////
    //     ___                              //
    //    / __|___ _ __  _ __  ___ _ _      //
    //   | (__/ _ | '  \| '  \/ _ | ' \     //
    //    \___\___|_|_|_|_|_|_\___|_||_|    //
    //                                      //
    //////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////
    // Here we are allocating commong module and signals.                   //
    //////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    //  Cores (mem) to socket (AXI-Full) converters (Instruction and Data)   //
    ///////////////////////////////////////////////////////////////////////////

    // Few exceptions:
    // - Microblaze V has its own interfaces and debug module
    if ( !( CORE_SELECTOR inside {CORE_MICROBLAZEV} ) ) begin : mem_convert

        // Connect memory interfaces to socket output memory ports
        `ASSIGN_AXI_BUS( rvm_socket_instr, core_instr_to_socket_instr );
        `ASSIGN_AXI_BUS( rvm_socket_data, core_data_to_socket_data );

        // Convert instructions socket (AXI) to core (MEM)
        custom_axi_from_mem axi_from_mem_instr_u (
            // AXI side
            .m_axi_awid     ( core_instr_to_socket_instr_axi_awid       ),
            .m_axi_awaddr   ( core_instr_to_socket_instr_axi_awaddr     ),
            .m_axi_awlen    ( core_instr_to_socket_instr_axi_awlen      ),
            .m_axi_awsize   ( core_instr_to_socket_instr_axi_awsize     ),
            .m_axi_awburst  ( core_instr_to_socket_instr_axi_awburst    ),
            .m_axi_awlock   ( core_instr_to_socket_instr_axi_awlock     ),
            .m_axi_awcache  ( core_instr_to_socket_instr_axi_awcache    ),
            .m_axi_awprot   ( core_instr_to_socket_instr_axi_awprot     ),
            .m_axi_awqos    ( core_instr_to_socket_instr_axi_awqos      ),
            .m_axi_awregion ( core_instr_to_socket_instr_axi_awregion   ),
            .m_axi_awvalid  ( core_instr_to_socket_instr_axi_awvalid    ),
            .m_axi_awready  ( core_instr_to_socket_instr_axi_awready    ),
            .m_axi_wdata    ( core_instr_to_socket_instr_axi_wdata      ),
            .m_axi_wstrb    ( core_instr_to_socket_instr_axi_wstrb      ),
            .m_axi_wlast    ( core_instr_to_socket_instr_axi_wlast      ),
            .m_axi_wvalid   ( core_instr_to_socket_instr_axi_wvalid     ),
            .m_axi_wready   ( core_instr_to_socket_instr_axi_wready     ),
            .m_axi_bid      ( core_instr_to_socket_instr_axi_bid        ),
            .m_axi_bresp    ( core_instr_to_socket_instr_axi_bresp      ),
            .m_axi_bvalid   ( core_instr_to_socket_instr_axi_bvalid     ),
            .m_axi_bready   ( core_instr_to_socket_instr_axi_bready     ),
            .m_axi_araddr   ( core_instr_to_socket_instr_axi_araddr     ),
            .m_axi_arlen    ( core_instr_to_socket_instr_axi_arlen      ),
            .m_axi_arsize   ( core_instr_to_socket_instr_axi_arsize     ),
            .m_axi_arburst  ( core_instr_to_socket_instr_axi_arburst    ),
            .m_axi_arlock   ( core_instr_to_socket_instr_axi_arlock     ),
            .m_axi_arcache  ( core_instr_to_socket_instr_axi_arcache    ),
            .m_axi_arprot   ( core_instr_to_socket_instr_axi_arprot     ),
            .m_axi_arqos    ( core_instr_to_socket_instr_axi_arqos      ),
            .m_axi_arregion ( core_instr_to_socket_instr_axi_arregion   ),
            .m_axi_arvalid  ( core_instr_to_socket_instr_axi_arvalid    ),
            .m_axi_arready  ( core_instr_to_socket_instr_axi_arready    ),
            .m_axi_arid     ( core_instr_to_socket_instr_axi_arid       ),
            .m_axi_rid      ( core_instr_to_socket_instr_axi_rid        ),
            .m_axi_rdata    ( core_instr_to_socket_instr_axi_rdata      ),
            .m_axi_rresp    ( core_instr_to_socket_instr_axi_rresp      ),
            .m_axi_rlast    ( core_instr_to_socket_instr_axi_rlast      ),
            .m_axi_rvalid   ( core_instr_to_socket_instr_axi_rvalid     ),
            .m_axi_rready   ( core_instr_to_socket_instr_axi_rready     ),

            // MEM side
            .clk_i              ( clk_i                 ),
            .rst_ni             ( rst_ni                ),
            .s_mem_req          ( core_instr_mem_req    ),
            .s_mem_addr         ( core_instr_mem_addr   ),
            .s_mem_we           ( '0                    ),  // RO Interface
            .s_mem_wdata        ( '0                    ),  // RO Interface
            .s_mem_be           ( '0                    ),  // RO Interface
            .s_mem_gnt          ( core_instr_mem_gnt    ),
            .s_mem_valid        ( core_instr_mem_valid  ),
            .s_mem_rdata        ( core_instr_mem_rdata  ),
            .s_mem_error        ( core_instr_mem_error  )
        );

        // Convert instructions socket (AXI) to core (MEM)
        custom_axi_from_mem axi_from_mem_data_u (
            // AXI side
            .m_axi_awid     ( core_data_to_socket_data_axi_awid       ),
            .m_axi_awaddr   ( core_data_to_socket_data_axi_awaddr     ),
            .m_axi_awlen    ( core_data_to_socket_data_axi_awlen      ),
            .m_axi_awsize   ( core_data_to_socket_data_axi_awsize     ),
            .m_axi_awburst  ( core_data_to_socket_data_axi_awburst    ),
            .m_axi_awlock   ( core_data_to_socket_data_axi_awlock     ),
            .m_axi_awcache  ( core_data_to_socket_data_axi_awcache    ),
            .m_axi_awprot   ( core_data_to_socket_data_axi_awprot     ),
            .m_axi_awqos    ( core_data_to_socket_data_axi_awqos      ),
            .m_axi_awregion ( core_data_to_socket_data_axi_awregion   ),
            .m_axi_awvalid  ( core_data_to_socket_data_axi_awvalid    ),
            .m_axi_awready  ( core_data_to_socket_data_axi_awready    ),
            .m_axi_wdata    ( core_data_to_socket_data_axi_wdata      ),
            .m_axi_wstrb    ( core_data_to_socket_data_axi_wstrb      ),
            .m_axi_wlast    ( core_data_to_socket_data_axi_wlast      ),
            .m_axi_wvalid   ( core_data_to_socket_data_axi_wvalid     ),
            .m_axi_wready   ( core_data_to_socket_data_axi_wready     ),
            .m_axi_bid      ( core_data_to_socket_data_axi_bid        ),
            .m_axi_bresp    ( core_data_to_socket_data_axi_bresp      ),
            .m_axi_bvalid   ( core_data_to_socket_data_axi_bvalid     ),
            .m_axi_bready   ( core_data_to_socket_data_axi_bready     ),
            .m_axi_araddr   ( core_data_to_socket_data_axi_araddr     ),
            .m_axi_arlen    ( core_data_to_socket_data_axi_arlen      ),
            .m_axi_arsize   ( core_data_to_socket_data_axi_arsize     ),
            .m_axi_arburst  ( core_data_to_socket_data_axi_arburst    ),
            .m_axi_arlock   ( core_data_to_socket_data_axi_arlock     ),
            .m_axi_arcache  ( core_data_to_socket_data_axi_arcache    ),
            .m_axi_arprot   ( core_data_to_socket_data_axi_arprot     ),
            .m_axi_arqos    ( core_data_to_socket_data_axi_arqos      ),
            .m_axi_arregion ( core_data_to_socket_data_axi_arregion   ),
            .m_axi_arvalid  ( core_data_to_socket_data_axi_arvalid    ),
            .m_axi_arready  ( core_data_to_socket_data_axi_arready    ),
            .m_axi_arid     ( core_data_to_socket_data_axi_arid       ),
            .m_axi_rid      ( core_data_to_socket_data_axi_rid        ),
            .m_axi_rdata    ( core_data_to_socket_data_axi_rdata      ),
            .m_axi_rresp    ( core_data_to_socket_data_axi_rresp      ),
            .m_axi_rlast    ( core_data_to_socket_data_axi_rlast      ),
            .m_axi_rvalid   ( core_data_to_socket_data_axi_rvalid     ),
            .m_axi_rready   ( core_data_to_socket_data_axi_rready     ),

            // MEM side
            .clk_i              ( clk_i                     ),
            .rst_ni             ( rst_ni                    ),
            .s_mem_req          ( core_data_mem_req         ),
            .s_mem_addr         ( core_data_mem_addr        ),
            .s_mem_we           ( core_data_mem_we          ),
            .s_mem_wdata        ( core_data_mem_wdata       ),
            .s_mem_be           ( core_data_mem_be          ),
            .s_mem_gnt          ( core_data_mem_gnt         ),
            .s_mem_valid        ( core_data_mem_valid       ),
            .s_mem_rdata        ( core_data_mem_rdata       ),
            .s_mem_error        ( core_data_mem_error       )
        );
    end

    ///////////////////////////////////
    //    ___  ___ ___ _   _  ___    //
    //   |   \| __| _ ) | | |/ __|   //
    //   | |) | _|| _ \ |_| | (_ |   //
    //   |___/|___|___/\___/ \___|   //
    //                               //
    ///////////////////////////////////
    // Debug sub-modules
    //
    //  This would be the most basic RISC-V DMI-compliant design. Unfortunately, the interfaces of PULP DM are not precisely DMI-compliant
    //  ______________                 ________________               ______________
    // |              |               | (JtagExtBscan) |             |    (PULP)    |
    // | Debug bridge | --- BSCAN --> |    bscan2dmi   | --- DMI --> |    dm_top    | -- debug_req_core -->
    // |______________|               |________________|             |______________|
    //                                                                 |           ^
    //                                                                 v           |
    //                                                            MEM master   MEM slave
    //                                                                 |           |
    //                                                               MEM2AXI    AXI2MEM
    //                                                                 |           ^
    //                                                                 v           |
    //  ______________________                 ______________________                 _______________                ____________________
    // |  (BSCAN primitive)   |               | (BSCAN-to-Debug Hub) |               |               |              |                    |
    // | BSCANE2/Debug bridge | --- BSCAN --> |     Debug bridge     | --- BSCAN --> | bscan_to_jtag | --- JTAG --> | custom_riscv_debug | --- debug_req_core -->
    // |______________________|               |______________________|               |_______________|              |____________________|
    //                                                                                                                  |             ^         _________
    //                                                                                                                  v             |        |         |
    //                                                                                                             MEM master     MEM slave <--| AXI2MEM | <-- AXI slave ---
    //                                                                                                                  |                      |_________|
    //                                                                                                                  |                       _________
    //                                                                                                                  |                      |         |
    //                                                                                                                  \--------------------->| MEM2AXI | --- AXI master -->
    //                                                                                                                                         |_________|
    generate
    if ( DEBUG_MODULE == 1 ) begin : dm_gen
        // BSCAN interface
        logic S_BSCAN_bscanid_en , m0_bscan_bscanid_en;
        logic S_BSCAN_capture    , m0_bscan_capture;
        logic S_BSCAN_drck       , m0_bscan_drck;
        logic S_BSCAN_reset      , m0_bscan_reset;
        logic S_BSCAN_runtest    , m0_bscan_runtest;
        logic S_BSCAN_sel        , m0_bscan_sel;
        logic S_BSCAN_shift      , m0_bscan_shift;
        logic S_BSCAN_tck        , m0_bscan_tck;
        logic S_BSCAN_tdi        , m0_bscan_tdi;
        logic S_BSCAN_tdo        , m0_bscan_tdo;
        logic S_BSCAN_tms        , m0_bscan_tms;
        logic S_BSCAN_update     , m0_bscan_update;
        // JTAG Interface
        logic jtag_tdo;
        logic jtag_tdi;
        logic jtag_tms;
        logic jtag_tck;
        logic jtag_trst_n;
        // Tie-off unused signals
        assign dbg_master_mem_end_wdata = '0;
        assign dbg_master_mem_end_be    = '0;
        //////////////////
        // Debug bridge //
        //////////////////
        // In BSCAN primitive mode
        xlnx_debug_bridge_bscan debug_bridge_bscan_u (
            .m0_bscan_bscanid_en    ( S_BSCAN_bscanid_en ), // output wire m0_bscan_bscanid_en
            .m0_bscan_capture       ( S_BSCAN_capture    ), // output wire m0_bscan_capture
            .m0_bscan_drck          ( S_BSCAN_drck       ), // output wire m0_bscan_drck
            .m0_bscan_reset         ( S_BSCAN_reset      ), // output wire m0_bscan_reset
            .m0_bscan_runtest       ( S_BSCAN_runtest    ), // output wire m0_bscan_runtest
            .m0_bscan_sel           ( S_BSCAN_sel        ), // output wire m0_bscan_sel
            .m0_bscan_shift         ( S_BSCAN_shift      ), // output wire m0_bscan_shift
            .m0_bscan_tck           ( S_BSCAN_tck        ), // output wire m0_bscan_tck
            .m0_bscan_tdi           ( S_BSCAN_tdi        ), // output wire m0_bscan_tdi
            .m0_bscan_tdo           ( S_BSCAN_tdo        ), // input wire m0_bscan_tdo
            .m0_bscan_tms           ( S_BSCAN_tms        ), // output wire m0_bscan_tms
            .m0_bscan_update        ( S_BSCAN_update     )  // output wire m0_bscan_update
        );
        // // BSCANE2 primitive
        // BSCANE2 #(
        //     .JTAG_CHAIN(1)  // Value for USER command. (Must match debug_bridge_u IP config)
        // ) BSCANE2_u (
        //     .CAPTURE ( S_BSCAN_capture ), // 1-bit output: CAPTURE output from TAP controller.
        //     .DRCK    ( S_BSCAN_drck    ), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
        //     .RESET   ( S_BSCAN_reset   ), // 1-bit output: Reset output for TAP controller.
        //     .RUNTEST ( S_BSCAN_runtest ), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
        //     .SEL     ( S_BSCAN_sel     ), // 1-bit output: USER instruction active output.
        //     .SHIFT   ( S_BSCAN_shift   ), // 1-bit output: SHIFT output from TAP controller.
        //     .TCK     ( S_BSCAN_tck     ), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
        //     .TDI     ( S_BSCAN_tdi     ), // 1-bit output: Test Data Input (TDI) output from TAP controller.
        //     .TMS     ( S_BSCAN_tms     ), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
        //     .UPDATE  ( S_BSCAN_update  ), // 1-bit output: UPDATE output from TAP controller
        //     .TDO     ( S_BSCAN_tdo     )  // 1-bit input: Test Data Output (TDO) input for USER function.
        // );
        // In BSCAN-to-Debug Hub mode
        xlnx_debug_bridge debug_bridge_u (
            .clk                 ( clk_i               ), // input wire clk
            .S_BSCAN_bscanid_en  ( S_BSCAN_bscanid_en  ), // input wire S_BSCAN_bscanid_en
            .S_BSCAN_capture     ( S_BSCAN_capture     ), // input wire S_BSCAN_capture
            .S_BSCAN_drck        ( S_BSCAN_drck        ), // input wire S_BSCAN_drck
            .S_BSCAN_reset       ( S_BSCAN_reset       ), // input wire S_BSCAN_reset
            .S_BSCAN_runtest     ( S_BSCAN_runtest     ), // input wire S_BSCAN_runtest
            .S_BSCAN_sel         ( S_BSCAN_sel         ), // input wire S_BSCAN_sel
            .S_BSCAN_shift       ( S_BSCAN_shift       ), // input wire S_BSCAN_shift
            .S_BSCAN_tck         ( S_BSCAN_tck         ), // input wire S_BSCAN_tck
            .S_BSCAN_tdi         ( S_BSCAN_tdi         ), // input wire S_BSCAN_tdi
            .S_BSCAN_tdo         ( S_BSCAN_tdo         ), // output wire S_BSCAN_tdo
            .S_BSCAN_tms         ( S_BSCAN_tms         ), // input wire S_BSCAN_tms
            .S_BSCAN_update      ( S_BSCAN_update      ), // input wire S_BSCAN_update
            .m0_bscan_bscanid_en ( m0_bscan_bscanid_en ), // output wire m0_bscan_bscanid_en
            .m0_bscan_capture    ( m0_bscan_capture    ), // output wire m0_bscan_capture
            .m0_bscan_drck       ( m0_bscan_drck       ), // output wire m0_bscan_drck
            .m0_bscan_reset      ( m0_bscan_reset      ), // output wire m0_bscan_reset
            .m0_bscan_runtest    ( m0_bscan_runtest    ), // output wire m0_bscan_runtest
            .m0_bscan_sel        ( m0_bscan_sel        ), // output wire m0_bscan_sel
            .m0_bscan_shift      ( m0_bscan_shift      ), // output wire m0_bscan_shift
            .m0_bscan_tck        ( m0_bscan_tck        ), // output wire m0_bscan_tck
            .m0_bscan_tdi        ( m0_bscan_tdi        ), // output wire m0_bscan_tdi
            .m0_bscan_tdo        ( m0_bscan_tdo        ), // input wire m0_bscan_tdo
            .m0_bscan_tms        ( m0_bscan_tms        ), // output wire m0_bscan_tms
            .m0_bscan_update     ( m0_bscan_update     )  // output wire m0_bscan_update
        );

        ///////////////////
        // BSCAN to JTAG //
        ///////////////////

        xlnx_bscan_to_jtag bscan_to_jtag_u (
            .S_BSCAN_bscanid_en ( m0_bscan_bscanid_en ), // input wire S_BSCAN_bscanid_en
            .S_BSCAN_capture    ( m0_bscan_capture    ), // input wire S_BSCAN_capture
            .S_BSCAN_drck       ( m0_bscan_drck       ), // input wire S_BSCAN_drck
            .S_BSCAN_reset      ( m0_bscan_reset      ), // input wire S_BSCAN_reset
            .S_BSCAN_runtest    ( m0_bscan_runtest    ), // input wire S_BSCAN_runtest
            .S_BSCAN_sel        ( m0_bscan_sel        ), // input wire S_BSCAN_sel
            .S_BSCAN_shift      ( m0_bscan_shift      ), // input wire S_BSCAN_shift
            .S_BSCAN_tck        ( m0_bscan_tck        ), // input wire S_BSCAN_tck
            .S_BSCAN_tdi        ( m0_bscan_tdi        ), // input wire S_BSCAN_tdi
            .S_BSCAN_tms        ( m0_bscan_tms        ), // input wire S_BSCAN_tms
            .S_BSCAN_update     ( m0_bscan_update     ), // input wire S_BSCAN_update
            .S_BSCAN_tdo        ( m0_bscan_tdo        ), // output wire S_BSCAN_tdo
            .JTAG_TDO           ( jtag_tdo            ), // input wire JTAG_TDO
            .JTAG_TDI           ( jtag_tdi            ), // output wire JTAG_TDI
            .JTAG_TMS           ( jtag_tms            ), // output wire JTAG_TMS
            .JTAG_TCK           ( jtag_tck            )  // output wire JTAG_TCK
        );

        ///////////////
        // Hart Info //
        ///////////////

        // From ariane_pkg::DebugHartInfo
        // TODO: compare with riscy in demo system
        // TODO: export in uninasoc_pkg
        logic [31:24] hartinfo_i_zero1;
        logic [23:20] hartinfo_i_nscratch;
        logic [19:17] hartinfo_i_zero0;
        logic         hartinfo_i_dataaccess;
        logic [15:12] hartinfo_i_datasize;
        logic [11:0]  hartinfo_i_dataaddr;
        localparam logic [3:0] DataCount = 4'h2;
        localparam logic [11:0] DataAddr = 12'h380;  // we are aligned with Rocket here
        assign hartinfo_zero1       = '0;
        assign hartinfo_nscratch    = 2;  // Debug module needs at least two scratch regs
        assign hartinfo_zero0       = '0;
        assign hartinfo_dataaccess  = 1'b1;  // data registers are memory mapped in the debugger
        assign hartinfo_datasize    = DataCount;
        assign hartinfo_dataaddr    = DataAddr;

        ////////////////////
        // DMI top module //
        ////////////////////

        // (* keep = 1 *) logic jtag_tdo_oe; // Unconnected
        // Drive floating JTAG signals
        assign jtag_trst_n = rst_ni;
        // custom_riscv_dbg_bscane riscv_dgb_u (   // BSCANE2 tap
        custom_riscv_dbg riscv_dgb_u (       // JTAG tap
            .clk_i                  ( clk_i                  ),
            .rst_ni                 ( rst_ni                 ),
            .testmode_i             ( '0                     ),
            .unavailable_i          ( '0                     ),
            .ndmreset_o             (                        ),
            .dmactive_o             (                        ),
            // Hartinfo
            .hartinfo_i_zero1       ( hartinfo_zero1         ),
            .hartinfo_i_nscratch    ( hartinfo_nscratch      ),
            .hartinfo_i_zero0       ( hartinfo_zero0         ),
            .hartinfo_i_dataaccess  ( hartinfo_dataaccess    ),
            .hartinfo_i_datasize    ( hartinfo_datasize      ),
            .hartinfo_i_dataaddr    ( hartinfo_dataaddr      ),
            // Mem Master
            .dbg_master_mem_req     ( dbg_master_mem_req    ),
            .dbg_master_mem_gnt     ( dbg_master_mem_gnt    ),
            .dbg_master_mem_valid   ( dbg_master_mem_valid  ),
            .dbg_master_mem_addr    ( dbg_master_mem_addr   ),
            .dbg_master_mem_rdata   ( dbg_master_mem_rdata  ),
            .dbg_master_mem_wdata   ( dbg_master_mem_wdata  ),
            .dbg_master_mem_we      ( dbg_master_mem_we     ),
            .dbg_master_mem_be      ( dbg_master_mem_be     ),
            .dbg_master_mem_error   ( dbg_master_mem_error  ),
            // Mem Slave
            .dbg_slave_mem_req      ( dbg_slave_mem_req     ),
            .dbg_slave_mem_gnt      ( dbg_slave_mem_gnt     ),
            .dbg_slave_mem_valid    ( dbg_slave_mem_valid   ),
            .dbg_slave_mem_addr     ( dbg_slave_mem_addr    ),
            .dbg_slave_mem_rdata    ( dbg_slave_mem_rdata   ),
            .dbg_slave_mem_wdata    ( dbg_slave_mem_wdata   ),
            .dbg_slave_mem_we       ( dbg_slave_mem_we      ),
            .dbg_slave_mem_be       ( dbg_slave_mem_be      ),
            .dbg_slave_mem_error    ( dbg_slave_mem_error   ),
            // JTAG interface
            .jtag_trst_ni           ( jtag_trst_n           ),
            .jtag_tck_i             ( jtag_tck              ),
            .jtag_tms_i             ( jtag_tms              ),
            .jtag_tdi_i             ( jtag_tdi              ),
            .jtag_tdo_o             ( jtag_tdo              ),
            .jtag_tdo_oe_o          ( jtag_tdo_oe           ),
            // To core
            .debug_req_o            ( debug_req_core        )
        );

        // MEM to AXI converter
        // dbg_master_mem -> axi_from_mem ->dbg_master_axi
        custom_axi_from_mem axi_from_mem_dbg_master_u (
            // AXI side
            .m_axi_awid         ( dbg_master_axi_awid       ),
            .m_axi_awaddr       ( dbg_master_axi_awaddr     ),
            .m_axi_awlen        ( dbg_master_axi_awlen      ),
            .m_axi_awsize       ( dbg_master_axi_awsize     ),
            .m_axi_awburst      ( dbg_master_axi_awburst    ),
            .m_axi_awlock       ( dbg_master_axi_awlock     ),
            .m_axi_awcache      ( dbg_master_axi_awcache    ),
            .m_axi_awprot       ( dbg_master_axi_awprot     ),
            .m_axi_awqos        ( dbg_master_axi_awqos      ),
            .m_axi_awregion     ( dbg_master_axi_awregion   ),
            .m_axi_awvalid      ( dbg_master_axi_awvalid    ),
            .m_axi_awready      ( dbg_master_axi_awready    ),
            .m_axi_wdata        ( dbg_master_axi_wdata      ),
            .m_axi_wstrb        ( dbg_master_axi_wstrb      ),
            .m_axi_wlast        ( dbg_master_axi_wlast      ),
            .m_axi_wvalid       ( dbg_master_axi_wvalid     ),
            .m_axi_wready       ( dbg_master_axi_wready     ),
            .m_axi_bid          ( dbg_master_axi_bid        ),
            .m_axi_bresp        ( dbg_master_axi_bresp      ),
            .m_axi_bvalid       ( dbg_master_axi_bvalid     ),
            .m_axi_bready       ( dbg_master_axi_bready     ),
            .m_axi_araddr       ( dbg_master_axi_araddr     ),
            .m_axi_arlen        ( dbg_master_axi_arlen      ),
            .m_axi_arsize       ( dbg_master_axi_arsize     ),
            .m_axi_arburst      ( dbg_master_axi_arburst    ),
            .m_axi_arlock       ( dbg_master_axi_arlock     ),
            .m_axi_arcache      ( dbg_master_axi_arcache    ),
            .m_axi_arprot       ( dbg_master_axi_arprot     ),
            .m_axi_arqos        ( dbg_master_axi_arqos      ),
            .m_axi_arregion     ( dbg_master_axi_arregion   ),
            .m_axi_arvalid      ( dbg_master_axi_arvalid    ),
            .m_axi_arready      ( dbg_master_axi_arready    ),
            .m_axi_arid         ( dbg_master_axi_arid       ),
            .m_axi_rid          ( dbg_master_axi_rid        ),
            .m_axi_rdata        ( dbg_master_axi_rdata      ),
            .m_axi_rresp        ( dbg_master_axi_rresp      ),
            .m_axi_rlast        ( dbg_master_axi_rlast      ),
            .m_axi_rvalid       ( dbg_master_axi_rvalid     ),
            .m_axi_rready       ( dbg_master_axi_rready     ),
            // MEM side
            .clk_i              ( clk_i                      ),
            .rst_ni             ( rst_ni                     ),
            .s_mem_req          ( dbg_master_mem_req         ),
            .s_mem_addr         ( dbg_master_mem_addr        ),
            .s_mem_we           ( dbg_master_mem_we          ),
            .s_mem_wdata        ( dbg_master_mem_end_wdata   ),
            .s_mem_be           ( dbg_master_mem_end_be      ),
            .s_mem_gnt          ( dbg_master_mem_gnt         ),
            .s_mem_valid        ( dbg_master_mem_valid       ),
            .s_mem_rdata        ( dbg_master_mem_rdata       ),
            .s_mem_error        ( dbg_master_mem_error       )
        );

        // AXI to MEM converter
        // dbg_slave_mem -> axi_to_mem -> dbg_slave_axi
        // (* keep = 1 *) logic busy_axi_from_mem;
        custom_axi_to_mem axi_to_mem_dbg_slave_u (
            .clk_i              ( clk_i                    ),
            .rst_ni             ( rst_ni                   ),
            .busy_o             ( busy_axi_from_mem        ),
            // AXI side
            .s_axi_awid         ( dbg_slave_axi_awid       ),
            .s_axi_awaddr       ( dbg_slave_axi_awaddr     ),
            .s_axi_awlen        ( dbg_slave_axi_awlen      ),
            .s_axi_awsize       ( dbg_slave_axi_awsize     ),
            .s_axi_awburst      ( dbg_slave_axi_awburst    ),
            .s_axi_awlock       ( dbg_slave_axi_awlock     ),
            .s_axi_awcache      ( dbg_slave_axi_awcache    ),
            .s_axi_awprot       ( dbg_slave_axi_awprot     ),
            .s_axi_awqos        ( dbg_slave_axi_awqos      ),
            .s_axi_awregion     ( dbg_slave_axi_awregion   ),
            .s_axi_awvalid      ( dbg_slave_axi_awvalid    ),
            .s_axi_awready      ( dbg_slave_axi_awready    ),
            .s_axi_wdata        ( dbg_slave_axi_wdata      ),
            .s_axi_wstrb        ( dbg_slave_axi_wstrb      ),
            .s_axi_wlast        ( dbg_slave_axi_wlast      ),
            .s_axi_wvalid       ( dbg_slave_axi_wvalid     ),
            .s_axi_wready       ( dbg_slave_axi_wready     ),
            .s_axi_bid          ( dbg_slave_axi_bid        ),
            .s_axi_bresp        ( dbg_slave_axi_bresp      ),
            .s_axi_bvalid       ( dbg_slave_axi_bvalid     ),
            .s_axi_bready       ( dbg_slave_axi_bready     ),
            .s_axi_araddr       ( dbg_slave_axi_araddr     ),
            .s_axi_arlen        ( dbg_slave_axi_arlen      ),
            .s_axi_arsize       ( dbg_slave_axi_arsize     ),
            .s_axi_arburst      ( dbg_slave_axi_arburst    ),
            .s_axi_arlock       ( dbg_slave_axi_arlock     ),
            .s_axi_arcache      ( dbg_slave_axi_arcache    ),
            .s_axi_arprot       ( dbg_slave_axi_arprot     ),
            .s_axi_arqos        ( dbg_slave_axi_arqos      ),
            .s_axi_arregion     ( dbg_slave_axi_arregion   ),
            .s_axi_arvalid      ( dbg_slave_axi_arvalid    ),
            .s_axi_arready      ( dbg_slave_axi_arready    ),
            .s_axi_arid         ( dbg_slave_axi_arid       ),
            .s_axi_rid          ( dbg_slave_axi_rid        ),
            .s_axi_rdata        ( dbg_slave_axi_rdata      ),
            .s_axi_rresp        ( dbg_slave_axi_rresp      ),
            .s_axi_rlast        ( dbg_slave_axi_rlast      ),
            .s_axi_rvalid       ( dbg_slave_axi_rvalid     ),
            .s_axi_rready       ( dbg_slave_axi_rready     ),
            // MEM side
            .m_mem_req          ( dbg_slave_mem_req         ),
            .m_mem_addr         ( dbg_slave_mem_addr        ),
            .m_mem_we           ( dbg_slave_mem_we          ),
            .m_mem_wdata        ( dbg_slave_mem_wdata       ),
            .m_mem_be           ( dbg_slave_mem_be          ),
            .m_mem_gnt          ( dbg_slave_mem_gnt         ),
            .m_mem_valid        ( dbg_slave_mem_valid       ),
            .m_mem_rdata        ( dbg_slave_mem_rdata       ),
            .m_mem_error        ( dbg_slave_mem_error       )
        );

    end : dm_gen
    else begin : dm_not_gen

        // Tie-off debug request signal to cores
        assign debug_req_core = '0;
        // Tie-off debug mem master outputs
        assign dbg_master_mem_req = '0;
        assign dbg_master_mem_addr = '0;
        assign dbg_master_mem_wdata = '0;
        assign dbg_master_mem_we = '0;
        assign dbg_master_mem_be = '0;
        // Tie-off debug mem slave outputs
        assign dbg_slave_mem_gnt = '0;
        assign dbg_slave_mem_valid = '0;
        assign dbg_slave_mem_rdata = '0;
        assign dbg_slave_mem_error = '0;

    end : dm_not_gen
    endgenerate

endmodule : rvm_socket
