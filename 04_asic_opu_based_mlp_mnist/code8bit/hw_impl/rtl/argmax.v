module argmax #(
    parameter integer WIDTH      = 32,  // 各要素のビット幅
    parameter integer LABEL_N    = 10,  // 比較する要素数（MNISTなら10）
    parameter integer VEC_ELEMS  = 32,  // pb_vec 全体の要素数
    parameter integer OUT_WIDTH  = 4    // 出力ラベルのビット幅
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       en,       // enable: 1 のサイクルで結果を確定
    input  wire [WIDTH*VEC_ELEMS-1:0] pb_vec,   // 32bit×VEC_ELEMS のベクトル

    output reg  [OUT_WIDTH-1:0]       label,    // argmax のインデックス (0~LABEL_N-1)
    output reg                        valid     // label が有効なサイクルで 1
);
    // ceil(log2(v)) を返す関数
    function integer clog2;
        input integer v;
        integer i;
        begin
            v = v - 1;
            for (i = 0; v > 0; i = i + 1)
                v = v >> 1;
            clog2 = (i < 1) ? 1 : i;
        end
    endfunction

    localparam integer LABEL_W = clog2(LABEL_N);

    // 最大値探索用（組み合わせ）
    reg  signed [WIDTH-1:0] max_val;
    reg  [LABEL_W-1:0]      label_next;
    integer                 i;

    // ------------ 組み合わせ部：pb_vec から argmax を計算 ------------
    always @* begin
        // 0 番目要素で初期化
        max_val    = $signed(pb_vec[0 +: WIDTH]);
        label_next = {LABEL_W{1'b0}};  // 0

        // 1〜LABEL_N-1 番目の要素と比較
        for (i = 1; i < LABEL_N; i = i + 1) begin
            if ($signed(pb_vec[WIDTH*i +: WIDTH]) > max_val) begin
                max_val    = $signed(pb_vec[WIDTH*i +: WIDTH]);
                label_next = i[LABEL_W-1:0];  // 新しい最大値インデックス
            end
        end
    end

    // ------------ 順序部：en が立ったサイクルで出力レジスタに確定 ------------
    always @(posedge clk) begin
        if (reset) begin
            label <= {LABEL_W{1'b0}};
            valid <= 1'b0;
        end else begin
            if (en) begin
                label <= label_next;
                valid <= 1'b1;
            end else begin
                valid <= 1'b0;
            end
        end
    end

endmodule
