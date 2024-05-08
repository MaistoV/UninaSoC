module dummy(
  input  logic  rstn_i,
  input  logic  clk_i,
  input  logic  a_i,
  output logic  bit_o 
  );
  
  assign bit_o = a_i | 1'b1;
endmodule
