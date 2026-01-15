`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Counter
// - lp_load で loop_in を保持 (loop_out)
// - lp_clear / lp_incr でカウント (loop_cnt)
// - loop_cnt >= loop_out で lp_end
//------------------------------------------------------------------------------
module Counter #(
    parameter integer BLOOP = 16
)(
    input  wire                 clk,
    input  wire                 reset,

    input  wire                 lp_load,
    input  wire [BLOOP-1:0]     loop_in,

    input  wire                 lp_clear,
    input  wire                 lp_incr,
    output wire                 lp_end
    
    // --- dbg ---
    // , output wire [BLOOP-1:0]   loop_cnt_dbg
    // , output wire [BLOOP-1:0]   loop_out_dbg
);
    wire [BLOOP-1:0] loop_out;
    wire [BLOOP-1:0] loop_cnt;

    // loop limit register
    loop_reg_ce #(
        .BLOOP(BLOOP)
    ) u_loop_reg (
        .clk     (clk),
        .reset   (reset),
        .lp_load (lp_load),
        .loop_in (loop_in),
        .loop_out(loop_out)
    );

    // loop counter
    counter_reg_ce #(
        .BLOOP(BLOOP)
    ) u_counter_reg (
        .clk     (clk),
        .reset   (reset),
        .lp_clear(lp_clear),
        .lp_incr  (lp_incr),
        .cout    (loop_cnt)
    );

    // end check
    LoopChecker #(
        .BLOOP(BLOOP)
    ) u_loop_checker (
        .loop_cnt(loop_cnt),
        .loop_reg(loop_out),
        .lp_end  (lp_end)
    );

    // --- dbg ---
    // assign loop_out_dbg = loop_out;
    // assign loop_cnt_dbg = loop_cnt;

endmodule

//------------------------------------------------------------------------------
// loop_reg_ce: lp_load で loop_in を保持するだけのレジスタ
//------------------------------------------------------------------------------
module loop_reg_ce #(
    parameter integer BLOOP = 16
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 lp_load,
    input  wire [BLOOP-1:0]     loop_in,
    output wire [BLOOP-1:0]     loop_out
);
    reg_ce #(
        .SIZE(BLOOP)
    ) u_loop_reg (
        .clk  (clk),
        .reset(reset),
        // .reset(1'b0),
        .clear(1'b0),
        .en   (lp_load),
        .in   (loop_in),
        .out  (loop_out)
    );
endmodule

//------------------------------------------------------------------------------
// counter_reg_ce: lp_clear / lp_incr を受けるカウンタ
// 元コード仕様:
//   next = lp_clear ? {0..0, lp_incr} : (lp_incr ? state+1 : state)
// => clear と inc 同時なら 1
//------------------------------------------------------------------------------
// module counter_reg_ce #(
//     parameter integer BLOOP = 16
// )(
//     input  wire                 clk,
//     input  wire                 reset,
//     input  wire                 lp_clear,
//     input  wire                 lp_incr,
//     output wire [BLOOP-1:0]     cout
// );

//     wire [BLOOP-1:0] state;
//     wire [BLOOP-1:0] next_state;

//     reg_ce #(
//         .SIZE(BLOOP)
//     ) u_counter_reg (
//         .clk  (clk),
//         .reset(reset),
//         .clear(1'b0),
//         .en   (1'b1),
//         .in   (next_state),
//         .out  (state)
//     );

//     // 明示的に「clear時のベース」と「inc分」を分けて読みやすくする
//     wire [BLOOP-1:0] base = lp_clear ? {BLOOP{1'b0}} : state;
//     wire [BLOOP-1:0] add  = lp_incr   ? {{(BLOOP-1){1'b0}}, 1'b1} : {BLOOP{1'b0}};

//     assign next_state = base + add;
//     assign cout       = state;

// endmodule
module counter_reg_ce #(
    parameter BLOOP = 16
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 lp_clear,
    input  wire                 lp_incr,
    output wire [BLOOP-1:0]     cout
);

    wire [BLOOP-1:0] next_state;
    wire [BLOOP-1:0] state;

    reg_ce #(
        .SIZE(BLOOP)
    ) u_counter_reg (
        .clk(clk),
        .reset(reset),
        .clear(1'b0),
        .en(1'b1),
        .in(next_state),
        .out(state)
    );

    assign next_state = lp_clear ? {{(BLOOP-1){1'b0}}, lp_incr} : 
                        lp_incr   ? state + 1'b1 : 
                        state;
                        
    assign cout = state;

endmodule

//------------------------------------------------------------------------------
// LoopChecker
//------------------------------------------------------------------------------
module LoopChecker #(
    parameter integer BLOOP = 16
)(
    input  wire [BLOOP-1:0] loop_cnt,
    input  wire [BLOOP-1:0] loop_reg,
    output wire             lp_end
);
    assign lp_end = (loop_cnt >= loop_reg);
endmodule

