`timescale 1ns/1ps
// 2x2 MaxPool (unsigned) with 1-cycle latency
// win2x2_flat = {r1c1, r1c0, r0c1, r0c0}
module MaxPool2x2 #(
    parameter integer DW = 8
)(
    input  wire                 clk,
    input  wire                 reset,          // Active-High async reset (posedge)
    input  wire                 in_valid,
    input  wire [DW*4-1:0]      win2x2_flat,    // {r1c1,r1c0,r0c1,r0c0}

    output reg                  out_valid,
    output reg  [DW-1:0]        out_u8
);
    // Unpack {r1c1,r1c0,r0c1,r0c0}
    wire [DW-1:0] a = win2x2_flat[DW*3 +: DW];  // r1c1
    wire [DW-1:0] b = win2x2_flat[DW*2 +: DW];  // r1c0
    wire [DW-1:0] c = win2x2_flat[DW*1 +: DW];  // r0c1
    wire [DW-1:0] d = win2x2_flat[DW*0 +: DW];  // r0c0

    // 2-level max tree (unsigned)
    wire [DW-1:0] m1 = (a > b) ? a : b;
    wire [DW-1:0] m2 = (c > d) ? c : d;
    wire [DW-1:0] m  = (m1 > m2) ? m1 : m2;

    // 1-cycle register; async active-high reset
    always @(posedge clk) begin
        if (reset) begin
            out_valid <= 1'b0;
            out_u8    <= {DW{1'b0}};
        end else begin
            out_valid <= in_valid;
            out_u8    <= m;
        end
    end
endmodule
