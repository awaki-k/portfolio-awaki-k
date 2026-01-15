`timescale 1ns / 1ps

module OPU #(
    parameter integer PE_NUM = 32,
    parameter integer SIZE = 8,
    parameter integer ACC_SIZE = 32
)(
    input clk,
    input reset,
    input wire acc_en,
    input wire acc_sel,
    input wire [PE_NUM*SIZE-1:0] win,
    input wire [SIZE-1:0] xin,
    output wire [ACC_SIZE*PE_NUM-1:0] yout
);

    genvar i;
    generate
        for(i = 0; i < PE_NUM; i = i+1) begin : PE_GEN
            wire [SIZE-1:0] weight_elem = win[i*SIZE +: SIZE];
            PE #(
                .SIZE(SIZE),
                .ACC_SIZE(ACC_SIZE)
            ) inst_pe (
                .clk(clk),
                .reset(reset),
                .acc_en(acc_en),
                .acc_sel(acc_sel),
                .xin(xin),
                .win(weight_elem),
                .yout(yout[i*ACC_SIZE +: ACC_SIZE])
            );
        end
    endgenerate

endmodule


module PE #(
    parameter integer SIZE = 8,
    parameter integer ACC_SIZE = 32
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    acc_en,
    input  wire                    acc_sel,
    input  wire [SIZE-1:0]         xin,   // uint8 (0..255)
    input  wire signed [SIZE-1:0]  win,   // int8
    output wire signed [ACC_SIZE-1:0] yout
);
    wire signed [SIZE:0] xin_s = $signed({1'b0, xin}); // 9-bit signed
    wire signed [2*SIZE:0] prod = win * xin_s;         // 17-bit signed

    wire signed [ACC_SIZE-1:0] mult = {{(ACC_SIZE-(2*SIZE+1)){prod[2*SIZE]}}, prod};

    wire signed [ACC_SIZE-1:0] acc_in;

    reg_ce #(.SIZE(ACC_SIZE)) acc_reg_inst (
        .clk  (clk),
        .reset(reset),
        .clear(1'b0),
        .en   (acc_en),
        .in   (acc_in),
        .out  (yout)
    );

    assign acc_in = acc_sel ? (yout + mult) : mult;

endmodule


// module PE #(
//     parameter integer SIZE = 8,
//     parameter integer ACC_SIZE = 32
// )(
//     input                               clk,
//     input                               reset,
//     input                               acc_en,
//     input                               acc_sel,
//     input   unsigned    [SIZE-1:0]      xin,
//     input   signed      [SIZE-1:0]      win,
//     output  signed      [ACC_SIZE-1:0]  yout
// );

//     wire signed [ACC_SIZE-1:0] mult;
//     wire signed [ACC_SIZE-1:0] acc_in;
    
//     reg_ce #(
//         .SIZE(ACC_SIZE)
//     ) acc_reg_inst (
//         .clk(clk),
//         .reset(reset),
//         .clear(1'b0),
//         .en(acc_en),
//         .in(acc_in),
//         .out(yout)
//     );
    
//     assign mult = $signed(win) * $unsigned(xin);
//     assign acc_in = (acc_sel) ? ($signed(yout) + $signed(mult)) : $signed(mult);

// endmodule
