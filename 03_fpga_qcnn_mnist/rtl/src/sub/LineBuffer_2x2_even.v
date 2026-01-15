`timescale 1ns/1ps
// LineBuffer_2x2_even.v
//  - WIDTH は必ず偶数 (デフォルト 26)
//  - 入力: 1pix/cyc（in_valid 高時）
//  - 出力: ストライド2 (横:奇数列のみ, 縦:1行おき) の 2x2 ウィンドウ
//  - 1フレーム 26x26 入力 -> 13x13 個の 2x2 出力（各DW*4）
//
// win_flat の並び: {r1c1, r1c0, r0c1, r0c0}
//   r1=上段(row1), r0=下段(row2), c0=左, c1=右

module LineBuffer_2x2_even #(
    parameter integer WIDTH = 26,     // 偶数のみ
    parameter integer DW    = 8
)(
    input  wire              clk,
    input  wire              reset,        // Active-High 同期リセット
    input  wire              in_valid,
    input  wire [DW-1:0]     in_pixel,

    output reg               win_valid,
    output reg  [DW*4-1:0]   win_flat
);

    // 出力カウント: CNT_NUM = WIDTH/2 (奇数列の数)
    localparam integer CNT_NUM = WIDTH/2;

    // カウンタ幅
    localparam integer COLW = (WIDTH <= 2) ? 1 : $clog2(WIDTH);
    localparam integer CNTW = (CNT_NUM <= 2) ? 1 : $clog2(CNT_NUM+1);

    // 1 行前バッファ（上段）/ 現行行バッファ（下段）
    reg [DW-1:0] row1 [0:WIDTH-1];
    reg [DW-1:0] row2 [0:WIDTH-1];

    // 内部フラグ: row1 が満杯になったか（= 上段が有効）
    reg full_row1;

    // 列位置（0..WIDTH-1）
    reg [COLW-1:0] col;

    // 奇数列判定（1,3,5,...,WIDTH-1）
    wire col_is_odd = col[0];

    // 出力カウント（この下段行で何回 2x2 を出したか: 0..CNT_NUM-1）
    reg [CNTW-1:0] cycle_cnt;

    // 直近の上段/下段ピクセル（左隣用 1-tap）
    reg  [DW-1:0] r1_d1;          // row1 の col-1
    reg  [DW-1:0] r2_d1;          // row2 の col-1
    wire [DW-1:0] r1_now = row1[col];  // row1 の col

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            col       <= {COLW{1'b0}};
            full_row1 <= 1'b0;
            cycle_cnt <= {CNTW{1'b0}};
            r1_d1     <= {DW{1'b0}};
            r2_d1     <= {DW{1'b0}};
            win_valid <= 1'b0;
            win_flat  <= {DW*4{1'b0}};
            // row1/row2 は win_valid により外部観測から保護されるため未初期化でOK
        end else begin
            // 既定は VALID 無し（入力が無いサイクルや非出力サイクル）
            win_valid <= 1'b0;

            if (in_valid) begin
                if (!full_row1) begin
                    //------------------------------------------------------
                    // フェーズA: 上段 row1 を 26 要素蓄積する期間
                    //------------------------------------------------------
                    row1[col] <= in_pixel;

                    // 列進行
                    if (col == WIDTH-1) begin
                        col       <= {COLW{1'b0}};
                        full_row1 <= 1'b1;            // 次サイクルから下段 row2 フェーズへ
                        cycle_cnt <= {CNTW{1'b0}};    // 出力回数をリセット
                        r1_d1     <= {DW{1'b0}};      // 上段の左隣タップ初期化（任意）
                        r2_d1     <= {DW{1'b0}};      // 下段の左隣タップ初期化
                    end else begin
                        col   <= col + {{(COLW-1){1'b0}}, 1'b1};
                    end

                end else begin
                    //------------------------------------------------------
                    // フェーズB: 下段 row2 を入力しながら 2x2 を出力
                    //           奇数列（col_is_odd）でのみ VALID を立てる
                    //------------------------------------------------------
                    // 下段へ書き込み（右画素）
                    row2[col] <= in_pixel;

                    // 2x2 ウィンドウの組み立て（このサイクルの col を基準）
                    // {r1c1, r1c0, r0c1, r0c0} = { row1[col], row1[col-1], in_pixel, r2_d1 }
                    if (col_is_odd) begin
                        win_flat  <= { r1_now, r1_d1, in_pixel, r2_d1 };
                        win_valid <= 1'b1;                 // ストライド2（横）
                        cycle_cnt <= cycle_cnt + {{(CNTW-1){1'b0}}, 1'b1};
                    end

                    // 1-tap を更新（次サイクルの左隣）
                    r1_d1 <= r1_now;       // 上段 col   -> 次サイクルの r1(col-1) 相当
                    r2_d1 <= in_pixel;     // 下段 col   -> 次サイクルの r0(col-1)

                    // 行末処理
                    if (col == WIDTH-1) begin
                        // この時点で奇数列なら 13 回目の出力が発生済み（WIDTH 偶数前提）
                        col       <= {COLW{1'b0}};
                        full_row1 <= 1'b0;               // 次行は再び row1 へ蓄積
                        cycle_cnt <= {CNTW{1'b0}};
                        r2_d1     <= {DW{1'b0}};         // 次行先頭に備えてクリア
                        // r1_d1 は row1 を再蓄積する間は参照しないため不用
                    end else begin
                        col <= col + {{(COLW-1){1'b0}}, 1'b1};
                    end
                end
            end
        end
    end

endmodule
