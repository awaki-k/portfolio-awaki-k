`timescale 1ns / 1ps

module qcnn_top_tb;
    // ========= Parameters =========
    localparam integer IMG_WIDTH         = 28;
    localparam integer IMG_HEIGHT        = 26;   // 既存コード踏襲
    localparam integer POOL1_WIDTH       = 26;
    localparam integer CONV2_WIDTH       = 13;
    localparam integer POOL2_WIDTH       = 11;
    localparam integer IMG_NUM           = 10;
    localparam integer DW                = 8;
    localparam integer ACC_W             = 32;
    localparam integer CONV1_N           = 3*3*1;
    localparam integer CONV2_N           = 3*3*4;
    localparam integer FC1_N             = 8;
    localparam integer CONV1_STAGE_DEPTH = 1;
    localparam integer CONV2_STAGE_DEPTH = 1;
    localparam integer FC_STAGE_DEPTH    = 1;
    localparam integer FC_ACC_N          = 25;
    localparam integer CLK_NS            = 10;   // 100MHz

    // ========= Image memory =========
    reg [DW-1:0] img_mem [0:IMG_WIDTH*IMG_HEIGHT*IMG_NUM-1];
    integer img_idx;
    integer fd;
    initial begin
        fd = $fopen("D:/cfs/final/RTL/src/img_mem.hex","r");
        if (fd) begin
            $fclose(fd);
            $readmemh("D:/cfs/final/RTL/src/img_mem.hex", img_mem);
            $display("Loaded img_mem.hex.");
        end else begin
            for (img_idx = 0; img_idx < IMG_WIDTH*IMG_HEIGHT*IMG_NUM; img_idx = img_idx + 1)
                img_mem[img_idx] = img_idx[7:0];
            $display("img_mem.hex not found. Using fallback pattern.");
        end
    end

    // ========= DUT I/F =========
    reg  clk;
    reg  reset;                 // DUT は Active-High 同期リセット
    reg  in_valid;
    reg  signed [7:0] pixel_in;
    wire [3:0] pred_out;
    wire out_valid;

    // ========= DUT =========
    qcnn_top dut (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .pixel_in(pixel_in),
        .pred_out(pred_out),
        .out_valid(out_valid)
    );

    // ========= Clock =========
    initial clk = 0;
    always #(CLK_NS/2) clk = ~clk; // 100MHz

    // ========= Measurement =========
    time    t_start, t_last_in, t_end;   // ns
    integer cyc_cnt;                     // free-running cycle counter (cleared by reset)
    integer cyc_start, cyc_last_in, cyc_end;
    real    img_latency_ns, img_gap_ns;
    integer total_imgs_measured;
    real    sum_latency_ns;

    initial begin
        cyc_cnt = 0;
        total_imgs_measured = 0;
        sum_latency_ns = 0.0;
    end

    always @(posedge clk) begin
        if (reset) cyc_cnt <= 0;
        else       cyc_cnt <= cyc_cnt + 1;
    end

    // ========= Accuracy counters =========
    integer correct_predictions;
    integer total_predictions;

    // ========= Handy tasks (negedge 駆動で安全マージン確保) =========
    // Verilog-2001 形式の引数宣言に変更
    task automatic safe_reset_pulse;
        input integer posedge_cycles;
        begin
            // 非同期に assert（いつでも可）
            reset = 1'b1;
            // 指定サイクル数だけ posedge を待つ
            repeat (posedge_cycles) @(posedge clk);
            // posedge から半周期離れた negedge で deassert（= 同期解除）
            @(negedge clk);
            reset = 1'b0;
        end
    endtask

    task automatic drive_inputs;
        input [7:0] pix;
        input       v;
        begin
            // 次の posedge まで 5ns 以上のセットアップ時間を確保
            @(negedge clk);
            pixel_in <= $signed(pix);
            in_valid <= v;
        end
    endtask

    task automatic deassert_in_valid;
        begin
            @(negedge clk);
            in_valid <= 1'b0;
        end
    endtask

    // ========= Stimulus =========
    integer r, c;
    localparam integer LOOPNUM = 10;

    integer started;
    real avg_latency_ns;
    real fps;

    initial begin
        // init
        reset    = 1'b1;
        in_valid = 1'b0;
        pixel_in = {DW{1'b0}};
        correct_predictions = 0;
        total_predictions   = 0;

        // 初期リセット：3サイクル保持→negedge で解除（= 同期解除）
        safe_reset_pulse(3);

        // 画像を順送
        for (img_idx = 0; img_idx < LOOPNUM; img_idx = img_idx + 1) begin
            // （必要であれば）フレーム間リセットも安全に実施
            // 実効スループット重視ならコメントアウト可
            safe_reset_pulse(2);

            // ==== measurement start on first pixel ====
            started = 0;

            // raster scan 入力（すべて negedge 更新）
            for (r = 0; r < IMG_HEIGHT; r = r + 1) begin
                for (c = 0; c < IMG_WIDTH; c = c + 1) begin
                    drive_inputs(
                        img_mem[img_idx * IMG_WIDTH * IMG_HEIGHT + r * IMG_WIDTH + c],
                        1'b1
                    );

                    if (!started) begin
                        started   = 1;
                        t_start   = $time;
                        cyc_start = cyc_cnt;
                    end

                    if ((r == IMG_HEIGHT-1) && (c == IMG_WIDTH-1)) begin
                        t_last_in   = $time;
                        cyc_last_in = cyc_cnt;
                    end
                end
            end

            // 入力終了（negedge で in_valid を下げる）
            deassert_in_valid();

            // 最初の有効出力を待つ（posedge out_valid）
            @(posedge out_valid);

            // timestamp on output
            t_end   = $time;
            cyc_end = cyc_cnt;

            // report
            img_latency_ns = (t_end - t_start);
            img_gap_ns     = (t_end - t_last_in);

            $display("Output data for image: label=%0d, pred=%0d", img_idx, pred_out);
            if (pred_out == img_idx) begin
                correct_predictions = correct_predictions + 1;
            end
            total_predictions = total_predictions + 1;

            // accumulate for average
            total_imgs_measured = total_imgs_measured + 1;
            sum_latency_ns      = sum_latency_ns + img_latency_ns;

            // フレーム間のアイドル（必要量を調整）
            repeat (30) @(posedge clk);
        end

        // ===== Summary =====
        avg_latency_ns = (total_imgs_measured > 0) ? (sum_latency_ns / total_imgs_measured) : 0.0;
        fps            = (avg_latency_ns > 0.0) ? (1e9 / avg_latency_ns) : 0.0;

        $display("---- Summary ----");
        $display("Images measured      : %0d", total_imgs_measured);
        $display("Avg latency (ns)     : %0f", avg_latency_ns);
        $display("Throughput (img/s)   : %0f", fps);
        if (total_predictions > 0)
            $display("Accuracy             : %0d%%", (correct_predictions * 100) / total_predictions);

        $finish;
    end

    // optional waveform log
    // always @(posedge clk) if (out_valid) $display("T=%0t pred=%0d", $time, pred_out);

endmodule


// `timescale 1ns / 1ps

