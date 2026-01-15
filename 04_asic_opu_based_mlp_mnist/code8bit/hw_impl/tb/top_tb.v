`timescale 1ns / 1ps

module top_tb;

    parameter integer CLK_PERIOD = 10;
    parameter integer TRUE_LABEL = 9;

    // -----------------------------
    // Common params
    // -----------------------------
    parameter integer WIDTH      = 8;
    parameter integer PE_NUM     = 32;
    parameter integer ACC_SIZE   = 32;

    parameter integer FC0_N      = 28*28;   // 784
    parameter integer FC1_N      = 64;
    parameter integer FC2_N      = 32;
    parameter integer FC3_N      = 10;

    // -----------------------------
    // Match top's bank params
    // -----------------------------
    parameter integer X1_WIDTH      = 8;
    parameter integer X1_DEPTH      = 28*28;
    parameter integer W1_WIDTH      = 8*32;
    parameter integer W1_DEPTH      = 28*28*2;
    parameter integer X2_WIDTH      = 8;
    parameter integer X2_DEPTH      = 64;
    parameter integer X2_VEC_ELEMS  = 32;
    parameter integer X3_WIDTH      = 8;
    parameter integer X3_DEPTH      = 32;
    parameter integer X3_VEC_ELEMS  = 32;
    parameter integer W2_WIDTH      = 8*32;
    parameter integer W2_DEPTH      = 64;
    parameter integer W3_WIDTH      = 8*32;
    parameter integer W3_DEPTH      = 32;
    parameter integer B1_WIDTH      = 32*32;
    parameter integer B1_DEPTH      = 2;
    parameter integer B2_WIDTH      = 32*32;
    parameter integer B2_DEPTH      = 1;
    parameter integer B3_WIDTH      = 32*32;
    parameter integer B3_DEPTH      = 1;
    parameter integer SC_WIDTH      = 24;
    parameter integer SC_DEPTH      = 4;
    parameter integer SH_WIDTH      = 8;
    parameter integer SH_DEPTH      = 4;
    parameter integer ZP_WIDTH      = 8;
    parameter integer ZP_DEPTH      = 4;
    parameter integer LI_WIDTH      = 12;
    parameter integer LI_DEPTH      = 3;
    parameter integer LO_WIDTH      = 4;
    parameter integer LO_DEPTH      = 3;
    parameter integer LABEL_N      = 10;
    parameter integer OUT_WIDTH    = 4;
    parameter integer STATE_SIZE    = 4;

    // -----------------------------
    // Hex paths (Input)
    // -----------------------------
    // parameter X1_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00000_label7_pred7_OK_u8.hex";
    parameter X1_HEX =  (TRUE_LABEL == 0) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00003_label0_pred0_OK_u8.hex" :
                        (TRUE_LABEL == 1) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00002_label1_pred1_OK_u8.hex" :
                        (TRUE_LABEL == 2) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00001_label2_pred2_OK_u8.hex" :
                        (TRUE_LABEL == 3) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00018_label3_pred3_OK_u8.hex" :
                        (TRUE_LABEL == 4) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00004_label4_pred4_OK_u8.hex" :
                        (TRUE_LABEL == 5) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00015_label5_pred5_OK_u8.hex" :
                        (TRUE_LABEL == 6) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00011_label6_pred6_OK_u8.hex" :
                        (TRUE_LABEL == 7) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00000_label7_pred7_OK_u8.hex" :
                        (TRUE_LABEL == 8) ? "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00061_label8_pred8_OK_u8.hex" :
                                            "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/correct/mnist_00007_label9_pred9_OK_u8.hex";
                        
    // -----------------------------
    // Hex paths (Parameters)
    // -----------------------------
    parameter W1_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc1_W_rowmajor_int8.hex";
    parameter W2_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc2_W_rowmajor_int8.hex";
    parameter W3_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc3_W_rowmajor_int8.hex";
    parameter B1_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc1_b_int32.hex";
    parameter B2_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc2_b_int32.hex";
    parameter B3_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/fc3_b_int32.hex";
    parameter SC_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/meta/requant_scale.hex";
    parameter SH_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/meta/requant_shift.hex";
    parameter ZP_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/meta/out_zero_point.hex";
    parameter LI_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/meta/inner_loop.hex";
    parameter LO_HEX = "D:/vlsi/code/export_hw_fixed_halfup_rowmajor/meta/outer_loop.hex";

    // -----------------------------
    // DUT I/O
    // -----------------------------
    reg                         clk;
    reg                         reset;

    reg                         x1_wr_en;
    reg  [X1_WIDTH-1:0]         x1_wr_data;

    reg                         w1_wr_en;
    reg  [W1_WIDTH-1:0]         w1_wr_data;

    reg                         w2_wr_en;
    reg  [W2_WIDTH-1:0]         w2_wr_data;

    reg                         w3_wr_en;
    reg  [W3_WIDTH-1:0]         w3_wr_data;

    reg                         b1_wr_en;
    reg  [B1_WIDTH-1:0]         b1_wr_data;

    reg                         b2_wr_en;
    reg  [B2_WIDTH-1:0]         b2_wr_data;

    reg                         b3_wr_en;
    reg  [B3_WIDTH-1:0]         b3_wr_data;

    reg                         sc_wr_en;
    reg  [SC_WIDTH-1:0]         sc_wr_data;

    reg                         sh_wr_en;
    reg  [SH_WIDTH-1:0]         sh_wr_data;

    reg                         zp_wr_en;
    reg  [ZP_WIDTH-1:0]         zp_wr_data;
    
    reg                         li_wr_en;
    reg  [LI_WIDTH-1:0]         li_wr_data;

    reg                         lo_wr_en;
    reg  [LO_WIDTH-1:0]         lo_wr_data;
    
    reg                         exec;
    reg                         tready;

    wire [OUT_WIDTH-1:0]        argmx_out;
    wire                        tvalid;

    // -------- dbg ports --------
    // wire [2:0]                  exec_ready_dbg;
    // wire                        fc0_exec_ready_dbg;
    // wire                        fc1_exec_ready_dbg;
    // wire                        fc2_exec_ready_dbg;
    // wire                        xw1_rd_en_dbg;
    // wire [X1_WIDTH-1:0]         x1_rd_data_dbg;
    // wire                        x1_rd_valid_dbg;
    // wire [W1_WIDTH-1:0]         w1_rd_data_dbg;
    // wire                        w1_rd_valid_dbg;
    // wire                        xw2_rd_en_dbg;
    // wire [X2_WIDTH-1:0]         x2_rd_data_dbg;
    // wire                        x2_rd_valid_dbg;
    // wire [W2_WIDTH-1:0]         w2_rd_data_dbg;
    // wire                        w2_rd_valid_dbg;
    // wire                        xw3_rd_en_dbg;
    // wire [X3_WIDTH-1:0]         x3_rd_data_dbg;
    // wire                        x3_rd_valid_dbg;
    // wire [W3_WIDTH-1:0]         w3_rd_data_dbg;
    // wire                        w3_rd_valid_dbg;
    // wire                        b1_rd_en_dbg;
    // wire [B1_WIDTH-1:0]         b1_rd_data_dbg;
    // wire                        b1_rd_valid_dbg;
    // wire                        b2_rd_en_dbg;
    // wire [B2_WIDTH-1:0]         b2_rd_data_dbg;
    // wire                        b2_rd_valid_dbg;
    // wire                        b3_rd_en_dbg;
    // wire [B3_WIDTH-1:0]         b3_rd_data_dbg;
    // wire                        b3_rd_valid_dbg;
    // wire                        rq_rd_en_dbg;
    // wire [SC_WIDTH-1:0]         sc_rd_data_dbg;
    // wire                        sc_rd_valid_dbg;
    // wire [SH_WIDTH-1:0]         sh_rd_data_dbg;
    // wire                        sh_rd_valid_dbg;
    // wire [ZP_WIDTH-1:0]         zp_rd_data_dbg;
    // wire                        zp_rd_valid_dbg;
    // wire                        x2_wr_en_dbg;
    // wire                        x3_wr_en_dbg;
    // wire [LI_WIDTH-1:0]         li_cnt_dbg;
    // wire [LO_WIDTH-1:0]         lo_cnt_dbg;
    // wire [LI_WIDTH-1:0]         li_out_dbg;
    // wire [LO_WIDTH-1:0]         lo_out_dbg;
    // wire                        li_rd_en_dbg;
    // wire                        lo_rd_en_dbg;
    // wire [LI_WIDTH-1:0]         li_rd_data_dbg;
    // wire [LO_WIDTH-1:0]         lo_rd_data_dbg;
    // wire                        li_rd_valid_dbg;
    // wire                        lo_rd_valid_dbg;
    // wire                        li_end_dbg;
    // wire                        lo_end_dbg;
    // wire                        acc_en_dbg;
    // wire                        acc_sel_dbg;
    // wire [STATE_SIZE-1:0]       state_dbg;
    // wire [STATE_SIZE-1:0]       next_state_dbg;
    // wire                        li_clear_dbg;
    // wire                        li_incr_dbg;
    // wire                        lo_clear_dbg;
    // wire                        lo_incr_dbg;
    // wire [ACC_SIZE*PE_NUM-1:0]  acc_out_dbg;
    // wire [ACC_SIZE*PE_NUM-1:0]  pb_out_dbg;
    // wire                        pb_valid_dbg;
    // wire                        x1_full_dbg;
    // wire                        w1_full_dbg;
    // wire                        w2_full_dbg;
    // wire                        w3_full_dbg;
    // wire                        b1_full_dbg;
    // wire                        b2_full_dbg;
    // wire                        b3_full_dbg;
    // wire                        sc_full_dbg;
    // wire                        sh_full_dbg;
    // wire                        zp_full_dbg;
    // wire                        li_full_dbg;
    // wire                        lo_full_dbg;

    // ---------------------------------
    // Instance
    // ---------------------------------
    top #(
        .X1_WIDTH   (X1_WIDTH),
        .X1_DEPTH   (X1_DEPTH),

        .W1_WIDTH   (W1_WIDTH),
        .W1_DEPTH   (W1_DEPTH),

        .W2_WIDTH   (W2_WIDTH),
        .W2_DEPTH   (W2_DEPTH),

        .W3_WIDTH   (W3_WIDTH),
        .W3_DEPTH   (W3_DEPTH),

        .B1_WIDTH   (B1_WIDTH),
        .B1_DEPTH   (B1_DEPTH),

        .B2_WIDTH   (B2_WIDTH),
        .B2_DEPTH   (B2_DEPTH),

        .B3_WIDTH   (B3_WIDTH),
        .B3_DEPTH   (B3_DEPTH),

        .SC_WIDTH   (SC_WIDTH),
        .SC_DEPTH   (SC_DEPTH),

        .SH_WIDTH   (SH_WIDTH),
        .SH_DEPTH   (SH_DEPTH),

        .ZP_WIDTH   (ZP_WIDTH),
        .ZP_DEPTH   (ZP_DEPTH),

        .LI_WIDTH   (LI_WIDTH),
        .LI_DEPTH   (LI_DEPTH),

        .LO_WIDTH   (LO_WIDTH),
        .LO_DEPTH   (LO_DEPTH),

        .PE_NUM     (PE_NUM),
        .WIDTH      (WIDTH),
        .ACC_SIZE   (ACC_SIZE)
    ) top_inst (
        .clk            (clk),
        .reset          (reset),

        // writes (10 banks)
        .x1_wr_en       (x1_wr_en), .x1_wr_data (x1_wr_data),
        .w1_wr_en       (w1_wr_en), .w1_wr_data (w1_wr_data),
        .w2_wr_en       (w2_wr_en), .w2_wr_data (w2_wr_data),
        .w3_wr_en       (w3_wr_en), .w3_wr_data (w3_wr_data),

        .b1_wr_en       (b1_wr_en), .b1_wr_data (b1_wr_data),
        .b2_wr_en       (b2_wr_en), .b2_wr_data (b2_wr_data),
        .b3_wr_en       (b3_wr_en), .b3_wr_data (b3_wr_data),

        .sc_wr_en       (sc_wr_en), .sc_wr_data (sc_wr_data),
        .sh_wr_en       (sh_wr_en), .sh_wr_data (sh_wr_data),
        .zp_wr_en       (zp_wr_en), .zp_wr_data (zp_wr_data),

        .li_wr_en       (li_wr_en), .li_wr_data (li_wr_data),
        .lo_wr_en       (lo_wr_en), .lo_wr_data (lo_wr_data),
        
        // controller input
        .exec           (exec),
        .tready         (tready),

        // outputs
        .argmx_out            (argmx_out),
        .tvalid               (tvalid)

        // --- dbg ---
        // , .exec_ready_dbg     (exec_ready_dbg)
        // , .fc0_exec_ready_dbg (fc0_exec_ready_dbg)
        // , .fc1_exec_ready_dbg (fc1_exec_ready_dbg)
        // , .fc2_exec_ready_dbg (fc2_exec_ready_dbg)
        // , .xw1_rd_en_dbg      (xw1_rd_en_dbg)
        // , .x1_rd_data_dbg     (x1_rd_data_dbg)
        // , .x1_rd_valid_dbg    (x1_rd_valid_dbg)
        // , .w1_rd_data_dbg     (w1_rd_data_dbg)
        // , .w1_rd_valid_dbg    (w1_rd_valid_dbg)
        // , .w2_rd_data_dbg     (w2_rd_data_dbg)
        // , .w2_rd_valid_dbg    (w2_rd_valid_dbg)
        // , .w3_rd_data_dbg     (w3_rd_data_dbg)
        // , .w3_rd_valid_dbg    (w3_rd_valid_dbg)
        // , .xw2_rd_en_dbg      (xw2_rd_en_dbg)
        // , .x2_rd_data_dbg     (x2_rd_data_dbg)
        // , .x2_rd_valid_dbg    (x2_rd_valid_dbg)
        // , .xw3_rd_en_dbg      (xw3_rd_en_dbg)
        // , .x3_rd_data_dbg     (x3_rd_data_dbg)
        // , .x3_rd_valid_dbg    (x3_rd_valid_dbg)
        // , .b1_rd_en_dbg       (b1_rd_en_dbg)
        // , .b1_rd_data_dbg     (b1_rd_data_dbg)
        // , .b1_rd_valid_dbg    (b1_rd_valid_dbg)
        // , .b2_rd_en_dbg       (b2_rd_en_dbg)
        // , .b2_rd_data_dbg     (b2_rd_data_dbg)
        // , .b2_rd_valid_dbg    (b2_rd_valid_dbg)
        // , .b3_rd_en_dbg       (b3_rd_en_dbg)
        // , .b3_rd_data_dbg     (b3_rd_data_dbg)
        // , .b3_rd_valid_dbg    (b3_rd_valid_dbg)
        // , .rq_rd_en_dbg       (rq_rd_en_dbg)
        // , .sc_rd_data_dbg     (sc_rd_data_dbg)
        // , .sc_rd_valid_dbg    (sc_rd_valid_dbg)
        // , .sh_rd_data_dbg     (sh_rd_data_dbg)
        // , .sh_rd_valid_dbg    (sh_rd_valid_dbg)
        // , .zp_rd_data_dbg     (zp_rd_data_dbg)
        // , .zp_rd_valid_dbg    (zp_rd_valid_dbg)
        // , .x2_wr_en_dbg       (x2_wr_en_dbg)
        // , .x3_wr_en_dbg       (x3_wr_en_dbg)
        // , .li_cnt_dbg         (li_cnt_dbg)
        // , .lo_cnt_dbg         (lo_cnt_dbg)
        // , .li_out_dbg         (li_out_dbg)
        // , .lo_out_dbg         (lo_out_dbg)
        // , .li_rd_en_dbg       (li_rd_en_dbg)
        // , .lo_rd_en_dbg       (lo_rd_en_dbg)
        // , .li_rd_data_dbg     (li_rd_data_dbg)
        // , .lo_rd_data_dbg     (lo_rd_data_dbg)
        // , .li_rd_valid_dbg    (li_rd_valid_dbg)
        // , .lo_rd_valid_dbg    (lo_rd_valid_dbg)
        // , .li_end_dbg         (li_end_dbg)
        // , .lo_end_dbg         (lo_end_dbg)
        // , .acc_en_dbg         (acc_en_dbg)
        // , .acc_sel_dbg        (acc_sel_dbg)
        // , .state_dbg          (state_dbg)
        // , .next_state_dbg     (next_state_dbg)
        // , .li_clear_dbg       (li_clear_dbg)
        // , .li_incr_dbg        (li_incr_dbg)
        // , .lo_clear_dbg       (lo_clear_dbg)
        // , .lo_incr_dbg        (lo_incr_dbg)
        // , .acc_out_dbg        (acc_out_dbg)
        // , .pb_out_dbg         (pb_out_dbg)
        // , .pb_valid_dbg       (pb_valid_dbg)
        // , .x1_full_dbg        (x1_full_dbg)
        // , .w1_full_dbg        (w1_full_dbg)
        // , .w2_full_dbg        (w2_full_dbg)
        // , .w3_full_dbg        (w3_full_dbg)
        // , .b1_full_dbg        (b1_full_dbg)
        // , .b2_full_dbg        (b2_full_dbg)
        // , .b3_full_dbg        (b3_full_dbg)
        // , .sc_full_dbg        (sc_full_dbg)
        // , .sh_full_dbg        (sh_full_dbg)
        // , .zp_full_dbg        (zp_full_dbg)
        // , .li_full_dbg        (li_full_dbg)
        // , .lo_full_dbg        (lo_full_dbg)
    );

    // ---------------------------------
    // Clock
    // ---------------------------------
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---------------------------------
    // Memories loaded from hex
    // ---------------------------------
    reg [WIDTH-1:0]     x1_mem [0:FC0_N-1];
    reg [WIDTH-1:0]     w1_mem [0:FC0_N*FC1_N-1];
    reg [WIDTH-1:0]     w2_mem [0:FC1_N*FC2_N-1];
    reg [WIDTH-1:0]     w3_mem [0:FC2_N*FC3_N-1];
    reg [ACC_SIZE-1:0]  b1_mem [0:FC1_N-1];
    reg [ACC_SIZE-1:0]  b2_mem [0:FC2_N-1];
    reg [ACC_SIZE-1:0]  b3_mem [0:FC3_N-1];
    reg [SC_WIDTH-1:0]  sc_mem [0:SC_DEPTH-1];
    reg [SH_WIDTH-1:0]  sh_mem [0:SH_DEPTH-1];
    reg [ZP_WIDTH-1:0]  zp_mem [0:ZP_DEPTH-1];
    reg [LI_WIDTH-1:0]  li_mem [0:LI_DEPTH-1];
    reg [LO_WIDTH-1:0]  lo_mem [0:LO_DEPTH-1];
    

    initial begin
        $readmemh(X1_HEX, x1_mem);
        $readmemh(W1_HEX, w1_mem);
        $readmemh(B1_HEX, b1_mem);
        $readmemh(W2_HEX, w2_mem);
        $readmemh(W3_HEX, w3_mem);
        $readmemh(B2_HEX, b2_mem);
        $readmemh(B3_HEX, b3_mem);
        $readmemh(SC_HEX, sc_mem);
        $readmemh(SH_HEX, sh_mem);
        $readmemh(ZP_HEX, zp_mem);
        $readmemh(LI_HEX, li_mem);
        $readmemh(LO_HEX, lo_mem);
    end

    // ---------------------------------
    // Write task: push into each bank
    // ---------------------------------
    task automatic write_task;
        integer i, j, k;
        begin
            // default
            x1_wr_en = 1'b0; x1_wr_data = {X1_WIDTH{1'b0}};
            w1_wr_en = 1'b0; w1_wr_data = {W1_WIDTH{1'b0}};
            w2_wr_en = 1'b0; w2_wr_data = {W2_WIDTH{1'b0}};
            w3_wr_en = 1'b0; w3_wr_data = {W3_WIDTH{1'b0}};
            b1_wr_en = 1'b0; b1_wr_data = {B1_WIDTH{1'b0}};
            b2_wr_en = 1'b0; b2_wr_data = {B2_WIDTH{1'b0}};
            b3_wr_en = 1'b0; b3_wr_data = {B3_WIDTH{1'b0}};
            sc_wr_en = 1'b0; sc_wr_data = {SC_WIDTH{1'b0}};
            sh_wr_en = 1'b0; sh_wr_data = {SH_WIDTH{1'b0}};
            zp_wr_en = 1'b0; zp_wr_data = {ZP_WIDTH{1'b0}};
            li_wr_en = 1'b0; li_wr_data = {LI_WIDTH{1'b0}};
            lo_wr_en = 1'b0; lo_wr_data = {LO_WIDTH{1'b0}};

            #(CLK_PERIOD);

            // -------------------------
            // X1 write
            // -------------------------
            for (i = 0; i < X1_DEPTH; i = i + 1) begin
                x1_wr_en = 1'b1; x1_wr_data = x1_mem[i]; #(CLK_PERIOD);
            end
            x1_wr_en = 1'b0; x1_wr_data ={X1_WIDTH{1'b0}}; #(CLK_PERIOD);

            // -------------------------
            // W1 write
            // -------------------------
            for (i = 0; i < (FC1_N/PE_NUM); i = i + 1) begin
                for (j = 0; j < FC0_N; j = j + 1) begin
                    for (k = 0; k < PE_NUM; k = k + 1) begin
                        w1_wr_data[WIDTH*k +: WIDTH] = w1_mem[(i*PE_NUM + k)*FC0_N + j];
                    end
                    w1_wr_en = 1'b1; #(CLK_PERIOD);
                end
            end
            w1_wr_en = 1'b0; w1_wr_data ={W1_WIDTH{1'b0}}; #(CLK_PERIOD);

            // -------------------------
            // W2 write
            // -------------------------
            for (i = 0; i < FC1_N; i = i + 1) begin
                for (j = 0; j < PE_NUM; j = j + 1) begin
                    w2_wr_data[WIDTH*j +: WIDTH] =  w2_mem[j*FC1_N + i];
                end
                w2_wr_en = 1'b1; #(CLK_PERIOD);
            end
            w2_wr_en = 1'b0; w2_wr_data ={W2_WIDTH{1'b0}}; #(CLK_PERIOD);

            // -------------------------
            // W3 write
            // -------------------------
            for (i = 0; i < FC2_N; i = i + 1) begin
                w3_wr_data = {PE_NUM*WIDTH{1'b0}}; // zero padding
                for (j = 0; j < FC3_N; j = j + 1) begin
                    w3_wr_data[WIDTH*j +: WIDTH] =  w3_mem[j*FC2_N + i];
                end
                w3_wr_en = 1'b1; #(CLK_PERIOD);
            end
            w3_wr_en = 1'b0; w3_wr_data ={W3_WIDTH{1'b0}}; #(CLK_PERIOD);


            // -------------------------
            // B1 write
            // -------------------------
            for (i = 0; i < (FC1_N/PE_NUM); i = i + 1) begin
                for (j = 0; j < PE_NUM; j = j + 1) begin
                    b1_wr_data[ACC_SIZE*j +: ACC_SIZE] = b1_mem[i*PE_NUM + j];
                end
                b1_wr_en = 1'b1; #(CLK_PERIOD);
            end
            b1_wr_en = 1'b0; b1_wr_data ={B1_WIDTH{1'b0}}; #(CLK_PERIOD);


            // -------------------------
            // B2 write
            // -------------------------
            for (i = 0; i < PE_NUM; i = i + 1) begin
                b2_wr_data[ACC_SIZE*i +: ACC_SIZE] = b2_mem[i];
            end
            b2_wr_en = 1'b1; #(CLK_PERIOD);
            b2_wr_en = 1'b0; b2_wr_data ={B2_WIDTH{1'b0}}; #(CLK_PERIOD);

            // -------------------------
            // B3 write
            // -------------------------
            b3_wr_data = {PE_NUM*ACC_SIZE{1'b0}}; 
            for (i = 0; i < FC3_N; i = i + 1) begin
                b3_wr_data[ACC_SIZE*i +: ACC_SIZE] = b3_mem[i];
            end
            b3_wr_en = 1'b1; #(CLK_PERIOD);
            b3_wr_en = 1'b0; b3_wr_data ={B3_WIDTH{1'b0}}; #(CLK_PERIOD);

            // -------------------------
            // SC write
            // -------------------------
            for (i = 0; i < SC_DEPTH; i = i + 1) begin
                sc_wr_data = sc_mem[i];
                sc_wr_en = 1'b1;
                #(CLK_PERIOD);
            end
            sc_wr_en = 1'b0; sc_wr_data ={SC_WIDTH{1'b0}}; #(CLK_PERIOD);


            // -------------------------
            // SH write
            // -------------------------
            for (i = 0; i < SH_DEPTH; i = i + 1) begin
                sh_wr_data = sh_mem[i];
                sh_wr_en = 1'b1;
                #(CLK_PERIOD);
            end
            sh_wr_en = 1'b0; sh_wr_data ={SH_WIDTH{1'b0}}; #(CLK_PERIOD);


            // -------------------------
            // ZP write
            // -------------------------
            for (i = 0; i < ZP_DEPTH; i = i + 1) begin
                zp_wr_data = zp_mem[i];
                zp_wr_en = 1'b1;
                #(CLK_PERIOD);
            end
            zp_wr_en = 1'b0; zp_wr_data ={ZP_WIDTH{1'b0}}; #(CLK_PERIOD);
            
            // -------------------------
            // LI write
            // -------------------------
            for (i = 0; i < LI_DEPTH; i = i + 1) begin
                li_wr_data = li_mem[i];
                li_wr_en = 1'b1;
                #(CLK_PERIOD);
            end
            li_wr_en = 1'b0; li_wr_data ={LI_WIDTH{1'b0}}; #(CLK_PERIOD);
            
            // -------------------------
            // LO write
            // -------------------------
            for (i = 0; i < LO_DEPTH; i = i + 1) begin
                lo_wr_data = lo_mem[i];
                lo_wr_en = 1'b1;
                #(CLK_PERIOD);
            end
            lo_wr_en = 1'b0; lo_wr_data ={LO_WIDTH{1'b0}}; #(CLK_PERIOD);
        end
    endtask

    // ---------------------------------
    // Stimulus
    // ---------------------------------
    initial begin
        reset = 1'b0; exec = 1'b0; tready = 1'b1;

        x1_wr_en = 1'b0; x1_wr_data = {X1_WIDTH{1'b0}};
        w1_wr_en = 1'b0; w1_wr_data = {W1_WIDTH{1'b0}};
        w2_wr_en = 1'b0; w2_wr_data = {W2_WIDTH{1'b0}};
        w3_wr_en = 1'b0; w3_wr_data = {W3_WIDTH{1'b0}};
        b1_wr_en = 1'b0; b1_wr_data = {B1_WIDTH{1'b0}};
        b2_wr_en = 1'b0; b2_wr_data = {B2_WIDTH{1'b0}};
        b3_wr_en = 1'b0; b3_wr_data = {B3_WIDTH{1'b0}};
        sc_wr_en = 1'b0; sc_wr_data = {SC_WIDTH{1'b0}};
        sh_wr_en = 1'b0; sh_wr_data = {SH_WIDTH{1'b0}};
        zp_wr_en = 1'b0; zp_wr_data = {ZP_WIDTH{1'b0}};
        li_wr_en = 1'b0; li_wr_data = {LI_WIDTH{1'b0}};
        lo_wr_en = 1'b0; lo_wr_data = {LO_WIDTH{1'b0}};

        #(CLK_PERIOD*5.4);

        reset = 1'b1; #(CLK_PERIOD);
        reset = 1'b0; #(CLK_PERIOD);

        write_task(); #(CLK_PERIOD*0.2);

        exec = 1'b1; 

        wait (tvalid == 1'b1);
        

        exec = 1'b0; #(CLK_PERIOD*10);

        $finish;
    end

    initial begin
        #(CLK_PERIOD*100000);
        $finish;
    end

    // ---------------------------------
    // Latency measurement
    // ---------------------------------
    integer cycle_cnt;
    integer start_cycle, end_cycle;

    initial cycle_cnt = 0;
    always @(posedge clk) begin
        cycle_cnt <= cycle_cnt + 1;
    end

    task automatic measure_exec_to_tvalid_latency;
        integer delta_cycles;
        real    latency_us;
        reg [OUT_WIDTH-1:0] argmx_at_done;
        begin
            // exec 立ち上がりを待つ
            @(posedge exec);
            start_cycle = cycle_cnt;

            // tvalid が 1 になるまで待つ
            wait (tvalid);

            end_cycle    = cycle_cnt;
            delta_cycles = end_cycle - start_cycle;

            // tvalid=1 のタイミングでの argmax 出力をキャプチャ
            argmx_at_done = argmx_out;

            // us = cycles * CLK_PERIOD[ns] / 1000
            latency_us = delta_cycles * CLK_PERIOD / 1000.0;

            if (argmx_at_done == TRUE_LABEL) begin
                $display("[CORRECT  ]: LABEL=%0d, PRED=%0d, CYCLE=%0d, LATENCY=%.3f us (CLK_PERIOD=%0d ns)",
                         TRUE_LABEL,
                         argmx_at_done,
                         delta_cycles,
                         latency_us,
                         CLK_PERIOD);
            end else begin
                $display("[INCORRECT]: LABEL=%0d, PRED=%0d, CYCLE=%0d, LATENCY=%.3f us (CLK_PERIOD=%0d ns)",
                         TRUE_LABEL,
                         argmx_at_done,
                         delta_cycles,
                         latency_us,
                         CLK_PERIOD);
            end
        end
    endtask


    // task を起動するだけの initial
    initial begin
        measure_exec_to_tvalid_latency();
    end




endmodule
