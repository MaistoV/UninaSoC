// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Utility variables and macros for DDR4 interface

`ifndef UNINASOC_DDR4_SVH__
`define UNINASOC_DDR4_SVH__


// DDR4 Ports
// ch admitted values: c0, c1, c2, c3

`define DEFINE_DDR4_PORTS(ch)                 \
    output logic [16:0]  ddr4_``ch``_adr,     \
    output logic [1:0]   ddr4_``ch``_ba,      \
    output logic [1:0]   ddr4_``ch``_bg,      \
    output logic [0:0]   ddr4_``ch``_ck_t,    \
    output logic [0:0]   ddr4_``ch``_ck_c,    \
    output logic [0:0]   ddr4_``ch``_cke,     \
    output logic [0:0]   ddr4_``ch``_cs_n,    \
    output logic         ddr4_``ch``_act_n,   \
    output logic [0:0]   ddr4_``ch``_odt,     \
    output logic         ddr4_``ch``_par,     \
    output logic         ddr4_``ch``_reset_n, \
    inout  logic [71:0]  ddr4_``ch``_dq,      \
    inout  logic [17:0]  ddr4_``ch``_dqs_t,   \
    inout  logic [17:0]  ddr4_``ch``_dqs_c
    


`endif 