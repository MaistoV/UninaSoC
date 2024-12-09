// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Utility variables and macros for DDR4 interface

`ifndef UNINASOC_DDR4_SVH__
`define UNINASOC_DDR4_SVH__

// DDR4 Ports
// ch admitted values: c0, c1, c2, c3
`define DEFINE_DDR4_PORTS(ch)                  \
    output logic [16:0]  ddr4_``ch``_adr_o,     \          
    output logic [1:0]   ddr4_``ch``_ba_o,      \          
    output logic [1:0]   ddr4_``ch``_bg_o,      \
    output logic [0:0]   ddr4_``ch``_ck_t_o,    \ 
    output logic [0:0]   ddr4_``ch``_ck_c_o,    \
    output logic [0:0]   ddr4_``ch``_cke_o,     \ 
    output logic [0:0]   ddr4_``ch``_cs_n_o,    \ 
    output logic         ddr4_``ch``_act_n_o,   \
    output logic [0:0]   ddr4_``ch``_odt_o,     \
    output logic         ddr4_``ch``_par_o,     \
    inout  logic [71:0]  ddr4_``ch``_dq_io,     \
    inout  logic [17:0]  ddr4_``ch``_dqs_t_io,  \
    inout  logic [17:0]  ddr4_``ch``_dqs_c_io

`endif 