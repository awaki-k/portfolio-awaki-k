`timescale 1ns/1ps
// ============================================================
// requant.v  (Verilog-2001)
// - 32-lane (PE_NUM) parallel requantization
// - input : signed int32 lanes (ACC_SIZE=32 assumed)
// - params loaded via scale_load/shift_load/zp_load
// - output: uint8 lanes (8*PE_NUM) with clip
//
// Python-compatible behavior (per lane):
//   mul64 = (int64)x_i32 * requant_s
//   if (shift > 0) rnd64 = mul64 + 2^(shift-1)   // unconditional add (sign-independent)
//   out64 = rnd64 >>> shift                      // arithmetic shift
//   rq_i32 = saturate int64->int32
//   qy = rq_i32 + out_zp
//   lo = (RELU_FUSED ? out_zp : 0)
//   q_u8 = clamp(qy, lo..255)
//
// Notes:
// - shift uses only [5:0] (0..63)
// - RELU_FUSED is a module parameter (set per layer)
// ============================================================
module requant #(
    parameter integer PE_NUM        = 32,
    parameter integer ACC_SIZE      = 32,       // must be 32 for this implementation
    parameter         RELU_FUSED    = 1'b0      // fc1/fc2: 1, fc3: 0
)(
    input  wire                         clk,
    input  wire                         reset,

    input  wire                         scale_load,
    input  wire signed [23:0]           scale_in,   // requant_s

    input  wire                         shift_load,
    input  wire [7:0]                   shift_in,   // requant_shift (use [5:0])

    input  wire                         zp_load,
    input  wire [7:0]                   zp_in,      // out_zero_point

    input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,     // int32 lanes
    input  wire                         in_valid,

    output reg  [8*PE_NUM-1:0]          out_vec,    // u8 lanes
    output reg                          out_valid
);

    // ------------------------------------------------------------
    // Parameter registers (can be updated at runtime)
    // ------------------------------------------------------------
    reg  signed [31:0] scale_reg;
    reg         [5:0]  shift_reg;
    reg         [7:0]  zp_reg;

    // effective params for "this cycle" (supports load + in_valid same cycle)
    wire signed [31:0] scale_eff = (scale_load != 1'b0) ? scale_in : scale_reg;
    wire        [5:0]  shift_eff = (shift_load != 1'b0) ? shift_in[5:0] : shift_reg;
    wire        [7:0]  zp_eff    = (zp_load    != 1'b0) ? zp_in         : zp_reg;

    // ------------------------------------------------------------
    // Stage-1 registers: latch mul result and params aligned to it
    // (1-cycle latency from in_valid to out_valid)
    // ------------------------------------------------------------
    reg  [64*PE_NUM-1:0] mul_vec_r;
    reg  [5:0]           sh_r;
    reg  [7:0]           zp_r;
    reg                  v1;

    // combinational multiply results (in_vec * scale_eff)
    wire [64*PE_NUM-1:0] mul_vec_w;

    genvar gi0;
    generate
        for (gi0 = 0; gi0 < PE_NUM; gi0 = gi0 + 1) begin : GEN_MUL
            wire signed [31:0] x_i32;
            wire signed [63:0] mul64;

            assign x_i32 = $signed(in_vec[ACC_SIZE*gi0 +: ACC_SIZE]);
            assign mul64 = $signed(x_i32) * $signed(scale_eff);

            assign mul_vec_w[64*gi0 +: 64] = mul64;
        end
    endgenerate

    // ------------------------------------------------------------
    // Stage-2 combinational: rounding+shift, sat to int32, +zp, clip to u8
    // ------------------------------------------------------------
    wire [8*PE_NUM-1:0] q_u8_vec_w;

    // lower bound for u8 clip (relu_fused aware)
    wire [8:0] lo_u9 = (RELU_FUSED != 1'b0) ? {1'b0, zp_r} : 9'd0;

    genvar gi1;
    generate
        for (gi1 = 0; gi1 < PE_NUM; gi1 = gi1 + 1) begin : GEN_QUANT
            wire signed [63:0] mul64_r;
            wire signed [63:0] rnd64;
            wire signed [63:0] out64;

            wire               in_range;
            wire signed [31:0] rq_i32;

            wire signed [33:0] qy_s34;
            wire signed [33:0] lo_s34;

            wire [7:0]         q_u8;

            assign mul64_r = $signed(mul_vec_r[64*gi1 +: 64]);

            // half_up rounding (Python-compatible)
            // if shift==0: no rounding/no shift
            assign rnd64 = (sh_r == 6'd0) ? mul64_r : (mul64_r + ($signed(64'sd1) <<< (sh_r - 6'd1)));

            assign out64 = (sh_r == 6'd0) ? rnd64 : ($signed(rnd64) >>> sh_r);

            // int64 -> int32 saturate via sign-extension check
            assign in_range = (out64[63:31] == {33{out64[31]}});
            assign rq_i32   = in_range ? out64[31:0] : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

            // add out_zero_point (zp)
            assign qy_s34 = $signed({{2{rq_i32[31]}}, rq_i32}) + $signed({26'd0, zp_r});

            // lo bound as signed 34b
            assign lo_s34 = $signed({{25{1'b0}}, lo_u9});

            // clip to u8 [lo..255]
            assign q_u8 = (qy_s34 < lo_s34) ? lo_u9[7:0] : (qy_s34 > 34'sd255) ? 8'hFF : qy_s34[7:0];

            assign q_u8_vec_w[8*gi1 +: 8] = q_u8;
        end
    endgenerate

    // ------------------------------------------------------------
    // Sequential: update params + pipeline regs + outputs
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            scale_reg  <= 32'sd0;
            shift_reg  <= 6'd0;
            zp_reg     <= 8'd0;

            mul_vec_r  <= { (64*PE_NUM){1'b0} };
            sh_r       <= 6'd0;
            zp_r       <= 8'd0;
            v1         <= 1'b0;

            out_vec    <= { (8*PE_NUM){1'b0} };
            out_valid  <= 1'b0;
        end else begin
            // update stored params
            if (scale_load != 1'b0) scale_reg <= scale_in;
            if (shift_load != 1'b0) shift_reg <= shift_in[5:0];
            if (zp_load    != 1'b0) zp_reg    <= zp_in;

            // stage1 capture (mul + aligned params)
            if (in_valid != 1'b0) begin
                mul_vec_r <= mul_vec_w;
                sh_r      <= shift_eff;
                zp_r      <= zp_eff;
                v1        <= 1'b1;
            end else begin
                v1        <= 1'b0;
            end

            // stage2 output (1 cycle after stage1 valid)
            out_valid <= v1;
            if (v1 != 1'b0) begin
                out_vec <= q_u8_vec_w;
            end
        end
    end

endmodule