// module qcnn_top_tb;
//     // ========= Parameters =========
//     localparam integer IMG_WIDTH         = 28;
//     localparam integer IMG_HEIGHT        = 26;   // �?コード踏襲
//     localparam integer POOL1_WIDTH       = 26;
//     localparam integer CONV2_WIDTH       = 13;
//     localparam integer POOL2_WIDTH       = 11;
//     localparam integer IMG_NUM           = 10;
//     localparam integer DW                = 8;
//     localparam integer ACC_W             = 32;
//     localparam integer CONV1_N           = 3*3*1;
//     localparam integer CONV2_N           = 3*3*4;
//     localparam integer FC1_N             = 8;
//     localparam integer CONV1_STAGE_DEPTH = 1;
//     localparam integer CONV2_STAGE_DEPTH = 1;
//     localparam integer FC_STAGE_DEPTH    = 1;
//     localparam integer FC_ACC_N          = 25;
//     localparam integer CLK_NS            = 10;   // 100MHz

//     // ========= Image memory =========
//     reg [DW-1:0] img_mem [0:IMG_WIDTH*IMG_HEIGHT*IMG_NUM-1];
//     integer img_idx;
//     integer fd;
//     initial begin
//         fd = $fopen("D:/cfs/final/RTL/src/img_mem.hex","r");
//         if (fd) begin
//             $fclose(fd);
//             $readmemh("D:/cfs/final/RTL/src/img_mem.hex", img_mem);
//             $display("Loaded img_mem.hex.");
//         end else begin
//             for (img_idx = 0; img_idx < IMG_WIDTH*IMG_HEIGHT*IMG_NUM; img_idx = img_idx + 1)
//                 img_mem[img_idx] = img_idx[7:0];
//             $display("img_mem.hex not found. Using fallback pattern.");
//         end
//     end

//     // ========= DUT I/F =========
//     reg  clk;
//     reg  reset;
//     reg  in_valid;
//     reg  signed [7:0] pixel_in;
//     wire [3:0] pred_out;
//     wire out_valid;

//     // ========= DUT =========
//     qcnn_top dut (
//         .clk(clk),
//         .reset(reset),
//         .in_valid(in_valid),
//         .pixel_in(pixel_in),
//         .pred_out(pred_out),
//         .out_valid(out_valid)
//     );

//     // ========= Clock =========
//     initial clk = 0;
//     always #(CLK_NS/2) clk = ~clk; // 100MHz

