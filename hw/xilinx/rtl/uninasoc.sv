// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>                                                       
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>   
// Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
// Description: Basic version of UninaSoC that allows to work with axi transactions to and from slaves (ToBeUpdated)    
// NOTE: ONLY GPIO_OUT, AXI CROSSBAR, MEM_GEN AND JTAG_AXI COMPONENTS HAVE BEEN USED IN THIS VERSION
                                                                                                             
                                                                                                             
// System architecture:                                                                                      
//                                                                                    ________               
//   _________              ____________               __________                    |        |              
//  |         |            |            |             |          |                   |  Main  |              
//  |   vio   |----------->| rvm_socket |------------>|          |        /--------->| Memory |              
//  |_________|            |____________|             |   AXI    |        |          |________|              
//   __________                                       | crossbar |--------|           ________               
//  |          |                                      |          |        |          |        |              
//  | jtag_axi |------------------------------------->|          |        |--------->|  UART  |              
//  |__________|                                      |__________|        |          |________|              
//                                                                        |           ________               
//                                                                        |          |        |              
//                                                                        \--------->|  GPIO  |              
//                                                                                   |________|              
//                       

import uninasoc_pkg::*;                                                                                      
                                                                                                             
module uninasoc  # (                                                                                         
    parameter NUM_GPIO_IN       = 0,                                                                         
    parameter NUM_GPIO_OUT      = 1,
    parameter ID_WIDTH          = 2,                                                                         
    parameter MEMORY_SIZE_BYTES = 1024                                                                       
) (                                                                                                          
     // interfaccia                                                                                          
    input sys_clk,                                                                                           
    input sys_rst,                                                                                           
  //  input  wire [NUM_GPIO_IN  -1 : 0]  gpio_in,                                                           
    output logic [NUM_GPIO_OUT -1 : 0]  gpio_out                                                             
);                                                                                                           
                                                                                                             
    localparam int NUM_SLAVES= NUM_GPIO_OUT+ NUM_GPIO_IN+1;                                                                                                      
    // clkwiz -> all                                                                                         
    logic soc_clk;                                                                                           
    // vio -> all                                                                                            
    logic vio_reset_n;                                                                                       
    // vio -> rvm_socket                                                                                     
    logic [AXI_ADDR_WIDTH -1 : 0 ] vio_bootaddr;                                                             
    logic [NUM_IRQ        -1 : 0 ] vio_irq;                                                                  
    // uart -> rvm_socket                                                                                    
    logic uart_interrupt;                                                                                    
                                                  
                                                                                                             
//wires to connect jtag2axi master to crossbar                                                         
    wire [0:0] m_axi_awid;                                                                                   
    wire [AXI_ADDR_WIDTH -1 : 0] m_axi_awaddr;                                                               
    wire [7:0] m_axi_awlen;                                                                                  
    wire [2:0] m_axi_awsize;                                                                               
    wire [1:0] m_axi_awburst;                                                                                
    wire m_axi_awlock;                                                                                       
    wire [3:0] m_axi_awcache;                                                                                
    wire [2:0] m_axi_awprot;                                                                                 
    wire [3:0] m_axi_awqos;                                                                                  
    wire m_axi_awvalid;                                                                                      
    wire m_axi_awready;                                                                                      
    wire [AXI_DATA_WIDTH -1 : 0] m_axi_wdata;                                                                
    wire [AXI_DATA_WIDTH/8 -1 :0] m_axi_wstrb;                                                               
    wire m_axi_wlast;                                                                                        
    wire m_axi_wvalid;                                                                                       
    wire m_axi_wready;                                                                                       
    wire [0:0] m_axi_bid;   
    wire [0:0] m_axi_arid;                                                                                 
    wire [1:0] m_axi_bresp;                                                                                  
    wire m_axi_bvalid;                                                                                       
    wire m_axi_bready;                                                                                       
