`timescale 1ns / 1ps

module DPUconv1ch0 #(
    parameter integer N            = 3*3*1,
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
    // --- dbg ---
    // , output wire [MULT_W*N-1:0]  mult_vec_dbg
);

    // ---------------------------------------------------------
    // 固定重みベクトル (内部レジスタ = ROM)
    // ---------------------------------------------------------
    localparam signed [WEIGHT_WIDTH*N-1:0] w_vec = {
        8'sd81,    // w8
        8'sd127,   // w7
        8'sd112,   // w6
        8'sd68,    // w5
        -8'sd59,   // w4
        8'sd22,    // w3
        8'sh80,  // w2
        -8'sd93,   // w1
        -8'sd17    // w0
    };

    // ---------------------------------------------------------
    // 乗算結果ベクトル
    // ---------------------------------------------------------
    wire [MULT_W*N-1:0] mult_vec;
    
    // --- dbg ---
    // assign mult_vec_dbg = mult_vec;

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : GEN_MUL
            assign mult_vec[MULT_W*k +: MULT_W] =
                $signed(w_vec[WEIGHT_WIDTH*k +: WEIGHT_WIDTH]) *
                $signed(a_vec[ACT_WIDTH*k +: ACT_WIDTH]);
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
    assign out = (adder_tree_out >= 0) ? {{ACC_W-ODATA_WIDTH{1'b0}}, adder_tree_out} 
                                       : {{ACC_W-ODATA_WIDTH{1'b1}}, adder_tree_out};

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

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // initial cnt = 0;
    // always @(posedge clk) begin
    //     if (out_valid) begin
    //         $display("conv1_ch0_out_dbg[%0d][%0d]: %0d", cnt/26, cnt%26, $signed(out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

endmodule
