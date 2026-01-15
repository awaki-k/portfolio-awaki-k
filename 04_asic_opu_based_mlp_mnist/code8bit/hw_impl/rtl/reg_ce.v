`timescale 1ns / 1ps

module reg_ce #(
    parameter SIZE = 24
) (
    input clk,
    input reset,
    input clear, 
    input en,
    input [SIZE-1:0] in,
    output reg [SIZE-1:0] out
);

    always @(posedge clk) begin
        if (reset) begin
            out <= {SIZE{1'b0}};
        end else begin
            if (clear) begin
                out <= {SIZE{1'b0}};
            end else if (en) begin
                out <= in;
            end
        end
    end

endmodule

//reg_ce #(.SIZE(SIZE)) cnt_reg (
//    .clk(clk),
//    .reset(reset),
//    .en(en),
//    .in(cnt_next),
//    .clear(clear),
//    .out(out)
//);
