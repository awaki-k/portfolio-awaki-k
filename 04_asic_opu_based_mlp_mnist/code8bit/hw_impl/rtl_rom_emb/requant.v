// ============================================================
// requant_fc1.v  (Handshake-ready, lane-safe, Verilog-2001)
//
// fc1 fixed params:
//   SCALE_C = 423831 (0x067797)  [24-bit signed const]
//   SHIFT_C = 30
//   out_zp  = 0
//   relu_fused = true (lo=0)
//
// Pipeline (1 chunk = MUL_PARL lanes):
//   stage0: latch input vector + issue idx
//   stage1: mul (int32 * scale -> int64)
//   stage2: add rounding bias (half_up)
//   stage3: arithmetic shift + sat int32 + clip u8 + writeback lanes
//
// Handshake:
//   - Accept input only when (in_valid && in_ready)
//   - in_ready deasserted while processing the current vector
//   - out_valid pulses 1 cycle after the last writeback, and out_vec is stable then
// ============================================================
module requant_fc1 #(
    parameter integer PE_NUM   = 32,
    parameter integer ACC_SIZE = 32,
    parameter integer MUL_PARL = 4,
    parameter integer WIDTH    = 8
)(
    input  wire                          clk,
    input  wire                          reset,

    input  wire [ACC_SIZE*PE_NUM-1:0]    in_vec,     // int32 lanes packed (lane0 at [31:0])
    input  wire                          in_valid,
    output wire                          in_ready,

    output reg  [WIDTH*PE_NUM-1:0]       out_vec,    // u8 lanes packed (lane0 at [7:0])
    output reg                           out_valid
);

    // -----------------------------
    // Fixed params (FC1)
    // -----------------------------
    localparam signed [23:0] SCALE_C = 24'h067797; // 423831
    localparam integer       SHIFT_C = 30;
    localparam integer       DEPTH   = (PE_NUM + MUL_PARL - 1) / MUL_PARL;

    // -----------------------------
    // Verilog-2001 clog2
    // -----------------------------
    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction
    localparam integer IDX_W = (DEPTH <= 1) ? 1 : clog2(DEPTH);

    // -----------------------------
    // Handshake / busy
    // -----------------------------
    reg busy;
    assign in_ready = !busy;

    wire accept = in_valid && in_ready; // accept new vector

    // -----------------------------
    // Stage-0: hold full vector + issue chunk index
    // -----------------------------
    reg  [ACC_SIZE*PE_NUM-1:0] x_vec_r;
    reg  [IDX_W-1:0]           idx0_iss;
    reg                        v0;

    // Chunk issue counter (0..DEPTH-1)
    reg  [IDX_W-1:0]           issue_cnt;

    // -----------------------------
    // Stage-1..3 regs
    // -----------------------------
    reg  [64*MUL_PARL-1:0]     mul_vec_r;
    reg  [IDX_W-1:0]           idx1;
    reg                        v1;

    reg  [64*MUL_PARL-1:0]     rnd_vec_r;
    reg  [IDX_W-1:0]           idx2;
    reg                        v2;

    reg  [64*MUL_PARL-1:0]     s3_rnd_vec_r;
    reg  [IDX_W-1:0]           idx3;
    reg                        v3;

    // out_valid delayed pulse
    reg out_valid_d;

    // -----------------------------
    // Helper: extract lane int32 from latched vector
    // -----------------------------
    function [31:0] get_x32;
        input integer lane;
        begin
            get_x32 = x_vec_r[ACC_SIZE*lane +: ACC_SIZE];
        end
    endfunction

    // ============================================================
    // Stage-1 combinational: mul (int32 * int24 -> int64)
    // ============================================================
    wire [64*MUL_PARL-1:0] mul_vec_w;

    genvar p1;
    generate
        for (p1 = 0; p1 < MUL_PARL; p1 = p1 + 1) begin : GEN_MUL
            wire [IDX_W+2:0] base_lane;   // enough bits for idx*4 up to 31
            wire [IDX_W+3:0] lane_u;      // base_lane + p1
            wire [31:0]      x_raw;
            wire signed [31:0] x_i32;
            wire signed [55:0] mul56;
            wire signed [63:0] mul64;

            assign base_lane = {3'b000, idx0_iss} * MUL_PARL;
            assign lane_u    = base_lane + p1[IDX_W+3:0];

            assign x_raw = (lane_u < PE_NUM) ? get_x32(lane_u) : 32'd0;

            assign x_i32 = $signed(x_raw);
            assign mul56 = $signed(x_i32) * $signed(SCALE_C); // 32x24 -> 56
            assign mul64 = {{8{mul56[55]}}, mul56};           // sign extend to 64

            assign mul_vec_w[64*p1 +: 64] = mul64;
        end
    endgenerate

    // ============================================================
    // Stage-2 combinational: rounding add (half_up)
    //   rnd64 = mul64 + (1<<(SHIFT_C-1))  if SHIFT_C>0
    // ============================================================
    wire [64*MUL_PARL-1:0] rnd_vec_w;
    localparam signed [63:0] ROUND_BIAS = (SHIFT_C > 0) ? (64'sd1 <<< (SHIFT_C-1)) : 64'sd0;

    genvar p2;
    generate
        for (p2 = 0; p2 < MUL_PARL; p2 = p2 + 1) begin : GEN_ROUND
            wire signed [63:0] mul64_r = $signed(mul_vec_r[64*p2 +: 64]);
            wire signed [63:0] rnd64   = (SHIFT_C == 0) ? mul64_r : (mul64_r + ROUND_BIAS);
            assign rnd_vec_w[64*p2 +: 64] = rnd64;
        end
    endgenerate

    // ============================================================
    // Stage-3 combinational: shift + sat(int32) + clip u8 [0..255]
    // ============================================================
    wire [WIDTH*MUL_PARL-1:0] q_u8_vec_w;

    genvar p3;
    generate
        for (p3 = 0; p3 < MUL_PARL; p3 = p3 + 1) begin : GEN_QUANT
            wire signed [63:0] rnd64_r = $signed(s3_rnd_vec_r[64*p3 +: 64]);
            wire signed [63:0] out64   = (SHIFT_C == 0) ? rnd64_r : (rnd64_r >>> SHIFT_C);

            // saturate int64 -> int32
            wire in_range = (out64[63:31] == {33{out64[31]}});
            wire signed [31:0] rq_i32 = in_range ? out64[31:0]
                                                 : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

            // out_zp=0, relu_fused=true => clip [0..255]
            wire signed [31:0] qy = rq_i32;

            wire [7:0] q_u8 = (qy < 32'sd0)   ? 8'h00 :
                              (qy > 32'sd255) ? 8'hFF :
                                               qy[7:0];

            assign q_u8_vec_w[WIDTH*p3 +: WIDTH] = q_u8;
        end
    endgenerate

    // ============================================================
    // Sequential: issue + pipeline + writeback + handshake
    // ============================================================
    integer k;
    integer lane_i;
    integer bitpos;

    always @(posedge clk) begin
        if (reset) begin
            busy        <= 1'b0;

            x_vec_r     <= {(ACC_SIZE*PE_NUM){1'b0}};
            out_vec     <= {(WIDTH*PE_NUM){1'b0}};

            idx0_iss    <= {IDX_W{1'b0}};
            issue_cnt   <= {IDX_W{1'b0}};
            v0          <= 1'b0;

            mul_vec_r   <= {(64*MUL_PARL){1'b0}};
            idx1        <= {IDX_W{1'b0}};
            v1          <= 1'b0;

            rnd_vec_r   <= {(64*MUL_PARL){1'b0}};
            idx2        <= {IDX_W{1'b0}};
            v2          <= 1'b0;

            s3_rnd_vec_r<= {(64*MUL_PARL){1'b0}};
            idx3        <= {IDX_W{1'b0}};
            v3          <= 1'b0;

            out_valid   <= 1'b0;
            out_valid_d <= 1'b0;

        end else begin
            // out_valid: delayed 1-cycle pulse after last writeback
            out_valid   <= out_valid_d;
            out_valid_d <= 1'b0;

            // default: no issue unless set below
            v0 <= 1'b0;

            // --------------------------------------------------
            // Accept new vector (only when ready)
            // --------------------------------------------------
            if (accept) begin
                // latch input
                x_vec_r  <= in_vec;

                // clear output buffer for this transaction (safe because we won't accept while busy)
                out_vec  <= {(WIDTH*PE_NUM){1'b0}};

                // start issuing chunks
                busy      <= 1'b1;
                idx0_iss   <= {IDX_W{1'b0}};  // issue chunk0 immediately
                v0         <= 1'b1;

                // next issue = 1
                if (DEPTH > 1)
                    issue_cnt <= {{(IDX_W-1){1'b0}}, 1'b1};
                else
                    issue_cnt <= {IDX_W{1'b0}};
            end
            else if (busy) begin
                // --------------------------------------------------
                // While busy: issue chunks 1..DEPTH-1
                // --------------------------------------------------
                idx0_iss <= issue_cnt;
                v0       <= 1'b1;

                if (issue_cnt == (DEPTH-1)) begin
                    // issued last chunk this cycle; stop issuing next cycle
                    busy      <= 1'b0;
                    issue_cnt <= {IDX_W{1'b0}};
                end else begin
                    issue_cnt <= issue_cnt + 1'b1;
                end
            end

            // --------------------------------------------------
            // stage1
            // --------------------------------------------------
            if (v0) begin
                mul_vec_r <= mul_vec_w;
                idx1      <= idx0_iss;
                v1        <= 1'b1;
            end else begin
                v1        <= 1'b0;
            end

            // --------------------------------------------------
            // stage2
            // --------------------------------------------------
            if (v1) begin
                rnd_vec_r <= rnd_vec_w;
                idx2      <= idx1;
                v2        <= 1'b1;
            end else begin
                v2        <= 1'b0;
            end

            // --------------------------------------------------
            // stage3 input reg (use registered rnd_vec_r!)
            // --------------------------------------------------
            if (v2) begin
                s3_rnd_vec_r <= rnd_vec_r;
                idx3         <= idx2;
                v3           <= 1'b1;
            end else begin
                v3           <= 1'b0;
            end

            // --------------------------------------------------
            // stage3 writeback
            // --------------------------------------------------
            if (v3) begin
                for (k = 0; k < MUL_PARL; k = k + 1) begin
                    lane_i = (idx3 * MUL_PARL) + k;
                    if (lane_i < PE_NUM) begin
                        bitpos = WIDTH * lane_i;
                        out_vec[bitpos +: WIDTH] <= q_u8_vec_w[WIDTH*k +: WIDTH];
                    end
                end

                // last chunk written -> pulse out_valid next cycle
                if (idx3 == (DEPTH-1)) begin
                    out_valid_d <= 1'b1;
                end
            end
        end
    end

endmodule








// ============================================================
// requant_fc2.v  (Handshake-ready, lane-safe, Verilog-2001)
//
// fc2 fixed params:
//   SCALE_C = 0x377E80
//   SHIFT_C = 30
//   out_zp  = 0
//   (relu_fused assumed; zp=0 so lo=0 anyway)
//
// Pipeline (1 chunk = MUL_PARL lanes):
//   stage0: latch input vector + issue idx
//   stage1: mul (int32 * scale -> int64)
//   stage2: add rounding bias (half_up)
//   stage3: arithmetic shift + sat int32 + clip u8 + writeback lanes
//
// Handshake:
//   - Accept input only when (in_valid && in_ready)
//   - in_ready deasserted while processing the current vector
//   - out_valid pulses 1 cycle after the last writeback, and out_vec is stable then
// ============================================================
module requant_fc2 #(
    parameter integer PE_NUM   = 32,
    parameter integer ACC_SIZE = 32,
    parameter integer MUL_PARL = 4,
    parameter integer WIDTH    = 8
)(
    input  wire                          clk,
    input  wire                          reset,

    input  wire [ACC_SIZE*PE_NUM-1:0]    in_vec,     // int32 lanes packed (lane0 at [31:0])
    input  wire                          in_valid,
    output wire                          in_ready,

    output reg  [WIDTH*PE_NUM-1:0]       out_vec,    // u8 lanes packed (lane0 at [7:0])
    output reg                           out_valid
);

    // -----------------------------
    // Fixed params (FC2)
    // -----------------------------
    localparam signed [23:0] SCALE_C = 24'h377E80; // fc2 scale
    localparam integer       SHIFT_C = 30;
    localparam integer       DEPTH   = (PE_NUM + MUL_PARL - 1) / MUL_PARL;

    // -----------------------------
    // Verilog-2001 clog2
    // -----------------------------
    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction
    localparam integer IDX_W = (DEPTH <= 1) ? 1 : clog2(DEPTH);

    // -----------------------------
    // Handshake / busy
    // -----------------------------
    reg busy;
    assign in_ready = !busy;

    wire accept = in_valid && in_ready;

    // -----------------------------
    // Stage-0 regs
    // -----------------------------
    reg  [ACC_SIZE*PE_NUM-1:0] x_vec_r;
    reg  [IDX_W-1:0]           idx0_iss;
    reg                        v0;

    reg  [IDX_W-1:0]           issue_cnt; // 0..DEPTH-1

    // -----------------------------
    // Stage-1..3 regs
    // -----------------------------
    reg  [64*MUL_PARL-1:0]     mul_vec_r;
    reg  [IDX_W-1:0]           idx1;
    reg                        v1;

    reg  [64*MUL_PARL-1:0]     rnd_vec_r;
    reg  [IDX_W-1:0]           idx2;
    reg                        v2;

    reg  [64*MUL_PARL-1:0]     s3_rnd_vec_r;
    reg  [IDX_W-1:0]           idx3;
    reg                        v3;

    reg out_valid_d;

    // -----------------------------
    // Helper: extract lane int32
    // -----------------------------
    function [31:0] get_x32;
        input integer lane;
        begin
            get_x32 = x_vec_r[ACC_SIZE*lane +: ACC_SIZE];
        end
    endfunction

    // ============================================================
    // Stage-1 combinational: mul (int32 * int24 -> int64)
    // ============================================================
    wire [64*MUL_PARL-1:0] mul_vec_w;

    genvar p1;
    generate
        for (p1 = 0; p1 < MUL_PARL; p1 = p1 + 1) begin : GEN_MUL
            wire [IDX_W+2:0] base_lane;   // idx*4 fits within 0..31
            wire [IDX_W+3:0] lane_u;
            wire [31:0]        x_raw;
            wire signed [31:0] x_i32;
            wire signed [55:0] mul56;
            wire signed [63:0] mul64;

            assign base_lane = {3'b000, idx0_iss} * MUL_PARL;
            assign lane_u    = base_lane + p1[IDX_W+3:0];

            assign x_raw = (lane_u < PE_NUM) ? get_x32(lane_u) : 32'd0;

            assign x_i32 = $signed(x_raw);
            assign mul56 = $signed(x_i32) * $signed(SCALE_C); // 32x24 -> 56
            assign mul64 = {{8{mul56[55]}}, mul56};           // sign extend to 64

            assign mul_vec_w[64*p1 +: 64] = mul64;
        end
    endgenerate

    // ============================================================
    // Stage-2 combinational: rounding add (half_up)
    // ============================================================
    wire [64*MUL_PARL-1:0] rnd_vec_w;
    localparam signed [63:0] ROUND_BIAS = (SHIFT_C > 0) ? (64'sd1 <<< (SHIFT_C-1)) : 64'sd0;

    genvar p2;
    generate
        for (p2 = 0; p2 < MUL_PARL; p2 = p2 + 1) begin : GEN_ROUND
            wire signed [63:0] mul64_r = $signed(mul_vec_r[64*p2 +: 64]);
            wire signed [63:0] rnd64   = (SHIFT_C == 0) ? mul64_r : (mul64_r + ROUND_BIAS);
            assign rnd_vec_w[64*p2 +: 64] = rnd64;
        end
    endgenerate

    // ============================================================
    // Stage-3 combinational: shift + sat(int32) + clip u8 [0..255]
    // ============================================================
    wire [WIDTH*MUL_PARL-1:0] q_u8_vec_w;

    genvar p3;
    generate
        for (p3 = 0; p3 < MUL_PARL; p3 = p3 + 1) begin : GEN_QUANT
            wire signed [63:0] rnd64_r = $signed(s3_rnd_vec_r[64*p3 +: 64]);
            wire signed [63:0] out64   = (SHIFT_C == 0) ? rnd64_r : (rnd64_r >>> SHIFT_C);

            // sat int64 -> int32
            wire in_range = (out64[63:31] == {33{out64[31]}});
            wire signed [31:0] rq_i32 = in_range ? out64[31:0]
                                                 : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

            // out_zp = 0, clip [0..255]
            wire signed [31:0] qy = rq_i32;

            wire [7:0] q_u8 = (qy < 32'sd0)   ? 8'h00 :
                              (qy > 32'sd255) ? 8'hFF :
                                               qy[7:0];

            assign q_u8_vec_w[WIDTH*p3 +: WIDTH] = q_u8;
        end
    endgenerate

    // ============================================================
    // Sequential: issue + pipeline + writeback
    // ============================================================
    integer k;
    integer lane_i;
    integer bitpos;

    always @(posedge clk) begin
        if (reset) begin
            busy        <= 1'b0;

            x_vec_r     <= {(ACC_SIZE*PE_NUM){1'b0}};
            out_vec     <= {(WIDTH*PE_NUM){1'b0}};

            idx0_iss    <= {IDX_W{1'b0}};
            issue_cnt   <= {IDX_W{1'b0}};
            v0          <= 1'b0;

            mul_vec_r   <= {(64*MUL_PARL){1'b0}};
            idx1        <= {IDX_W{1'b0}};
            v1          <= 1'b0;

            rnd_vec_r   <= {(64*MUL_PARL){1'b0}};
            idx2        <= {IDX_W{1'b0}};
            v2          <= 1'b0;

            s3_rnd_vec_r<= {(64*MUL_PARL){1'b0}};
            idx3        <= {IDX_W{1'b0}};
            v3          <= 1'b0;

            out_valid   <= 1'b0;
            out_valid_d <= 1'b0;

        end else begin
            // out_valid pulse
            out_valid   <= out_valid_d;
            out_valid_d <= 1'b0;

            // default
            v0 <= 1'b0;

            // accept new vector
            if (accept) begin
                x_vec_r  <= in_vec;
                out_vec  <= {(WIDTH*PE_NUM){1'b0}};

                busy      <= 1'b1;
                idx0_iss   <= {IDX_W{1'b0}};
                v0         <= 1'b1;

                if (DEPTH > 1)
                    issue_cnt <= {{(IDX_W-1){1'b0}}, 1'b1};
                else
                    issue_cnt <= {IDX_W{1'b0}};
            end
            else if (busy) begin
                idx0_iss <= issue_cnt;
                v0       <= 1'b1;

                if (issue_cnt == (DEPTH-1)) begin
                    busy      <= 1'b0;
                    issue_cnt <= {IDX_W{1'b0}};
                end else begin
                    issue_cnt <= issue_cnt + 1'b1;
                end
            end

            // stage1
            if (v0) begin
                mul_vec_r <= mul_vec_w;
                idx1      <= idx0_iss;
                v1        <= 1'b1;
            end else v1 <= 1'b0;

            // stage2
            if (v1) begin
                rnd_vec_r <= rnd_vec_w;
                idx2      <= idx1;
                v2        <= 1'b1;
            end else v2 <= 1'b0;

            // stage3 input (use registered rnd_vec_r)
            if (v2) begin
                s3_rnd_vec_r <= rnd_vec_r;
                idx3         <= idx2;
                v3           <= 1'b1;
            end else v3 <= 1'b0;

            // stage3 writeback
            if (v3) begin
                for (k = 0; k < MUL_PARL; k = k + 1) begin
                    lane_i = (idx3 * MUL_PARL) + k;
                    if (lane_i < PE_NUM) begin
                        bitpos = WIDTH * lane_i;
                        out_vec[bitpos +: WIDTH] <= q_u8_vec_w[WIDTH*k +: WIDTH];
                    end
                end

                if (idx3 == (DEPTH-1)) begin
                    out_valid_d <= 1'b1;
                end
            end
        end
    end

endmodule




// `timescale 1ns/1ps
// module requant #(
//     parameter integer PE_NUM        = 32,
//     parameter integer ACC_SIZE      = 32,       // must be 32
//     parameter         RELU_FUSED    = 1'b0
// )(
//     input  wire                         clk,
//     input  wire                         reset,

//     input  wire                         scale_load,
//     input  wire signed [23:0]           scale_in,

//     input  wire                         shift_load,
//     input  wire [7:0]                   shift_in,

//     input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,
//     input  wire                         in_valid,

//     output reg  [8*PE_NUM-1:0]          out_vec,
//     output reg                          out_valid
// );

//     // ------------------------------------------------------------
//     // Params (REGISTERED ONLY)
//     // ------------------------------------------------------------
//     reg  signed [23:0] scale_reg;      // 24-bit scale
//     reg         [5:0]  shift_reg;      // 0..63
//     reg         [4:0]  zp_reg_fixed;   // fixed 30 for mlp

//     // ------------------------------------------------------------
//     // Stage-0: register input vector (cuts pb_out -> mul input path)
//     // ------------------------------------------------------------
//     reg  [ACC_SIZE*PE_NUM-1:0] x_vec_r;
//     reg                        v0;

//     // ------------------------------------------------------------
//     // Stage-1: mul (uses x_vec_r, scale_reg ONLY)
//     // ------------------------------------------------------------
//     reg  [64*PE_NUM-1:0] mul_vec_r;
//     reg  [5:0]           sh1_r;
//     reg                  v1;

//     wire [64*PE_NUM-1:0] mul_vec_w;

//     genvar gi0;
//     generate
//         for (gi0 = 0; gi0 < PE_NUM; gi0 = gi0 + 1) begin : GEN_MUL
//             wire signed [31:0] x_i32;
//             wire signed [55:0] mul56; // 32x24 -> 56
//             wire signed [63:0] mul64;

//             assign x_i32 = $signed(x_vec_r[ACC_SIZE*gi0 +: ACC_SIZE]);
//             assign mul56 = $signed(x_i32) * $signed(scale_reg);
//             assign mul64 = {{8{mul56[55]}}, mul56}; // sign extend

//             assign mul_vec_w[64*gi0 +: 64] = mul64;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Stage-2: rounding add
//     // ------------------------------------------------------------
//     reg  [64*PE_NUM-1:0] rnd_vec_r;
//     reg  [5:0]           sh2_r;
//     reg                  v2;

//     wire [64*PE_NUM-1:0] rnd_vec_w;

//     genvar gi1;
//     generate
//         for (gi1 = 0; gi1 < PE_NUM; gi1 = gi1 + 1) begin : GEN_ROUND
//             wire signed [63:0] mul64_r;
//             wire signed [63:0] rnd64;

//             assign mul64_r = $signed(mul_vec_r[64*gi1 +: 64]);

//             // half_up rounding (unconditional add when shift>0)
//             assign rnd64   = (sh1_r == 6'd0) ? mul64_r
//                           : (mul64_r + ($signed(64'sd1) <<< (sh1_r - 6'd1)));

//             assign rnd_vec_w[64*gi1 +: 64] = rnd64;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Stage-3: shift + sat + zp + clip
//     // ------------------------------------------------------------
//     wire [8*PE_NUM-1:0] q_u8_vec_w;
//     reg  [8:0] lo3_r;
//     reg        v3;

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
//             assign out64   = (sh2_r == 6'd0) ? rnd64_r : ($signed(rnd64_r) >>> sh2_r);

//             // int64 -> int32 saturate via sign-extension check
//             assign in_range = (out64[63:31] == {33{out64[31]}});
//             assign rq_i32   = in_range ? out64[31:0]
//                                        : (out64[63] ? 32'sh8000_0000 : 32'sh7FFF_FFFF);

//             // add fixed zp (30)
//             assign qy_s34 = $signed({{2{rq_i32[31]}}, rq_i32}) + $signed({26'd0, zp_reg_fixed});

//             // lo bound
//             assign lo_s34 = $signed({{25{1'b0}}, lo3_r});

//             // clip to u8 [lo..255]
//             assign q_u8 = (qy_s34 < lo_s34) ? lo3_r[7:0]
//                        : (qy_s34 > 34'sd255) ? 8'hFF
//                        : qy_s34[7:0];

//             assign q_u8_vec_w[8*gi2 +: 8] = q_u8;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // Sequential
//     // ------------------------------------------------------------
//     always @(posedge clk) begin
//         if (reset) begin
//             scale_reg     <= 24'sd0;
//             shift_reg     <= 6'd0;
//             zp_reg_fixed  <= 5'h1e; // 30

//             x_vec_r       <= {(ACC_SIZE*PE_NUM){1'b0}};
//             v0            <= 1'b0;

//             mul_vec_r     <= {(64*PE_NUM){1'b0}};
//             sh1_r         <= 6'd0;
//             v1            <= 1'b0;

//             rnd_vec_r     <= {(64*PE_NUM){1'b0}};
//             sh2_r         <= 6'd0;
//             v2            <= 1'b0;

//             lo3_r         <= 9'd0;
//             v3            <= 1'b0;

//             out_vec       <= {(8*PE_NUM){1'b0}};
//             out_valid     <= 1'b0;

//         end else begin
//             // param update (NO direct use same cycle in datapath)
//             if (scale_load) scale_reg <= scale_in;
//             if (shift_load) shift_reg <= shift_in[5:0];

//             // Stage0: capture input vector
//             if (in_valid) begin
//                 x_vec_r <= in_vec;
//                 v0      <= 1'b1;
//             end else begin
//                 v0      <= 1'b0;
//             end

//             // Stage1: mul
//             if (v0) begin
//                 mul_vec_r <= mul_vec_w;
//                 sh1_r     <= shift_reg; // registered shift only
//                 v1        <= 1'b1;
//             end else begin
//                 v1        <= 1'b0;
//             end

//             // Stage2: rounding add
//             if (v1) begin
//                 rnd_vec_r <= rnd_vec_w;
//                 sh2_r     <= sh1_r;
//                 v2        <= 1'b1;
//             end else begin
//                 v2        <= 1'b0;
//             end

//             // Stage3: prep lo (registered) + output valid
//             if (v2) begin
//                 lo3_r     <= (RELU_FUSED != 1'b0) ? {1'b0, zp_reg_fixed} : 9'd0;
//                 v3        <= 1'b1;
//             end else begin
//                 v3        <= 1'b0;
//             end

//             out_valid <= v3;
//             if (v3) out_vec <= q_u8_vec_w;
//         end
//     end

// endmodule