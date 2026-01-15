
// Argmax10_pipeline4.v  (4-stage pipeline, total latency = 4 cycles)
// - Stage1: 10 -> 5
// - Stage2: 5  -> 3
// - Stage3: 3  -> 2
// - Stage4: 2  -> 1  (final)
// 同値のときは左（小さい index）を優先
`timescale 1ns/1ps
module Argmax10 #(
    parameter W = 32
)(
    input  wire              clk,
    input  wire              reset,      // Active-High async
    input  wire              in_valid,
    input  wire signed [W-1:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9,
    output reg               out_valid,
    output reg        [3:0]  out_index
);
    // =========================================================
    // Stage1: pairwise 10 -> 5
    // =========================================================
    reg               v_s1;
    reg  signed [W-1:0] s1_val [0:4];
    reg         [3:0]   s1_idx [0:4];

    wire signed [W-1:0] w01 = (v0 >= v1) ? v0 : v1;  wire [3:0] i01 = (v0 >= v1) ? 4'd0 : 4'd1;
    wire signed [W-1:0] w23 = (v2 >= v3) ? v2 : v3;  wire [3:0] i23 = (v2 >= v3) ? 4'd2 : 4'd3;
    wire signed [W-1:0] w45 = (v4 >= v5) ? v4 : v5;  wire [3:0] i45 = (v4 >= v5) ? 4'd4 : 4'd5;
    wire signed [W-1:0] w67 = (v6 >= v7) ? v6 : v7;  wire [3:0] i67 = (v6 >= v7) ? 4'd6 : 4'd7;
    wire signed [W-1:0] w89 = (v8 >= v9) ? v8 : v9;  wire [3:0] i89 = (v8 >= v9) ? 4'd8 : 4'd9;

    always @(posedge clk) begin
        if (reset) begin
            v_s1 <= 1'b0;
        end else begin
            v_s1      <= in_valid;
            s1_val[0] <= w01; s1_idx[0] <= i01;
            s1_val[1] <= w23; s1_idx[1] <= i23;
            s1_val[2] <= w45; s1_idx[2] <= i45;
            s1_val[3] <= w67; s1_idx[3] <= i67;
            s1_val[4] <= w89; s1_idx[4] <= i89;
        end
    end

    // =========================================================
    // Stage2: 5 -> 3  ([(0vs1),(2vs3)] の勝者 + そのまま4番目)
    // =========================================================
    reg               v_s2;
    reg  signed [W-1:0] s2_val [0:2];
    reg         [3:0]   s2_idx [0:2];

    wire signed [W-1:0] a01v = (s1_val[0] >= s1_val[1]) ? s1_val[0] : s1_val[1];
    wire        [3:0]   a01i = (s1_val[0] >= s1_val[1]) ? s1_idx[0] : s1_idx[1];

    wire signed [W-1:0] a23v = (s1_val[2] >= s1_val[3]) ? s1_val[2] : s1_val[3];
    wire        [3:0]   a23i = (s1_val[2] >= s1_val[3]) ? s1_idx[2] : s1_idx[3];

    always @(posedge clk) begin
        if (reset) begin
            v_s2 <= 1'b0;
        end else begin
            v_s2      <= v_s1;
            s2_val[0] <= a01v; s2_idx[0] <= a01i;   // winner of (0,1)
            s2_val[1] <= a23v; s2_idx[1] <= a23i;   // winner of (2,3)
            s2_val[2] <= s1_val[4]; s2_idx[2] <= s1_idx[4]; // original 4
        end
    end

    // =========================================================
    // Stage3: 3 -> 2  (勝者同士で 1つ、残り1つはそのまま)
    // =========================================================
    reg               v_s3;
    reg  signed [W-1:0] s3_val [0:1];
    reg         [3:0]   s3_idx [0:1];

    wire signed [W-1:0] b0123v = (s2_val[0] >= s2_val[1]) ? s2_val[0] : s2_val[1];
    wire        [3:0]   b0123i = (s2_val[0] >= s2_val[1]) ? s2_idx[0] : s2_idx[1];

    always @(posedge clk) begin
        if (reset) begin
            v_s3 <= 1'b0;
        end else begin
            v_s3      <= v_s2;
            s3_val[0] <= b0123v; s3_idx[0] <= b0123i;  // winner of (0,1)
            s3_val[1] <= s2_val[2]; s3_idx[1] <= s2_idx[2]; // carry-over of #2
        end
    end

    // =========================================================
    // Stage4: 2 -> 1  (最終比較)
    // =========================================================
    reg               v_s4;
    reg  signed [W-1:0] final_val;
    reg         [3:0]   final_idx;

    wire signed [W-1:0] bfinv = (s3_val[0] >= s3_val[1]) ? s3_val[0] : s3_val[1];
    wire        [3:0]   bfini = (s3_val[0] >= s3_val[1]) ? s3_idx[0] : s3_idx[1];

    always @(posedge clk) begin
        if (reset) begin
            v_s4      <= 1'b0;
            out_valid <= 1'b0;
            out_index <= 4'd0;
        end else begin
            v_s4      <= v_s3;
            final_val <= bfinv;
            final_idx <= bfini;

            out_valid <= v_s4;      // latency = 4 cycles
            out_index <= final_idx;
        end
    end
endmodule


// // Argmax10_pipeline2.v  (2-stage pipeline, total latency = 2 cycles)
// `timescale 1ns/1ps
// module Argmax10 #(
//     parameter W = 32
// ) (
//     input  wire             clk,
//     input  wire             reset,     // Active-High async
//     input  wire             in_valid,
//     input  wire signed [W-1:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9,
//     output reg              out_valid,
//     output reg       [3:0]  out_index
// );
//     // -------- stage1: 10 -> 5 勝ち上がり --------
//     reg               v_s1;
//     reg  signed [W-1:0] s1_val [0:4];
//     reg         [3:0]   s1_idx [0:4];

