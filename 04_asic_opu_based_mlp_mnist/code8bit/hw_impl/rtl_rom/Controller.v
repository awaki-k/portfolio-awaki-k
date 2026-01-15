`timescale 1ns / 1ps

// Current-State
`define     S_INIT           4'b0000

`define     S_EXEC00         4'b0001
`define     S_EXEC01         4'b0010
`define     S_EXEC02         4'b0011

`define     S_EXEC10         4'b0100
`define     S_EXEC11         4'b0101
`define     S_EXEC12         4'b0110

`define     S_BIAS0          4'b0111
`define     S_BIAS1          4'b1000
`define     S_BIAS2          4'b1001

`define     S_REQT0          4'b1010
`define     S_REQT1          4'b1011
`define     S_ARGMX          4'b1100

`define     S_WRITE0         4'b1101
`define     S_WRITE1         4'b1110
`define     S_DONE           4'b1111

// Single
`define     I        1'b1
`define     O        1'b0
`define     X        1'bx

module Controller #(
    parameter integer STATE_SIZE     = 4,
    parameter integer FSM_IN_SIZE    = STATE_SIZE + 10,
    parameter integer FSM_OUT_SIZE   = 19
)(
    input  wire                      clk,
    input  wire                      reset,

    input  wire [2:0]                exec_ready,
    input  wire                      exec_valid,
    input  wire                      li_end,
    input  wire                      lo_end,
    input  wire                      pb_valid,
    input  wire                      rq_valid,
    input  wire                      argmx_valid,
    input  wire                      tready,

    output wire                      li_rd_en,
    output wire                      lo_rd_en,
    output wire [2:0]                xw_rd_en,
    output wire                      acc_en,
    output wire                      acc_sel,
    output wire                      li_incr,
    output wire                      li_clear,
    output wire                      lo_incr,
    output wire                      lo_clear,
    output wire [2:0]                b_rd_en,
    output wire                      rq_rd_en,
    output wire [1:0]                x_wr_en,
    output wire                      argmx_en,
    output wire                      tvalid
    // --- dbg ---
    // , output wire [STATE_SIZE-1:0]    state_dbg
    // , output wire [STATE_SIZE-1:0]    next_state_dbg
);
    reg  [STATE_SIZE-1:0]   state, next_state;
    reg  [FSM_OUT_SIZE-1:0] fsm_out;
    wire [FSM_IN_SIZE-1:0]  fsm_in;

    // --- dbg ---
    // assign state_dbg      = state;
    // assign next_state_dbg = next_state;


    always @(posedge clk) begin
        if (reset) begin
            state <= `S_INIT;
        end else begin
            state <= next_state;
        end
    end

    assign fsm_in = {state, exec_ready, exec_valid, li_end, lo_end, pb_valid, rq_valid, argmx_valid, tready};
    always @(fsm_in) begin
        casex (fsm_in)
//      {     state, exec_ready[2:0], exec_valid, li_end, lo_end, pb_valid, rq_valid, argmx_valid, tready } :  next_state, fsm_out  <= { next_state, li_rd_en, lo_rd_en, xw_rd_en[2:0], acc_en, acc_sel, li_incr, li_clear, lo_incr, lo_clear, b_rd_en[2:0], rq_rd_en, x_wr_en[1:0],    argmx_en, tvalid };
        {   `S_INIT,          3'b000,         `X,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {    `S_INIT,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {   `S_INIT,          3'b001,         `O,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {    `S_INIT,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {   `S_INIT,          3'b001,         `I,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC00,       `I,       `I,        3'b000,     `O,      `O,      `I,       `I,      `O,       `I,       3'b000,       `O,        2'b00,          `O,     `O };

        { `S_EXEC00,          3'bxxx,         `X,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC10,       `O,       `O,        3'b001,     `I,      `O,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_EXEC01,          3'bxxx,         `X,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC11,       `O,       `O,        3'b010,     `I,      `O,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_EXEC02,          3'bxxx,         `X,     `X,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC12,       `O,       `O,        3'b100,     `I,      `O,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };        

        { `S_EXEC10,          3'bxxx,         `X,     `O,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC10,       `O,       `O,        3'b001,     `I,      `I,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_EXEC11,          3'bxxx,         `X,     `O,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC11,       `O,       `O,        3'b010,     `I,      `I,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_EXEC12,          3'bxxx,         `X,     `O,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC12,       `O,       `O,        3'b100,     `I,      `I,      `I,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };        

        { `S_EXEC10,          3'bxxx,         `X,     `I,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS0,       `O,       `O,        3'b000,     `I,      `I,      `O,       `O,      `I,       `O,       3'b001,       `O,        2'b00,          `O,     `O };
        { `S_EXEC11,          3'bxxx,         `X,     `I,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS1,       `O,       `O,        3'b000,     `I,      `I,      `O,       `O,      `I,       `O,       3'b010,       `O,        2'b00,          `O,     `O };
        { `S_EXEC12,          3'bxxx,         `X,     `I,     `X,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS2,       `O,       `O,        3'b000,     `I,      `I,      `O,       `O,      `I,       `O,       3'b100,       `O,        2'b00,          `O,     `O };        
        
        {  `S_BIAS0,          3'bxxx,         `X,     `X,     `X,       `O,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS0,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {  `S_BIAS1,          3'bxxx,         `X,     `X,     `X,       `O,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS1,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {  `S_BIAS2,          3'bxxx,         `X,     `X,     `X,       `O,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_BIAS2,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };        
        
        {  `S_BIAS0,          3'bxxx,         `X,     `X,     `X,       `I,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_REQT0,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `I,        2'b00,          `O,     `O };
        {  `S_BIAS1,          3'bxxx,         `X,     `X,     `X,       `I,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_REQT1,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `I,        2'b00,          `O,     `O };
        {  `S_BIAS2,          3'bxxx,         `X,     `X,     `X,       `I,       `X,          `X,     `X } : {next_state, fsm_out} <= {   `S_ARGMX,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `I,     `O };        
        
        {  `S_REQT0,          3'bxxx,         `X,     `X,     `X,       `X,       `O,          `X,     `X } : {next_state, fsm_out} <= {   `S_REQT0,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {  `S_REQT1,          3'bxxx,         `X,     `X,     `X,       `X,       `O,          `X,     `X } : {next_state, fsm_out} <= {   `S_REQT1,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {  `S_ARGMX,          3'bxxx,         `X,     `X,     `X,       `X,       `X,          `O,     `X } : {next_state, fsm_out} <= {   `S_ARGMX,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };        
        
        {  `S_REQT0,          3'bxxx,         `X,     `X,     `X,       `X,       `I,          `X,     `X } : {next_state, fsm_out} <= {  `S_WRITE0,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b01,          `O,     `O };
        {  `S_REQT1,          3'bxxx,         `X,     `X,     `X,       `X,       `I,          `X,     `X } : {next_state, fsm_out} <= {  `S_WRITE1,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b10,          `O,     `O };           
        
        { `S_WRITE0,          3'b00x,         `X,     `X,     `O,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC00,       `O,       `O,        3'b001,     `O,      `O,      `I,       `I,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_WRITE0,          3'b01x,         `X,     `X,     `I,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC01,       `I,       `I,        3'b010,     `O,      `O,      `I,       `I,      `O,       `I,       3'b000,       `O,        2'b00,          `O,     `O };
        { `S_WRITE1,          3'b10x,         `X,     `X,     `I,       `X,       `X,          `X,     `X } : {next_state, fsm_out} <= {  `S_EXEC02,       `I,       `I,        3'b100,     `O,      `O,      `I,       `I,      `O,       `I,       3'b000,       `O,        2'b00,          `O,     `O };        
        
        {  `S_ARGMX,          3'bxxx,         `X,     `X,     `I,       `X,       `X,          `I,     `O } : {next_state, fsm_out} <= {   `S_ARGMX,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `O };
        {  `S_ARGMX,          3'bxxx,         `X,     `X,     `I,       `X,       `X,          `I,     `I } : {next_state, fsm_out} <= {    `S_DONE,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,        2'b00,          `O,     `I };
        
        default                                                                                            : {next_state, fsm_out} <= {    `S_INIT,       `O,       `O,        3'b000,     `O,      `O,      `O,       `O,      `O,       `O,       3'b000,       `O,         2'b00,          `O,     `O }; // ERROR (unexpected inputs)
        endcase
    end

    assign { li_rd_en, lo_rd_en, xw_rd_en, acc_en, acc_sel, li_incr, li_clear, lo_incr, lo_clear, b_rd_en, rq_rd_en, x_wr_en, argmx_en, tvalid } = fsm_out;

endmodule