// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Wrapper module for a RVM core

module rvm_socket # (
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
    parameter NUM_IRQ    = 3
) (
    input  logic                            clock_i,
    input  logic                            reset_ni,
    input  logic [AXI_ADDR_WIDTH -1 : 0 ]   bootaddr_i,
    input  logic [NUM_IRQ        -1 : 0 ]   irq_i,
    // AXI Master    
    TBD
);

endmodule : rvm_socket