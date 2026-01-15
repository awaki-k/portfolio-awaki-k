`timescale 1ns / 1ps

module mlp_tb;

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
    // Match mlp's bank params
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
    parameter integer LO_WIDTH      = 2;
    parameter integer LO_DEPTH      = 3;
    parameter integer LABEL_N       = 10;
    parameter integer OUT_WIDTH     = 4;
    parameter integer STATE_SIZE    = 4;

    // -----------------------------
    // Hex paths (Input)
    // -----------------------------
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
    // DUT I/O
    // -----------------------------
    reg                         clk;
    reg                         reset;

    reg                         x1_wr_en;
    reg  [X1_WIDTH-1:0]         x1_wr_data;


    reg                         exec;
    reg                         tready;

    wire [OUT_WIDTH-1:0]        pred_out;
    wire                        tvalid;

    // -------- dbg ports --------
    // wire [2:0]                  exec_ready_dbg;
    // wire [9:0]                  x1_wptr_dbg;
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

    // ---------------------------------
    // Instance
    // ---------------------------------
    mlp #(
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
    ) mlp_inst (
        .clk            (clk),
        .reset          (reset),

        // writes (10 banks)
        .x1_wr_en       (x1_wr_en), .x1_wr_data (x1_wr_data),
        
        // controller input
        .exec           (exec),
        .tready         (tready),

        // outputs
        .pred_out            (pred_out),
        .tvalid               (tvalid)

        // --- dbg ---
        // , .exec_ready_dbg     (exec_ready_dbg)
        // , .x1_wptr_dbg        (x1_wptr_dbg)
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
    initial begin
        $readmemh(X1_HEX, x1_mem);
    end

    // ---------------------------------
    // Write task: push into each bank
    // ---------------------------------
    task automatic write_task;
        integer i, j, k;
        begin
            // default
            x1_wr_en = 1'b0; x1_wr_data = {X1_WIDTH{1'b0}};

            #(CLK_PERIOD);

            // -------------------------
            // X1 write
            // -------------------------
            for (i = 0; i < X1_DEPTH; i = i + 1) begin
                x1_wr_en = 1'b1; x1_wr_data = x1_mem[i]; #(CLK_PERIOD);
            end
            x1_wr_en = 1'b0; x1_wr_data ={X1_WIDTH{1'b0}}; #(CLK_PERIOD);

        end
    endtask

    // ---------------------------------
    // Stimulus
    // ---------------------------------
    initial begin
        reset = 1'b0; exec = 1'b0; tready = 1'b1;

        x1_wr_en = 1'b0; x1_wr_data = {X1_WIDTH{1'b0}};

        #(CLK_PERIOD*5.4);

        reset = 1'b1; #(CLK_PERIOD);
        reset = 1'b0; #(CLK_PERIOD*3);

        write_task(); #(CLK_PERIOD*0.2);

        exec = 1'b1; 

        wait (tvalid == 1'b1);
        
        exec = 1'b0; #(CLK_PERIOD*10);

        $finish;
    end

    initial begin
        #(CLK_PERIOD*10000);
        $finish;
    end

    // ---------------------------------
    // Latency measurement
    // ---------------------------------
    integer cycle_cnt;
    integer start_cycle, end_cycle;

    initial cycle_cnt = 0; initial start_cycle = 0; initial end_cycle = 0;
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
            argmx_at_done = pred_out;

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
