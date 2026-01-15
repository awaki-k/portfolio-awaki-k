`timescale 1ns / 1ps

module DPU #(
    parameter integer N            = 3*3*1,  // ch1
    parameter integer ACT_WIDTH    = 8,      // x(8bit)
    parameter integer WEIGHT_WIDTH = 8,      // w(8bit)
    parameter integer STAGE_DEPTH  = 3,
    parameter integer MULT_W       = 16,
    parameter integer ACC_W        = 32      // acc(32bit)
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      in_valid, 
    input  wire                      wen,
    input  wire [WEIGHT_WIDTH*N-1:0] w_vec,
    input  wire [ACT_WIDTH*N-1:0]    a_vec,
    output wire [ACC_W-1:0]          out, 
    output wire                      out_valid
);

    localparam integer SAFE_STAGE_DEPTH = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;
    localparam integer PIPE_DEPTH = ($clog2(N)) / SAFE_STAGE_DEPTH;

    wire [MULT_W*N-1:0] mult_vec;

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin
            assign mult_vec[MULT_W*k +: MULT_W] = $signed(w_vec[WEIGHT_WIDTH*k +: WEIGHT_WIDTH]) * $signed(a_vec[ACT_WIDTH*k +: ACT_WIDTH]);
        end
    endgenerate


    AdderTree #(
        .INPUTS_NUM (N),
        .IDATA_WIDTH(MULT_W),
        .STAGE_DEPTH(SAFE_STAGE_DEPTH)
    ) adder_tree (
        .clk  (clk),
        .reset(reset),
        .wen  (wen),
        .idata(mult_vec),
        .odata(out)
    );

    generate
        if (PIPE_DEPTH == 0) begin
            assign out_valid = in_valid;
        end else begin
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
