// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Wrapper module for a RVM core


// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module rvm_socket # (
    parameter CORE_SELECTOR = CORE_MICROBLAZEV,
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter NUM_IRQ       = 3
) (
    input  logic                            clk_i,
    input  logic                            rst_ni,
    input  logic [AXI_ADDR_WIDTH -1 : 0 ]   bootaddr_i,
    input  logic [NUM_IRQ        -1 : 0 ]   irq_i,

    `DEFINE_AXI_MASTER_PORTS(rvm_socket_instr),
    `DEFINE_AXI_MASTER_PORTS(rvm_socket_data)
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

    	// Connect memory interfaces to socket output memory ports
    `ASSIGN_AXI_BUS(rvm_socket_instr, core_instr_to_socket_instr);
    `ASSIGN_AXI_BUS(rvm_socket_data, core_data_to_socket_data);
	

	//////////////////////////////////////////////////////
	//     ___               ___          _          	//
	//    / __|___ _ _ ___  | _ \___ __ _(_)___ _ _  	//
	//   | (__/ _ \ '_/ -_) |   / -_) _` | / _ \ ' \ 	//
	//    \___\___/_| \___| |_|_\___\__, |_\___/_||_|	//
	//                              |___/            	//
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
                .rst_ni   	    	( rst_ni                    ),
                .trap_o     	    (                           ),

                .instr_mem_req      ( core_instr_mem_req        ),
                .instr_mem_gnt      ( core_instr_mem_gnt        ),
                .instr_mem_valid    ( core_instr_mem_valid      ),
                .instr_mem_addr     ( core_instr_mem_addr       ),
                .instr_mem_rdata    ( core_instr_mem_rdata  ),

                .data_mem_req       ( core_data_mem_req         ),
                .data_mem_valid     ( core_data_mem_valid       ),
                .data_mem_gnt       ( core_data_mem_gnt         ),
                .data_mem_we        ( core_data_mem_we          ),
                .data_mem_be        ( core_data_mem_be          ),
                .data_mem_addr      ( core_data_mem_addr        ),
                .data_mem_wdata     ( core_data_mem_wdata       ),
                .data_mem_rdata     ( core_data_mem_rdata   ),

                .irq_i		        ( irq_i                     ),

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

                // Data memory interface
                .data_mem_req           ( core_data_mem_req         ),
                .data_mem_valid         ( core_data_mem_valid       ),
                .data_mem_gnt           ( core_data_mem_gnt         ),
                .data_mem_we            ( core_data_mem_we          ),
                .data_mem_be            ( core_data_mem_be          ),
                .data_mem_addr          ( core_data_mem_addr        ),
                .data_mem_wdata         ( core_data_mem_wdata       ),
                .data_mem_rdata         ( core_data_mem_rdata       ),

                // Interrupt inputs
                .irq_i                  ( irq_i                     ),  // CLINT interrupts + CLINT extension interrupts
                .irq_ack_o              (                           ),  // TBD
                .irq_id_o               (                           ),  // TBD

                // Debug Interface
                .debug_req_i            ( debug_req_core            ),
                .debug_havereset_o      (                           ),  // TBD
                .debug_running_o        (                           ),  // TBD
                .debug_halted_o         (                           ),  // TBD

                // CPU Control Signals
                .fetch_enable_i         ( 1'b1                      ),
                .core_sleep_o           (                           )   // TBD
            );




        else if (CORE_SELECTOR == CORE_MICROBLAZEV) begin: xlnx_microblaze_riscv

            //////////////////////////
            //      MICROBLAZE      //
            //////////////////////////
			`DECLARE_AXI_BUS(microblaze_instr,DATA_WIDTH);
			`DECLARE_AXI_BUS(microblaze_data,DATA_WIDTH);
			`ASSIGN_AXI_BUS( rvm_socket_instr,microblaze_instr ):
    		`ASSIGN_AXI_BUS( rvm_socket_data,microblaze_data );

			xlnx_microblaze_riscv microblaze_riscv (
  				.Clk(clk_i),                             		 // input wire Clk
  				.Reset(rst_ni),                        		  // input wire Reset
  				.Interrupt(irq_i),                  			// input wire Interrupt
 				.Interrupt_Address(Interrupt_Address),  // input wire [0 : 31] Interrupt_Address
  				.Interrupt_Ack(Interrupt_Ack),          // output wire [0 : 1] Interrupt_Ack
 				.M_AXI_IC_AWID(microblaze_instr_axi_awid),			// input wire [0 : 31] Interrupt_Address
 				.M_AXI_IC_AWADDR(microblaze_instr_axi_awaddr),      // output wire [31 : 0] M_AXI_IP_AWADDR
 				.M_AXI_IC_AWLEN(microblaze_axi_awlen),        // output wire [7 : 0] M_AXI_IC_AWLEN
 				.M_AXI_IC_AWSIZE(microblaze_instr_axi_awsize),      // output wire [2 : 0] M_AXI_IC_AWSIZE
 				.M_AXI_IC_AWBURST(microblaze_instruction_axi_awburst),    // output wire [1 : 0] M_AXI_IC_AWBURST
 				.M_AXI_IC_AWLOCK(microblaze_instruction_axi_awlock),      // output wire M_AXI_IC_AWLOCK
  				.M_AXI_IC_AWCACHE(microblaze_axi_awcache),    // output wire [3 : 0] M_AXI_IC_AWCACHE
  				.M_AXI_IC_AWPROT(microblaze_instr_axi_awprot),      // output wire [2 : 0] M_AXI_IP_AWPROT
  				.M_AXI_IC_AWQOS(microblaze_instr_axi_awqos),        // output wire [3 : 0] M_AXI_IC_AWQOS
  				.M_AXI_IC_AWVALID(microblaze_instr_axi_awvalid),    // output wire M_AXI_IP_AWVALID
  				.M_AXI_IC_AWREADY(microblaze_instr_axi_awready),    // input wire M_AXI_IP_AWREADY
  				.M_AXI_IC_AWUSER(microblaze_instr_axi_awuser),      // output wire [4 : 0] M_AXI_IC_AWUSER
 				.M_AXI_IC_WDATA(microblaze_instr_axi_wdata),        // output wire [31 : 0] M_AXI_IP_WDATA
  				.M_AXI_IC_WSTRB(microblaze_instr_axi_wstrb),        // output wire [3 : 0] M_AXI_IP_WSTRB
  				.M_AXI_IC_WLAST(microblaze_instr_axi_wlast),        // output wire M_AXI_IC_WLAST
  				.M_AXI_IC_WVALID(microblaze_instr_axi_wvalid),      // output wire M_AXI_IP_WVALID
  				.M_AXI_IC_WREADY(microblaze_instr_axi_wready),      // input wire M_AXI_IP_WREADY
  				.M_AXI_IC_BRESP(microblaze_instr_axi_bresp),        // input wire [1 : 0] M_AXI_IP_BRESP
  				.M_AXI_IC_BVALID(microblaze_instr_axi_bvalid),      // input wire M_AXI_IP_BVALID
 				.M_AXI_IC_BREADY(microblaze_instr_axi_bready),      // output wire M_AXI_IP_BREADY
 				.M_AXI_IC_ARID(microblaze_instr_axi_arid),          // output wire [0 : 0] M_AXI_IC_ARID
 				.M_AXI_IC_ARADDR(microblaze_instr_axi_araddr),      // output wire [31 : 0] M_AXI_IP_ARADDR
 				.M_AXI_IC_ARLEN(microblaze_instr_axi_arlen),        // output wire [7 : 0] M_AXI_IC_ARLEN
 				.M_AXI_IC_ARSIZE(microblaze_instr_axi_arsize),      // output wire [2 : 0] M_AXI_IC_ARSIZE
  				.M_AXI_IC_ARBURST(microblaze_instr_axi_arburst),    // output wire [1 : 0] M_AXI_IC_ARBURST
  				.M_AXI_IC_ARLOCK(microblaze_instr_axi_arlock),      // output wire M_AXI_IC_ARLOCK
  				.M_AXI_IC_ARCACHE(microblaze_instr_axi_arcache),    // output wire [3 : 0] M_AXI_IC_ARCACHE
 				.M_AXI_IC_ARPROT(microblaze_instr_axi_arprot),      // output wire [2 : 0] M_AXI_IP_ARPROT
 				.M_AXI_IC_ARQOS(microblaze_instr_axi_arqos),        // output wire [3 : 0] M_AXI_IC_ARQOS
  				.M_AXI_IC_ARVALID(microblaze_instr_axi_arvalid),    // output wire M_AXI_IP_ARVALID
  				.M_AXI_IC_ARREADY(microblaze_instr_axi_arready),    // input wire M_AXI_IP_ARREADY
  				.M_AXI_IC_ARUSER(microblaze_instr_axi_aruser),      // output wire [4 : 0] M_AXI_IC_ARUSER
  				.M_AXI_IC_RID(microblaze_isntr_axi_rid),            // input wire [0 : 0] M_AXI_IC_RID
 				.M_AXI_IC_RDATA(microblaze_instr_axi_rdata),        // input wire [31 : 0] M_AXI_IP_RDATA
 				.M_AXI_IC_RRESP(microblaze_instr_axi_rresp),        // input wire [1 : 0] M_AXI_IP_RRESP
 				.M_AXI_IC_RLAST(microblaze_instr_axi_rlast),        // input wire M_AXI_IC_RLAST
 				.M_AXI_IC_RVALID(microblaze_instr_axi_rvalid),      // input wire M_AXI_IP_RVALID
  				.M_AXI_IC_RREADY(microblaze_instr_axi_rready),      // output wire M_AXI_IP_RREADY
				
				.M_AXI_DC_AWID(microblaze_data_axi_awid),
 				.M_AXI_DC_AWADDR(microblaze_data_axi_awaddr),		// output wire [31 : 0] M_AXI_DP_AWADDR
 				.M_AXI_IC_AWLEN(microblaze_data_axi_awlen),        // output wire [7 : 0] M_AXI_IC_AWLEN
 				.M_AXI_IC_AWSIZE(microblaze_data_axi_awsize),      // output wire [2 : 0] M_AXI_IC_AWSIZE
 				.M_AXI_IC_AWBURST(microblaze_instruction_axi_awburst),    // output wire [1 : 0] M_AXI_IC_AWBURST
 				.M_AXI_IC_AWLOCK(microblaze_data_axi_awlock),      // output wire M_AXI_IC_AWLOCK
  				.M_AXI_IC_AWCACHE(microblaze_data_axi_awcache),    // output wire [3 : 0] M_AXI_IC_AWCACHE
				.M_AXI_DC_AWPROT(microblaze_data_axi_awprot),      // output wire [2 : 0] M_AXI_DP_AWPROT
				.M_AXI_IC_AWQOS(microblaze_data_axi_awqos),        // output wire [3 : 0] M_AXI_IC_AWQOS
 				.M_AXI_DC_AWVALID(microblaze_data_axi_awvalid),    // output wire M_AXI_DP_AWVALID
 				.M_AXI_DC_AWREADY(microblaze_data_axi_awready),    // input wire M_AXI_DP_AWREADY
 				.M_AXI_IC_AWUSER(microblaze_data_axi_awuser),      // output wire [4 : 0] M_AXI_IC_AWUSER
 				.M_AXI_DC_WDATA(microblaze_data_axi_wdata),        // output wire [31 : 0] M_AXI_DP_WDATA
 				.M_AXI_DC_WSTRB(microblaze_data_axi_wstrb),        // output wire [3 : 0] M_AXI_DP_WSTRB
 				.M_AXI_IC_WLAST(microblaze_data_axi_wlast),        // output wire M_AXI_IC_WLAST
				.M_AXI_DC_WVALID(microblaze_data_axi_wvalid),      // output wire M_AXI_DP_WVALID
				.M_AXI_DC_WREADY(microblaze_data_axi_wready),      // input wire M_AXI_DP_WREADY
 				.M_AXI_DC_BRESP(microblaze_data_axi_bresp),        // input wire [1 : 0] M_AXI_DP_BRESP
 				.M_AXI_DC_BVALID(microblaze_data_axi_bvalid),      // input wire M_AXI_DP_BVALID
 				.M_AXI_DC_BREADY(microblaze_data_axi_bready),      // output wire M_AXI_DP_BREADY
 				.M_AXI_IC_ARID(microblaze_data_axi_arid),          // output wire [0 : 0] M_AXI_IC_ARID
				.M_AXI_DC_ARADDR(microblaze_data_axi_araddr),      // output wire [31 : 0] M_AXI_DP_ARADDR
				.M_AXI_IC_ARLEN(microblaze_data_axi_arlen),        // output wire [7 : 0] M_AXI_IC_ARLEN
				.M_AXI_IC_ARSIZE(microblaze_data_axi_arsize),      // output wire [2 : 0] M_AXI_IC_ARSIZE
  				.M_AXI_IC_ARBURST(microblaze_data_axi_arburst),    // output wire [1 : 0] M_AXI_IC_ARBURST
  				.M_AXI_IC_ARLOCK(microblaze_data_axi_arlock),      // output wire M_AXI_IC_ARLOCK
  				.M_AXI_IC_ARCACHE(microblaze_data_axi_arcache),    // output wire [3 : 0] M_AXI_IC_ARCACHE
 				.M_AXI_DC_ARPROT(microblaze_data_axi_arprot),      // output wire [2 : 0] M_AXI_DP_ARPROT
 				.M_AXI_IC_ARQOS(microblaze_data_axi_arqos),        // output wire [3 : 0] M_AXI_IC_ARQOS
 				.M_AXI_DC_ARVALID(microblaze_data_axi_arvalid),    // output wire M_AXI_DP_ARVALID
 				.M_AXI_DC_ARREADY(microblaze_data_axi_arready),    // input wire M_AXI_DP_ARREADY
 				.M_AXI_IC_ARUSER(microblaze_data_axi_aruser),      // output wire [4 : 0] M_AXI_IC_ARUSER
  				.M_AXI_IC_RID(microblaze_data_axi_rid),            // input wire [0 : 0] M_AXI_IC_RID
 				.M_AXI_DC_RDATA(microblaze_data_axi_rdata),        // input wire [31 : 0] M_AXI_DP_RDATA
 				.M_AXI_DC_RRESP(microblaze_data_axi_rresp),        // input wire [1 : 0] M_AXI_DP_RRESP
 				.M_AXI_IC_RLAST(microblaze_data_axi_rlast),        // input wire M_AXI_IC_RLAST
 				.M_AXI_DC_RVALID(microblaze_data_axi_rvalid),      // input wire M_AXI_DP_RVALID
 				.M_AXI_DC_RREADY(microblaze_data_axi_rready)      // output wire M_AXI_DP_RREADY
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

    //////////////////////////////////////////////////////////
    //  MEM to AXI-Full converters (Instruction and Data)   //
    //////////////////////////////////////////////////////////

    // Instruction interface conversion

	custom_axi_from_mem axi_from_mem_instr_u (
		// AXI side
        .m_axi_awid			( core_instr_to_socket_instr_axi_awid       ),
        .m_axi_awaddr		( core_instr_to_socket_instr_axi_awaddr     ),
        .m_axi_awlen		( core_instr_to_socket_instr_axi_awlen      ),
        .m_axi_awsize		( core_instr_to_socket_instr_axi_awsize     ),
        .m_axi_awburst	    ( core_instr_to_socket_instr_axi_awburst    ),
        .m_axi_awlock		( core_instr_to_socket_instr_axi_awlock     ),
        .m_axi_awcache	    ( core_instr_to_socket_instr_axi_awcache    ),
        .m_axi_awprot		( core_instr_to_socket_instr_axi_awprot     ),
        .m_axi_awqos		( core_instr_to_socket_instr_axi_awqos      ),
        .m_axi_awregion     ( core_instr_to_socket_instr_axi_awregion   ),
        .m_axi_awvalid      ( core_instr_to_socket_instr_axi_awvalid    ),
        .m_axi_awready      ( core_instr_to_socket_instr_axi_awready    ),
        .m_axi_wdata		( core_instr_to_socket_instr_axi_wdata      ),
        .m_axi_wstrb		( core_instr_to_socket_instr_axi_wstrb      ),
        .m_axi_wlast		( core_instr_to_socket_instr_axi_wlast      ),
        .m_axi_wvalid		( core_instr_to_socket_instr_axi_wvalid     ),
        .m_axi_wready		( core_instr_to_socket_instr_axi_wready     ),
        .m_axi_bid			( core_instr_to_socket_instr_axi_bid        ),
        .m_axi_bresp		( core_instr_to_socket_instr_axi_bresp      ),
        .m_axi_bvalid		( core_instr_to_socket_instr_axi_bvalid     ),
        .m_axi_bready		( core_instr_to_socket_instr_axi_bready     ),
        .m_axi_araddr		( core_instr_to_socket_instr_axi_araddr     ),
        .m_axi_arlen		( core_instr_to_socket_instr_axi_arlen      ),
        .m_axi_arsize		( core_instr_to_socket_instr_axi_arsize     ),
        .m_axi_arburst	    ( core_instr_to_socket_instr_axi_arburst    ),
        .m_axi_arlock		( core_instr_to_socket_instr_axi_arlock     ),
        .m_axi_arcache	    ( core_instr_to_socket_instr_axi_arcache    ),
        .m_axi_arprot		( core_instr_to_socket_instr_axi_arprot     ),
        .m_axi_arqos		( core_instr_to_socket_instr_axi_arqos      ),
        .m_axi_arregion	    ( core_instr_to_socket_instr_axi_arregion   ),
        .m_axi_arvalid	    ( core_instr_to_socket_instr_axi_arvalid    ),
        .m_axi_arready	    ( core_instr_to_socket_instr_axi_arready    ),
        .m_axi_arid			( core_instr_to_socket_instr_axi_arid       ),
        .m_axi_rid			( core_instr_to_socket_instr_axi_rid        ),
        .m_axi_rdata		( core_instr_to_socket_instr_axi_rdata      ),
        .m_axi_rresp		( core_instr_to_socket_instr_axi_rresp      ),
        .m_axi_rlast		( core_instr_to_socket_instr_axi_rlast      ),
        .m_axi_rvalid		( core_instr_to_socket_instr_axi_rvalid     ),
        .m_axi_rready		( core_instr_to_socket_instr_axi_rready     ),

        // MEM side
        .clk_i				( clk_i                 ),
        .rst_ni				( rst_ni                ),
        .s_mem_req			( core_instr_mem_req    ),
        .s_mem_addr			( core_instr_mem_addr   ),
        .s_mem_we			( '0                    ),	// RO Interface
        .s_mem_wdata		( '0                    ),	// RO Interface
        .s_mem_be			( '0                    ),	// RO Interface
        .s_mem_gnt			( core_instr_mem_gnt    ),
        .s_mem_valid	    ( core_instr_mem_valid  ),
        .s_mem_rdata	    ( core_instr_mem_rdata  ),
        .s_mem_error	    ( core_instr_mem_error  )
    );

    // Data interface conversion
	custom_axi_from_mem axi_from_mem_data_u (
		// AXI side
        .m_axi_awid			( core_data_to_socket_data_axi_awid       ),
        .m_axi_awaddr		( core_data_to_socket_data_axi_awaddr     ),
        .m_axi_awlen		( core_data_to_socket_data_axi_awlen      ),
        .m_axi_awsize		( core_data_to_socket_data_axi_awsize     ),
        .m_axi_awburst	    ( core_data_to_socket_data_axi_awburst    ),
        .m_axi_awlock		( core_data_to_socket_data_axi_awlock     ),
        .m_axi_awcache	    ( core_data_to_socket_data_axi_awcache    ),
        .m_axi_awprot		( core_data_to_socket_data_axi_awprot     ),
        .m_axi_awqos		( core_data_to_socket_data_axi_awqos      ),
        .m_axi_awregion     ( core_data_to_socket_data_axi_awregion   ),
        .m_axi_awvalid      ( core_data_to_socket_data_axi_awvalid    ),
        .m_axi_awready      ( core_data_to_socket_data_axi_awready    ),
        .m_axi_wdata		( core_data_to_socket_data_axi_wdata      ),
        .m_axi_wstrb		( core_data_to_socket_data_axi_wstrb      ),
        .m_axi_wlast		( core_data_to_socket_data_axi_wlast      ),
        .m_axi_wvalid		( core_data_to_socket_data_axi_wvalid     ),
        .m_axi_wready		( core_data_to_socket_data_axi_wready     ),
        .m_axi_bid			( core_data_to_socket_data_axi_bid        ),
        .m_axi_bresp		( core_data_to_socket_data_axi_bresp      ),
        .m_axi_bvalid		( core_data_to_socket_data_axi_bvalid     ),
        .m_axi_bready		( core_data_to_socket_data_axi_bready     ),
        .m_axi_araddr		( core_data_to_socket_data_axi_araddr     ),
        .m_axi_arlen		( core_data_to_socket_data_axi_arlen      ),
        .m_axi_arsize		( core_data_to_socket_data_axi_arsize     ),
        .m_axi_arburst	    ( core_data_to_socket_data_axi_arburst    ),
        .m_axi_arlock		( core_data_to_socket_data_axi_arlock     ),
        .m_axi_arcache	    ( core_data_to_socket_data_axi_arcache    ),
        .m_axi_arprot		( core_data_to_socket_data_axi_arprot     ),
        .m_axi_arqos		( core_data_to_socket_data_axi_arqos      ),
        .m_axi_arregion	    ( core_data_to_socket_data_axi_arregion   ),
        .m_axi_arvalid	    ( core_data_to_socket_data_axi_arvalid    ),
        .m_axi_arready	    ( core_data_to_socket_data_axi_arready    ),
        .m_axi_arid			( core_data_to_socket_data_axi_arid       ),
        .m_axi_rid			( core_data_to_socket_data_axi_rid        ),
        .m_axi_rdata		( core_data_to_socket_data_axi_rdata      ),
        .m_axi_rresp		( core_data_to_socket_data_axi_rresp      ),
        .m_axi_rlast		( core_data_to_socket_data_axi_rlast      ),
        .m_axi_rvalid		( core_data_to_socket_data_axi_rvalid     ),
        .m_axi_rready		( core_data_to_socket_data_axi_rready     ),

		// MEM side
        .clk_i              ( clk_i                     ),
        .rst_ni             ( rst_ni                    ),
        .s_mem_req          ( core_data_mem_req         ),
        .s_mem_addr         ( core_data_mem_addr        ),
        .s_mem_we           ( core_data_mem_we          ),
        .s_mem_wdata        ( core_data_mem_wdata       ),
        .s_mem_be	        ( core_data_mem_be          ),
        .s_mem_gnt	        ( core_data_mem_gnt         ),
        .s_mem_valid        ( core_data_mem_valid       ),
        .s_mem_rdata	    ( core_data_mem_rdata       ),
        .s_mem_error	    ( core_data_mem_error       )
    );
	

endmodule : rvm_socket
