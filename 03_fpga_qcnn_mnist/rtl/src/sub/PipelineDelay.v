`timescale 1ns / 1ps

module PipelineDelay #(
    parameter DEPTH = 1, 
              WIDTH = 1) 
(
    input clk,
    input reset, 
    input wen,
    input [WIDTH-1:0] din,
    output[WIDTH-1:0] dout
);

    reg [WIDTH-1:0] delay_reg [DEPTH-1:0];
    
    integer k;
    always @(posedge clk) begin
        if (reset) begin
            for (k = 0 ; k < DEPTH ; k = k + 1) begin
                delay_reg[k] <= {WIDTH{1'b0}};
            end
        end
        else begin
            if (wen) begin
                delay_reg[0] <= din;
                for (k = 0 ; k < DEPTH-1 ; k = k + 1) begin
                    delay_reg[k+1] <= delay_reg[k];
                end        
            end
        end            
    end        
    
    assign dout = delay_reg[DEPTH-1];
    
endmodule
