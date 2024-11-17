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
	
	// Declare AXI interfaces for instruction memory port and data memory port for MicroblazeV 
	`DECLARE_AXI_BUS(microblaze_instr,DATA_WIDTH);
	`DECLARE_AXI_BUS(microblaze_data,DATA_WIDTH);

	

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



		end
        else if (CORE_SELECTOR == CORE_MICROBLAZEV) begin: xlnx_microblaze_riscv

            //////////////////////////
            //      MICROBLAZE      //
            //////////////////////////

			
			////////////////////////////
			// Compatibility settings //
			////////////////////////////
			
			// ID's are of size one in microblaze, while the BUS has size 2. First bit is assigned, second is set to 0.
			assign microblaze_instr_axi_awid[1]='0;
			assign microblaze_instr_axi_bid[1]='0;
			assign microblaze_instr_axi_arid[1]='0;
			assign microblaze_instr_axi_rid[1]='0;
			assign microblaze_data_axi_awid[1]='0;
			assign microblaze_data_axi_bid[1]='0;
			assign microblaze_data_axi_arid[1]='0;
			assign microblaze_data_axi_rid[1]='0;
			
			// Regions are not present in microblaze implementation so they are set to 0.
			assign microblaze_instr_axi_awregion='0;
			assign microblaze_instr_axi_arregion='0;
			assign microblaze_data_axi_awregion='0;
			assign microblaze_data_axi_arregion='0;
			
			// Users are not implemented in bus but are present in microblaze, so they are not set.
			// Microblaze takes Reset as 1 so rst_ni is negated.
			// Last warning to be solved is about interrupt irq_i size (rvm has 2, microblaze has 1)
			
			//assign irq_i[1]='0;
			//assign irq_i[2]='0;
			
			xlnx_microblaze_riscv microblaze_riscv (
  				.Clk					( clk_i),                             				 // input wire Clk
  				.Reset					( ~rst_ni),                        				  // input wire Reset
  				.Interrupt				( irq_i[0]),                  						// input wire Interrupt
 				.Interrupt_Address		( bootaddr_i),  							// input wire [0 : 31] Interrupt_Address
  				.Interrupt_Ack			( ),          								// output wire [0 : 1] Interrupt_Ack
 				
				.Dbg_Clk(Dbg_Clk),                      // input wire Dbg_Clk
  				.Dbg_TDI(Dbg_TDI),                      // input wire Dbg_TDI
 				.Dbg_TDO(Dbg_TDO),                      // output wire Dbg_TDO
 				.Dbg_Reg_En(Dbg_Reg_En_0),                // input wire [0 : 7] Dbg_Reg_En
 				.Dbg_Shift(Dbg_Shift),                  // input wire Dbg_Shift
 				.Dbg_Capture(Dbg_Capture),              // input wire Dbg_Capture
 				.Dbg_Update(Dbg_Update),                // input wire Dbg_Update
 				.Debug_Rst(Debug_Rst),                  // input wire Debug_Rst
  				.Dbg_Disable(Dbg_Disable),              // input wire Dbg_Disable
 				
 				.M_AXI_IC_AWID			( microblaze_instr_axi_awid[0]),			
 				.M_AXI_IC_AWADDR		( microblaze_instr_axi_awaddr),      
 				.M_AXI_IC_AWLEN			( microblaze_instr_axi_awlen),       
 				.M_AXI_IC_AWSIZE		( microblaze_instr_axi_awsize),      
 				.M_AXI_IC_AWBURST		( microblaze_instr_axi_awburst),    
 				.M_AXI_IC_AWLOCK		( microblaze_instr_axi_awlock),      
  				.M_AXI_IC_AWCACHE		( microblaze_instr_axi_awcache),   
  				.M_AXI_IC_AWPROT		( microblaze_instr_axi_awprot),      
  				.M_AXI_IC_AWQOS			( microblaze_instr_axi_awqos),        
  				.M_AXI_IC_AWVALID		( microblaze_instr_axi_awvalid),   
  				.M_AXI_IC_AWREADY		( microblaze_instr_axi_awready),    
  				.M_AXI_IC_AWUSER		( ),      							
 				.M_AXI_IC_WDATA			( microblaze_instr_axi_wdata),        
  				.M_AXI_IC_WSTRB			( microblaze_instr_axi_wstrb),        
  				.M_AXI_IC_WLAST			( microblaze_instr_axi_wlast),        
  				.M_AXI_IC_WVALID		( microblaze_instr_axi_wvalid),      
  				.M_AXI_IC_WREADY		( microblaze_instr_axi_wready),      
  				.M_AXI_IC_BID			( microblaze_instr_axi_bid[0]),            
  				.M_AXI_IC_BRESP			( microblaze_instr_axi_bresp),        
  				.M_AXI_IC_BVALID		( microblaze_instr_axi_bvalid),      
 				.M_AXI_IC_BREADY		( microblaze_instr_axi_bready),      
 				.M_AXI_IC_ARID			( microblaze_instr_axi_arid[0]),          
 				.M_AXI_IC_ARADDR		( microblaze_instr_axi_araddr),      
 				.M_AXI_IC_ARLEN			( microblaze_instr_axi_arlen),        
 				.M_AXI_IC_ARSIZE		( microblaze_instr_axi_arsize),      
  				.M_AXI_IC_ARBURST		( microblaze_instr_axi_arburst),    
  				.M_AXI_IC_ARLOCK		( microblaze_instr_axi_arlock),      
  				.M_AXI_IC_ARCACHE		( microblaze_instr_axi_arcache),    
 				.M_AXI_IC_ARPROT		( microblaze_instr_axi_arprot),      
 				.M_AXI_IC_ARQOS			( microblaze_instr_axi_arqos),        
  				.M_AXI_IC_ARVALID		( microblaze_instr_axi_arvalid),    
  				.M_AXI_IC_ARREADY		( microblaze_instr_axi_arready),    
  				.M_AXI_IC_ARUSER		( ),     							
  				.M_AXI_IC_RID			( microblaze_instr_axi_rid[0]),            
 				.M_AXI_IC_RDATA			( microblaze_instr_axi_rdata),        
 				.M_AXI_IC_RRESP			( microblaze_instr_axi_rresp),        
 				.M_AXI_IC_RLAST			( microblaze_instr_axi_rlast),       
 				.M_AXI_IC_RVALID		( microblaze_instr_axi_rvalid),      
  				.M_AXI_IC_RREADY		( microblaze_instr_axi_rready),      
				
				.M_AXI_DC_AWID(microblaze_data_axi_awid[0]),
 				.M_AXI_DC_AWADDR(microblaze_data_axi_awaddr),		
 				.M_AXI_DC_AWLEN(microblaze_data_axi_awlen),        
 				.M_AXI_DC_AWSIZE(microblaze_data_axi_awsize),      
 				.M_AXI_DC_AWBURST(microblaze_data_axi_awburst),    
 				.M_AXI_DC_AWLOCK(microblaze_data_axi_awlock),      
  				.M_AXI_DC_AWCACHE(microblaze_data_axi_awcache),    
				.M_AXI_DC_AWPROT(microblaze_data_axi_awprot),      
				.M_AXI_DC_AWQOS(microblaze_data_axi_awqos),       
 				.M_AXI_DC_AWVALID(microblaze_data_axi_awvalid),    
 				.M_AXI_DC_AWREADY(microblaze_data_axi_awready),    
 				.M_AXI_DC_AWUSER(),      							
 				.M_AXI_DC_WDATA(microblaze_data_axi_wdata),       
 				.M_AXI_DC_WSTRB(microblaze_data_axi_wstrb),       
 				.M_AXI_DC_WLAST(microblaze_data_axi_wlast),        
				.M_AXI_DC_WVALID(microblaze_data_axi_wvalid),      
				.M_AXI_DC_WREADY(microblaze_data_axi_wready),     
				.M_AXI_DC_BID(microblaze_data_axi_bid[0]),           
 				.M_AXI_DC_BRESP(microblaze_data_axi_bresp),        
 				.M_AXI_DC_BVALID(microblaze_data_axi_bvalid),      
 				.M_AXI_DC_BREADY(microblaze_data_axi_bready),      
 				.M_AXI_DC_ARID(microblaze_data_axi_arid[0]),          
				.M_AXI_DC_ARADDR(microblaze_data_axi_araddr),      
				.M_AXI_DC_ARLEN(microblaze_data_axi_arlen),        
				.M_AXI_DC_ARSIZE(microblaze_data_axi_arsize),     
  				.M_AXI_DC_ARBURST(microblaze_data_axi_arburst),    
  				.M_AXI_DC_ARLOCK(microblaze_data_axi_arlock),      
  				.M_AXI_DC_ARCACHE(microblaze_data_axi_arcache),    
 				.M_AXI_DC_ARPROT(microblaze_data_axi_arprot),      
 				.M_AXI_DC_ARQOS(microblaze_data_axi_arqos),        
 				.M_AXI_DC_ARVALID(microblaze_data_axi_arvalid),    
 				.M_AXI_DC_ARREADY(microblaze_data_axi_arready),    
 				.M_AXI_DC_ARUSER(),    								  
  				.M_AXI_DC_RID(microblaze_data_axi_rid[0]),           
 				.M_AXI_DC_RDATA(microblaze_data_axi_rdata),        
 				.M_AXI_DC_RRESP(microblaze_data_axi_rresp),        
 				.M_AXI_DC_RLAST(microblaze_data_axi_rlast),        
 				.M_AXI_DC_RVALID(microblaze_data_axi_rvalid),      
 				.M_AXI_DC_RREADY(microblaze_data_axi_rready)      
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
    if( CORE_SELECTOR == CORE_MICROBLAZEV ) begin : microblaze

    	`ASSIGN_AXI_BUS( rvm_socket_instr , microblaze_instr );
    	`ASSIGN_AXI_BUS( rvm_socket_data , microblaze_data );
    	
    	
    	xlnx_microblaze_debug_module_v your_instance_name (
    		.Debug_SYS_Rst(rst_ni),  // output wire Debug_SYS_Rst
  			.Dbg_Clk_0(Dbg_Clk),          // output wire Dbg_Clk_0
  			.Dbg_TDI_0(Dbg_TDI),          // output wire Dbg_TDI_0
  			.Dbg_TDO_0(Dbg_TDO),          // input wire Dbg_TDO_0
  			.Dbg_Reg_En_0(Dbg_Reg_En_0),    // output wire [0 : 7] Dbg_Reg_En_0
  			.Dbg_Capture_0(Dbg_Capture),  // output wire Dbg_Capture_0
  			.Dbg_Shift_0(Dbg_Shift),      // output wire Dbg_Shift_0
  			.Dbg_Update_0(Dbg_Update),    // output wire Dbg_Update_0
  			.Dbg_Rst_0(Dbg_Rst),          // output wire Dbg_Rst_0
  			.Dbg_Disable_0(Dbg_Disable)  // output wire Dbg_Disable_0
		);
    	
    end
	else begin : not_microblaze
	
	 // Connect memory interfaces to socket output memory ports
   		`ASSIGN_AXI_BUS( rvm_socket_instr, core_instr_to_socket_instr );
    	`ASSIGN_AXI_BUS( rvm_socket_data, core_data_to_socket_data );
	
	
	
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
	end


endmodule : rvm_socket