//     // ========= Measurement =========
//     // time-based & cycle-based timestamps
//     time    t_start, t_last_in, t_end;          // ns
//     integer cyc_cnt;                             // free-running cycle counter (cleared by reset)
//     integer cyc_start, cyc_last_in, cyc_end;
//     real    img_latency_ns, img_gap_ns;
//     integer total_imgs_measured;
//     real    sum_latency_ns;

//     initial begin
//         cyc_cnt = 0;
//         total_imgs_measured = 0;
//         sum_latency_ns = 0.0;
//     end

//     always @(posedge clk) begin
//         if (reset) cyc_cnt <= 0;
//         else       cyc_cnt <= cyc_cnt + 1;
//     end

//     // ========= Accuracy counters (任�?) =========
//     integer correct_predictions;
//     integer total_predictions;

//     // ========= Stimulus =========
//     integer r, c;
//     parameter LOOPNUM = 10;

//     integer started;        
//     real avg_latency_ns;
//     real fps;
//     initial begin
//         // init
//         reset    = 1'b1;
//         in_valid = 1'b0;
//         pixel_in = {DW{1'b0}};
//         correct_predictions = 0;
//         total_predictions   = 0;

//         // release reset
//         repeat (3) @(posedge clk);
//         reset = 1'b0;

//         // send images
//         for (img_idx = 0; img_idx < LOOPNUM; img_idx = img_idx + 1) begin
//             // per-image reset (�?のコード踏襲 / 実効スループット測定なら外してもOK)
//             @(posedge clk);
//             reset = 1'b1;
//             @(posedge clk);
//             reset = 1'b0;

//             @(posedge clk);

//             // ==== measurement start on first pixel ====
//             started = 0;

//             // send pixels (raster scan)
//             for (r = 0; r < IMG_HEIGHT; r = r + 1) begin
//                 for (c = 0; c < IMG_WIDTH; c = c + 1) begin
//                     @(posedge clk);
//                     pixel_in = img_mem[img_idx * IMG_WIDTH * IMG_HEIGHT + r * IMG_WIDTH + c];
//                     in_valid = 1'b1;

//                     if (!started) begin
//                         started   = 1;
//                         t_start   = $time;
//                         cyc_start = cyc_cnt;
//                     end

//                     if ((r == IMG_HEIGHT-1) && (c == IMG_WIDTH-1)) begin
//                         t_last_in   = $time;
//                         cyc_last_in = cyc_cnt;
//                     end
//                 end
//             end

//             @(posedge clk);
//             in_valid = 1'b0;

//             // wait for first valid output of the frame
//             @(posedge out_valid);

//             // timestamp on output
//             t_end   = $time;
//             cyc_end = cyc_cnt;

//             // report
//             img_latency_ns = (t_end - t_start);
//             img_gap_ns     = (t_end - t_last_in);

//             // $display("[IMG %0d] latency(first_in->out) = %0t ns (%0d cycles @%0dns)",
//             //          img_idx, (t_end - t_start), (cyc_end - cyc_start), CLK_NS);

//             // $display("[IMG %0d] pipeline gap(last_in->out) = %0t ns (%0d cycles)",
//             //          img_idx, (t_end - t_last_in), (cyc_end - cyc_last_in));

//             // print result & (optional) accuracy check
//             $display("Output data for image: label=%0d, pred=%0d", img_idx, pred_out);
//             if (pred_out == img_idx) begin
//                 correct_predictions = correct_predictions + 1;
//             end
//             total_predictions = total_predictions + 1;

//             // accumulate for average
//             total_imgs_measured = total_imgs_measured + 1;
//             sum_latency_ns      = sum_latency_ns + img_latency_ns;

//             // inter-frame reset & wait (�?コード踏襲)
//             @(posedge clk);
//             reset = 1'b1;
//             repeat (1) @(posedge clk);
//             reset = 1'b0;
//             repeat (30) @(posedge clk);
//         end

//         // ===== Summary =====
//         // Average latency & throughput
//         avg_latency_ns = (total_imgs_measured > 0) ? (sum_latency_ns / total_imgs_measured) : 0.0;
//         fps            = (avg_latency_ns > 0.0) ? (1e9 / avg_latency_ns) : 0.0;

//         $display("---- Summary ----");
//         $display("Images measured      : %0d", total_imgs_measured);
//         $display("Avg latency (ns)     : %0f", avg_latency_ns);
//         $display("Throughput (img/s)   : %0f", fps);
//         if (total_predictions > 0)
//             $display("Accuracy             : %0d%%", (correct_predictions * 100) / total_predictions);

//         $finish;
//     end

//     // optional waveform log
//     // always @(posedge clk) if (out_valid) $display("T=%0t pred=%0d", $time, pred_out);

// endmodule