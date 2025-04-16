// Author: Stefano Mercogliano  <stefano.mercogliano@unina.it>
// Description: Utility variables and macros for MEMb (SRAM) protocols
// Note: The main rationale behind this macro is to avoid the usage of structs and
//       macros for the widest possible syntax compatibility.

`ifndef UNINASOC_MEM_SVH__
`define UNINASOC_MEM_SVH__

//////////////////////////////////////////////////////
//    ___                         _                 //
//   | _ \__ _ _ _ __ _ _ __  ___| |_ ___ _ _ ___   //
//   |  _/ _` | '_/ _` | '  \/ -_)  _/ -_) '_(_-<   //
//   |_| \__,_|_| \__,_|_|_|_\___|\__\___|_| /__/   //
//                                                  //
//////////////////////////////////////////////////////

// MEM parameters, such as strobe, data and address width,
// must be compatible with AXI, therefore we directly reuse them.

//////////////////////////////////
//    _____                     //
//   |_   _|  _ _ __  ___ ___   //
//     | || || | '_ \/ -_|_-<   //
//     |_| \_, | .__/\___/__/   //
//         |__/|_|              //
//////////////////////////////////

// MEM signal types
typedef logic                           mem_logic_t;

////////////////////////////////////////
//    __  __   _   ___ ___  ___       //
//   |  \/  | /_\ / __| _ \/ _ \ ___  //
//   | |\/| |/ _ \ (__|   / (_) (_-<  //
//   |_|  |_/_/ \_\___|_|_\\___//__/  //
//                                    //
////////////////////////////////////////

////////////////////////
//  Bus Declaration   //
////////////////////////

// Declare MEM bus specifying the DATA_WIDTH
`define DECLARE_MEM_BUS(bus_name, DATA_WIDTH, ADDR_WIDTH)   \
                                                \
    mem_logic_t                     ``bus_name``_mem_req;       \
    mem_logic_t                     ``bus_name``_mem_gnt;       \
    mem_logic_t                     ``bus_name``_mem_valid;     \
    logic [ADDR_WIDTH-1 : 0]        ``bus_name``_mem_addr;      \
    logic [DATA_WIDTH-1 : 0]        ``bus_name``_mem_rdata;     \
    logic [DATA_WIDTH-1 : 0]        ``bus_name``_mem_wdata;     \
    mem_logic_t                     ``bus_name``_mem_we;        \
    logic [(DATA_WIDTH)/8-1 : 0]    ``bus_name``_mem_be;        \
    mem_logic_t                     ``bus_name``_mem_error;

// Declare MEM array
`define DECLARE_MEM_BUS_ARRAY(array_name, size, DATA_WIDTH, ADDR_WIDTH)   \
                                                \
    mem_logic_t [``size`` -1 : 0]                       ``bus_name``_mem_req;       \
    mem_logic_t [``size`` -1 : 0]                       ``bus_name``_mem_gnt;       \
    mem_logic_t [``size`` -1 : 0]                       ``bus_name``_mem_valid;     \
    logic [ADDR_WIDTH-1 : 0]        [``size`` -1 : 0]   ``bus_name``_mem_addr;      \
    logic [DATA_WIDTH-1 : 0]        [``size`` -1 : 0]   ``bus_name``_mem_rdata;     \
    logic [DATA_WIDTH-1 : 0]        [``size`` -1 : 0]   ``bus_name``_mem_wdata;     \
    mem_logic_t [``size`` -1 : 0]                       ``bus_name``_mem_we;        \
    logic [(DATA_WIDTH)/8-1 : 0]    [``size`` -1 : 0]   ``bus_name``_mem_be;        \
    mem_logic_t [``size`` -1 : 0]                       ``bus_name``_mem_error;

///////////////////////
//  Bus Assignment   //
///////////////////////

