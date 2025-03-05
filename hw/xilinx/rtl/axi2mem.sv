// From https://github.com/pulp-platform/axi_mem_if/blob/b494701501886ad71ba0c128560cc371610bcf1a/src/axi2mem.sv


// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// ----------------------------
// AXI to SRAM Adapter
// ----------------------------
// Author: Florian Zaruba (zarubaf@iis.ee.ethz.ch)
//
// Description: Manages AXI transactions
//              Supports all burst accesses but only on aligned addresses and with full data width.
//              Assertions should guide you if there is something unsupported happening.
//

// Import headers
`include "uninasoc_axi.svh"
`include "uninasoc_mem.svh"

module axi2mem #(
    parameter int unsigned AXI_ID_WIDTH      = 2,
    parameter int unsigned AXI_ADDR_WIDTH    = 32,
    parameter int unsigned AXI_DATA_WIDTH    = 32,
    parameter int unsigned AXI_USER_WIDTH    = 1
)(
    input logic                         clk_i,    // Clock
    input logic                         rst_ni,  // Asynchronous reset active low
    // AXI_BUS.Slave                       slave,
    `DEFINE_AXI_SLAVE_PORTS(slave),
    // `DEFINE_MEM_MASTER_PORTS(master),
    output logic                        req_o,
    output logic                        we_o,
    output logic [AXI_ADDR_WIDTH-1:0]   addr_o,
    output logic [AXI_DATA_WIDTH/8-1:0] be_o,
    output logic [AXI_USER_WIDTH-1:0]   user_o,
    output logic [AXI_DATA_WIDTH-1:0]   data_o,
    input  logic [AXI_USER_WIDTH-1:0]   user_i,
    input  logic [AXI_DATA_WIDTH-1:0]   data_i
);

    ///////////////////////////
    // Unimplemented signals //
    ///////////////////////////
    logic slave_axi_wuser;
    assign slave_axi_wuser = '0;
    logic slave_axi_ruser;
    logic slave_axi_buser;

    // AXI has the following rules governing the use of bursts:
    // - for wrapping bursts, the burst length must be 2, 4, 8, or 16
    // - a burst must not cross a 4KB address boundary
    // - early termination of bursts is not supported.
    typedef enum logic [1:0] { FIXED = 2'b00, INCR = 2'b01, WRAP = 2'b10} axiburst_t;

    localparam LOG_NR_BYTES = $clog2(AXI_DATA_WIDTH/8);

    typedef struct packed {
        logic [AXI_ID_WIDTH-1:0]   id;
        logic [AXI_ADDR_WIDTH-1:0] addr;
        logic [7:0]                len;
        logic [2:0]                size;
        axiburst_t                burst;
    } ax_req_t;

    // Registers
    enum logic [2:0] { IDLE, READ, WRITE, SEND_B, WAIT_WVALID }  state_d, state_q;
    ax_req_t                   ax_req_d, ax_req_q;
    logic [AXI_ADDR_WIDTH-1:0] req_addr_d, req_addr_q;
    logic [7:0]                cnt_d, cnt_q;

    function automatic logic [AXI_ADDR_WIDTH-1:0] get_wrap_boundary (input logic [AXI_ADDR_WIDTH-1:0] unaligned_address, input logic [7:0] len);
        logic [AXI_ADDR_WIDTH-1:0] warpaddress = '0;
        //  for wrapping transfers axlen can only be of size 1, 3, 7 or 15
        if (len == 4'b1)
            warpaddress[AXI_ADDR_WIDTH-1:1+LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH-1:1+LOG_NR_BYTES];
        else if (len == 4'b11)
            warpaddress[AXI_ADDR_WIDTH-1:2+LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH-1:2+LOG_NR_BYTES];
        else if (len == 4'b111)
            warpaddress[AXI_ADDR_WIDTH-1:3+LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH-3:2+LOG_NR_BYTES];
        else if (len == 4'b1111)
            warpaddress[AXI_ADDR_WIDTH-1:4+LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH-3:4+LOG_NR_BYTES];

        return warpaddress;
    endfunction

    logic [AXI_ADDR_WIDTH-1:0] alignedaddress;
    logic [AXI_ADDR_WIDTH-1:0] wrap_boundary;
    logic [AXI_ADDR_WIDTH-1:0] upper_wrap_boundary;
    logic [AXI_ADDR_WIDTH-1:0] consaddr;

    always_comb begin
        // address generation
        alignedaddress = {ax_req_q.addr[AXI_ADDR_WIDTH-1:LOG_NR_BYTES], {{LOG_NR_BYTES}{1'b0}}};
        wrap_boundary = get_wrap_boundary(ax_req_q.addr, ax_req_q.len);
        // this will overflow
        upper_wrap_boundary = wrap_boundary + ((ax_req_q.len + 1) << LOG_NR_BYTES);
        // calculate consecutive address
        consaddr = alignedaddress + (cnt_q << LOG_NR_BYTES);

        // Transaction attributes
        // default assignments
        state_d    = state_q;
        ax_req_d   = ax_req_q;
        req_addr_d = req_addr_q;
        cnt_d      = cnt_q;
        // Memory default assignments
        data_o = slave_axi_wdata;
        user_o = slave_axi_wuser;
        be_o   = slave_axi_wstrb;
        we_o   = 1'b0;
        req_o  = 1'b0;
        addr_o = '0;
        // AXI assignments
        // request
        slave_axi_awready = 1'b0;
        slave_axi_arready = 1'b0;
        // read response channel
        slave_axi_rvalid  = 1'b0;
        slave_axi_rdata   = data_i;
        slave_axi_rresp   = '0; // NOTE: This is constant
        slave_axi_rlast   = '0;
        slave_axi_rid     = ax_req_q.id;
        slave_axi_ruser   = user_i;
        // slave write data channel
        slave_axi_wready  = 1'b0;
        // write response channel
        slave_axi_bvalid  = 1'b0;
        slave_axi_bresp   = 1'b0; // NOTE: This is constant
        slave_axi_bid     = 1'b0;
        slave_axi_buser   = 1'b0;

        case (state_q)

            IDLE: begin
                // Wait for a read or write
                // ------------
                // Read
                // ------------
                if (slave_axi_arvalid) begin
                    slave_axi_arready = 1'b1;
                    // sample ax
                    ax_req_d       = {slave_axi_arid, slave_axi_araddr, slave_axi_arlen, slave_axi_arsize, slave_axi_arburst};
                    state_d        = READ;
                    //  we can request the first address, this saves us time
                    req_o          = 1'b1;
                    addr_o         = slave_axi_araddr;
                    // save the address
                    req_addr_d     = slave_axi_araddr;
                    // save the arlen
                    cnt_d          = 1;
                // ------------
                // Write
                // ------------
                end else if (slave_axi_awvalid) begin
                    slave_axi_awready = 1'b1;
                    slave_axi_wready  = 1'b1;
                    addr_o         = slave_axi_awaddr;
                    // sample ax
                    ax_req_d       = {slave_axi_awid, slave_axi_awaddr, slave_axi_awlen, slave_axi_awsize, slave_axi_awburst};
                    // we've got our first wvalid so start the write process
                    if (slave_axi_wvalid) begin
                        req_o          = 1'b1;
                        we_o           = 1'b1;
                        state_d        = (slave_axi_wlast) ? SEND_B : WRITE;
                        cnt_d          = 1;
                    // we still have to wait for the first wvalid to arrive
                    end else
                        state_d = WAIT_WVALID;
                end
            end

            // ~> we are still missing a wvalid
            WAIT_WVALID: begin
                slave_axi_wready = 1'b1;
                addr_o = ax_req_q.addr;
                // we can now make our first request
                if (slave_axi_wvalid) begin
                    req_o          = 1'b1;
                    we_o           = 1'b1;
                    state_d        = (slave_axi_wlast) ? SEND_B : WRITE;
                    cnt_d          = 1;
                end
            end

            READ: begin
                // keep request to memory high
                req_o  = 1'b1;
                addr_o = req_addr_q;
                // send the response
                slave_axi_rvalid = 1'b1;
                slave_axi_rdata  = data_i;
                slave_axi_ruser  = user_i;
                slave_axi_rid    = ax_req_q.id;
                slave_axi_rlast  = (cnt_q == ax_req_q.len + 1);

                // check that the master is ready, the slave must not wait on this
                if (slave_axi_rready) begin
                    // ----------------------------
                    // Next address generation
                    // ----------------------------
                    // handle the correct burst type
                    case (ax_req_q.burst)
                        FIXED, INCR: addr_o = consaddr;
                        WRAP:  begin
                            // check if the address reached warp boundary
                            if (consaddr == upper_wrap_boundary) begin
                                addr_o = wrap_boundary;
                            // address warped beyond boundary
                            end else if (consaddr > upper_wrap_boundary) begin
                                addr_o = ax_req_q.addr + ((cnt_q - ax_req_q.len) << LOG_NR_BYTES);
                            // we are still in the incremental regime
                            end else begin
                                addr_o = consaddr;
                            end
                        end
                    endcase
                    // we need to change the address here for the upcoming request
                    // we sent the last byte -> go back to idle
                    if (slave_axi_rlast) begin
                        state_d = IDLE;
                        // we already got everything
                        req_o = 1'b0;
                    end
                    // save the request address for the next cycle
                    req_addr_d = addr_o;
                    // we can decrease the counter as the master has consumed the read data
                    cnt_d = cnt_q + 1;
                    // TODO: configure correct byte-lane
                end
            end
            // ~> we already wrote the first word here
            WRITE: begin

                slave_axi_wready = 1'b1;

                // consume a word here
                if (slave_axi_wvalid) begin
                    req_o         = 1'b1;
                    we_o          = 1'b1;
                    // ----------------------------
                    // Next address generation
                    // ----------------------------
                    // handle the correct burst type
                    case (ax_req_q.burst)

                        FIXED, INCR: addr_o = consaddr;
                        WRAP:  begin
                            // check if the address reached warp boundary
                            if (consaddr == upper_wrap_boundary) begin
                                addr_o = wrap_boundary;
                            // address warped beyond boundary
                            end else if (consaddr > upper_wrap_boundary) begin
                                addr_o = ax_req_q.addr + ((cnt_q - ax_req_q.len) << LOG_NR_BYTES);
                            // we are still in the incremental regime
                            end else begin
                                addr_o = consaddr;
                            end
                        end
                    endcase
                    // save the request address for the next cycle
                    req_addr_d = addr_o;
                    // we can decrease the counter as the master has consumed the read data
                    cnt_d = cnt_q + 1;

                    if (slave_axi_wlast)
                        state_d = SEND_B;
                end
            end
            // ~> send a write acknowledge back
            SEND_B: begin
                slave_axi_bvalid = 1'b1;
                slave_axi_bid    = ax_req_q.id;
                if (slave_axi_bready)
                    state_d = IDLE;
            end

        endcase
    end

    `ifndef SYNTHESIS
    `ifndef VERILATOR
    // assert that only full data lane transfers allowed
    // assert property (
    //   @(posedge clk_i) slave_axi_awvalid |-> (slave_axi_awsize == LOG_NR_BYTES)) else $fatal ("Only full data lane transfers allowed");
    //   assert property (
    //   @(posedge clk_i) slave_axi_arvalid |-> (slave_axi_arsize == LOG_NR_BYTES)) else $fatal ("Only full data lane transfers allowed");
    // assert property (
    //   @(posedge clk_i) slave_axi_awvalid |-> (slave_axi_araddr[LOG_NR_BYTES-1:0] == '0)) else $fatal ("Unaligned accesses are not allowed at the moment");
    // assert property (
    //   @(posedge clk_i) slave_axi_arvalid |-> (slave_axi_awaddr[LOG_NR_BYTES-1:0] == '0)) else $fatal ("Unaligned accesses are not allowed at the moment");
    `endif
    `endif
    // --------------
    // Registers
    // --------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            state_q    <= IDLE;
            ax_req_q  <= '0;
            req_addr_q <= '0;
            cnt_q      <= '0;
        end else begin
            state_q    <= state_d;
            ax_req_q   <= ax_req_d;
            req_addr_q <= req_addr_d;
            cnt_q      <= cnt_d;
        end
    end
endmodule