//     wire signed [W-1:0] a01_val = (v0 >= v1) ? v0 : v1;  // tie -> smaller index stays
//     wire        [3:0]   a01_idx = (v0 >= v1) ? 4'd0 : 4'd1;

//     wire signed [W-1:0] a23_val = (v2 >= v3) ? v2 : v3;
//     wire        [3:0]   a23_idx = (v2 >= v3) ? 4'd2 : 4'd3;

//     wire signed [W-1:0] a45_val = (v4 >= v5) ? v4 : v5;
//     wire        [3:0]   a45_idx = (v4 >= v5) ? 4'd4 : 4'd5;

//     wire signed [W-1:0] a67_val = (v6 >= v7) ? v6 : v7;
//     wire        [3:0]   a67_idx = (v6 >= v7) ? 4'd6 : 4'd7;

//     wire signed [W-1:0] a89_val = (v8 >= v9) ? v8 : v9;
//     wire        [3:0]   a89_idx = (v8 >= v9) ? 4'd8 : 4'd9;

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             v_s1 <= 1'b0;
//         end else begin
//             v_s1      <= in_valid;
//             s1_val[0] <= a01_val;  s1_idx[0] <= a01_idx;
//             s1_val[1] <= a23_val;  s1_idx[1] <= a23_idx;
//             s1_val[2] <= a45_val;  s1_idx[2] <= a45_idx;
//             s1_val[3] <= a67_val;  s1_idx[3] <= a67_idx;
//             s1_val[4] <= a89_val;  s1_idx[4] <= a89_idx;
//         end
//     end

//     // -------- stage2: 5 -> 1（[(0vs1),(2vs3)] を勝者同士→最後は(その勝者) vs 4）--------
//     reg               v_s2;
//     reg  signed [W-1:0] final_val;
//     reg         [3:0]   final_idx;

//     wire signed [W-1:0] b01_val = (s1_val[0] >= s1_val[1]) ? s1_val[0] : s1_val[1];
//     wire        [3:0]   b01_idx = (s1_val[0] >= s1_val[1]) ? s1_idx[0] : s1_idx[1];

//     wire signed [W-1:0] b23_val = (s1_val[2] >= s1_val[3]) ? s1_val[2] : s1_val[3];
//     wire        [3:0]   b23_idx = (s1_val[2] >= s1_val[3]) ? s1_idx[2] : s1_idx[3];

//     wire signed [W-1:0] b0123_val = (b01_val >= b23_val) ? b01_val : b23_val;
//     wire        [3:0]   b0123_idx = (b01_val >= b23_val) ? b01_idx : b23_idx;

//     wire signed [W-1:0] b_final_val = (b0123_val >= s1_val[4]) ? b0123_val : s1_val[4];
//     wire        [3:0]   b_final_idx = (b0123_val >= s1_val[4]) ? b0123_idx : s1_idx[4];

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             v_s2      <= 1'b0;
//             out_valid <= 1'b0;
//             out_index <= 4'd0;
//         end else begin
//             v_s2      <= v_s1;
//             final_val <= b_final_val;
//             final_idx <= b_final_idx;

//             out_valid <= v_s2;          // latency = 2
//             out_index <= final_idx;
//         end
//     end
// endmodule