//wire [0:0] m_axi_arid;                                                                                   
    wire [AXI_ADDR_WIDTH -1 :0] m_axi_araddr;                                                                
    wire [7:0] m_axi_arlen;                                                                                  
    wire [2:0] m_axi_arsize;                                                                                 
    wire [1:0] m_axi_arburst;                                                                                
    wire m_axi_arlock;                                                                                       
    wire [3:0] m_axi_arcache;                                                                                
    wire [2:0] m_axi_arprot;                                                                                 
    wire [3:0] m_axi_arqos;                                                                                  
    wire m_axi_arvalid;                                                                                      
    wire m_axi_arready;                                                                                      
    wire [0:0] m_axi_rid;                                                                                    
    wire [AXI_DATA_WIDTH -1 :0] m_axi_rdata;                                                                 
    wire [1:0] m_axi_rresp;                                                                                  
    wire m_axi_rlast;                                                                                        
    wire m_axi_rvalid;                                                                                       
    wire m_axi_rready;                                                                                       
    wire [31:0] noIn;                      
                                                                  
//wires to connect crossbar to 2 slaves. 
    
    wire [NUM_SLAVES*ID_WIDTH-1:0] s_axi_awid;                                                                                   
    wire [NUM_SLAVES*AXI_ADDR_WIDTH -1 : 0] s_axi_awaddr;                                                               
    wire [NUM_SLAVES*8-1:0] s_axi_awlen;  //NUM_SLAVES*8                                                                           
    wire [NUM_SLAVES*3-1: 0] s_axi_awsize;   //NUM_SLAVES*3                                                                            
    wire [NUM_SLAVES*2-1:0] s_axi_awburst;    //NUM_SLAVES*2                                                                            
    wire [NUM_SLAVES-1:0] s_axi_awlock;       //NUM_SLAVES*1                                                                                
    wire [NUM_SLAVES*4-1:0] s_axi_awcache;   //NUM_SLAVES*4                                                                             
    wire [NUM_SLAVES*3-1: 0] s_axi_awprot;  //NUM_SLAVES*3                                                                               
    wire [NUM_SLAVES*4-1:0] s_axi_awqos;   //NUM_SLAVES*4                                                                                
    wire [NUM_SLAVES-1:0] s_axi_awvalid;    //NUM_SLAVES*1                                                                                    
    wire [NUM_SLAVES-1:0] s_axi_awready;    //NUM_SLAVES*1  

    //slave interface write data ports   
    wire [NUM_SLAVES*ID_WIDTH-1:0]    s_axi_wid;                                                                             
    wire [NUM_SLAVES*AXI_DATA_WIDTH -1 : 0] s_axi_wdata;                                                                
    wire [(NUM_SLAVES*AXI_DATA_WIDTH)/8 -1 :0] s_axi_wstrb;                                                               
    wire [NUM_SLAVES-1:0]s_axi_wlast;       //NUM_SLAVES*1                                                                                  
    wire [NUM_SLAVES-1:0] s_axi_wvalid;            //NUM_SLAVES*1                                                                            
    wire [NUM_SLAVES-1:0] s_axi_wready;         //NUM_SLAVES*1   
    // Slave Interface Write response ports                                                               
    wire [NUM_SLAVES*ID_WIDTH-1:0] s_axi_bid;        //NUM_SLAVES*ID_WIDTH                                                                            
    wire [NUM_SLAVES*2-1:0] s_axi_bresp;       //NUM_SLAVES*2                                                                           
    wire [NUM_SLAVES-1:0]s_axi_bvalid;             //NUM_SLAVES*1                                                                          
    wire [NUM_SLAVES-1:0]s_axi_bready;             //NUM_SLAVES*1  
    // Slave Interface read Address Ports                                                                        
    wire [NUM_SLAVES*ID_WIDTH-1:0] s_axi_arid;     //NUM_SLAVES*ID_WIDTH                                                                        
    wire [NUM_SLAVES*AXI_ADDR_WIDTH -1 :0] s_axi_araddr;       //NUM_SLAVES*ADDR_WIDTH                                                         
    wire [NUM_SLAVES*8-1:0] s_axi_arlen;           //NUM_SLAVES*8                                                                       
    wire [NUM_SLAVES*3-1:0] s_axi_arsize;          //NUM_SLAVES*3                                                                       
    wire [NUM_SLAVES*2-1:0] s_axi_arburst;         //NUM_SLAVES*2                                                                       
    wire [NUM_SLAVES-1:0]s_axi_arlock;             //NUM_SLAVES*1                                                                      
    wire [NUM_SLAVES*4-1:0] s_axi_arcache;         //NUM_SLAVES*4                                                                       
    wire [NUM_SLAVES*3-1:0] s_axi_arprot;          //NUM_SLAVES*3                                                                       
    wire [NUM_SLAVES*4-1:0] s_axi_arqos;           //NUM_SLAVES*4                                                                       
    wire [NUM_SLAVES-1:0] s_axi_arvalid;               //NUM_SLAVES*1                                                                       
    wire [NUM_SLAVES-1:0] s_axi_arready;               //NUM_SLAVES*1      
    // Slave Interface Read data ports                                                                 
    wire [NUM_SLAVES*ID_WIDTH-1:0] s_axi_rid;             //NUM_SLAVES*ID_WIDTH                                                                       
    wire [NUM_SLAVES*AXI_DATA_WIDTH-1:0] s_axi_rdata;   //NUM_SLAVES*DATA_WIDTH                                                              
    wire [NUM_SLAVES*2-1:0] s_axi_rresp;           //NUM_SLAVES*2                                                                      
    wire [NUM_SLAVES-1:0] s_axi_rlast;                 //NUM_SLAVES*1                                                                       
    wire [NUM_SLAVES-1:0] s_axi_rvalid;                //NUM_SLAVES*1                                                                     
    wire [NUM_SLAVES-1:0] s_axi_rready;                //NUM_SLAVES*1
                                       
                                                                                                             
    // AXI masters                                                                                           
    // AXI slaves                                                                                            
                                                                                                             
    /////////////                                                                                            
    // Moduli che compongono l'architettura //                                                               
    /////////////                                                                                            
                                                                                                             
    // PLL                                                                                                   
    xlnx_clk_wiz clkwiz_inst (                                                                               
        .clk_in1  ( sys_clk ),                                                                               
        .resetn   ( ~sys_rst ),                                                                               
        .locked   ( ),                                                                                       
        .clk_100  ( ),                                                                                       
        .clk_50   ( soc_clk  ),                                                                              
        .clk_20   ( ),                                                                                       
        .clk_10   ( )                                                                                        
    );                                                                                                       
                                                                                                             
                                                                                                             
    // JTAG2AXI Master                                                                                       
    xlnx_jtag_axi jtag_axi_inst (                                                                            
        .aclk           (   soc_clk        ), // input wire aclk                                            
        .aresetn        (   ~sys_rst    ), // input wire aresetn                                              
        .m_axi_awid     (   m_axi_awid     ), // output wire [0 : 0] m_axi_awid                                    
        .m_axi_awaddr   (   m_axi_awaddr    ), // output wire [31 : 0] m_axi_awid                            
        .m_axi_awlen    (   m_axi_awlen    ), // output wire [7 : 0] m_axi_awlen                                   
        .m_axi_awsize   (   m_axi_awsize ), // output wire [2 : 0] m_axi_awsize                                   
        .m_axi_awburst  (   m_axi_awburst   ), // output wire [1 : 0] m_axi_awburst                                   
        .m_axi_awlock   (   m_axi_awlock      ), // output wire m_axi_awlock                                           
        .m_axi_awcache  (   m_axi_awcache   ), // output wire [3 : 0] m_axi_awcache                                    
        .m_axi_awprot   (   m_axi_awprot  ), // output wire [2 : 0] m_axi_awprot                                    
        .m_axi_awqos    (   m_axi_awqos   ), // output wire [3 : 0] m_axi_awqos                                   
        .m_axi_awvalid  (   m_axi_awvalid   ), // output wire m_axi_awvalid                                  
        .m_axi_awready  (   m_axi_awready   ), // input wire m_axi_awready                                   
        .m_axi_wdata    (   m_axi_wdata     ), // output wire [31 : 0] m_axi_wdata                           
        .m_axi_wstrb    (   m_axi_wstrb     ), // output wire [3 : 0] m_axi_wstrb                            
        .m_axi_wlast    (   m_axi_wlast    ), // output wire m_axi_wlast                                           
        .m_axi_wvalid   (   m_axi_wvalid    ), // output wire m_axi_wvalid                                   
        .m_axi_wready   (   m_axi_wready    ), // input wire m_axi_wready                                    
        .m_axi_bid      (   m_axi_bid       ), // input wire [0 : 0] m_axi_bid                               
        .m_axi_bresp    (   m_axi_bresp     ), // input wire [1 : 0] m_axi_bresp                             
        .m_axi_bvalid   (   m_axi_bvalid    ), // input wire m_axi_bvalid                                    
        .m_axi_bready   (   m_axi_bready    ), // output wire m_axi_bready                                   
        .m_axi_arid     (   m_axi_arid     ), // output wire [0 : 0] m_axi_arid                                   
        .m_axi_araddr   (   m_axi_araddr    ), // output wire [31 : 0] m_axi_araddr                          
        .m_axi_arlen    (   m_axi_arlen     ), // output wire [7 : 0] m_axi_arlen                                   
        .m_axi_arsize   (   m_axi_arsize   ), // output wire [2 : 0] m_axi_arsize                                    
        .m_axi_arburst  (  m_axi_arburst  ), // output wire [1 : 0] m_axi_arburst                                   
        .m_axi_arlock   (    m_axi_arlock  ), // output wire m_axi_arlock                                           
        .m_axi_arcache  (  m_axi_arcache ), // output wire [3 : 0] m_axi_arcache                                     
        .m_axi_arprot   (     m_axi_arprot  ), // output wire [2 : 0] m_axi_arprot                                   
        .m_axi_arqos    (   m_axi_arqos    ), // output wire [3 : 0] m_axi_arqos                                   
        .m_axi_arvalid  (   m_axi_arvalid   ), // output wire m_axi_arvalid                                  
        .m_axi_arready  (   m_axi_arready   ), // input wire m_axi_arready                                   
        .m_axi_rid      (   m_axi_rid       ), // input wire [0 : 0] m_axi_rid                               
        .m_axi_rdata    (   m_axi_rdata     ), // input wire [31 : 0] m_axi_rdata                            
        .m_axi_rresp    (   m_axi_rresp     ), // input wire [1 : 0] m_axi_rresp                             
        .m_axi_rlast    (   m_axi_rlast     ), // input wire m_axi_rlast                                     
        .m_axi_rvalid   (   m_axi_rvalid    ), // input wire m_axi_rvalid                                    
        .m_axi_rready   (   m_axi_rready    )  // output wire m_axi_rready                                   
    );          
                                                                                                 
    // Axi Crossbar 

    xlnx_axi_crossbar axi_xbar_inst (
        .aclk           ( soc_clk        ), // input wire aclk
        .aresetn        ( ~sys_rst      ), // input wire aresetn
        .s_axi_awid     ( m_axi_awid     ),
        .s_axi_awaddr   ( m_axi_awaddr   ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( m_axi_awlen    ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( m_axi_awsize   ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( m_axi_awburst  ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( m_axi_awlock   ), // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( m_axi_awcache  ), // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( m_axi_awprot   ), // input wire [2 : 0] s_axi_awprot
        .s_axi_awqos    ( m_axi_awqos    ), // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( m_axi_awvalid  ), // input wire [0 : 0] s_axi_awvalid
        .s_axi_awready  ( m_axi_awready  ), // output wire [0 : 0] s_axi_awready
        .s_axi_wdata    ( m_axi_wdata    ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( m_axi_wstrb    ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( m_axi_wlast    ), // input wire [0 : 0] s_axi_wlast
        .s_axi_wvalid   ( m_axi_wvalid   ), // input wire [0 : 0] s_axi_wvalid
        .s_axi_wready   ( m_axi_wready   ), // output wire [0 : 0] s_axi_wready
        .s_axi_bid      ( m_axi_bid      ),
        .s_axi_bresp    ( m_axi_bresp    ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( m_axi_bvalid   ), // output wire [0 : 0] s_axi_bvalid
        .s_axi_bready   ( m_axi_bready   ), // input wire [0 : 0] s_axi_bready
        .s_axi_arid     ( m_axi_arid     ),
        .s_axi_araddr   ( m_axi_araddr   ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( m_axi_arlen    ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( m_axi_arsize   ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( m_axi_arburst  ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( m_axi_arlock   ), // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( m_axi_arcache  ), // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( m_axi_arprot   ), // input wire [2 : 0] s_axi_arprot
        .s_axi_arqos    ( m_axi_arqos    ), // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( m_axi_arvalid  ), // input wire [0 : 0] s_axi_arvalid
        .s_axi_arready  ( m_axi_arready  ), // output wire [0 : 0] s_axi_arready
        .s_axi_rid      ( m_axi_rid      ),
        .s_axi_rdata    ( m_axi_rdata    ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( m_axi_rresp    ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( m_axi_rlast    ), // output wire [0 : 0] s_axi_rlast
        .s_axi_rvalid   ( m_axi_rvalid   ), // output wire [0 : 0] s_axi_rvalid
        .s_axi_rready   ( m_axi_rready   ), // input wire [0 : 0] s_axi_rready
        .m_axi_awid     ( s_axi_awid     ),
        .m_axi_awaddr   ( s_axi_awaddr   ), // output wire [63 : 0] m_axi_awaddr
        .m_axi_awlen    ( s_axi_awlen    ), // output wire [15 : 0] m_axi_awlen
        .m_axi_awsize   ( s_axi_awsize   ), // output wire [5 : 0] m_axi_awsize
        .m_axi_awburst  ( s_axi_awburst  ), // output wire [3 : 0] m_axi_awburst
        .m_axi_awlock   ( s_axi_awlock   ), // output wire [1 : 0] m_axi_awlock
        .m_axi_awcache  ( s_axi_awcache  ), // output wire [7 : 0] m_axi_awcache
        .m_axi_awprot   ( s_axi_awprot   ), // output wire [5 : 0] m_axi_awprot
        .m_axi_awregion (  ), // output wire [7 : 0] m_axi_awregion
        .m_axi_awqos    ( s_axi_awqos    ), // output wire [7 : 0] m_axi_awqos
        .m_axi_awvalid  ( s_axi_awvalid  ), // output wire [1 : 0] m_axi_awvalid
        .m_axi_awready  ( s_axi_awready  ), // input wire [1 : 0] m_axi_awready
        .m_axi_wdata    ( s_axi_wdata    ), // output wire [63 : 0] m_axi_wdata
        .m_axi_wstrb    ( s_axi_wstrb    ), // output wire [7 : 0] m_axi_wstrb
        .m_axi_wlast    ( s_axi_wlast    ), // output wire [1 : 0] m_axi_wlast
        .m_axi_wvalid   ( s_axi_wvalid   ), // output wire [1 : 0] m_axi_wvalid
        .m_axi_wready   ( s_axi_wready   ), // input wire [1 : 0] m_axi_wready
        .m_axi_bid      ( s_axi_bid      ),
        .m_axi_bresp    ( s_axi_bresp    ), // input wire [3 : 0] m_axi_bresp
        .m_axi_bvalid   ( s_axi_bvalid   ), // input wire [1 : 0] m_axi_bvalid
        .m_axi_bready   ( s_axi_bready   ), // output wire [1 : 0] m_axi_bready
        .m_axi_arid     ( s_axi_arid     ),
        .m_axi_araddr   ( s_axi_araddr   ), // output wire [63 : 0] m_axi_araddr
        .m_axi_arlen    ( s_axi_arlen    ), // output wire [15 : 0] m_axi_arlen
        .m_axi_arsize   ( s_axi_arsize   ), // output wire [5 : 0] m_axi_arsize
        .m_axi_arburst  ( s_axi_arburst  ), // output wire [3 : 0] m_axi_arburst
        .m_axi_arlock   ( s_axi_arlock   ), // output wire [1 : 0] m_axi_arlock
        .m_axi_arcache  ( s_axi_arcache  ), // output wire [7 : 0] m_axi_arcache
        .m_axi_arprot   ( s_axi_arprot   ), // output wire [5 : 0] m_axi_arprot
//        .m_axi_arregion ( m_axi_arregion ), // output wire [7 : 0] m_axi_arregion
        .m_axi_arqos    ( s_axi_arqos    ), // output wire [7 : 0] m_axi_arqos
        .m_axi_arvalid  ( s_axi_arvalid  ), // output wire [1 : 0] m_axi_arvalid
        .m_axi_arready  ( s_axi_arready  ), // input wire [1 : 0] m_axi_arready
        .m_axi_rid      ( s_axi_rid      ),
        .m_axi_rdata    ( s_axi_rdata    ), // input wire [63 : 0] m_axi_rdata
        .m_axi_rresp    ( s_axi_rresp    ), // input wire [3 : 0] m_axi_rresp
        .m_axi_rlast    ( s_axi_rlast    ), // input wire [1 : 0] m_axi_rlast
        .m_axi_rvalid   ( s_axi_rvalid   ), // input wire [1 : 0] m_axi_rvalid
        .m_axi_rready   ( s_axi_rready   ) // output wire [1 : 0] m_axi_rready
    );

    
        // Main memory
    xlnx_blk_mem_gen main_memory_inst (
//        .rsta_busy      ( rsta_busy     ), // output wire rsta_busy
//        .rstb_busy      ( rstb_busy     ), // output wire rstb_busy
        .s_aclk         ( soc_clk        ), // input wire s_aclk
        .s_aresetn      ( ~sys_rst    ), // input wire s_aresetn
        .s_axi_awid     ( s_axi_awid[3:0]    ), // input wire [3 : 0] s_axi_awid
        .s_axi_awaddr   ( s_axi_awaddr[31:0]  ), // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( s_axi_awlen [7:0]  ), // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( s_axi_awsize[2:0]  ), // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( s_axi_awburst[1:0] ), // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid  ( s_axi_awvalid[0] ), // input wire s_axi_awvalid
        .s_axi_awready  ( s_axi_awready[0] ), // output wire s_axi_awready
        .s_axi_wdata    ( s_axi_wdata[31:0]   ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( s_axi_wstrb[3:0]   ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( s_axi_wlast[0]   ), // input wire s_axi_wlast
        .s_axi_wvalid   ( s_axi_wvalid[0]  ), // input wire s_axi_wvalid
        .s_axi_wready   ( s_axi_wready[0]  ), // output wire s_axi_wready
        .s_axi_bid      ( s_axi_bid[3:0]     ), // output wire [3 : 0] s_axi_bid
        .s_axi_bresp    ( s_axi_bresp[1:0]   ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( s_axi_bvalid[0]  ), // output wire s_axi_bvalid
        .s_axi_bready   ( s_axi_bready[0]  ), // input wire s_axi_bready
        .s_axi_arid     ( s_axi_arid[3:0]    ), // input wire [3 : 0] s_axi_arid
        .s_axi_araddr   ( s_axi_araddr[31:0]  ), // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( s_axi_arlen[7:0]  ), // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( s_axi_arsize[2:0]  ), // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( s_axi_arburst[1:0] ), // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid  ( s_axi_arvalid[0] ), // input wire s_axi_arvalid
        .s_axi_arready  ( s_axi_arready[0] ), // output wire s_axi_arready
        .s_axi_rid      ( s_axi_rid[3:0]     ), // output wire [3 : 0] s_axi_rid
        .s_axi_rdata    ( s_axi_rdata[31:0]   ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( s_axi_rresp[1:0]   ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( s_axi_rlast[0]   ), // output wire s_axi_rlast
        .s_axi_rvalid   ( s_axi_rvalid[0]  ), // output wire s_axi_rvalid
        .s_axi_rready   ( s_axi_rready[0]  )  // input wire s_axi_rready
    );
                                                                                                             
    // GPIOs                                                                                                                                                                              
    generate                                                                                                                                                           
            for ( genvar i = 1; i <= NUM_GPIO_OUT; i++ ) begin     
//           
                xlnx_axi_gpio_out gpio_out_inst (                                                            
                    .s_axi_aclk     ( soc_clk ), // input wire s_axi_aclk                                   
                    .s_axi_aresetn  ( ~sys_rst ), // input wire s_axi_aresetn                                 
                    .s_axi_awaddr   ( s_axi_awaddr[9*i+8:9*i]  ), // input wire [8 : 0] s_axi_awaddr              
                    .s_axi_awvalid  ( s_axi_awvalid[i] ), // input wire s_axi_awvalid                           
                    .s_axi_awready  ( s_axi_awready[i] ), // output wire s_axi_awready                          
                    .s_axi_wdata    ( s_axi_wdata[32*i+31:32*i]  ), // input wire [31 : 0] s_axi_wdata                    
                    .s_axi_wstrb    ( s_axi_wstrb [4*i+3:4*i]  ), // input wire [3 : 0] s_axi_wstrb                     
                    .s_axi_wvalid   ( s_axi_wvalid [i]  ), // input wire s_axi_wvalid                            
                    .s_axi_wready   ( s_axi_wready [i] ), // output wire s_axi_wready                           
                    .s_axi_bresp    ( s_axi_bresp  [2*i+1:2*i]  ), // output wire [1 : 0] s_axi_bresp                    
                    .s_axi_bvalid   ( s_axi_bvalid [i]  ), // output wire s_axi_bvalid                           
                    .s_axi_bready   ( s_axi_bready [i] ), // input wire s_axi_bready                            
                    .s_axi_araddr   ( s_axi_araddr [9*i+8:9*i] ), // input wire [8 : 0] s_axi_araddr                    
                    .s_axi_arvalid  ( s_axi_arvalid [i] ), // input wire s_axi_arvalid                           
                    .s_axi_arready  ( s_axi_arready [i] ), // output wire s_axi_arready                          
                    .s_axi_rdata    ( s_axi_rdata  [32*i+31:32*i]  ), // output wire [31 : 0] s_axi_rdata                   
                    .s_axi_rresp    ( s_axi_rresp  [2*i+1:2*i]  ), // output wire [1 : 0] s_axi_rresp                    
                    .s_axi_rvalid   ( s_axi_rvalid  [i] ), // output wire s_axi_rvalid                           
                    .s_axi_rready   ( s_axi_rready  [i] ), // input wire s_axi_rready                            
                    .gpio_io_o      ( gpio_out [0]  )  // input wire [0 : 0] gpio_io_i                       
                );                                                                                           
            end                                                                                                                                                                            
      endgenerate                                                                                            
                                                                                                                                    
                                                                                                             
endmodule : uninasoc                                                                                         
                                                                                                             
