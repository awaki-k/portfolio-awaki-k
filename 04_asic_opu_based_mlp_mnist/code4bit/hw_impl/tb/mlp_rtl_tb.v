`timescale 1ns / 1ps

module mlp_rtl_tb;

    parameter real    CLK_PERIOD = 7.5;
    parameter integer TRUE_LABEL = 1;

    // -----------------------------
    // Common params
    // -----------------------------
    parameter integer PE_NUM     = 32;
    parameter integer WIDTH      =  4;
    parameter integer ACC_SIZE   = 16;

    parameter integer FC0_N      = 14*14;   // 196
    parameter integer FC1_N      = 32;
    parameter integer FC2_N      = 16;
    parameter integer FC3_N      = 10;

    // -----------------------------
    // Match mlp's bank params
    // -----------------------------
    // Input Image (14x14 = 196 pixels, 4-bit)
    parameter integer X1_WIDTH      = 4;
    parameter integer X1_DEPTH      = 14*14; // 196

    // Hidden Layer 1 Output (32 nodes, 4-bit)
    parameter integer X2_WIDTH      = 4;
    parameter integer X2_DEPTH      = 32;
    parameter integer X2_VEC_ELEMS  = 32;

    // Hidden Layer 2 Output (16 nodes, 4-bit)
    parameter integer X3_WIDTH      = 4;
    parameter integer X3_DEPTH      = 16;
    parameter integer X3_VEC_ELEMS  = 16; // Keep aligned to PE_NUM
    // parameter integer X3_VEC_ELEMS  = 32; // Keep aligned to PE_NUM

    // Weights (4-bit * 32 parallel = 128 bit width)
    // W1: In=196
    parameter integer W1_WIDTH      = 4*32; // 128
    parameter integer W1_DEPTH      = 196;
    // W2: In=32
    parameter integer W2_WIDTH      = 4*32; // 128
    parameter integer W2_DEPTH      = 32;
    // W3: In=16
    parameter integer W3_WIDTH      = 4*32; // 128
    parameter integer W3_DEPTH      = 16;

    parameter integer LABEL_N       = 10;
    parameter integer OUT_WIDTH     = 4;
    parameter integer STATE_SIZE    = 4;

    // -----------------------------
    // Hex paths (Input)
    // -----------------------------
    // parameter X1_HEX =  (TRUE_LABEL == 0) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0003_label0_pred0.hex" :
    //                     (TRUE_LABEL == 1) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0002_label1_pred1.hex" :
    //                     (TRUE_LABEL == 2) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0001_label2_pred2.hex" :
    //                     (TRUE_LABEL == 3) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0018_label3_pred3.hex" :
    //                     (TRUE_LABEL == 4) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0004_label4_pred4.hex" :
    //                     (TRUE_LABEL == 5) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0015_label5_pred5.hex" :
    //                     (TRUE_LABEL == 6) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0011_label6_pred6.hex" :
    //                     (TRUE_LABEL == 7) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0000_label7_pred7.hex" :
    //                     (TRUE_LABEL == 8) ? "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0061_label8_pred8.hex" :
    //                                         "D:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0007_label9_pred9.hex" ;
    parameter X1_HEX =  (TRUE_LABEL == 0) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0003_label0_pred0.hex" :
                        (TRUE_LABEL == 1) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0002_label1_pred1.hex" :
                        (TRUE_LABEL == 2) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0001_label2_pred2.hex" :
                        (TRUE_LABEL == 3) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0018_label3_pred3.hex" :
                        (TRUE_LABEL == 4) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0004_label4_pred4.hex" :
                        (TRUE_LABEL == 5) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0015_label5_pred5.hex" :
                        (TRUE_LABEL == 6) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0011_label6_pred6.hex" :
                        (TRUE_LABEL == 7) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0000_label7_pred7.hex" :
                        (TRUE_LABEL == 8) ? "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0061_label8_pred8.hex" :
                                            "E:/vlsi/code4bit/export_4bit_asic/inputs/correct/mnist_0007_label9_pred9.hex" ;
                        

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

        // wire [X1_WIDTH-1:0]         x_rd_data_dbg;
        // wire [W1_WIDTH-1:0]         w_rd_data_dbg;

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

        // wire                        x2_wr_en_dbg;
        // wire                        x3_wr_en_dbg;

        // wire [STATE_SIZE-1:0]       state_dbg;
        // wire [STATE_SIZE-1:0]       next_state_dbg;
        
        // wire                        acc_en_dbg;
        // wire                        acc_sel_dbg;
        // wire [ACC_SIZE*PE_NUM-1:0]  acc_out_dbg;
        
        // wire                        pb1_en_dbg;
        // wire                        pb2_en_dbg;
        // wire                        pb3_en_dbg;
        // wire [ACC_SIZE*PE_NUM-1:0]  pb1_out_dbg;
        // wire [ACC_SIZE*PE_NUM-1:0]  pb2_out_dbg;
        // wire [ACC_SIZE*PE_NUM-1:0]  pb3_out_dbg;
        // wire                        pb1_valid_dbg;
        // wire                        pb2_valid_dbg;
        // wire                        pb3_valid_dbg;

        // wire                        rq1_en_dbg;    
        // wire [WIDTH*PE_NUM-1:0]     rq1_out_dbg;
        // wire                        rq1_valid_dbg;
        // wire                        rq2_en_dbg;    
        // wire [WIDTH*PE_NUM-1:0]     rq2_out_dbg;
        // wire                        rq2_valid_dbg;

        // wire                        lp1_clear_dbg;
        // wire                        lp1_incr_dbg;
        // wire                        lp1_end_dbg;
        // wire                        lp2_clear_dbg;
        // wire                        lp2_incr_dbg;
        // wire                        lp2_end_dbg;
        // wire                        lp3_clear_dbg;
        // wire                        lp3_incr_dbg;
        // wire                        lp3_end_dbg;

        // wire [7:0]                  cnt1_dbg;
        // wire [7:0]                  cnt2_dbg;
        // wire [7:0]                  cnt3_dbg;

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
            // , .x_rd_data_dbg      (x_rd_data_dbg)
            // , .w_rd_data_dbg      (w_rd_data_dbg)

            // , .xw1_rd_en_dbg      (xw1_rd_en_dbg)
            // , .x1_rd_data_dbg     (x1_rd_data_dbg)
            // , .x1_rd_valid_dbg    (x1_rd_valid_dbg)
            // , .w1_rd_data_dbg     (w1_rd_data_dbg)
            // , .w1_rd_valid_dbg    (w1_rd_valid_dbg)
            
            // , .xw2_rd_en_dbg      (xw2_rd_en_dbg)
            // , .x2_rd_data_dbg     (x2_rd_data_dbg)
            // , .x2_rd_valid_dbg    (x2_rd_valid_dbg)
            // , .w2_rd_data_dbg     (w2_rd_data_dbg)
            // , .w2_rd_valid_dbg    (w2_rd_valid_dbg)
            
            // , .xw3_rd_en_dbg      (xw3_rd_en_dbg)
            // , .x3_rd_data_dbg     (x3_rd_data_dbg)
            // , .x3_rd_valid_dbg    (x3_rd_valid_dbg)
            // , .w3_rd_data_dbg     (w3_rd_data_dbg)
            // , .w3_rd_valid_dbg    (w3_rd_valid_dbg)
            
            // , .state_dbg          (state_dbg)
            // , .next_state_dbg     (next_state_dbg)

            // , .acc_en_dbg         (acc_en_dbg)
            // , .acc_sel_dbg        (acc_sel_dbg)
            // , .acc_out_dbg        (acc_out_dbg)
            
            // , .pb1_en_dbg         (pb1_en_dbg)
            // , .pb2_en_dbg         (pb2_en_dbg)
            // , .pb3_en_dbg         (pb3_en_dbg)
            // , .pb1_out_dbg        (pb1_out_dbg)
            // , .pb2_out_dbg        (pb2_out_dbg)
            // , .pb3_out_dbg        (pb3_out_dbg)
            // , .pb1_valid_dbg      (pb1_valid_dbg)
            // , .pb2_valid_dbg      (pb2_valid_dbg)
            // , .pb3_valid_dbg      (pb3_valid_dbg)
            
            // , .rq1_en_dbg         (rq1_en_dbg)    
            // , .rq1_out_dbg        (rq1_out_dbg)
            // , .rq1_valid_dbg      (rq1_valid_dbg)
            // , .rq2_en_dbg         (rq2_en_dbg)
            // , .rq2_out_dbg        (rq2_out_dbg)
            // , .rq2_valid_dbg      (rq2_valid_dbg)    
            
            // , .lp1_clear_dbg        (lp1_clear_dbg)
            // , .lp1_incr_dbg         (lp1_incr_dbg)
            // , .lp1_end_dbg          (lp1_end_dbg)
            // , .lp2_clear_dbg        (lp2_clear_dbg)
            // , .lp2_incr_dbg         (lp2_incr_dbg)
            // , .lp2_end_dbg          (lp2_end_dbg)
            // , .lp3_clear_dbg        (lp3_clear_dbg)
            // , .lp3_incr_dbg         (lp3_incr_dbg)
            // , .lp3_end_dbg          (lp3_end_dbg)
            
            // , .cnt1_dbg             (cnt1_dbg)
            // , .cnt2_dbg             (cnt2_dbg)
            // , .cnt3_dbg             (cnt3_dbg)
    );

    // ---------------------------------
    // Clock
    // ---------------------------------
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---------------------------------
    // Memories loaded from hex
    // ---------------------------------
    reg [WIDTH-1:0] x1_mem [0:FC0_N-1];
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
        reset = 1'b0; #(CLK_PERIOD*20);

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
                $display("[CORRECT  ]: LABEL=%0d, PRED=%0d, CYCLE=%0d, LATENCY=%.3f us (CLK_PERIOD=%0.3f ns)",
                         TRUE_LABEL,
                         argmx_at_done,
                         delta_cycles,
                         latency_us,
                         CLK_PERIOD);
            end else begin
                $display("[INCORRECT]: LABEL=%0d, PRED=%0d, CYCLE=%0d, LATENCY=%.3f us (CLK_PERIOD=%0.3f ns)",
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




    // ---------------------------------
    // Debug
    // ---------------------------------
    // reg [31:0] cnt_dbg;
    // initial cnt_dbg = 0;
    // always @(posedge clk) begin
    //     // X1, W1
    //     if(x1_rd_valid_dbg && w1_rd_valid_dbg) begin
    //         cnt_dbg = cnt_dbg + 1;
    //         // $display("[FC1(1/1), acc(%03d/196)] %h %h", cnt_dbg, x1_rd_data_dbg, w1_rd_data_dbg);
    //     end
    //     // ACC1
    //     if(cnt_dbg >= 2) begin
    //         $display("[FC1(1/1), acc(%03d/196)] %h", cnt_dbg-1, acc_out_dbg);
    //     end


    //     // X2, W2
    //     if(x2_rd_valid_dbg && w2_rd_valid_dbg) begin
    //         cnt_dbg = cnt_dbg + 1;
    //         // $display("[FC1(1/1), acc(%02d/32)] %h %h", cnt_dbg, x2_rd_data_dbg, w2_rd_data_dbg);
    //     end
    //     // ACC2
    //     if(cnt_dbg >= 2) begin
    //         $display("[FC2(1/1), acc(%02d/32)] %h", cnt_dbg-1, acc_out_dbg);
    //     end
    // end
    
    // initial wait(cnt_dbg == 197) $finish;
    // initial wait(cnt_dbg == 33) $finish;

endmodule
