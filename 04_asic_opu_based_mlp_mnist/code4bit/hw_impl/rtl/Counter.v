`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Counter (Hardcoded Limit)
// - lp_clear: Reset counter to 0 (or 1 depending on logic)
// - lp_incr: Increment counter
// - lp_end: Asserted when counter >= LIMIT
//------------------------------------------------------------------------------
module Counter #(
    parameter integer BLOOP = 16,
    parameter integer LIMIT = 196 // Hardcoded limit
)(
    input  wire                 clk,
    input  wire                 reset,

    input  wire                 lp_clear,
    input  wire                 lp_incr,
    output wire                 lp_end,
    
    // 現在のカウント値（アドレス生成などに使う場合）
    output wire [BLOOP-1:0]     cnt_dbg 
);

    wire [BLOOP-1:0] loop_cnt;

    // loop counter
    counter_reg_ce #(
        .BLOOP(BLOOP)
    ) u_counter_reg (
        .clk      (clk),
        .reset    (reset),
        .lp_clear (lp_clear),
        .lp_incr  (lp_incr),
        .cout     (loop_cnt)
    );

    // end check (Constant Comparison)
    assign lp_end  = (loop_cnt >= LIMIT);
    
    assign cnt_dbg = loop_cnt;

endmodule

//------------------------------------------------------------------------------
// Counter Register (Increment logic)
//------------------------------------------------------------------------------
module counter_reg_ce #(
    parameter BLOOP = 16
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 lp_clear,
    input  wire                 lp_incr,
    output wire [BLOOP-1:0]     cout
);

    reg [BLOOP-1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state <= {BLOOP{1'b0}};
        end else if (lp_clear) begin
            state <= {BLOOP{1'b0}}; // Reset to 0
        end else if (lp_incr) begin
            state <= state + 1'b1;
        end
    end
                        
    assign cout = state;

endmodule