// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Description: Wrapper module for a block ram memory

module block_ram_memory # (
    parameter SIZE_BYTES = 1024,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    // AXI Slave
    axi_slave_TBD
);

endmodule : block_ram_memory