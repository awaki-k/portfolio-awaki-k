`timescale 1ns/1ps
// LineBuffer_2x2_odd.v
// - WIDTH は必ず奇数 (デフォルト 11)
// - 入力: 1pix/cyc（in_valid 高時）
// - 出力: ストライド2（横:奇数列のみ, 縦:下段行のみ）の 2x2 ウィンドウ
// - 1フレーム 11x11 入力 -> 5x5=25 個の 2x2 出力（各DW*4）
//
// win_flat 並び: {r1c1, r1c0, r0c1, r0c0}
//   r1=上段(row1), r0=下段(row2), c0=左, c1=右
//
// 仕様上のポイント（奇数幅対応）
// - 各行で最後の要素（index=WIDTH-1）は必ず「ゴミ箱レジスタ」へ格納し、絶対に出力に使わない
// - したがって row 配列は [0 .. WIDTH-2] の 10 要素のみ保持する
// - 出力は row2 側のカウントが奇数かつ < WIDTH-1 のときだけ（1,3,5,7,9）

module LineBuffer_2x2_odd #(
    parameter integer WIDTH = 11,   // 奇数のみ
    parameter integer DW    = 8
)(
    input  wire              clk,
    input  wire              reset,        // Active-High 同期リセット
    input  wire              in_valid,
    input  wire [DW-1:0]     in_pixel,

    output reg               win_valid,
    output reg  [DW*4-1:0]   win_flat
);

    // 幅の妥当性チェック（合成ツールにより無視される場合あり）
    generate
        if (WIDTH % 2 == 0) begin : g_assert_odd_width
            initial $error("LineBuffer_2x2_odd: WIDTH must be odd.");
        end
    endgenerate

    // 出力個数: CNT_NUM = floor(WIDTH/2) （例: 11 -> 5）
    localparam integer CNT_NUM = WIDTH/2;

    // カウンタ幅（0..WIDTH-1 を表現）
    localparam integer COLW = (WIDTH <= 2) ? 1 : $clog2(WIDTH);

    // 上段/下段の保持配列（最後の1要素は保持しない = ゴミ箱へ）
    //   有効保持は 0..WIDTH-2 の 10 要素
    reg [DW-1:0] row1 [0:WIDTH-2];
    reg [DW-1:0] row2 [0:WIDTH-2];

    // 行末のゴミ箱用レジスタ（絶対に出力に使わない）
    reg [DW-1:0] trash1, trash2;

    // 内部フラグ: 上段 row1 が満杯になったか（= 次行で出力フェーズ）
    reg full_row1;

    // 書き込み位置カウンタ（row1 フェーズ / row2 フェーズで別管理）
    reg [COLW-1:0] row1_cnt;  // 0..WIDTH-1, ただし WIDTH-1 はゴミ箱
    reg [COLW-1:0] row2_cnt;  // 0..WIDTH-1, ただし WIDTH-1 はゴミ箱

    // 1タップ横シフト（左隣）
    reg  [DW-1:0] r1_d1;   // 上段 col-1
    reg  [DW-1:0] r2_d1;   // 下段 col-1

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            full_row1 <= 1'b0;
            row1_cnt  <= {COLW{1'b0}};
            row2_cnt  <= {COLW{1'b0}};
            r1_d1     <= {DW{1'b0}};
            r2_d1     <= {DW{1'b0}};
            win_valid <= 1'b0;
            win_flat  <= {DW*4{1'b0}};
            trash1    <= {DW{1'b0}};
            trash2    <= {DW{1'b0}};
        end else begin
            // 既定は VALID 無し
            win_valid <= 1'b0;

            if (in_valid) begin
                if (!full_row1) begin
                    //------------------------------------------------------
                    // フェーズA: 上段 row1 を埋める（0..WIDTH-2 を保持、WIDTH-1 はゴミ箱）
                    //------------------------------------------------------
                    if (row1_cnt < (WIDTH-1)) begin
                        // 保持領域（0..WIDTH-2）
                        row1[row1_cnt] <= in_pixel;
                        row1_cnt       <= row1_cnt + {{(COLW-1){1'b0}}, 1'b1};
                    end else begin
                        // 最後の1要素（index=WIDTH-1）はゴミ箱へ、出力フェーズへ移行
                        trash1    <= in_pixel;      // 絶対に使わない
                        full_row1 <= 1'b1;
                        row1_cnt  <= {COLW{1'b0}};  // 次の上段行の準備
                        row2_cnt  <= {COLW{1'b0}};  // 下段行の先頭から
                        r1_d1     <= {DW{1'b0}};    // 行切替時にクリア
                        r2_d1     <= {DW{1'b0}};
                    end

                end else begin
                    //------------------------------------------------------
                    // フェーズB: 下段 row2 を入力しながら 2x2 を出力
                    //            奇数列（1,3,5,7,9）かつ < WIDTH-1 で VALID
                    //------------------------------------------------------
                    if (row2_cnt < (WIDTH-1)) begin
                        // 保持領域（0..WIDTH-2）
                        row2[row2_cnt] <= in_pixel;

                        // 上段の同列画素（右）を取得して 1-tap を更新
                        // ※ row2_cnt==0 では出力しないが、次サイクル用に r*_d1 を更新
                        begin : blk_update_taps
                            reg [DW-1:0] r1_now;
                            r1_now = row1[row2_cnt]; // row2_cnt < WIDTH-1 なので安全
                            // 2x2 の組み立てと出力（奇数列のみ）
                            if (row2_cnt[0] == 1'b1) begin
                                // {r1c1, r1c0, r0c1, r0c0} = { r1_now, r1_d1, in_pixel, r2_d1 }
                                win_flat  <= { r1_now, r1_d1, in_pixel, r2_d1 };
                                win_valid <= 1'b1;
                            end
                            // 次サイクルの左隣用に更新
                            r1_d1 <= r1_now;
                        end

                        r2_d1    <= in_pixel;
                        row2_cnt <= row2_cnt + {{(COLW-1){1'b0}}, 1'b1};

                    end else begin
                        // 最後の1要素（index=WIDTH-1）はゴミ箱へ、次の上段行へ戻る
                        trash2    <= in_pixel;      // 絶対に使わない
                        full_row1 <= 1'b0;
                        row2_cnt  <= {COLW{1'b0}};
                        r1_d1     <= {DW{1'b0}};    // 行切替時にクリア
                        r2_d1     <= {DW{1'b0}};
                    end
                end
            end
        end
    end

endmodule