// Assign srce to dest signals
`define ASSIGN_MEM_BUS(dest, src) \
    assign ``dest``_mem_req     = ``src``_mem_req   ; \
    assign ``dest``_mem_gnt     = ``src``_mem_gnt   ; \
    assign ``dest``_mem_valid   = ``src``_mem_valid ; \
    assign ``dest``_mem_addr    = ``src``_mem_addr  ; \
    assign ``dest``_mem_rdata   = ``src``_mem_rdata ; \
    assign ``dest``_mem_wdata   = ``src``_mem_wdata ; \
    assign ``dest``_mem_we      = ``src``_mem_we    ; \
    assign ``dest``_mem_be      = ``src``_mem_be    ; \
    assign ``dest``_mem_error   = ``src``_mem_error ;


////////////////////////
//  Bus Concatenation //
////////////////////////

// NOTE: these macro are just enumerating, without variadic args
//       I don't see a better way to do this, for now

// Mock macro for one bus for compatibility
// Effectively, just renaming the signals
`define CONCAT_MEM_MASTERS_ARRAY1(array_name, bus_name0) \
    `ASSIGN_MEM_BUS(``array_name``, ``bus_name0``)

// Concatenate 2 master buses
`define CONCAT_MEM_MASTERS_ARRAY2(array_name, bus_name1, bus_name0) \
    assign ``array_name``_mem_req       = {``bus_name1``_mem_req        , ``bus_name0``_mem_req     }; \
    assign ``array_name``_mem_gnt       = {``bus_name1``_mem_gnt        , ``bus_name0``_mem_gnt     }; \
    assign ``array_name``_mem_valid     = {``bus_name1``_mem_valid      , ``bus_name0``_mem_valid   }; \
    assign ``array_name``_mem_addr      = {``bus_name1``_mem_addr       , ``bus_name0``_mem_addr    }; \
    assign ``array_name``_mem_rdata     = {``bus_name1``_mem_rdata      , ``bus_name0``_mem_rdata   }; \
    assign ``array_name``_mem_wdata     = {``bus_name1``_mem_wdata      , ``bus_name0``_mem_wdata   }; \
    assign ``array_name``_mem_we        = {``bus_name1``_mem_we         , ``bus_name0``_mem_we      }; \
    assign ``array_name``_mem_be        = {``bus_name1``_mem_be         , ``bus_name0``_mem_be      }; \
    assign ``array_name``_mem_error     = {``bus_name1``_mem_error      , ``bus_name0``_mem_error   };

//////////////////
//  Bus Ports   //
//////////////////

// MEM MASTER PORTS
`define DEFINE_MEM_MASTER_PORTS(bus_name, DATA_WIDTH, ADDR_WIDTH)               \
    output mem_logic_t                  ``bus_name``_mem_req,        \
    input  mem_logic_t                  ``bus_name``_mem_gnt,        \
    input  mem_logic_t                  ``bus_name``_mem_valid,      \
    output logic [ADDR_WIDTH-1 : 0]     ``bus_name``_mem_addr,       \
    input  logic [DATA_WIDTH-1 : 0]     ``bus_name``_mem_rdata,      \
    output logic [DATA_WIDTH-1 : 0]     ``bus_name``_mem_wdata,      \
    output mem_logic_t                  ``bus_name``_mem_we,         \
    output logic [(DATA_WIDTH)/8-1 : 0] ``bus_name``_mem_be,         \
    input  mem_logic_t                  ``bus_name``_mem_error

`define DEFINE_MEM_SLAVE_PORTS(bus_name, DATA_WIDTH, ADDR_WIDTH)                \
    input  mem_logic_t                  ``bus_name``_mem_req,        \
    output mem_logic_t                  ``bus_name``_mem_gnt,        \
    output mem_logic_t                  ``bus_name``_mem_valid,      \
    input  logic [ADDR_WIDTH-1 : 0]     ``bus_name``_mem_addr,       \
    output logic [DATA_WIDTH-1 : 0]     ``bus_name``_mem_rdata,      \
    input  logic [DATA_WIDTH-1 : 0]     ``bus_name``_mem_wdata,      \
    input  mem_logic_t                  ``bus_name``_mem_we,         \
    input  logic [(DATA_WIDTH)/8-1 : 0] ``bus_name``_mem_be,         \
    output mem_logic_t                  ``bus_name``_mem_error

/////////////////////
// Sink interfaces //
/////////////////////

// These macros are meant to emulate a stub master or slave,
// never really doing anything. This way, we avoid to leave
// floating signals around.

// Sink MEM master interface
`define SINK_MEM_MASTER_INTERFACE(bus_name) \
    assign ``bus_name``_mem_gnt     = '0;   \
    assign ``bus_name``_mem_valid   = '0;   \
    assign ``bus_name``_mem_rdata   = '0;   \
    assign ``bus_name``_mem_error   = '0;

// Sink MEM slave interface
`define SINK_MEM_SLAVE_INTERFACE(bus_name)  \
    assign ``bus_name``_mem_req     = '0;   \
    assign ``bus_name``_mem_addr    = '0;   \
    assign ``bus_name``_mem_wdata   = '0;   \
    assign ``bus_name``_mem_we      = '0;   \
    assign ``bus_name``_mem_be      = '0;

`endif // UNINASOC_MEM_SVH__