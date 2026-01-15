`timescale 1ns/1ps
module requant #(
    parameter integer PE_NUM        = 32,
    parameter integer ACC_SIZE      = 32,       // must be 32
    parameter         RELU_FUSED    = 1'b0
)(
    input  wire                         clk,
    input  wire                         reset,

    input  wire                         scale_load,
    input  wire signed [23:0]           scale_in,

    input  wire                         shift_load,
    input  wire [7:0]                   shift_in,

    input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,
    input  wire                         in_valid,

    output reg  [8*PE_NUM-1:0]          out_vec,
    output reg                          out_valid
);

    // ------------------------------------------------------------
    // Params (REGISTERED ONLY)
    // ------------------------------------------------------------
    reg  signed [23:0] scale_reg;      // 24-bit scale
    reg         [5:0]  shift_reg;      // 0..63
    reg         [4:0]  zp_reg_fixed;   // fixed 30 for mlp

    // ------------------------------------------------------------
    // Stage-0: register input vector (cuts pb_out -> mul input path)
    // ------------------------------------------------------------
    reg  [ACC_SIZE*PE_NUM-1:0] x_vec_r;
    reg                        v0;

    // ------------------------------------------------------------
    // Stage-1: mul (uses x_vec_r, scale_reg ONLY)
    // ------------------------------------------------------------
    reg  [64*PE_NUM-1:0] mul_vec_r;
    reg  [5:0]           sh1_r;
    reg                  v1;

    wire [64*PE_NUM-1:0] mul_vec_w;

    genvar gi0;
    generate
        for (gi0 = 0; gi0 < PE_NUM; gi0 = gi0 + 1) begin : GEN_MUL
            wire signed [31:0] x_i32;
            wire signed [55:0] mul56; // 32x24 -> 56
            wire signed [63:0] mul64;

            assign x_i32 = $signed(x_vec_r[ACC_SIZE*gi0 +: ACC_SIZE]);
            assign mul56 = $signed(x_i32) * $signed(scale_reg);
            assign mul64 = {{8{mul56[55]}}, mul56}; // sign extend

            assign mul_vec_w[64*gi0 +: 64] = mul64;
        end
    endgenerate

    // ------------------------------------------------------------
    // Stage-2: rounding add
    // ------------------------------------------------------------
    reg  [64*PE_NUM-1:0] rnd_vec_r;
    reg  [5:0]           sh2_r;
    reg                  v2;

    wire [64*PE_NUM-1:0] rnd_vec_w;

    genvar gi1;
    generate
        for (gi1 = 0; gi1 < PE_NUM; gi1 = gi1 + 1) begin : GEN_ROUND
            wire signed [63:0] mul64_r;
            wire signed [63:0] rnd64;

            assign mul64_r = $signed(mul_vec_r[64*gi1 +: 64]);

            // half_up rounding (unconditional add when shift>0)
            assign rnd64   = (sh1_r == 6'd0) ? mul64_r
                          : (mul64_r + ($signed(64'sd1) <<< (sh1_r - 6'd1)));

            assign rnd_vec_w[64*gi1 +: 64] = rnd64;
        end
    endgenerate

    // ------------------------------------------------------------
    // Stage-3: shift + sat + zp + clip
    // ------------------------------------------------------------
    wire [8*PE_NUM-1:0] q_u8_vec_w;
    reg  [8:0] lo3_r;
    reg        v3;

    genvar gi2;
    generate
        for (gi2 = 0; gi2 < PE_NUM; gi2 = gi2 + 1) begin : GEN_QUANT
            wire signed [63:0] rnd64_r;
            wire signed [63:0] out64;

            wire               in_range;
            wire signed [31:0] rq_i32;

            wire signed [33:0] qy_s34;
            wire signed [33:0] lo_s34;
            wire [7:0]         q_u8;

            assign rnd64_r = $signed(rnd_vec_r[64*gi2 +: 64]);
            assign out64   = (sh2_r == 6'd0) ? rnd64_r : ($signed(rnd64_r) >>> sh2_r);

            // int64 -> int32 saturate via sign-extension check
            assign in_range = (out64[63:31] == {33{out64[31]}});
            assign rq_i32   = in_range ? out64[31:0]
                                       : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

            // add fixed zp (30)
            assign qy_s34 = $signed({{2{rq_i32[31]}}, rq_i32}) + $signed({26'd0, zp_reg_fixed});

            // lo bound
            assign lo_s34 = $signed({{25{1'b0}}, lo3_r});

            // clip to u8 [lo..255]
            assign q_u8 = (qy_s34 < lo_s34) ? lo3_r[7:0]
                       : (qy_s34 > 34'sd255) ? 8'hFF
                       : qy_s34[7:0];

            assign q_u8_vec_w[8*gi2 +: 8] = q_u8;
        end
    endgenerate

    // ------------------------------------------------------------
    // Sequential
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            scale_reg     <= 24'sd0;
            shift_reg     <= 6'd0;
            zp_reg_fixed  <= 5'h1e; // 30

            x_vec_r       <= {(ACC_SIZE*PE_NUM){1'b0}};
            v0            <= 1'b0;

            mul_vec_r     <= {(64*PE_NUM){1'b0}};
            sh1_r         <= 6'd0;
            v1            <= 1'b0;

            rnd_vec_r     <= {(64*PE_NUM){1'b0}};
            sh2_r         <= 6'd0;
            v2            <= 1'b0;

            lo3_r         <= 9'd0;
            v3            <= 1'b0;

            out_vec       <= {(8*PE_NUM){1'b0}};
            out_valid     <= 1'b0;

        end else begin
            // param update (NO direct use same cycle in datapath)
            if (scale_load) scale_reg <= scale_in;
            if (shift_load) shift_reg <= shift_in[5:0];

            // Stage0: capture input vector
            if (in_valid) begin
                x_vec_r <= in_vec;
                v0      <= 1'b1;
            end else begin
                v0      <= 1'b0;
            end

            // Stage1: mul
            if (v0) begin
                mul_vec_r <= mul_vec_w;
                sh1_r     <= shift_reg; // registered shift only
                v1        <= 1'b1;
            end else begin
                v1        <= 1'b0;
            end

            // Stage2: rounding add
            if (v1) begin
                rnd_vec_r <= rnd_vec_w;
                sh2_r     <= sh1_r;
                v2        <= 1'b1;
            end else begin
                v2        <= 1'b0;
            end

            // Stage3: prep lo (registered) + output valid
            if (v2) begin
                lo3_r     <= (RELU_FUSED != 1'b0) ? {1'b0, zp_reg_fixed} : 9'd0;
                v3        <= 1'b1;
            end else begin
                v3        <= 1'b0;
            end

            out_valid <= v3;
            if (v3) out_vec <= q_u8_vec_w;
        end
    end

endmodule



// `timescale 1ns/1ps
// // ============================================================
// // requant_pipelined.v  (Verilog-2001)
// // - 32-lane (PE_NUM) parallel requantization
// // - pipelined: Stage1(mul) -> Stage2(round-add) -> Stage3(shift+sat+zp+clip)
// // - latency: +2 cycles vs original (total 3 cycles from in_valid to out_valid)
// // ============================================================
// module requant #(
//     parameter integer PE_NUM        = 32,
//     parameter integer ACC_SIZE      = 32,       // must be 32 for this implementation
//     parameter         RELU_FUSED    = 1'b0      // fc1/fc2: 1, fc3: 0
// )(
//     input  wire                         clk,
//     input  wire                         reset,

