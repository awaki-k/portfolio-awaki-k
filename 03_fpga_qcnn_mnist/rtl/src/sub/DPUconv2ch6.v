`timescale 1ns / 1ps

module DPUconv2ch6 #(
    parameter integer N            = 3*3*4,
    parameter integer ACT_WIDTH    = 8,
    parameter integer WEIGHT_WIDTH = 8,  
    parameter integer STAGE_DEPTH  = 3,
    parameter integer MULT_W       = 16,
    parameter integer ACC_W        = 32
)(
    input  wire                   clk,
    input  wire                   reset,
    input  wire                   in_valid, 
    input  wire                   wen,
    input  wire [ACT_WIDTH*N-1:0] a_vec,
    output wire [ACC_W-1:0]       out, 
    output wire                   out_valid
);

    // ---------------------------------------------------------
    // 固定重みベクトル (内部レジスタ = ROM)
    // ---------------------------------------------------------
    localparam signed [WEIGHT_WIDTH*N-1:0] w_vec = {
            8'sd7, -8'sd37, -8'sd14, 
            -8'sd29, -8'sd20, 8'sd5, 
            8'sd8, 8'sd5, 8'sd16, 

            -8'sd47, -8'sd11, 8'sd16, 
            8'sd17, 8'sd25, -8'sd34, 
            8'sd20, -8'sd59, -8'sd74, 

            8'sd10, -8'sd28, 8'sd4, 
            8'sd19, 8'sd30, 8'sd22, 
            8'sd58, 8'sd47, 8'sd2, 

            -8'sd21, -8'sd7, -8'sd3, 
            8'sd18, 8'sd18, -8'sd28, 
            8'sd33, 8'sd35, -8'sd68
        };

    // ---------------------------------------------------------
    // 乗算結果ベクトル
    // ---------------------------------------------------------
    wire [MULT_W*N-1:0] mult_vec;

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : GEN_MUL
            assign mult_vec[MULT_W*k +: MULT_W] =
                $signed(w_vec[WEIGHT_WIDTH*k +: WEIGHT_WIDTH]) *
                $signed({1'b0, a_vec[ACT_WIDTH*k +: ACT_WIDTH]});
        end
    endgenerate

    // ---------------------------------------------------------
    // 加算木
    // ---------------------------------------------------------
    localparam STAGES_NUM = $clog2(N);
    localparam ODATA_WIDTH = MULT_W + STAGES_NUM;
    // adder_tree_out の宣言を修正
    wire signed [ODATA_WIDTH-1:0] adder_tree_out;  // 1つの信号として出力を保持

    AdderTree #(
        .INPUTS_NUM (N),
        .IDATA_WIDTH(MULT_W),
        .STAGE_DEPTH(STAGE_DEPTH)
        //,.ODATA_WIDTH(ACC_W)  // ODATA_WIDTH は内部で自動計算されているため、省略可
    ) adder_tree (
        .clk  (clk),
        .reset(reset),
        .wen  (wen),
        .idata(mult_vec),
        .odata(adder_tree_out)  // 配列ではなく、単一信号として出力
    );

    // 出力の符号拡張を行う
    assign out = {{(ACC_W-ODATA_WIDTH){adder_tree_out[ODATA_WIDTH-1]}}, adder_tree_out};



    // ---------------------------------------------------------
    // out_valid の遅延
    // ---------------------------------------------------------
    localparam integer SAFE_STAGE_DEPTH = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;
    localparam integer PIPE_DEPTH       = ($clog2(N)) / SAFE_STAGE_DEPTH;

    generate
        if (PIPE_DEPTH == 0) begin : GEN_VALID_PASS
            assign out_valid = in_valid;
        end else begin : GEN_VALID_PIPE
            PipelineDelay #(
                .DEPTH(PIPE_DEPTH)
            ) inst_PipelineDelay (
                .clk  (clk),
                .reset(reset),
                .wen  (wen),
                .din  (in_valid),
                .dout (out_valid)
            );
        end
    endgenerate

endmodule