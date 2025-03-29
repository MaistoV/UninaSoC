// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: This module is the module wrapping the entire peripheral bus
//              it adds a AXI protocol converter before the axilite crossbar and all the peripherals connected to the axilite crossbar
//              NOTE: It would be more efficient to have the Clock Converter after the AXI Prot Converter.
//                    To keep things simple (since, for now, we do not have the AXI Lite Clock Converter) we leave it as follows.
//
//      _________________            _______________                  _____________             _______
//     |                 |  AXI4    |   AXI Prot    |   AXI Lite     |             |           |       |
// --->| Clock Converter |--------->|   Converter   |--------------->|             |---------->| UART  |
//     |_________________|          |_______________|                | Pheripheral |           |_______|
//                                                                   |    XBAR     |
//                                                                   |  (axilite)  |            ___________
//                                                                   |             |           |           |
//                                                                   |             |---------->| GPIO_out  |
//                                                                   |             |           |___________|
//                                                                   |             |            ___________
//                                                                   |             |           |           |
//                                                                   |             |---------->| GPIO_in   |
//                                                                   |             |           |___________|
//                                                                   |             |            ________
//                                                                   |             |           |        |
//                                                                   |             |---------->| TIM0   |
//                                                                   |             |           |________|
//                                                                   |             |            ________
//                                                                   |             |           |        |
//                                                                   |             |---------->| TIM1   |
//                                                                   |_____________|           |________|
//
//
//

// Import packages
import uninasoc_pkg::*;