//     input  wire                         scale_load,
//     input  wire signed [23:0]           scale_in,   // requant_s

//     input  wire                         shift_load,
//     input  wire [7:0]                   shift_in,   // requant_shift (use [5:0])

//     // input  wire                         zp_load,
//     // input  wire [7:0]                   zp_in,      // out_zero_point

//     input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,     // int32 lanes
//     input  wire                         in_valid,

//     output reg  [8*PE_NUM-1:0]          out_vec,    // u8 lanes
//     output reg                          out_valid
// );

//     // ------------------------------------------------------------
//     // Parameter registers (can be updated at runtime)
//     // ------------------------------------------------------------
//     reg  signed [31:0] scale_reg;
//     reg         [5:0]  shift_reg;
//     // reg         [7:0]  zp_reg;
//     reg         [4:0]  zp_reg_fixed = 5'h1e; // fixed 30 for mlp

//     // effective params for "this cycle" (supports load + in_valid same cycle)
//     wire signed [31:0] scale_eff = (scale_load != 1'b0) ? scale_in : scale_reg;
//     wire        [5:0]  shift_eff = (shift_load != 1'b0) ? shift_in[5:0] : shift_reg;
//     // wire        [7:0]  zp_eff    = (zp_load    != 1'b0) ? zp_in         : zp_reg;

//     // ------------------------------------------------------------
//     // Stage-1 registers: latch mul result and params aligned to it
//     // ------------------------------------------------------------
//     reg  [64*PE_NUM-1:0] mul_vec_r;
//     reg  [5:0]           sh1_r;
//     // reg  [7:0]           zp1_r;
//     reg                  v1;

//     // combinational multiply results (in_vec * scale_eff)
//     wire [64*PE_NUM-1:0] mul_vec_w;

//     genvar gi0;
//     generate
//         for (gi0 = 0; gi0 < PE_NUM; gi0 = gi0 + 1) begin : GEN_MUL
//             wire signed [31:0] x_i32;
//             wire signed [63:0] mul64;

//             assign x_i32 = $signed(in_vec[ACC_SIZE*gi0 +: ACC_SIZE]);
//             assign mul64 = $signed(x_i32) * $signed(scale_eff);

//             assign mul_vec_w[64*gi0 +: 64] = mul64;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Stage-2: rounding add (register rnd64)
//     // ------------------------------------------------------------
//     reg  [64*PE_NUM-1:0] rnd_vec_r;
//     reg  [5:0]           sh2_r;
//     // reg  [7:0]           zp2_r;
//     reg                  v2;

//     wire [64*PE_NUM-1:0] rnd_vec_w;

