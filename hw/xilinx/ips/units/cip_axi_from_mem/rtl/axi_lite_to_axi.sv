// Copyright (c) 2014-2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Authors:
// - Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Andreas Kurth <akurth@iis.ee.ethz.ch>

/// An AXI4-Lite to AXI4 adapter.
module axi_lite_to_axi #(
  parameter int unsigned AxiDataWidth = 32'd0,
  // LITE AXI structs
  parameter type  req_lite_t = logic,
  parameter type resp_lite_t = logic,
  // FULL AXI structs
  parameter type   axi_req_t = logic,
  parameter type  axi_resp_t = logic
) (
  // Slave AXI LITE port
  input  req_lite_t       slv_req_lite_i,
  output resp_lite_t      slv_resp_lite_o,
  input  axi_pkg::cache_t slv_aw_cache_i,
  input  axi_pkg::cache_t slv_ar_cache_i,
  // Master AXI port
  output axi_req_t        mst_req_o,
  input  axi_resp_t       mst_resp_i
);
  localparam int unsigned AxiSize = axi_pkg::size_t'($unsigned($clog2(AxiDataWidth/8)));

  // request assign
  assign mst_req_o.aw.id = '0;
  assign mst_req_o.aw.addr = slv_req_lite_i.aw.addr;
  assign mst_req_o.aw.len = '0;
  assign mst_req_o.aw.size = AxiSize;
  assign mst_req_o.aw.burst = axi_pkg::BURST_FIXED;
  assign mst_req_o.aw.cache = slv_aw_cache_i;
  assign mst_req_o.aw.lock = '0;
  assign mst_req_o.aw.prot = slv_req_lite_i.aw.prot;
  assign mst_req_o.aw.qos = '0;
  assign mst_req_o.aw.region = '0;
  assign mst_req_o.aw.atop = '0;
  assign mst_req_o.aw.user = '0;
  assign mst_req_o.aw_valid = slv_req_lite_i.aw_valid;

  assign mst_req_o.w.data = slv_req_lite_i.w.data;
  assign mst_req_o.w.strb = slv_req_lite_i.w.strb;
  assign mst_req_o.w.last = 1'b1;
  assign mst_req_o.w_valid = slv_req_lite_i.w_valid;
  assign mst_req_o.w.user = 0;

  assign mst_req_o.b_ready = slv_req_lite_i.b_ready;

  assign mst_req_o.ar.id = '0;
  assign mst_req_o.ar.addr = slv_req_lite_i.ar.addr;
  assign mst_req_o.ar.prot = slv_req_lite_i.ar.prot;
  assign mst_req_o.ar.size = AxiSize;
  assign mst_req_o.ar.burst = axi_pkg::BURST_FIXED;
  assign mst_req_o.ar.cache = slv_ar_cache_i;
  assign mst_req_o.ar.len = '0;
  assign mst_req_o.ar.lock = '0;
  assign mst_req_o.ar.qos = '0;
  assign mst_req_o.ar.region = '0;
  assign mst_req_o.ar.user = '0;
  assign mst_req_o.ar_valid = slv_req_lite_i.ar_valid;

  assign mst_req_o.r_ready = slv_req_lite_i.r_ready;
  
  // response assign
  assign slv_resp_lite_o.aw_ready = mst_resp_i.aw_ready;
  assign slv_resp_lite_o.w_ready = mst_resp_i.w_ready;
  assign slv_resp_lite_o.b.resp = mst_resp_i.b.resp;
  assign slv_resp_lite_o.b_valid = mst_resp_i.b_valid;
  assign slv_resp_lite_o.ar_ready = mst_resp_i.ar_ready;
  assign slv_resp_lite_o.r.data = mst_resp_i.r.data;
  assign slv_resp_lite_o.r.resp = mst_resp_i.r.resp;
  assign slv_resp_lite_o.r_valid = mst_resp_i.r_valid;

  // pragma translate_off
  `ifndef VERILATOR
  initial begin
    assert (AxiDataWidth > 0) else $fatal(1, "Data width must be non-zero!");
  end
  `endif
  // pragma translate_on
endmodule

module axi_lite_to_axi_intf #(
  parameter int unsigned AXI_DATA_WIDTH = 32'd0
) (
  AXI_LITE.Slave  in,
  input axi_pkg::cache_t slv_aw_cache_i,
  input axi_pkg::cache_t slv_ar_cache_i,
  AXI_BUS.Master  out
);
  localparam int unsigned AxiSize = axi_pkg::size_t'($unsigned($clog2(AXI_DATA_WIDTH/8)));

// pragma translate_off
  initial begin
    assert(in.AXI_ADDR_WIDTH == out.AXI_ADDR_WIDTH);
    assert(in.AXI_DATA_WIDTH == out.AXI_DATA_WIDTH);
    assert(AXI_DATA_WIDTH    == out.AXI_DATA_WIDTH);
  end
// pragma translate_on

  assign out.aw_id     = '0;
  assign out.aw_addr   = in.aw_addr;
  assign out.aw_len    = '0;
  assign out.aw_size   = AxiSize;
  assign out.aw_burst  = axi_pkg::BURST_FIXED;
  assign out.aw_lock   = '0;
  assign out.aw_cache  = slv_aw_cache_i;
  assign out.aw_prot   = '0;
  assign out.aw_qos    = '0;
  assign out.aw_region = '0;
  assign out.aw_atop   = '0;
  assign out.aw_user   = '0;
  assign out.aw_valid  = in.aw_valid;
  assign in.aw_ready   = out.aw_ready;

  assign out.w_data    = in.w_data;
  assign out.w_strb    = in.w_strb;
  assign out.w_last    = '1;
  assign out.w_user    = '0;
  assign out.w_valid   = in.w_valid;
  assign in.w_ready    = out.w_ready;

  assign in.b_resp     = out.b_resp;
  assign in.b_valid    = out.b_valid;
  assign out.b_ready   = in.b_ready;

  assign out.ar_id     = '0;
  assign out.ar_addr   = in.ar_addr;
  assign out.ar_len    = '0;
  assign out.ar_size   = AxiSize;
  assign out.ar_burst  = axi_pkg::BURST_FIXED;
  assign out.ar_lock   = '0;
  assign out.ar_cache  = slv_ar_cache_i;
  assign out.ar_prot   = '0;
  assign out.ar_qos    = '0;
  assign out.ar_region = '0;
  assign out.ar_user   = '0;
  assign out.ar_valid  = in.ar_valid;
  assign in.ar_ready   = out.ar_ready;

  assign in.r_data     = out.r_data;
  assign in.r_resp     = out.r_resp;
  assign in.r_valid    = out.r_valid;
  assign out.r_ready   = in.r_ready;

endmodule