// Import headers
`include "uninasoc_axi.svh"

module peripheral_bus #(
    parameter int unsigned    NUM_IRQ       = 4
    )(
    input logic main_clock_i,
    input logic main_reset_ni,
    input logic PBUS_clock_i,
    input logic PBUS_reset_ni,

    // AXI4 Slave interface from the main xbar
    `DEFINE_AXI_SLAVE_PORTS(s),

    // EMBEDDED ONLY
    // UART interface
    input  logic                        uart_rx_i,
    output logic                        uart_tx_o,

    // GPIOs
    input  logic [NUM_GPIO_IN  -1 : 0]  gpio_in_i,
    output logic [NUM_GPIO_OUT -1 : 0]  gpio_out_o,

    // Interrupts
    output logic [NUM_IRQ - 1 : 0]      int_o

);

    /////////////////////////////////////////
    // Buses declaration and concatenation //
    /////////////////////////////////////////
    `include "pbus_buses.svinc"
    `DECLARE_AXI_BUS(to_prot_conv, AXI_DATA_WIDTH)
    ///////////////////////
    // Interrupt Signals //
    ///////////////////////

    logic uart_int;
    logic tim0_int;
    logic tim1_int;
    // EMBEDDED ONLY
    logic gpio_in_int;

    // Assign interrupt pins
    assign int_o[PBUS_GPIOIN_INTERRUPT] = gpio_in_int;
    assign int_o[PBUS_TIM0_INTERRUPT]   = tim0_int;
    assign int_o[PBUS_TIM1_INTERRUPT]   = tim1_int;
    assign int_o[PBUS_UART_INTERRUPT]   = uart_int;


    /////////////////////
    // Clock Converter //
    /////////////////////

    // If the PBUS has a clock domain (the pbus has a clock different than main clock)
    `ifdef PBUS_HAS_CLOCK_DOMAIN
        xlnx_axi_clock_converter xlnx_axi_clock_converter_u (
            .s_axi_aclk     ( main_clock_i   ),
            .s_axi_aresetn  ( main_reset_ni  ),

            .m_axi_aclk     ( PBUS_clock_i   ),
            .m_axi_aresetn  ( PBUS_reset_ni  ),

            // Slave from MBUS
            .s_axi_awid     ( s_axi_awid     ),
            .s_axi_awaddr   ( s_axi_awaddr   ),
            .s_axi_awlen    ( s_axi_awlen    ),
            .s_axi_awsize   ( s_axi_awsize   ),
            .s_axi_awburst  ( s_axi_awburst  ),
            .s_axi_awlock   ( s_axi_awlock   ),
            .s_axi_awcache  ( s_axi_awcache  ),
            .s_axi_awprot   ( s_axi_awprot   ),
            .s_axi_awqos    ( s_axi_awqos    ),
            .s_axi_awvalid  ( s_axi_awvalid  ),
            .s_axi_awready  ( s_axi_awready  ),
            .s_axi_awregion ( s_axi_awregion ),
            .s_axi_wdata    ( s_axi_wdata    ),
            .s_axi_wstrb    ( s_axi_wstrb    ),
            .s_axi_wlast    ( s_axi_wlast    ),
            .s_axi_wvalid   ( s_axi_wvalid   ),
            .s_axi_wready   ( s_axi_wready   ),
            .s_axi_bid      ( s_axi_bid      ),
            .s_axi_bresp    ( s_axi_bresp    ),
            .s_axi_bvalid   ( s_axi_bvalid   ),
            .s_axi_bready   ( s_axi_bready   ),
            .s_axi_arid     ( s_axi_arid     ),
            .s_axi_araddr   ( s_axi_araddr   ),
            .s_axi_arlen    ( s_axi_arlen    ),
            .s_axi_arsize   ( s_axi_arsize   ),
            .s_axi_arburst  ( s_axi_arburst  ),
            .s_axi_arlock   ( s_axi_arlock   ),
            .s_axi_arregion ( s_axi_arregion ),
            .s_axi_arcache  ( s_axi_arcache  ),
            .s_axi_arprot   ( s_axi_arprot   ),
            .s_axi_arqos    ( s_axi_arqos    ),
            .s_axi_arvalid  ( s_axi_arvalid  ),
            .s_axi_arready  ( s_axi_arready  ),
            .s_axi_rid      ( s_axi_rid      ),
            .s_axi_rdata    ( s_axi_rdata    ),
            .s_axi_rresp    ( s_axi_rresp    ),
            .s_axi_rlast    ( s_axi_rlast    ),
            .s_axi_rvalid   ( s_axi_rvalid   ),
            .s_axi_rready   ( s_axi_rready   ),


            // Master to protocol converter
            .m_axi_awid     ( to_prot_conv_axi_awid      ),
            .m_axi_awaddr   ( to_prot_conv_axi_awaddr    ),
            .m_axi_awlen    ( to_prot_conv_axi_awlen     ),
            .m_axi_awsize   ( to_prot_conv_axi_awsize    ),
            .m_axi_awburst  ( to_prot_conv_axi_awburst   ),
            .m_axi_awlock   ( to_prot_conv_axi_awlock    ),
            .m_axi_awcache  ( to_prot_conv_axi_awcache   ),
            .m_axi_awprot   ( to_prot_conv_axi_awprot    ),
            .m_axi_awregion ( to_prot_conv_axi_awregion  ),
            .m_axi_awqos    ( to_prot_conv_axi_awqos     ),
            .m_axi_awvalid  ( to_prot_conv_axi_awvalid   ),
            .m_axi_awready  ( to_prot_conv_axi_awready   ),
            .m_axi_wdata    ( to_prot_conv_axi_wdata     ),
            .m_axi_wstrb    ( to_prot_conv_axi_wstrb     ),
            .m_axi_wlast    ( to_prot_conv_axi_wlast     ),
            .m_axi_wvalid   ( to_prot_conv_axi_wvalid    ),
            .m_axi_wready   ( to_prot_conv_axi_wready    ),
            .m_axi_bid      ( to_prot_conv_axi_bid       ),
            .m_axi_bresp    ( to_prot_conv_axi_bresp     ),
            .m_axi_bvalid   ( to_prot_conv_axi_bvalid    ),
            .m_axi_bready   ( to_prot_conv_axi_bready    ),
            .m_axi_arid     ( to_prot_conv_axi_arid      ),
            .m_axi_araddr   ( to_prot_conv_axi_araddr    ),
            .m_axi_arlen    ( to_prot_conv_axi_arlen     ),
            .m_axi_arsize   ( to_prot_conv_axi_arsize    ),
            .m_axi_arburst  ( to_prot_conv_axi_arburst   ),
            .m_axi_arlock   ( to_prot_conv_axi_arlock    ),
            .m_axi_arcache  ( to_prot_conv_axi_arcache   ),
            .m_axi_arprot   ( to_prot_conv_axi_arprot    ),
            .m_axi_arregion ( to_prot_conv_axi_arregion  ),
            .m_axi_arqos    ( to_prot_conv_axi_arqos     ),
            .m_axi_arvalid  ( to_prot_conv_axi_arvalid   ),
            .m_axi_arready  ( to_prot_conv_axi_arready   ),
            .m_axi_rid      ( to_prot_conv_axi_rid       ),
            .m_axi_rdata    ( to_prot_conv_axi_rdata     ),
            .m_axi_rresp    ( to_prot_conv_axi_rresp     ),
            .m_axi_rlast    ( to_prot_conv_axi_rlast     ),
            .m_axi_rvalid   ( to_prot_conv_axi_rvalid    ),
            .m_axi_rready   ( to_prot_conv_axi_rready    )
        );
    `else // The PBUS has the same clock of main clock
        `ASSIGN_AXI_BUS (to_prot_conv, s)
    `endif

    /////////////////////
    // AXI-lite Master //
    /////////////////////

    // AXI4 to AXI4-Lite protocol converter
    xlnx_axi4_to_axilite_converter axi4_to_axilite_u (
        .aclk           ( PBUS_clock_i              ), // input wire s_axi_aclk
        .aresetn        ( PBUS_reset_ni             ), // input wire s_axi_aresetn
        // AXI4 slave port (from main clock converter)
        .s_axi_awid     ( to_prot_conv_axi_awid     ),            // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr   ( to_prot_conv_axi_awaddr   ),            // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen    ( to_prot_conv_axi_awlen    ),            // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize   ( to_prot_conv_axi_awsize   ),            // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst  ( to_prot_conv_axi_awburst  ),            // input wire [1 : 0] s_axi_awburst
        .s_axi_awlock   ( to_prot_conv_axi_awlock   ),            // input wire [0 : 0] s_axi_awlock
        .s_axi_awcache  ( to_prot_conv_axi_awcache  ),            // input wire [3 : 0] s_axi_awcache
        .s_axi_awprot   ( to_prot_conv_axi_awprot   ),            // input wire [2 : 0] s_axi_awprot
        .s_axi_awregion ( to_prot_conv_axi_awregion ),            // input wire [3 : 0] s_axi_awregion
        .s_axi_awqos    ( to_prot_conv_axi_awqos    ),            // input wire [3 : 0] s_axi_awqos
        .s_axi_awvalid  ( to_prot_conv_axi_awvalid  ),            // input wire s_axi_awvalid
        .s_axi_awready  ( to_prot_conv_axi_awready  ),            // output wire s_axi_awready
        .s_axi_wdata    ( to_prot_conv_axi_wdata    ),            // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( to_prot_conv_axi_wstrb    ),            // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast    ( to_prot_conv_axi_wlast    ),            // input wire s_axi_wlast
        .s_axi_wvalid   ( to_prot_conv_axi_wvalid   ),            // input wire s_axi_wvalid
        .s_axi_wready   ( to_prot_conv_axi_wready   ),            // output wire s_axi_wready
        .s_axi_bid      ( to_prot_conv_axi_bid      ),            // output wire [1 : 0] s_axi_bid
        .s_axi_bresp    ( to_prot_conv_axi_bresp    ),            // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( to_prot_conv_axi_bvalid   ),            // output wire s_axi_bvalid
        .s_axi_bready   ( to_prot_conv_axi_bready   ),            // input wire s_axi_bready
        .s_axi_arid     ( to_prot_conv_axi_arid     ),            // input wire [1 : 0] s_axi_arid
        .s_axi_araddr   ( to_prot_conv_axi_araddr   ),            // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen    ( to_prot_conv_axi_arlen    ),            // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize   ( to_prot_conv_axi_arsize   ),            // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst  ( to_prot_conv_axi_arburst  ),            // input wire [1 : 0] s_axi_arburst
        .s_axi_arlock   ( to_prot_conv_axi_arlock   ),            // input wire [0 : 0] s_axi_arlock
        .s_axi_arcache  ( to_prot_conv_axi_arcache  ),            // input wire [3 : 0] s_axi_arcache
        .s_axi_arprot   ( to_prot_conv_axi_arprot   ),            // input wire [2 : 0] s_axi_arprot
        .s_axi_arregion ( to_prot_conv_axi_arregion ),            // input wire [3 : 0] s_axi_arregion
        .s_axi_arqos    ( to_prot_conv_axi_arqos    ),            // input wire [3 : 0] s_axi_arqos
        .s_axi_arvalid  ( to_prot_conv_axi_arvalid  ),            // input wire s_axi_arvalid
        .s_axi_arready  ( to_prot_conv_axi_arready  ),            // output wire s_axi_arready
        .s_axi_rid      ( to_prot_conv_axi_rid      ),            // output wire [1 : 0] s_axi_rid
        .s_axi_rdata    ( to_prot_conv_axi_rdata    ),            // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( to_prot_conv_axi_rresp    ),            // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast    ( to_prot_conv_axi_rlast    ),            // output wire s_axi_rlast
        .s_axi_rvalid   ( to_prot_conv_axi_rvalid   ),            // output wire s_axi_rvalid
        .s_axi_rready   ( to_prot_conv_axi_rready   ),            // input wire s_axi_rready
        // Master port (to AXI Lite crossbar)
        .m_axi_awaddr   ( PROT_CONV_to_PBUS_axilite_awaddr  ), // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot   ( PROT_CONV_to_PBUS_axilite_awprot  ), // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid  ( PROT_CONV_to_PBUS_axilite_awvalid ), // output wire m_axi_awvalid
        .m_axi_awready  ( PROT_CONV_to_PBUS_axilite_awready ), // input wire m_axi_awready
        .m_axi_wdata    ( PROT_CONV_to_PBUS_axilite_wdata   ), // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb    ( PROT_CONV_to_PBUS_axilite_wstrb   ), // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid   ( PROT_CONV_to_PBUS_axilite_wvalid  ), // output wire m_axi_wvalid
        .m_axi_wready   ( PROT_CONV_to_PBUS_axilite_wready  ), // input wire m_axi_wready
        .m_axi_bresp    ( PROT_CONV_to_PBUS_axilite_bresp   ), // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid   ( PROT_CONV_to_PBUS_axilite_bvalid  ), // input wire m_axi_bvalid
        .m_axi_bready   ( PROT_CONV_to_PBUS_axilite_bready  ), // output wire m_axi_bready
        .m_axi_araddr   ( PROT_CONV_to_PBUS_axilite_araddr  ), // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot   ( PROT_CONV_to_PBUS_axilite_arprot  ), // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid  ( PROT_CONV_to_PBUS_axilite_arvalid ), // output wire m_axi_arvalid
        .m_axi_arready  ( PROT_CONV_to_PBUS_axilite_arready ), // input wire m_axi_arready
        .m_axi_rdata    ( PROT_CONV_to_PBUS_axilite_rdata   ), // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp    ( PROT_CONV_to_PBUS_axilite_rresp   ), // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid   ( PROT_CONV_to_PBUS_axilite_rvalid  ), // input wire m_axi_rvalid
        .m_axi_rready   ( PROT_CONV_to_PBUS_axilite_rready  )  // output wire m_axi_rready
    );

    // AXI Lite crossbar
    xlnx_peripheral_crossbar peripheral_xbar_u (
        .aclk           ( PBUS_clock_i  ),
        .aresetn        ( PBUS_reset_ni ),

        .s_axi_awaddr   ( PBUS_masters_axilite_awaddr   ),
        .s_axi_awprot   ( PBUS_masters_axilite_awprot   ),
        .s_axi_awvalid  ( PBUS_masters_axilite_awvalid  ),
        .s_axi_awready  ( PBUS_masters_axilite_awready  ),
        .s_axi_wdata    ( PBUS_masters_axilite_wdata    ),
        .s_axi_wstrb    ( PBUS_masters_axilite_wstrb    ),
        .s_axi_wvalid   ( PBUS_masters_axilite_wvalid   ),
        .s_axi_wready   ( PBUS_masters_axilite_wready   ),
        .s_axi_bresp    ( PBUS_masters_axilite_bresp    ),
        .s_axi_bvalid   ( PBUS_masters_axilite_bvalid   ),
        .s_axi_bready   ( PBUS_masters_axilite_bready   ),
        .s_axi_araddr   ( PBUS_masters_axilite_araddr   ),
        .s_axi_arprot   ( PBUS_masters_axilite_arprot   ),
        .s_axi_arvalid  ( PBUS_masters_axilite_arvalid  ),
        .s_axi_arready  ( PBUS_masters_axilite_arready  ),
        .s_axi_rdata    ( PBUS_masters_axilite_rdata    ),
        .s_axi_rresp    ( PBUS_masters_axilite_rresp    ),
        .s_axi_rvalid   ( PBUS_masters_axilite_rvalid   ),
        .s_axi_rready   ( PBUS_masters_axilite_rready   ),

        .m_axi_awaddr   ( PBUS_slaves_axilite_awaddr    ),
        .m_axi_awprot   ( PBUS_slaves_axilite_awprot    ),
        .m_axi_awvalid  ( PBUS_slaves_axilite_awvalid   ),
        .m_axi_awready  ( PBUS_slaves_axilite_awready   ),
        .m_axi_wdata    ( PBUS_slaves_axilite_wdata     ),
        .m_axi_wstrb    ( PBUS_slaves_axilite_wstrb     ),
        .m_axi_wvalid   ( PBUS_slaves_axilite_wvalid    ),
        .m_axi_wready   ( PBUS_slaves_axilite_wready    ),
        .m_axi_bresp    ( PBUS_slaves_axilite_bresp     ),
        .m_axi_bvalid   ( PBUS_slaves_axilite_bvalid    ),
        .m_axi_bready   ( PBUS_slaves_axilite_bready    ),
        .m_axi_araddr   ( PBUS_slaves_axilite_araddr    ),
        .m_axi_arprot   ( PBUS_slaves_axilite_arprot    ),
        .m_axi_arvalid  ( PBUS_slaves_axilite_arvalid   ),
        .m_axi_arready  ( PBUS_slaves_axilite_arready   ),
        .m_axi_rdata    ( PBUS_slaves_axilite_rdata     ),
        .m_axi_rresp    ( PBUS_slaves_axilite_rresp     ),
        .m_axi_rvalid   ( PBUS_slaves_axilite_rvalid    ),
        .m_axi_rready   ( PBUS_slaves_axilite_rready    )

    );

    /////////////////////
    // AXI-lite Slaves //
    /////////////////////

    // AXI4 Lite UART
    axilite_uart axilite_uart_u (
        .clock_i        ( PBUS_clock_i              ), // input wire s_axi_aclk
        .reset_ni       ( PBUS_reset_ni             ), // input wire s_axi_aresetn
        .int_core_o     ( uart_int                  ), // Output interrupt
        .int_xdma_o     (                           ), // TBD
        .int_ack_i      ( '0                        ), // TBD

        // EMBEDDED ONLY
        .tx_o           ( uart_tx_o                 ), // Transmission signal (SoC output signal)
        .rx_i           ( uart_rx_i                 ), // Receive signal (SoC input signal)


        // AXI4 lite slave port (from xbar lite)
        .s_axilite_awaddr   ( PBUS_to_UART_axilite_awaddr  ),
        .s_axilite_awprot   ( PBUS_to_UART_axilite_awprot  ),
        .s_axilite_awvalid  ( PBUS_to_UART_axilite_awvalid ),
        .s_axilite_awready  ( PBUS_to_UART_axilite_awready ),
        .s_axilite_wdata    ( PBUS_to_UART_axilite_wdata   ),
        .s_axilite_wstrb    ( PBUS_to_UART_axilite_wstrb   ),
        .s_axilite_wvalid   ( PBUS_to_UART_axilite_wvalid  ),
        .s_axilite_wready   ( PBUS_to_UART_axilite_wready  ),
        .s_axilite_bresp    ( PBUS_to_UART_axilite_bresp   ),
        .s_axilite_bvalid   ( PBUS_to_UART_axilite_bvalid  ),
        .s_axilite_bready   ( PBUS_to_UART_axilite_bready  ),
        .s_axilite_araddr   ( PBUS_to_UART_axilite_araddr  ),
        .s_axilite_arprot   ( PBUS_to_UART_axilite_arprot  ),
        .s_axilite_arvalid  ( PBUS_to_UART_axilite_arvalid ),
        .s_axilite_arready  ( PBUS_to_UART_axilite_arready ),
        .s_axilite_rdata    ( PBUS_to_UART_axilite_rdata   ),
        .s_axilite_rresp    ( PBUS_to_UART_axilite_rresp   ),
        .s_axilite_rvalid   ( PBUS_to_UART_axilite_rvalid  ),
        .s_axilite_rready   ( PBUS_to_UART_axilite_rready  )
    );

    // AXI4 Lite Timers

    xlnx_axilite_timer tim0_u (
        .s_axi_aclk     ( PBUS_clock_i              ), // input wire s_axi_aclk
        .s_axi_aresetn  ( PBUS_reset_ni             ), // input wire s_axi_aresetn
        .s_axi_awaddr   ( PBUS_to_TIM0_axilite_awaddr [8:0]  ), // input wire [8 : 0] s_axi_awaddr
        .s_axi_awvalid  ( PBUS_to_TIM0_axilite_awvalid       ), // input wire s_axi_awvalid
        .s_axi_awready  ( PBUS_to_TIM0_axilite_awready       ), // output wire s_axi_awready
        .s_axi_wdata    ( PBUS_to_TIM0_axilite_wdata         ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( PBUS_to_TIM0_axilite_wstrb         ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid   ( PBUS_to_TIM0_axilite_wvalid        ), // input wire s_axi_wvalid
        .s_axi_wready   ( PBUS_to_TIM0_axilite_wready        ), // output wire s_axi_wready
        .s_axi_bresp    ( PBUS_to_TIM0_axilite_bresp         ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( PBUS_to_TIM0_axilite_bvalid        ), // output wire s_axi_bvalid
        .s_axi_bready   ( PBUS_to_TIM0_axilite_bready        ), // input wire s_axi_bready
        .s_axi_araddr   ( PBUS_to_TIM0_axilite_araddr [8:0]  ), // input wire [8 : 0] s_axi_araddr
        .s_axi_arvalid  ( PBUS_to_TIM0_axilite_arvalid       ), // input wire s_axi_arvalid
        .s_axi_arready  ( PBUS_to_TIM0_axilite_arready       ), // output wire s_axi_arready
        .s_axi_rdata    ( PBUS_to_TIM0_axilite_rdata         ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( PBUS_to_TIM0_axilite_rresp         ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid   ( PBUS_to_TIM0_axilite_rvalid        ), // output wire s_axi_rvalid
        .s_axi_rready   ( PBUS_to_TIM0_axilite_rready        ), // input wire s_axi_rready

        .capturetrig0   ( '0                        ), // input [0:0]
        .capturetrig1   ( '0                        ), // input [0:0]
        .freeze         ( '0                        ), // input [0:0]
        .generateout0   (                           ), // output [0:0]
        .generateout1   (                           ), // output [0:0]
        .interrupt      ( tim0_int                  ), // output [0:0]
        .pwm0           (                           ) // output [0:0]
    );

    xlnx_axilite_timer tim1_u (
        .s_axi_aclk     ( PBUS_clock_i              ), // input wire s_axi_aclk
        .s_axi_aresetn  ( PBUS_reset_ni             ), // input wire s_axi_aresetn
        .s_axi_awaddr   ( PBUS_to_TIM1_axilite_awaddr [8:0]  ), // input wire [8 : 0] s_axi_awaddr
        .s_axi_awvalid  ( PBUS_to_TIM1_axilite_awvalid       ), // input wire s_axi_awvalid
        .s_axi_awready  ( PBUS_to_TIM1_axilite_awready       ), // output wire s_axi_awready
        .s_axi_wdata    ( PBUS_to_TIM1_axilite_wdata         ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( PBUS_to_TIM1_axilite_wstrb         ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid   ( PBUS_to_TIM1_axilite_wvalid        ), // input wire s_axi_wvalid
        .s_axi_wready   ( PBUS_to_TIM1_axilite_wready        ), // output wire s_axi_wready
        .s_axi_bresp    ( PBUS_to_TIM1_axilite_bresp         ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( PBUS_to_TIM1_axilite_bvalid        ), // output wire s_axi_bvalid
        .s_axi_bready   ( PBUS_to_TIM1_axilite_bready        ), // input wire s_axi_bready
        .s_axi_araddr   ( PBUS_to_TIM1_axilite_araddr [8:0]  ), // input wire [8 : 0] s_axi_araddr
        .s_axi_arvalid  ( PBUS_to_TIM1_axilite_arvalid       ), // input wire s_axi_arvalid
        .s_axi_arready  ( PBUS_to_TIM1_axilite_arready       ), // output wire s_axi_arready
        .s_axi_rdata    ( PBUS_to_TIM1_axilite_rdata         ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( PBUS_to_TIM1_axilite_rresp         ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid   ( PBUS_to_TIM1_axilite_rvalid        ), // output wire s_axi_rvalid
        .s_axi_rready   ( PBUS_to_TIM1_axilite_rready        ), // input wire s_axi_rready

        .capturetrig0   ( '0                        ), // input [0:0]
        .capturetrig1   ( '0                        ), // input [0:0]
        .freeze         ( '0                        ), // input [0:0]
        .generateout0   (                           ), // output [0:0]
        .generateout1   (                           ), // output [0:0]
        .interrupt      ( tim1_int                  ), // output [0:0]
        .pwm0           (                           ) // output [0:0]
    );

`ifdef EMBEDDED

    // GPIO OUT instance
    xlnx_axi_gpio_out gpio_out_u (
        .s_axi_aclk     ( PBUS_clock_i                          ), // input wire s_axi_aclk
        .s_axi_aresetn  ( PBUS_reset_ni                         ), // input wire s_axi_aresetn
        .s_axi_awaddr   ( PBUS_to_GPIO_out_axilite_awaddr [8:0] ), // input wire [8 : 0] s_axi_awaddr
        .s_axi_awvalid  ( PBUS_to_GPIO_out_axilite_awvalid      ), // input wire s_axi_awvalid
        .s_axi_awready  ( PBUS_to_GPIO_out_axilite_awready      ), // output wire s_axi_awready
        .s_axi_wdata    ( PBUS_to_GPIO_out_axilite_wdata        ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( PBUS_to_GPIO_out_axilite_wstrb        ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid   ( PBUS_to_GPIO_out_axilite_wvalid       ), // input wire s_axi_wvalid
        .s_axi_wready   ( PBUS_to_GPIO_out_axilite_wready       ), // output wire s_axi_wready
        .s_axi_bresp    ( PBUS_to_GPIO_out_axilite_bresp        ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( PBUS_to_GPIO_out_axilite_bvalid       ), // output wire s_axi_bvalid
        .s_axi_bready   ( PBUS_to_GPIO_out_axilite_bready       ), // input wire s_axi_bready
        .s_axi_araddr   ( PBUS_to_GPIO_out_axilite_araddr [8:0] ), // input wire [8 : 0] s_axi_araddr
        .s_axi_arvalid  ( PBUS_to_GPIO_out_axilite_arvalid      ), // input wire s_axi_arvalid
        .s_axi_arready  ( PBUS_to_GPIO_out_axilite_arready      ), // output wire s_axi_arready
        .s_axi_rdata    ( PBUS_to_GPIO_out_axilite_rdata        ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( PBUS_to_GPIO_out_axilite_rresp        ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid   ( PBUS_to_GPIO_out_axilite_rvalid       ), // output wire s_axi_rvalid
        .s_axi_rready   ( PBUS_to_GPIO_out_axilite_rready       ), // input wire s_axi_rready
        .gpio_io_o      ( gpio_out_o                            )  // input wire [0 : 0] gpio_io_o
    );

    // GPIO IN instance
    xlnx_axi_gpio_in gpio_in_u (
        .s_axi_aclk     ( PBUS_clock_i                  ), // input wire s_axi_aclk
        .s_axi_aresetn  ( PBUS_reset_ni                 ), // input wire s_axi_aresetn
        .s_axi_awaddr   ( PBUS_to_GPIO_in_axilite_awaddr [8:0]  ), // input wire [8 : 0] s_axi_awaddr
        .s_axi_awvalid  ( PBUS_to_GPIO_in_axilite_awvalid       ), // input wire s_axi_awvalid
        .s_axi_awready  ( PBUS_to_GPIO_in_axilite_awready       ), // output wire s_axi_awready
        .s_axi_wdata    ( PBUS_to_GPIO_in_axilite_wdata         ), // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb    ( PBUS_to_GPIO_in_axilite_wstrb         ), // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid   ( PBUS_to_GPIO_in_axilite_wvalid        ), // input wire s_axi_wvalid
        .s_axi_wready   ( PBUS_to_GPIO_in_axilite_wready        ), // output wire s_axi_wready
        .s_axi_bresp    ( PBUS_to_GPIO_in_axilite_bresp         ), // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid   ( PBUS_to_GPIO_in_axilite_bvalid        ), // output wire s_axi_bvalid
        .s_axi_bready   ( PBUS_to_GPIO_in_axilite_bready        ), // input wire s_axi_bready
        .s_axi_araddr   ( PBUS_to_GPIO_in_axilite_araddr [8:0]  ), // input wire [8 : 0] s_axi_araddr
        .s_axi_arvalid  ( PBUS_to_GPIO_in_axilite_arvalid       ), // input wire s_axi_arvalid
        .s_axi_arready  ( PBUS_to_GPIO_in_axilite_arready       ), // output wire s_axi_arready
        .s_axi_rdata    ( PBUS_to_GPIO_in_axilite_rdata         ), // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp    ( PBUS_to_GPIO_in_axilite_rresp         ), // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid   ( PBUS_to_GPIO_in_axilite_rvalid        ), // output wire s_axi_rvalid
        .s_axi_rready   ( PBUS_to_GPIO_in_axilite_rready        ), // input wire s_axi_rready
        .gpio_io_i      ( gpio_in_i                     ),
        .ip2intc_irpt   ( gpio_in_int                   )  // output wire [0:0] (interrupt)
    );

`endif

endmodule : peripheral_bus