//     genvar gi1;
//     generate
//         for (gi1 = 0; gi1 < PE_NUM; gi1 = gi1 + 1) begin : GEN_ROUND
//             wire signed [63:0] mul64_r;
//             wire signed [63:0] rnd64;

//             assign mul64_r = $signed(mul_vec_r[64*gi1 +: 64]);

//             // half_up rounding (Python-compatible, unconditional add when shift>0)
//             assign rnd64 = (sh1_r == 6'd0)
//                          ? mul64_r
//                          : (mul64_r + ($signed(64'sd1) <<< (sh1_r - 6'd1)));

//             assign rnd_vec_w[64*gi1 +: 64] = rnd64;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Stage-3 combinational: shift, saturate to int32, +zp, clip to u8
//     // ------------------------------------------------------------
//     wire [8*PE_NUM-1:0] q_u8_vec_w;

//     // register lo to reduce fanout / keep alignment
//     reg  [8:0] lo3_r;
//     reg        v3;  // internal for clarity (out_valid = v3)

//     genvar gi2;
//     generate
//         for (gi2 = 0; gi2 < PE_NUM; gi2 = gi2 + 1) begin : GEN_QUANT
//             wire signed [63:0] rnd64_r;
//             wire signed [63:0] out64;

//             wire               in_range;
//             wire signed [31:0] rq_i32;

//             wire signed [33:0] qy_s34;
//             wire signed [33:0] lo_s34;

//             wire [7:0]         q_u8;

//             assign rnd64_r = $signed(rnd_vec_r[64*gi2 +: 64]);

//             assign out64 = (sh2_r == 6'd0) ? rnd64_r : ($signed(rnd64_r) >>> sh2_r);

//             // int64 -> int32 saturate via sign-extension check
//             assign in_range = (out64[63:31] == {33{out64[31]}});
//             assign rq_i32   = in_range ? out64[31:0]
//                                        : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

//             // add out_zero_point (zp)
//             // assign qy_s34 = $signed({{2{rq_i32[31]}}, rq_i32}) + $signed({26'd0, zp2_r});
//             assign qy_s34 = $signed({{2{rq_i32[31]}}, rq_i32}) + $signed({26'd0, zp_reg_fixed});

//             // lo bound as signed 34b
//             assign lo_s34 = $signed({{25{1'b0}}, lo3_r});

//             // clip to u8 [lo..255]
//             assign q_u8 = (qy_s34 < lo_s34) ? lo3_r[7:0]
//                        : (qy_s34 > 34'sd255) ? 8'hFF
//                        : qy_s34[7:0];

//             assign q_u8_vec_w[8*gi2 +: 8] = q_u8;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Sequential: update params + pipeline regs + outputs
//     // ------------------------------------------------------------
//     always @(posedge clk) begin
//         if (reset) begin
//             scale_reg  <= 32'sd0;
//             shift_reg  <= 6'd0;
//             // zp_reg     <= 8'd0;

//             mul_vec_r  <= { (64*PE_NUM){1'b0} };
//             sh1_r      <= 6'd0;
//             // zp1_r      <= 8'd0;
//             v1         <= 1'b0;

//             rnd_vec_r  <= { (64*PE_NUM){1'b0} };
//             sh2_r      <= 6'd0;
//             // zp2_r      <= 8'd0;
//             v2         <= 1'b0;

//             lo3_r      <= 9'd0;
//             v3         <= 1'b0;

//             out_vec    <= { (8*PE_NUM){1'b0} };
//             out_valid  <= 1'b0;

//         end else begin
//             // update stored params
//             if (scale_load != 1'b0) scale_reg <= scale_in;
//             if (shift_load != 1'b0) shift_reg <= shift_in[5:0];
//             // if (zp_load    != 1'b0) zp_reg    <= zp_in;

//             // -------------------------
//             // Stage1 capture (mul + params)
//             // -------------------------
//             if (in_valid != 1'b0) begin
//                 mul_vec_r <= mul_vec_w;
//                 sh1_r     <= shift_eff;
//                 // zp1_r     <= zp_eff;
//                 v1        <= 1'b1;
//             end else begin
//                 v1        <= 1'b0;
//             end

//             // -------------------------
//             // Stage2 capture (round-add + params)
//             // -------------------------
//             if (v1 != 1'b0) begin
//                 rnd_vec_r <= rnd_vec_w;
//                 sh2_r     <= sh1_r;
//                 // zp2_r     <= zp1_r;
//                 v2        <= 1'b1;
//             end else begin
//                 v2        <= 1'b0;
//             end

//             // -------------------------
//             // Stage3 capture (lo register + outputs)
//             // -------------------------
//             if (v2 != 1'b0) begin
//                 // lo3_r     <= (RELU_FUSED != 1'b0) ? {1'b0, zp2_r} : 9'd0;
//                 lo3_r     <= (RELU_FUSED != 1'b0) ? {1'b0, zp_reg_fixed} : 9'd0;
//                 v3        <= 1'b1;
//             end else begin
//                 v3        <= 1'b0;
//             end

//             out_valid <= v3;
//             if (v3 != 1'b0) begin
//                 out_vec <= q_u8_vec_w;
//             end
//         end
//     end

// endmodule