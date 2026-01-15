`timescale 1ns / 1ps

module qcnn_top #(
    parameter IMG_WIDTH = 28,
    parameter POOL1_WIDTH = 26,
    parameter CONV2_WIDTH = 13,
    parameter POOL2_WIDTH = 11,
    parameter DW = 8,
    parameter ACC_W = 32,
    parameter CONV1_N = 3*3*1,
    parameter CONV2_N = 3*3*4,
    parameter FC1_N   = 8,
    parameter CONV1_STAGE_DEPTH = 1,
    parameter CONV2_STAGE_DEPTH = 1,
    parameter FC_STAGE_DEPTH = 1,
    parameter FC_ACC_N = 25
)(
    input  wire clk,
    input  wire reset,
    input  wire in_valid,
    input  wire signed [7:0] pixel_in,
    output wire [3:0] pred_out,
    output wire out_valid

    // // --- dbg ---
    // , output wire                   linebuf_3x3_conv1_valid_dbg
    // , output wire [DW*9-1:0]        linebuf_3x3_conv1_flat_dbg
    // , output wire [ACC_W-1:0]       conv1_ch0_out_dbg, conv1_ch1_out_dbg, conv1_ch2_out_dbg, conv1_ch3_out_dbg
    // , output wire                   conv1_ch0_valid_dbg, conv1_ch1_valid_dbg, conv1_ch2_valid_dbg, conv1_ch3_valid_dbg
    // , output wire [DW-1:0]          postconv1_ch0_out_dbg, postconv1_ch1_out_dbg, postconv1_ch2_out_dbg, postconv1_ch3_out_dbg
    // , output wire                   postconv1_ch0_valid_dbg, postconv1_ch1_valid_dbg, postconv1_ch2_valid_dbg, postconv1_ch3_valid_dbg
    // , output wire                   linebuf_2x2_pool1_ch0_valid_dbg, linebuf_2x2_pool1_ch1_valid_dbg, linebuf_2x2_pool1_ch2_valid_dbg, linebuf_2x2_pool1_ch3_valid_dbg
    // , output wire [DW*4-1:0]        linebuf_2x2_pool1_ch0_flat_dbg, linebuf_2x2_pool1_ch1_flat_dbg, linebuf_2x2_pool1_ch2_flat_dbg, linebuf_2x2_pool1_ch3_flat_dbg
    // , output wire [DW-1:0]          pool1_ch0_out_dbg, pool1_ch1_out_dbg, pool1_ch2_out_dbg, pool1_ch3_out_dbg
    // , output wire                   pool1_ch0_valid_dbg, pool1_ch1_valid_dbg, pool1_ch2_valid_dbg, pool1_ch3_valid_dbg
    // , output wire [DW*9-1:0]        linebuf_3x3_conv2_ch0_flat_dbg, linebuf_3x3_conv2_ch1_flat_dbg, linebuf_3x3_conv2_ch2_flat_dbg, linebuf_3x3_conv2_ch3_flat_dbg
    // , output wire                   linebuf_3x3_conv2_ch0_valid_dbg, linebuf_3x3_conv2_ch1_valid_dbg, linebuf_3x3_conv2_ch2_valid_dbg, linebuf_3x3_conv2_ch3_valid_dbg
    // , output wire [ACC_W-1:0]       conv2_ch0_out_dbg, conv2_ch1_out_dbg, conv2_ch2_out_dbg, conv2_ch3_out_dbg, conv2_ch4_out_dbg, conv2_ch5_out_dbg, conv2_ch6_out_dbg, conv2_ch7_out_dbg
    // , output wire                   conv2_ch0_valid_dbg, conv2_ch1_valid_dbg, conv2_ch2_valid_dbg, conv2_ch3_valid_dbg, conv2_ch4_valid_dbg, conv2_ch5_valid_dbg, conv2_ch6_valid_dbg, conv2_ch7_valid_dbg
    // , output wire [DW-1:0]          postconv2_ch0_out_dbg, postconv2_ch1_out_dbg, postconv2_ch2_out_dbg, postconv2_ch3_out_dbg, postconv2_ch4_out_dbg, postconv2_ch5_out_dbg, postconv2_ch6_out_dbg, postconv2_ch7_out_dbg
    // , output wire                   postconv2_ch0_valid_dbg, postconv2_ch1_valid_dbg, postconv2_ch2_valid_dbg, postconv2_ch3_valid_dbg, postconv2_ch4_valid_dbg, postconv2_ch5_valid_dbg, postconv2_ch6_valid_dbg, postconv2_ch7_valid_dbg
    // , output wire                   linebuf_2x2_pool2_ch0_valid_dbg, linebuf_2x2_pool2_ch1_valid_dbg, linebuf_2x2_pool2_ch2_valid_dbg, linebuf_2x2_pool2_ch3_valid_dbg, linebuf_2x2_pool2_ch4_valid_dbg, linebuf_2x2_pool2_ch5_valid_dbg, linebuf_2x2_pool2_ch6_valid_dbg, linebuf_2x2_pool2_ch7_valid_dbg
    // , output wire [DW*4-1:0]        linebuf_2x2_pool2_ch0_flat_dbg, linebuf_2x2_pool2_ch1_flat_dbg, linebuf_2x2_pool2_ch2_flat_dbg, linebuf_2x2_pool2_ch3_flat_dbg, linebuf_2x2_pool2_ch4_flat_dbg, linebuf_2x2_pool2_ch5_flat_dbg, linebuf_2x2_pool2_ch6_flat_dbg, linebuf_2x2_pool2_ch7_flat_dbg
    // , output wire [DW-1:0]          pool2_ch0_out_dbg, pool2_ch1_out_dbg, pool2_ch2_out_dbg, pool2_ch3_out_dbg, pool2_ch4_out_dbg, pool2_ch5_out_dbg, pool2_ch6_out_dbg, pool2_ch7_out_dbg
    // , output wire                   pool2_ch0_valid_dbg, pool2_ch1_valid_dbg, pool2_ch2_valid_dbg, pool2_ch3_valid_dbg, pool2_ch4_valid_dbg, pool2_ch5_valid_dbg, pool2_ch6_valid_dbg, pool2_ch7_valid_dbg
    // , output wire [ACC_W-1:0]         fc_ch0_out_dbg, fc_ch1_out_dbg, fc_ch2_out_dbg, fc_ch3_out_dbg, fc_ch4_out_dbg, fc_ch5_out_dbg, fc_ch6_out_dbg, fc_ch7_out_dbg, fc_ch8_out_dbg, fc_ch9_out_dbg
    // , output wire                   fc_ch0_valid_dbg, fc_ch1_valid_dbg, fc_ch2_valid_dbg, fc_ch3_valid_dbg, fc_ch4_valid_dbg, fc_ch5_valid_dbg, fc_ch6_valid_dbg, fc_ch7_valid_dbg, fc_ch8_valid_dbg, fc_ch9_valid_dbg
    // , output wire [DW-1:0]          postfc_ch0_out_dbg, postfc_ch1_out_dbg, postfc_ch2_out_dbg, postfc_ch3_out_dbg, postfc_ch4_out_dbg, postfc_ch5_out_dbg, postfc_ch6_out_dbg, postfc_ch7_out_dbg, postfc_ch8_out_dbg, postfc_ch9_out_dbg
    // , output wire                   postfc_ch0_valid_dbg, postfc_ch1_valid_dbg, postfc_ch2_valid_dbg, postfc_ch3_valid_dbg, postfc_ch4_valid_dbg, postfc_ch5_valid_dbg, postfc_ch6_valid_dbg, postfc_ch7_valid_dbg, postfc_ch8_valid_dbg, postfc_ch9_valid_dbg
);
    wire wen;
    assign wen = 1'b1;

    // =========================================================================
    // LineBuffer3x3
    // =========================================================================
    wire            linebuf_3x3_conv1_valid;
    wire [DW*9-1:0] linebuf_3x3_conv1_flat;
    
    // --- dbg ---
//    assign linebuf_3x3_conv1_valid_dbg = linebuf_3x3_conv1_valid;
//    assign linebuf_3x3_conv1_flat_dbg = linebuf_3x3_conv1_flat;

    LineBuffer_3x3 #( .WIDTH(IMG_WIDTH), .DW(DW)) linebuf_3x3_conv1 (.clk(clk), .reset(reset), .in_valid(in_valid), .in_pixel(pixel_in), .win_valid(linebuf_3x3_conv1_valid), .win_flat(linebuf_3x3_conv1_flat));


    // =========================================================================
    // Convolution (ch=4)
    // =========================================================================
    wire [ACC_W-1:0] conv1_ch0_out,   conv1_ch1_out,   conv1_ch2_out,   conv1_ch3_out;
    wire             conv1_ch0_valid, conv1_ch1_valid, conv1_ch2_valid, conv1_ch3_valid;

    // --- dbg ---
    // assign conv1_ch0_out_dbg   = conv1_ch0_out;
    // assign conv1_ch1_out_dbg   = conv1_ch1_out;
    // assign conv1_ch2_out_dbg   = conv1_ch2_out;
    // assign conv1_ch3_out_dbg   = conv1_ch3_out;
    // assign conv1_ch0_valid_dbg = conv1_ch0_valid;
    // assign conv1_ch1_valid_dbg = conv1_ch1_valid;
    // assign conv1_ch2_valid_dbg = conv1_ch2_valid;
    // assign conv1_ch3_valid_dbg = conv1_ch3_valid;

    DPUconv1ch0 #(.N(CONV1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV1_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv1_ch0 ( .clk(clk), .reset(reset), .in_valid(linebuf_3x3_conv1_valid), .wen(wen), .a_vec(linebuf_3x3_conv1_flat), .out(conv1_ch0_out), .out_valid(conv1_ch0_valid));
    DPUconv1ch1 #(.N(CONV1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV1_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv1_ch1 ( .clk(clk), .reset(reset), .in_valid(linebuf_3x3_conv1_valid), .wen(wen), .a_vec(linebuf_3x3_conv1_flat), .out(conv1_ch1_out), .out_valid(conv1_ch1_valid));
    DPUconv1ch2 #(.N(CONV1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV1_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv1_ch2 ( .clk(clk), .reset(reset), .in_valid(linebuf_3x3_conv1_valid), .wen(wen), .a_vec(linebuf_3x3_conv1_flat), .out(conv1_ch2_out), .out_valid(conv1_ch2_valid));
    DPUconv1ch3 #(.N(CONV1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV1_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv1_ch3 ( .clk(clk), .reset(reset), .in_valid(linebuf_3x3_conv1_valid), .wen(wen), .a_vec(linebuf_3x3_conv1_flat), .out(conv1_ch3_out), .out_valid(conv1_ch3_valid));
    
    // =========================================================================
    // PostConv (ch=4)
    // =========================================================================
    wire [DW-1:0] postconv1_ch0_out, postconv1_ch1_out, postconv1_ch2_out, postconv1_ch3_out;
    wire             postconv1_ch0_valid, postconv1_ch1_valid, postconv1_ch2_valid, postconv1_ch3_valid;
    // --- dbg ---
    // assign postconv1_ch0_out_dbg   = postconv1_ch0_out;
    // assign postconv1_ch1_out_dbg   = postconv1_ch1_out;
    // assign postconv1_ch2_out_dbg   = postconv1_ch2_out;
    // assign postconv1_ch3_out_dbg   = postconv1_ch3_out;
    // assign postconv1_ch0_valid_dbg   = postconv1_ch0_valid;
    // assign postconv1_ch1_valid_dbg   = postconv1_ch1_valid;
    // assign postconv1_ch2_valid_dbg   = postconv1_ch2_valid;
    // assign postconv1_ch3_valid_dbg   = postconv1_ch3_valid;

//    reg  signed [31:0] conv1_mult_ch0, conv1_mult_ch1, conv1_mult_ch2, conv1_mult_ch3;
//    reg         [31:0] conv1_shift_ch0, conv1_shift_ch1, conv1_shift_ch2, conv1_shift_ch3; // unsigned
//    reg  signed [31:0] conv1_bias_ch0,  conv1_bias_ch1,  conv1_bias_ch2,  conv1_bias_ch3;
//
//    initial begin
//        conv1_mult_ch0  = 32'sd1087674880; conv1_mult_ch1  = 32'sd1206079616; conv1_mult_ch2  = 32'sd1080857984; conv1_mult_ch3  = 32'sd1640667776;  
//        conv1_shift_ch0 = 32'd39; conv1_shift_ch1 = 32'd38; conv1_shift_ch2 = 32'd38; conv1_shift_ch3 = 32'd38;
//        conv1_bias_ch0  = -32'sd4; conv1_bias_ch1  =  32'sd14; conv1_bias_ch2  = -32'sd8; conv1_bias_ch3  =  32'sd46;
//    end

    localparam signed [31:0] conv1_mult_ch0 = 32'sd1087674880;
    localparam signed [31:0] conv1_mult_ch1 = 32'sd1206079616;
    localparam signed [31:0] conv1_mult_ch2 = 32'sd1080857984;
    localparam signed [31:0] conv1_mult_ch3 = 32'sd1640667776;
    localparam        [31:0] conv1_shift_ch0 = 32'd39;
    localparam        [31:0] conv1_shift_ch1 = 32'd38;
    localparam        [31:0] conv1_shift_ch2 = 32'd38;
    localparam        [31:0] conv1_shift_ch3 = 32'd38;
    localparam signed [31:0] conv1_bias_ch0  = -32'sd4;
    localparam signed [31:0] conv1_bias_ch1  =  32'sd14;
    localparam signed [31:0] conv1_bias_ch2  = -32'sd8;
    localparam signed [31:0] conv1_bias_ch3  =  32'sd46;


    PostConv u_postconv1_ch0 (.clk(clk), .reset(reset), .in_valid(conv1_ch0_valid), .acc_i(conv1_ch0_out), .rq_mult(conv1_mult_ch0), .rq_rshift(conv1_shift_ch0), .bias_i(conv1_bias_ch0), .out_u8(postconv1_ch0_out), .out_valid(postconv1_ch0_valid));
    PostConv u_postconv1_ch1 (.clk(clk), .reset(reset), .in_valid(conv1_ch1_valid), .acc_i(conv1_ch1_out), .rq_mult(conv1_mult_ch1), .rq_rshift(conv1_shift_ch1), .bias_i(conv1_bias_ch1), .out_u8(postconv1_ch1_out), .out_valid(postconv1_ch1_valid));
    PostConv u_postconv1_ch2 (.clk(clk), .reset(reset), .in_valid(conv1_ch2_valid), .acc_i(conv1_ch2_out), .rq_mult(conv1_mult_ch2), .rq_rshift(conv1_shift_ch2), .bias_i(conv1_bias_ch2), .out_u8(postconv1_ch2_out), .out_valid(postconv1_ch2_valid));
    PostConv u_postconv1_ch3 (.clk(clk), .reset(reset), .in_valid(conv1_ch3_valid), .acc_i(conv1_ch3_out), .rq_mult(conv1_mult_ch3), .rq_rshift(conv1_shift_ch3), .bias_i(conv1_bias_ch3), .out_u8(postconv1_ch3_out), .out_valid(postconv1_ch3_valid));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // reg [100:0] img_cnt;
    // initial cnt = 0;
    // initial img_cnt = 0;
    // always @(posedge clk) begin
    //     if(out_valid) begin img_cnt <= img_cnt + 1; cnt <= 0; end
    //     if (img_cnt == 2 && postconv1_ch0_valid) begin
    //         $display("postconv1_ch0_out_dbg[%0d][%0d]: %0d", cnt/26, cnt%26, $unsigned(postconv1_ch0_out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------


    // =========================================================================
    // LineBuffer2x2 (ch=4)
    // =========================================================================
    wire            linebuf_2x2_pool1_ch0_valid, linebuf_2x2_pool1_ch1_valid, linebuf_2x2_pool1_ch2_valid, linebuf_2x2_pool1_ch3_valid;
    wire [DW*4-1:0] linebuf_2x2_pool1_ch0_flat, linebuf_2x2_pool1_ch1_flat, linebuf_2x2_pool1_ch2_flat, linebuf_2x2_pool1_ch3_flat;
    // --- dbg ---
    // assign linebuf_2x2_pool1_ch0_valid_dbg = linebuf_2x2_pool1_ch0_valid;
    // assign linebuf_2x2_pool1_ch1_valid_dbg = linebuf_2x2_pool1_ch1_valid;
    // assign linebuf_2x2_pool1_ch2_valid_dbg = linebuf_2x2_pool1_ch2_valid;
    // assign linebuf_2x2_pool1_ch3_valid_dbg = linebuf_2x2_pool1_ch3_valid;
    // assign linebuf_2x2_pool1_ch0_flat_dbg = linebuf_2x2_pool1_ch0_flat;
    // assign linebuf_2x2_pool1_ch1_flat_dbg = linebuf_2x2_pool1_ch1_flat;
    // assign linebuf_2x2_pool1_ch2_flat_dbg = linebuf_2x2_pool1_ch2_flat;
    // assign linebuf_2x2_pool1_ch3_flat_dbg = linebuf_2x2_pool1_ch3_flat;

    LineBuffer_2x2_even #( .WIDTH(POOL1_WIDTH), .DW(DW)) linebuf_2x2_pool1_ch0 (.clk(clk), .reset(reset), .in_valid(postconv1_ch0_valid), .in_pixel(postconv1_ch0_out), .win_valid(linebuf_2x2_pool1_ch0_valid), .win_flat(linebuf_2x2_pool1_ch0_flat));
    LineBuffer_2x2_even #( .WIDTH(POOL1_WIDTH), .DW(DW)) linebuf_2x2_pool1_ch1 (.clk(clk), .reset(reset), .in_valid(postconv1_ch1_valid), .in_pixel(postconv1_ch1_out), .win_valid(linebuf_2x2_pool1_ch1_valid), .win_flat(linebuf_2x2_pool1_ch1_flat));
    LineBuffer_2x2_even #( .WIDTH(POOL1_WIDTH), .DW(DW)) linebuf_2x2_pool1_ch2 (.clk(clk), .reset(reset), .in_valid(postconv1_ch2_valid), .in_pixel(postconv1_ch2_out), .win_valid(linebuf_2x2_pool1_ch2_valid), .win_flat(linebuf_2x2_pool1_ch2_flat));
    LineBuffer_2x2_even #( .WIDTH(POOL1_WIDTH), .DW(DW)) linebuf_2x2_pool1_ch3 (.clk(clk), .reset(reset), .in_valid(postconv1_ch3_valid), .in_pixel(postconv1_ch3_out), .win_valid(linebuf_2x2_pool1_ch3_valid), .win_flat(linebuf_2x2_pool1_ch3_flat));

    // =========================================================================
    // MaxPool (ch=4)
    // =========================================================================
    wire [DW-1:0] pool1_ch0_out, pool1_ch1_out, pool1_ch2_out, pool1_ch3_out;
    wire pool1_ch0_valid, pool1_ch1_valid, pool1_ch2_valid, pool1_ch3_valid;
    // --- dbg ---
    // assign pool1_ch0_valid_dbg = pool1_ch0_valid;
    // assign pool1_ch1_valid_dbg = pool1_ch1_valid;
    // assign pool1_ch2_valid_dbg = pool1_ch2_valid;
    // assign pool1_ch3_valid_dbg = pool1_ch3_valid;
    // assign pool1_ch0_out_dbg = pool1_ch0_out;
    // assign pool1_ch1_out_dbg = pool1_ch1_out;
    // assign pool1_ch2_out_dbg = pool1_ch2_out;
    // assign pool1_ch3_out_dbg = pool1_ch3_out;

    MaxPool2x2 #( .DW(DW)) maxpool1_ch0 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool1_ch0_valid), .win2x2_flat(linebuf_2x2_pool1_ch0_flat), .out_valid(pool1_ch0_valid), .out_u8(pool1_ch0_out));
    MaxPool2x2 #( .DW(DW)) maxpool1_ch1 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool1_ch1_valid), .win2x2_flat(linebuf_2x2_pool1_ch1_flat), .out_valid(pool1_ch1_valid), .out_u8(pool1_ch1_out));
    MaxPool2x2 #( .DW(DW)) maxpool1_ch2 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool1_ch2_valid), .win2x2_flat(linebuf_2x2_pool1_ch2_flat), .out_valid(pool1_ch2_valid), .out_u8(pool1_ch2_out));
    MaxPool2x2 #( .DW(DW)) maxpool1_ch3 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool1_ch3_valid), .win2x2_flat(linebuf_2x2_pool1_ch3_flat), .out_valid(pool1_ch3_valid), .out_u8(pool1_ch3_out));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // initial cnt = 0;
    // always @(posedge clk) begin
    //     if (pool1_ch0_valid) begin
    //         $display("pool1_ch0_out_dbg[%0d][%0d]: %0d", cnt/13, cnt%13, $unsigned(pool1_ch0_out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // LineBuffer3x3 (ch=4) 
    // =========================================================================
    wire            linebuf_3x3_conv2_ch0_valid, linebuf_3x3_conv2_ch1_valid, linebuf_3x3_conv2_ch2_valid, linebuf_3x3_conv2_ch3_valid;
    wire [DW*9-1:0] linebuf_3x3_conv2_ch0_flat, linebuf_3x3_conv2_ch1_flat, linebuf_3x3_conv2_ch2_flat, linebuf_3x3_conv2_ch3_flat;

    // --- dbg ---
    // assign linebuf_3x3_conv2_ch0_valid_dbg = linebuf_3x3_conv2_ch0_valid;
    // assign linebuf_3x3_conv2_ch1_valid_dbg = linebuf_3x3_conv2_ch1_valid;
    // assign linebuf_3x3_conv2_ch2_valid_dbg = linebuf_3x3_conv2_ch2_valid;
    // assign linebuf_3x3_conv2_ch3_valid_dbg = linebuf_3x3_conv2_ch3_valid;
    // assign linebuf_3x3_conv2_ch0_flat_dbg = linebuf_3x3_conv2_ch0_flat;
    // assign linebuf_3x3_conv2_ch1_flat_dbg = linebuf_3x3_conv2_ch1_flat;
    // assign linebuf_3x3_conv2_ch2_flat_dbg = linebuf_3x3_conv2_ch2_flat;
    // assign linebuf_3x3_conv2_ch3_flat_dbg = linebuf_3x3_conv2_ch3_flat;

    LineBuffer_3x3 #( .WIDTH(CONV2_WIDTH), .DW(DW)) linebuf_3x3_conv2_ch0 (.clk(clk), .reset(reset), .in_valid(pool1_ch0_valid), .in_pixel(pool1_ch0_out), .win_valid(linebuf_3x3_conv2_ch0_valid), .win_flat(linebuf_3x3_conv2_ch0_flat));
    LineBuffer_3x3 #( .WIDTH(CONV2_WIDTH), .DW(DW)) linebuf_3x3_conv2_ch1 (.clk(clk), .reset(reset), .in_valid(pool1_ch1_valid), .in_pixel(pool1_ch1_out), .win_valid(linebuf_3x3_conv2_ch1_valid), .win_flat(linebuf_3x3_conv2_ch1_flat));
    LineBuffer_3x3 #( .WIDTH(CONV2_WIDTH), .DW(DW)) linebuf_3x3_conv2_ch2 (.clk(clk), .reset(reset), .in_valid(pool1_ch2_valid), .in_pixel(pool1_ch2_out), .win_valid(linebuf_3x3_conv2_ch2_valid), .win_flat(linebuf_3x3_conv2_ch2_flat));
    LineBuffer_3x3 #( .WIDTH(CONV2_WIDTH), .DW(DW)) linebuf_3x3_conv2_ch3 (.clk(clk), .reset(reset), .in_valid(pool1_ch3_valid), .in_pixel(pool1_ch3_out), .win_valid(linebuf_3x3_conv2_ch3_valid), .win_flat(linebuf_3x3_conv2_ch3_flat));

    // =========================================================================
    // Convolution Layer 2 (ch8) 
    // =========================================================================
    wire [DW*CONV2_N-1:0] conv2_in;
    wire conv2_in_valid;
    assign conv2_in = {linebuf_3x3_conv2_ch3_flat, linebuf_3x3_conv2_ch2_flat, linebuf_3x3_conv2_ch1_flat, linebuf_3x3_conv2_ch0_flat}; // 4ch * 9 * 8bit = 288bit
    assign conv2_in_valid = linebuf_3x3_conv2_ch0_valid & linebuf_3x3_conv2_ch1_valid & linebuf_3x3_conv2_ch2_valid & linebuf_3x3_conv2_ch3_valid;
    wire [ACC_W-1:0] conv2_ch0_out, conv2_ch1_out, conv2_ch2_out, conv2_ch3_out, conv2_ch4_out, conv2_ch5_out, conv2_ch6_out, conv2_ch7_out;
    wire conv2_ch0_valid, conv2_ch1_valid, conv2_ch2_valid, conv2_ch3_valid, conv2_ch4_valid, conv2_ch5_valid, conv2_ch6_valid, conv2_ch7_valid;

    // --- dbg ---
    // assign conv2_ch0_out_dbg   = conv2_ch0_out;
    // assign conv2_ch1_out_dbg   = conv2_ch1_out;
    // assign conv2_ch2_out_dbg   = conv2_ch2_out;
    // assign conv2_ch3_out_dbg   = conv2_ch3_out;
    // assign conv2_ch4_out_dbg   = conv2_ch4_out;
    // assign conv2_ch5_out_dbg   = conv2_ch5_out;
    // assign conv2_ch6_out_dbg   = conv2_ch6_out;
    // assign conv2_ch7_out_dbg   = conv2_ch7_out;
    // assign conv2_ch0_valid_dbg = conv2_ch0_valid;
    // assign conv2_ch1_valid_dbg = conv2_ch1_valid;
    // assign conv2_ch2_valid_dbg = conv2_ch2_valid;
    // assign conv2_ch3_valid_dbg = conv2_ch3_valid;
    // assign conv2_ch4_valid_dbg = conv2_ch4_valid;
    // assign conv2_ch5_valid_dbg = conv2_ch5_valid;
    // assign conv2_ch6_valid_dbg = conv2_ch6_valid;
    // assign conv2_ch7_valid_dbg = conv2_ch7_valid;

    DPUconv2ch0 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch0 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch0_out), .out_valid(conv2_ch0_valid));
    DPUconv2ch1 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch1 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch1_out), .out_valid(conv2_ch1_valid));
    DPUconv2ch2 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch2 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch2_out), .out_valid(conv2_ch2_valid));
    DPUconv2ch3 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch3 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch3_out), .out_valid(conv2_ch3_valid));
    DPUconv2ch4 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch4 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch4_out), .out_valid(conv2_ch4_valid));
    DPUconv2ch5 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch5 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch5_out), .out_valid(conv2_ch5_valid));
    DPUconv2ch6 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch6 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch6_out), .out_valid(conv2_ch6_valid));
    DPUconv2ch7 #(.N(CONV2_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .STAGE_DEPTH(CONV2_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_conv2_ch7 (.clk(clk), .reset(reset), .in_valid(conv2_in_valid), .wen(wen), .a_vec(conv2_in), .out(conv2_ch7_out), .out_valid(conv2_ch7_valid));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // initial cnt = 0;
    // always @(posedge clk) begin
    //     if (conv2_ch0_valid) begin
    //         $display("conv2_ch0_out_dbg[%0d][%0d]: %0d", cnt/11, cnt%11, $signed(conv2_ch0_out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // PostConv (ch=8)
    // =========================================================================
    wire [DW-1:0] postconv2_ch0_out, postconv2_ch1_out, postconv2_ch2_out, postconv2_ch3_out, postconv2_ch4_out, postconv2_ch5_out, postconv2_ch6_out, postconv2_ch7_out;
    wire             postconv2_ch0_valid, postconv2_ch1_valid, postconv2_ch2_valid, postconv2_ch3_valid, postconv2_ch4_valid, postconv2_ch5_valid, postconv2_ch6_valid, postconv2_ch7_valid;
    // --- dbg ---
    // assign postconv2_ch0_out_dbg   = postconv2_ch0_out;
    // assign postconv2_ch1_out_dbg   = postconv2_ch1_out;
    // assign postconv2_ch2_out_dbg   = postconv2_ch2_out;
    // assign postconv2_ch3_out_dbg   = postconv2_ch3_out;
    // assign postconv2_ch4_out_dbg   = postconv2_ch4_out;
    // assign postconv2_ch5_out_dbg   = postconv2_ch5_out;
    // assign postconv2_ch6_out_dbg   = postconv2_ch6_out;
    // assign postconv2_ch7_out_dbg   = postconv2_ch7_out;
    // assign postconv2_ch0_valid_dbg   = postconv2_ch0_valid;
    // assign postconv2_ch1_valid_dbg   = postconv2_ch1_valid;
    // assign postconv2_ch2_valid_dbg   = postconv2_ch2_valid;
    // assign postconv2_ch3_valid_dbg   = postconv2_ch3_valid;
    // assign postconv2_ch4_valid_dbg   = postconv2_ch4_valid;
    // assign postconv2_ch5_valid_dbg   = postconv2_ch5_valid;
    // assign postconv2_ch6_valid_dbg   = postconv2_ch6_valid;
    // assign postconv2_ch7_valid_dbg   = postconv2_ch7_valid;

    // reg         [31:0] conv2_mult_ch0, conv2_mult_ch1, conv2_mult_ch2, conv2_mult_ch3, conv2_mult_ch4, conv2_mult_ch5, conv2_mult_ch6, conv2_mult_ch7;
    // reg         [31:0] conv2_shift_ch0, conv2_shift_ch1, conv2_shift_ch2, conv2_shift_ch3, conv2_shift_ch4, conv2_shift_ch5, conv2_shift_ch6, conv2_shift_ch7; // unsigned
    // reg  signed [31:0] conv2_bias_ch0,  conv2_bias_ch1,  conv2_bias_ch2,  conv2_bias_ch3,  conv2_bias_ch4,  conv2_bias_ch5,  conv2_bias_ch6,  conv2_bias_ch7;

    // initial begin
    //     conv2_mult_ch0  = 32'd1811430656; conv2_mult_ch1  = 32'd2081509888; conv2_mult_ch2  = 32'd1280804864; conv2_mult_ch3  = 32'd2010416000; conv2_mult_ch4  = 32'd1808612608; conv2_mult_ch5  = 32'd1638894208; conv2_mult_ch6  = 32'd1427796096; conv2_mult_ch7  = 32'd1213924224;
    //     conv2_shift_ch0 = 32'd38;         conv2_shift_ch1 = 32'd36;          conv2_shift_ch2 = 32'd35;          conv2_shift_ch3 = 32'd37;          conv2_shift_ch4 = 32'd37;          conv2_shift_ch5 = 32'd35;          conv2_shift_ch6 = 32'd37;          conv2_shift_ch7 = 32'd35;
    //     conv2_bias_ch0  = 32'd2;         conv2_bias_ch1  = -32'd1;         conv2_bias_ch2  = -32'd2;         conv2_bias_ch3  = 32'd1;          conv2_bias_ch4  = 32'd6;          conv2_bias_ch5  = 32'd2;          conv2_bias_ch6  = -32'd7;         conv2_bias_ch7  = 32'd4;
    // end
    
    localparam [31:0] conv2_mult_ch0  = 32'd1811430656;
    localparam [31:0] conv2_mult_ch1  = 32'd2081509888;
    localparam [31:0] conv2_mult_ch2  = 32'd1280804864;
    localparam [31:0] conv2_mult_ch3  = 32'd2010416000;
    localparam [31:0] conv2_mult_ch4  = 32'd1808612608;
    localparam [31:0] conv2_mult_ch5  = 32'd1638894208;
    localparam [31:0] conv2_mult_ch6  = 32'd1427796096;
    localparam [31:0] conv2_mult_ch7  = 32'd1213924224;

    localparam [31:0] conv2_shift_ch0 = 32'd38;
    localparam [31:0] conv2_shift_ch1 = 32'd36;
    localparam [31:0] conv2_shift_ch2 = 32'd35;
    localparam [31:0] conv2_shift_ch3 = 32'd37;
    localparam [31:0] conv2_shift_ch4 = 32'd37;
    localparam [31:0] conv2_shift_ch5 = 32'd35;
    localparam [31:0] conv2_shift_ch6 = 32'd37;
    localparam [31:0] conv2_shift_ch7 = 32'd35;

    localparam signed [31:0] conv2_bias_ch0 = 32'sd2;
    localparam signed [31:0] conv2_bias_ch1 = -32'sd1;
    localparam signed [31:0] conv2_bias_ch2 = -32'sd2;
    localparam signed [31:0] conv2_bias_ch3 = 32'sd1;
    localparam signed [31:0] conv2_bias_ch4 = 32'sd6;
    localparam signed [31:0] conv2_bias_ch5 = 32'sd2;
    localparam signed [31:0] conv2_bias_ch6 = -32'sd7;
    localparam signed [31:0] conv2_bias_ch7 = 32'sd4;


    PostConv u_postconv_ch0 (.clk(clk), .reset(reset), .in_valid(conv2_ch0_valid), .acc_i(conv2_ch0_out), .rq_mult(conv2_mult_ch0), .rq_rshift(conv2_shift_ch0), .bias_i(conv2_bias_ch0), .out_u8(postconv2_ch0_out), .out_valid(postconv2_ch0_valid));
    PostConv u_postconv_ch1 (.clk(clk), .reset(reset), .in_valid(conv2_ch1_valid), .acc_i(conv2_ch1_out), .rq_mult(conv2_mult_ch1), .rq_rshift(conv2_shift_ch1), .bias_i(conv2_bias_ch1), .out_u8(postconv2_ch1_out), .out_valid(postconv2_ch1_valid));
    PostConv u_postconv_ch2 (.clk(clk), .reset(reset), .in_valid(conv2_ch2_valid), .acc_i(conv2_ch2_out), .rq_mult(conv2_mult_ch2), .rq_rshift(conv2_shift_ch2), .bias_i(conv2_bias_ch2), .out_u8(postconv2_ch2_out), .out_valid(postconv2_ch2_valid));
    PostConv u_postconv_ch3 (.clk(clk), .reset(reset), .in_valid(conv2_ch3_valid), .acc_i(conv2_ch3_out), .rq_mult(conv2_mult_ch3), .rq_rshift(conv2_shift_ch3), .bias_i(conv2_bias_ch3), .out_u8(postconv2_ch3_out), .out_valid(postconv2_ch3_valid));
    PostConv u_postconv_ch4 (.clk(clk), .reset(reset), .in_valid(conv2_ch4_valid), .acc_i(conv2_ch4_out), .rq_mult(conv2_mult_ch4), .rq_rshift(conv2_shift_ch4), .bias_i(conv2_bias_ch4), .out_u8(postconv2_ch4_out), .out_valid(postconv2_ch4_valid));
    PostConv u_postconv_ch5 (.clk(clk), .reset(reset), .in_valid(conv2_ch5_valid), .acc_i(conv2_ch5_out), .rq_mult(conv2_mult_ch5), .rq_rshift(conv2_shift_ch5), .bias_i(conv2_bias_ch5), .out_u8(postconv2_ch5_out), .out_valid(postconv2_ch5_valid));
    PostConv u_postconv_ch6 (.clk(clk), .reset(reset), .in_valid(conv2_ch6_valid), .acc_i(conv2_ch6_out), .rq_mult(conv2_mult_ch6), .rq_rshift(conv2_shift_ch6), .bias_i(conv2_bias_ch6), .out_u8(postconv2_ch6_out), .out_valid(postconv2_ch6_valid));
    PostConv u_postconv_ch7 (.clk(clk), .reset(reset), .in_valid(conv2_ch7_valid), .acc_i(conv2_ch7_out), .rq_mult(conv2_mult_ch7), .rq_rshift(conv2_shift_ch7), .bias_i(conv2_bias_ch7), .out_u8(postconv2_ch7_out), .out_valid(postconv2_ch7_valid));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // initial cnt = 0;
    // always @(posedge clk) begin
    //     if (postconv2_ch5_valid) begin
    //         $display("postconv2_ch5_out_dbg[%0d][%0d]: %0d", cnt/11, cnt%11, $unsigned(postconv2_ch5_out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // LineBuffer2x2 (ch=8)
    // =========================================================================
    wire            linebuf_2x2_pool2_ch0_valid, linebuf_2x2_pool2_ch1_valid, linebuf_2x2_pool2_ch2_valid, linebuf_2x2_pool2_ch3_valid, linebuf_2x2_pool2_ch4_valid, linebuf_2x2_pool2_ch5_valid, linebuf_2x2_pool2_ch6_valid, linebuf_2x2_pool2_ch7_valid;
    wire [DW*4-1:0] linebuf_2x2_pool2_ch0_flat, linebuf_2x2_pool2_ch1_flat, linebuf_2x2_pool2_ch2_flat, linebuf_2x2_pool2_ch3_flat, linebuf_2x2_pool2_ch4_flat, linebuf_2x2_pool2_ch5_flat, linebuf_2x2_pool2_ch6_flat, linebuf_2x2_pool2_ch7_flat;
    // --- dbg ---
    // assign linebuf_2x2_pool2_ch0_valid_dbg = linebuf_2x2_pool2_ch0_valid;
    // assign linebuf_2x2_pool2_ch1_valid_dbg = linebuf_2x2_pool2_ch1_valid;
    // assign linebuf_2x2_pool2_ch2_valid_dbg = linebuf_2x2_pool2_ch2_valid;
    // assign linebuf_2x2_pool2_ch3_valid_dbg = linebuf_2x2_pool2_ch3_valid;
    // assign linebuf_2x2_pool2_ch4_valid_dbg = linebuf_2x2_pool2_ch4_valid;
    // assign linebuf_2x2_pool2_ch5_valid_dbg = linebuf_2x2_pool2_ch5_valid;
    // assign linebuf_2x2_pool2_ch6_valid_dbg = linebuf_2x2_pool2_ch6_valid;
    // assign linebuf_2x2_pool2_ch7_valid_dbg = linebuf_2x2_pool2_ch7_valid;
    // assign linebuf_2x2_pool2_ch0_flat_dbg = linebuf_2x2_pool2_ch0_flat;
    // assign linebuf_2x2_pool2_ch1_flat_dbg = linebuf_2x2_pool2_ch1_flat;
    // assign linebuf_2x2_pool2_ch2_flat_dbg = linebuf_2x2_pool2_ch2_flat;
    // assign linebuf_2x2_pool2_ch3_flat_dbg = linebuf_2x2_pool2_ch3_flat;
    // assign linebuf_2x2_pool2_ch4_flat_dbg = linebuf_2x2_pool2_ch4_flat;
    // assign linebuf_2x2_pool2_ch5_flat_dbg = linebuf_2x2_pool2_ch5_flat;
    // assign linebuf_2x2_pool2_ch6_flat_dbg = linebuf_2x2_pool2_ch6_flat;
    // assign linebuf_2x2_pool2_ch7_flat_dbg = linebuf_2x2_pool2_ch7_flat;

    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch0 (.clk(clk), .reset(reset), .in_valid(postconv2_ch0_valid), .in_pixel(postconv2_ch0_out), .win_valid(linebuf_2x2_pool2_ch0_valid), .win_flat(linebuf_2x2_pool2_ch0_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch1 (.clk(clk), .reset(reset), .in_valid(postconv2_ch1_valid), .in_pixel(postconv2_ch1_out), .win_valid(linebuf_2x2_pool2_ch1_valid), .win_flat(linebuf_2x2_pool2_ch1_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch2 (.clk(clk), .reset(reset), .in_valid(postconv2_ch2_valid), .in_pixel(postconv2_ch2_out), .win_valid(linebuf_2x2_pool2_ch2_valid), .win_flat(linebuf_2x2_pool2_ch2_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch3 (.clk(clk), .reset(reset), .in_valid(postconv2_ch3_valid), .in_pixel(postconv2_ch3_out), .win_valid(linebuf_2x2_pool2_ch3_valid), .win_flat(linebuf_2x2_pool2_ch3_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch4 (.clk(clk), .reset(reset), .in_valid(postconv2_ch4_valid), .in_pixel(postconv2_ch4_out), .win_valid(linebuf_2x2_pool2_ch4_valid), .win_flat(linebuf_2x2_pool2_ch4_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch5 (.clk(clk), .reset(reset), .in_valid(postconv2_ch5_valid), .in_pixel(postconv2_ch5_out), .win_valid(linebuf_2x2_pool2_ch5_valid), .win_flat(linebuf_2x2_pool2_ch5_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch6 (.clk(clk), .reset(reset), .in_valid(postconv2_ch6_valid), .in_pixel(postconv2_ch6_out), .win_valid(linebuf_2x2_pool2_ch6_valid), .win_flat(linebuf_2x2_pool2_ch6_flat));
    LineBuffer_2x2_odd #( .WIDTH(POOL2_WIDTH), .DW(DW)) linebuf_2x2_pool2_ch7 (.clk(clk), .reset(reset), .in_valid(postconv2_ch7_valid), .in_pixel(postconv2_ch7_out), .win_valid(linebuf_2x2_pool2_ch7_valid), .win_flat(linebuf_2x2_pool2_ch7_flat));

    // =========================================================================
    // MaxPool (ch=8)
    // =========================================================================
    wire [DW-1:0] pool2_ch0_out, pool2_ch1_out, pool2_ch2_out, pool2_ch3_out, pool2_ch4_out, pool2_ch5_out, pool2_ch6_out, pool2_ch7_out;
    wire pool2_ch0_valid, pool2_ch1_valid, pool2_ch2_valid, pool2_ch3_valid, pool2_ch4_valid, pool2_ch5_valid, pool2_ch6_valid, pool2_ch7_valid;
    // --- dbg ---
    // assign pool2_ch0_valid_dbg = pool2_ch0_valid;
    // assign pool2_ch1_valid_dbg = pool2_ch1_valid;
    // assign pool2_ch2_valid_dbg = pool2_ch2_valid;
    // assign pool2_ch3_valid_dbg = pool2_ch3_valid;
    // assign pool2_ch4_valid_dbg = pool2_ch4_valid;
    // assign pool2_ch5_valid_dbg = pool2_ch5_valid;
    // assign pool2_ch6_valid_dbg = pool2_ch6_valid;
    // assign pool2_ch7_valid_dbg = pool2_ch7_valid;
    // assign pool2_ch0_out_dbg = pool2_ch0_out;
    // assign pool2_ch1_out_dbg = pool2_ch1_out;
    // assign pool2_ch2_out_dbg = pool2_ch2_out;
    // assign pool2_ch3_out_dbg = pool2_ch3_out;
    // assign pool2_ch4_out_dbg = pool2_ch4_out;
    // assign pool2_ch5_out_dbg = pool2_ch5_out;
    // assign pool2_ch6_out_dbg = pool2_ch6_out;
    // assign pool2_ch7_out_dbg = pool2_ch7_out;

    MaxPool2x2 #( .DW(DW)) maxpool2_ch0 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch0_valid), .win2x2_flat(linebuf_2x2_pool2_ch0_flat), .out_valid(pool2_ch0_valid), .out_u8(pool2_ch0_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch1 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch1_valid), .win2x2_flat(linebuf_2x2_pool2_ch1_flat), .out_valid(pool2_ch1_valid), .out_u8(pool2_ch1_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch2 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch2_valid), .win2x2_flat(linebuf_2x2_pool2_ch2_flat), .out_valid(pool2_ch2_valid), .out_u8(pool2_ch2_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch3 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch3_valid), .win2x2_flat(linebuf_2x2_pool2_ch3_flat), .out_valid(pool2_ch3_valid), .out_u8(pool2_ch3_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch4 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch4_valid), .win2x2_flat(linebuf_2x2_pool2_ch4_flat), .out_valid(pool2_ch4_valid), .out_u8(pool2_ch4_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch5 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch5_valid), .win2x2_flat(linebuf_2x2_pool2_ch5_flat), .out_valid(pool2_ch5_valid), .out_u8(pool2_ch5_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch6 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch6_valid), .win2x2_flat(linebuf_2x2_pool2_ch6_flat), .out_valid(pool2_ch6_valid), .out_u8(pool2_ch6_out));
    MaxPool2x2 #( .DW(DW)) maxpool2_ch7 (.clk(clk), .reset(reset), .in_valid(linebuf_2x2_pool2_ch7_valid), .win2x2_flat(linebuf_2x2_pool2_ch7_flat), .out_valid(pool2_ch7_valid), .out_u8(pool2_ch7_out));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt;
    // initial cnt = 0;
    // always @(posedge clk) begin
    //     if (pool2_ch3_valid) begin
    //         $display("pool2_ch3_out_dbg[%0d][%0d]: %0d", cnt/5, cnt%5, $unsigned(pool2_ch3_out));
    //         cnt <= cnt + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // Fully Connected Layer (fc1 ch=10)
    // ==========================================================================
    wire [DW*FC1_N-1:0] fc1_in;
    wire fc1_in_valid;
    assign fc1_in = {pool2_ch7_out, pool2_ch6_out, pool2_ch5_out, pool2_ch4_out, pool2_ch3_out, pool2_ch2_out, pool2_ch1_out, pool2_ch0_out}; // 8ch * 8bit = 64bit
    assign fc1_in_valid = pool2_ch0_valid & pool2_ch1_valid & pool2_ch2_valid & pool2_ch3_valid & pool2_ch4_valid & pool2_ch5_valid & pool2_ch6_valid & pool2_ch7_valid;

    wire [ACC_W-1:0] fc_ch0_out, fc_ch1_out, fc_ch2_out, fc_ch3_out, fc_ch4_out, fc_ch5_out, fc_ch6_out, fc_ch7_out, fc_ch8_out, fc_ch9_out;
    wire fc_ch0_valid, fc_ch1_valid, fc_ch2_valid, fc_ch3_valid, fc_ch4_valid, fc_ch5_valid, fc_ch6_valid, fc_ch7_valid, fc_ch8_valid, fc_ch9_valid;

    // --- dbg ---
    // assign fc_ch0_out_dbg   = fc_ch0_out;
    // assign fc_ch1_out_dbg   = fc_ch1_out;
    // assign fc_ch2_out_dbg   = fc_ch2_out;
    // assign fc_ch3_out_dbg   = fc_ch3_out;
    // assign fc_ch4_out_dbg   = fc_ch4_out;
    // assign fc_ch5_out_dbg   = fc_ch5_out;
    // assign fc_ch6_out_dbg   = fc_ch6_out;
    // assign fc_ch7_out_dbg   = fc_ch7_out;
    // assign fc_ch8_out_dbg   = fc_ch8_out;
    // assign fc_ch9_out_dbg   = fc_ch9_out;
    // assign fc_ch0_valid_dbg = fc_ch0_valid;
    // assign fc_ch1_valid_dbg = fc_ch1_valid;
    // assign fc_ch2_valid_dbg = fc_ch2_valid;
    // assign fc_ch3_valid_dbg = fc_ch3_valid;
    // assign fc_ch4_valid_dbg = fc_ch4_valid;
    // assign fc_ch5_valid_dbg = fc_ch5_valid;
    // assign fc_ch6_valid_dbg = fc_ch6_valid;
    // assign fc_ch7_valid_dbg = fc_ch7_valid;
    // assign fc_ch8_valid_dbg = fc_ch8_valid;
    // assign fc_ch9_valid_dbg = fc_ch9_valid;

    DPUfc1ch0 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch0 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch0_out), .out_valid(fc_ch0_valid));
    DPUfc1ch1 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch1 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch1_out), .out_valid(fc_ch1_valid));
    DPUfc1ch2 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch2 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch2_out), .out_valid(fc_ch2_valid));
    DPUfc1ch3 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch3 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch3_out), .out_valid(fc_ch3_valid));
    DPUfc1ch4 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch4 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch4_out), .out_valid(fc_ch4_valid));
    DPUfc1ch5 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch5 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch5_out), .out_valid(fc_ch5_valid));
    DPUfc1ch6 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch6 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch6_out), .out_valid(fc_ch6_valid));
    DPUfc1ch7 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch7 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch7_out), .out_valid(fc_ch7_valid));
    DPUfc1ch8 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch8 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch8_out), .out_valid(fc_ch8_valid));
    DPUfc1ch9 #(.N(FC1_N), .ACT_WIDTH(DW), .WEIGHT_WIDTH(DW), .DEPTH(FC_ACC_N), .STAGE_DEPTH(FC_STAGE_DEPTH), .MULT_W(DW*2), .ACC_W(ACC_W)) u_fc1_ch9 (.clk(clk), .reset(reset), .in_valid(fc1_in_valid), .wen(wen), .a_vec(fc1_in), .out(fc_ch9_out), .out_valid(fc_ch9_valid));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt_fc;
    // initial cnt_fc = 0;
    // always @(posedge clk) begin
    //     if (fc_ch0_valid) begin
    //         $display("fc_ch0_out_dbg: %0d", $signed(fc_ch0_out));
    //         cnt_fc <= cnt_fc + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt_fc;
    // reg [100:0] img_cnt_fc;
    // initial cnt_fc = 0;
    // initial img_cnt_fc = 0;
    // always @(posedge clk) begin
    //     if(out_valid) begin img_cnt_fc <= img_cnt_fc + 1; cnt_fc <= 0; end
    //     if (img_cnt_fc == 3 && fc_ch0_valid) begin
    //         $display("fc_ch0_out_dbg: %0d", $signed(fc_ch0_out));
    //         $display("fc_ch1_out_dbg: %0d", $signed(fc_ch1_out));
    //         $display("fc_ch2_out_dbg: %0d", $signed(fc_ch2_out));
    //         $display("fc_ch3_out_dbg: %0d", $signed(fc_ch3_out));
    //         $display("fc_ch4_out_dbg: %0d", $signed(fc_ch4_out));
    //         $display("fc_ch5_out_dbg: %0d", $signed(fc_ch5_out));
    //         $display("fc_ch6_out_dbg: %0d", $signed(fc_ch6_out));
    //         $display("fc_ch7_out_dbg: %0d", $signed(fc_ch7_out));
    //         $display("fc_ch8_out_dbg: %0d", $signed(fc_ch8_out));
    //         $display("fc_ch9_out_dbg: %0d", $signed(fc_ch9_out));
    //         cnt_fc <= cnt_fc + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // Pipeline from FC to PostFC (fc1 ch=10)
    // ==========================================================================
    reg signed [ACC_W-1:0] fc_ch0_out_r, fc_ch1_out_r, fc_ch2_out_r, fc_ch3_out_r, fc_ch4_out_r, fc_ch5_out_r, fc_ch6_out_r, fc_ch7_out_r, fc_ch8_out_r, fc_ch9_out_r;
    reg fc_ch0_valid_r, fc_ch1_valid_r, fc_ch2_valid_r, fc_ch3_valid_r, fc_ch4_valid_r, fc_ch5_valid_r, fc_ch6_valid_r, fc_ch7_valid_r, fc_ch8_valid_r, fc_ch9_valid_r;

    always @(posedge clk) begin
        if (reset) begin
            fc_ch0_out_r   <= 0; fc_ch1_out_r   <= 0; fc_ch2_out_r   <= 0; fc_ch3_out_r   <= 0; fc_ch4_out_r   <= 0; fc_ch5_out_r   <= 0; fc_ch6_out_r   <= 0; fc_ch7_out_r   <= 0; fc_ch8_out_r   <= 0; fc_ch9_out_r   <= 0;
            fc_ch0_valid_r <= 0; fc_ch1_valid_r <= 0; fc_ch2_valid_r <= 0; fc_ch3_valid_r <= 0; fc_ch4_valid_r <= 0; fc_ch5_valid_r <= 0; fc_ch6_valid_r <= 0; fc_ch7_valid_r <= 0; fc_ch8_valid_r <= 0; fc_ch9_valid_r <= 0;
        end else begin
            fc_ch0_out_r   <= fc_ch0_out; fc_ch1_out_r   <= fc_ch1_out; fc_ch2_out_r   <= fc_ch2_out; fc_ch3_out_r   <= fc_ch3_out; fc_ch4_out_r   <= fc_ch4_out; fc_ch5_out_r   <= fc_ch5_out; fc_ch6_out_r   <= fc_ch6_out; fc_ch7_out_r   <= fc_ch7_out; fc_ch8_out_r   <= fc_ch8_out; fc_ch9_out_r   <= fc_ch9_out;
            fc_ch0_valid_r <= fc_ch0_valid; fc_ch1_valid_r <= fc_ch1_valid; fc_ch2_valid_r <= fc_ch2_valid; fc_ch3_valid_r <= fc_ch3_valid; fc_ch4_valid_r <= fc_ch4_valid; fc_ch5_valid_r <= fc_ch5_valid; fc_ch6_valid_r <= fc_ch6_valid; fc_ch7_valid_r <= fc_ch7_valid; fc_ch8_valid_r <= fc_ch8_valid; fc_ch9_valid_r <= fc_ch9_valid;
        end
    end

    // =========================================================================
    // PostFC (fc1 ch=10)
    // ==========================================================================
    wire signed [ACC_W-1:0] postfc_ch0_out, postfc_ch1_out, postfc_ch2_out, postfc_ch3_out, postfc_ch4_out, postfc_ch5_out, postfc_ch6_out, postfc_ch7_out, postfc_ch8_out, postfc_ch9_out;
    wire             postfc_ch0_valid, postfc_ch1_valid, postfc_ch2_valid, postfc_ch3_valid, postfc_ch4_valid, postfc_ch5_valid, postfc_ch6_valid, postfc_ch7_valid, postfc_ch8_valid, postfc_ch9_valid;
    // --- dbg ---
    // assign postfc_ch0_out_dbg   = postfc_ch0_out;
    // assign postfc_ch1_out_dbg   = postfc_ch1_out;
    // assign postfc_ch2_out_dbg   = postfc_ch2_out;
    // assign postfc_ch3_out_dbg   = postfc_ch3_out;
    // assign postfc_ch4_out_dbg   = postfc_ch4_out;
    // assign postfc_ch5_out_dbg   = postfc_ch5_out;
    // assign postfc_ch6_out_dbg   = postfc_ch6_out;
    // assign postfc_ch7_out_dbg   = postfc_ch7_out;
    // assign postfc_ch8_out_dbg   = postfc_ch8_out;
    // assign postfc_ch9_out_dbg   = postfc_ch9_out;
    // assign postfc_ch0_valid_dbg   = postfc_ch0_valid;
    // assign postfc_ch1_valid_dbg   = postfc_ch1_valid;
    // assign postfc_ch2_valid_dbg   = postfc_ch2_valid;
    // assign postfc_ch3_valid_dbg   = postfc_ch3_valid;
    // assign postfc_ch4_valid_dbg   = postfc_ch4_valid;
    // assign postfc_ch5_valid_dbg   = postfc_ch5_valid;
    // assign postfc_ch6_valid_dbg   = postfc_ch6_valid;
    // assign postfc_ch7_valid_dbg   = postfc_ch7_valid;
    // assign postfc_ch8_valid_dbg   = postfc_ch8_valid;
    // assign postfc_ch9_valid_dbg   = postfc_ch9_valid;

    // reg         [31:0] fc_mult_ch0, fc_mult_ch1, fc_mult_ch2, fc_mult_ch3, fc_mult_ch4, fc_mult_ch5, fc_mult_ch6, fc_mult_ch7, fc_mult_ch8, fc_mult_ch9;
    // reg         [31:0] fc_shift_ch0, fc_shift_ch1, fc_shift_ch2, fc_shift_ch3, fc_shift_ch4, fc_shift_ch5, fc_shift_ch6, fc_shift_ch7, fc_shift_ch8, fc_shift_ch9; // unsigned
    // reg  signed [31:0] fc_bias_ch0,  fc_bias_ch1,  fc_bias_ch2,  fc_bias_ch3,  fc_bias_ch4,  fc_bias_ch5,  fc_bias_ch6,  fc_bias_ch7,  fc_bias_ch8,  fc_bias_ch9;

    // initial begin
    //     fc_mult_ch0  = 32'd1111816192; fc_mult_ch1  = 32'd1387151360; fc_mult_ch2  = 32'd1890338944; fc_mult_ch3  = 32'd1093067648; fc_mult_ch4  = 32'd1215385728; fc_mult_ch5  = 32'd1117774208; fc_mult_ch6  = 32'd1496940288; fc_mult_ch7  = 32'd1097550720; fc_mult_ch8  = 32'd1075659904; fc_mult_ch9  = 32'd1489567104; 
    //     fc_shift_ch0 = 32'd34;         fc_shift_ch1 = 32'd34;         fc_shift_ch2 = 32'd35;         fc_shift_ch3 = 32'd36;         fc_shift_ch4 = 32'd34; fc_shift_ch5 = 32'd35; fc_shift_ch6 = 32'd35; fc_shift_ch7 = 32'd33; fc_shift_ch8 = 32'd33; fc_shift_ch9 = 32'd35; 
    //     fc_bias_ch0  = 32'sd3;         fc_bias_ch1  = 32'sd13;        fc_bias_ch2  = -32'sd4;        fc_bias_ch3  = -32'sd10;       fc_bias_ch4  = 32'sd0; fc_bias_ch5  = -32'sd2; fc_bias_ch6  = -32'sd2; fc_bias_ch7  = 32'sd5; fc_bias_ch8  = 32'sd4; fc_bias_ch9  = 32'sd5;
    
    localparam [31:0] fc_mult_ch0  = 32'd1111816192;
    localparam [31:0] fc_mult_ch1  = 32'd1387151360;
    localparam [31:0] fc_mult_ch2  = 32'd1890338944;
    localparam [31:0] fc_mult_ch3  = 32'd1093067648;
    localparam [31:0] fc_mult_ch4  = 32'd1215385728;
    localparam [31:0] fc_mult_ch5  = 32'd1117774208;
    localparam [31:0] fc_mult_ch6  = 32'd1496940288;
    localparam [31:0] fc_mult_ch7  = 32'd1097550720;
    localparam [31:0] fc_mult_ch8  = 32'd1075659904;
    localparam [31:0] fc_mult_ch9  = 32'd1489567104;

    localparam [31:0] fc_shift_ch0 = 32'd34;
    localparam [31:0] fc_shift_ch1 = 32'd34;
    localparam [31:0] fc_shift_ch2 = 32'd35;
    localparam [31:0] fc_shift_ch3 = 32'd36;
    localparam [31:0] fc_shift_ch4 = 32'd34;
    localparam [31:0] fc_shift_ch5 = 32'd35;
    localparam [31:0] fc_shift_ch6 = 32'd35;
    localparam [31:0] fc_shift_ch7 = 32'd33;
    localparam [31:0] fc_shift_ch8 = 32'd33;
    localparam [31:0] fc_shift_ch9 = 32'd35;

    localparam signed [31:0] fc_bias_ch0  = 32'sd3;
    localparam signed [31:0] fc_bias_ch1  = 32'sd13;
    localparam signed [31:0] fc_bias_ch2  = -32'sd4;
    localparam signed [31:0] fc_bias_ch3  = -32'sd10;
    localparam signed [31:0] fc_bias_ch4  = 32'sd0;
    localparam signed [31:0] fc_bias_ch5  = -32'sd2;
    localparam signed [31:0] fc_bias_ch6  = -32'sd2;
    localparam signed [31:0] fc_bias_ch7  = 32'sd5;
    localparam signed [31:0] fc_bias_ch8  = 32'sd4;
    localparam signed [31:0] fc_bias_ch9  = 32'sd5;

    PostFC u_postfc_ch0 (.clk(clk), .reset(reset), .in_valid(fc_ch0_valid_r), .acc_i(fc_ch0_out_r), .rq_mult(fc_mult_ch0), .rq_rshift(fc_shift_ch0), .bias_i(fc_bias_ch0), .out_valid(postfc_ch0_valid), .out_i32(postfc_ch0_out));
    PostFC u_postfc_ch1 (.clk(clk), .reset(reset), .in_valid(fc_ch1_valid_r), .acc_i(fc_ch1_out_r), .rq_mult(fc_mult_ch1), .rq_rshift(fc_shift_ch1), .bias_i(fc_bias_ch1), .out_valid(postfc_ch1_valid), .out_i32(postfc_ch1_out));
    PostFC u_postfc_ch2 (.clk(clk), .reset(reset), .in_valid(fc_ch2_valid_r), .acc_i(fc_ch2_out_r), .rq_mult(fc_mult_ch2), .rq_rshift(fc_shift_ch2), .bias_i(fc_bias_ch2), .out_valid(postfc_ch2_valid), .out_i32(postfc_ch2_out));
    PostFC u_postfc_ch3 (.clk(clk), .reset(reset), .in_valid(fc_ch3_valid_r), .acc_i(fc_ch3_out_r), .rq_mult(fc_mult_ch3), .rq_rshift(fc_shift_ch3), .bias_i(fc_bias_ch3), .out_valid(postfc_ch3_valid), .out_i32(postfc_ch3_out));
    PostFC u_postfc_ch4 (.clk(clk), .reset(reset), .in_valid(fc_ch4_valid_r), .acc_i(fc_ch4_out_r), .rq_mult(fc_mult_ch4), .rq_rshift(fc_shift_ch4), .bias_i(fc_bias_ch4), .out_valid(postfc_ch4_valid), .out_i32(postfc_ch4_out));
    PostFC u_postfc_ch5 (.clk(clk), .reset(reset), .in_valid(fc_ch5_valid_r), .acc_i(fc_ch5_out_r), .rq_mult(fc_mult_ch5), .rq_rshift(fc_shift_ch5), .bias_i(fc_bias_ch5), .out_valid(postfc_ch5_valid), .out_i32(postfc_ch5_out));
    PostFC u_postfc_ch6 (.clk(clk), .reset(reset), .in_valid(fc_ch6_valid_r), .acc_i(fc_ch6_out_r), .rq_mult(fc_mult_ch6), .rq_rshift(fc_shift_ch6), .bias_i(fc_bias_ch6), .out_valid(postfc_ch6_valid), .out_i32(postfc_ch6_out));
    PostFC u_postfc_ch7 (.clk(clk), .reset(reset), .in_valid(fc_ch7_valid_r), .acc_i(fc_ch7_out_r), .rq_mult(fc_mult_ch7), .rq_rshift(fc_shift_ch7), .bias_i(fc_bias_ch7), .out_valid(postfc_ch7_valid), .out_i32(postfc_ch7_out));
    PostFC u_postfc_ch8 (.clk(clk), .reset(reset), .in_valid(fc_ch8_valid_r), .acc_i(fc_ch8_out_r), .rq_mult(fc_mult_ch8), .rq_rshift(fc_shift_ch8), .bias_i(fc_bias_ch8), .out_valid(postfc_ch8_valid), .out_i32(postfc_ch8_out));
    PostFC u_postfc_ch9 (.clk(clk), .reset(reset), .in_valid(fc_ch9_valid_r), .acc_i(fc_ch9_out_r), .rq_mult(fc_mult_ch9), .rq_rshift(fc_shift_ch9), .bias_i(fc_bias_ch9), .out_valid(postfc_ch9_valid), .out_i32(postfc_ch9_out));

    // // ------------ DEBUG DISPLAY ------------
    // reg [100:0] cnt_postfc;
    // reg [100:0] img_cnt_postfc;
    // initial cnt_postfc = 0;
    // initial img_cnt_postfc = 0;
    // always @(posedge clk) begin
    //     if(out_valid) begin img_cnt_postfc <= img_cnt_postfc + 1; cnt_postfc <= 0; end
    //     if (img_cnt_postfc == 3 && postfc_ch0_valid) begin
    //         $display("postfc_ch0_out_dbg: %0d", $signed(postfc_ch0_out));
    //         $display("postfc_ch1_out_dbg: %0d", $signed(postfc_ch1_out));
    //         $display("postfc_ch2_out_dbg: %0d", $signed(postfc_ch2_out));
    //         $display("postfc_ch3_out_dbg: %0d", $signed(postfc_ch3_out));
    //         $display("postfc_ch4_out_dbg: %0d", $signed(postfc_ch4_out));
    //         $display("postfc_ch5_out_dbg: %0d", $signed(postfc_ch5_out));
    //         $display("postfc_ch6_out_dbg: %0d", $signed(postfc_ch6_out));
    //         $display("postfc_ch7_out_dbg: %0d", $signed(postfc_ch7_out));
    //         $display("postfc_ch8_out_dbg: %0d", $signed(postfc_ch8_out));
    //         $display("postfc_ch9_out_dbg: %0d", $signed(postfc_ch9_out));
    //         cnt_postfc <= cnt_postfc + 1;
    //     end
    // end
    // // ------------ DEBUG DISPLAY ------------

    // =========================================================================
    // Pipeline from PostFC to Argmax
    // =========================================================================
    reg               argmax_in_valid_r;
    reg signed [31:0] postfc_ch0_out_r;
    reg signed [31:0] postfc_ch1_out_r;
    reg signed [31:0] postfc_ch2_out_r;
    reg signed [31:0] postfc_ch3_out_r;
    reg signed [31:0] postfc_ch4_out_r;
    reg signed [31:0] postfc_ch5_out_r;
    reg signed [31:0] postfc_ch6_out_r;
    reg signed [31:0] postfc_ch7_out_r;
    reg signed [31:0] postfc_ch8_out_r;
    reg signed [31:0] postfc_ch9_out_r;

    always @(posedge clk) begin
        if (reset) begin
            argmax_in_valid_r <= 1'b0;
        end else begin
            argmax_in_valid_r <= postfc_ch0_valid && postfc_ch1_valid && postfc_ch2_valid && postfc_ch3_valid && postfc_ch4_valid && postfc_ch5_valid && postfc_ch6_valid && postfc_ch7_valid && postfc_ch8_valid && postfc_ch9_valid;
            postfc_ch0_out_r <= postfc_ch0_out; postfc_ch1_out_r <= postfc_ch1_out; postfc_ch2_out_r <= postfc_ch2_out; postfc_ch3_out_r <= postfc_ch3_out; postfc_ch4_out_r <= postfc_ch4_out;
            postfc_ch5_out_r <= postfc_ch5_out; postfc_ch6_out_r <= postfc_ch6_out; postfc_ch7_out_r <= postfc_ch7_out; postfc_ch8_out_r <= postfc_ch8_out; postfc_ch9_out_r <= postfc_ch9_out;
        end
    end

    // =========================================================================
    // Argmax
    // =========================================================================
    Argmax10 u_argmax10 ( .clk(clk), .reset(reset), .in_valid(argmax_in_valid_r), .v0(postfc_ch0_out_r), .v1(postfc_ch1_out_r), .v2(postfc_ch2_out_r), .v3(postfc_ch3_out_r), .v4(postfc_ch4_out_r), .v5(postfc_ch5_out_r), .v6(postfc_ch6_out_r), .v7(postfc_ch7_out_r), .v8(postfc_ch8_out_r), .v9(postfc_ch9_out_r), .out_valid(out_valid), .out_index(pred_out));

endmodule
