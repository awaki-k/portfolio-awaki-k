// module argmax #(
//     parameter integer WIDTH      = 16,
//     parameter integer LABEL_N    = 10,
//     parameter integer VEC_ELEMS  = 32,
//     parameter integer OUT_WIDTH  = 4,

//     // ★追加: pb_vec の並び指定
//     // MSB_FIRST=1: pb_vec = {lane0, lane1, ..., lane31}（lane0がMSB）
//     // MSB_FIRST=0: pb_vec = {lane31, ..., lane1, lane0}（lane0がLSB）
//     parameter integer MSB_FIRST  = 0,

//     // ★追加: 比較対象の開始lane
//     // 例: 32並列の末尾10個(lane22..31)をラベル0..9として比較したいなら 22
//     parameter integer LABEL_BASE = (VEC_ELEMS - LABEL_N)
// )(
//     input  wire                       clk,
//     input  wire                       reset,
//     input  wire                       en,       // start pulse
//     input  wire [WIDTH*VEC_ELEMS-1:0] pb_vec,

//     output reg  [OUT_WIDTH-1:0]       pred,
//     output reg                        valid
// );

//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer pred_W = clog2(LABEL_N);

//     // ------------------------------------------------------------
//     // Stage0: input register
//     // ------------------------------------------------------------
//     reg [WIDTH*VEC_ELEMS-1:0] pb_vec_r;
//     reg                      v0;

//     // ------------------------------------------------------------
//     // Stage1: argmax across LABEL_N labels (relative index 0..LABEL_N-1)
//     // ------------------------------------------------------------
//     reg signed [WIDTH-1:0]    max_r;
//     reg        [pred_W-1:0]   idx_r;
//     reg                       v1;

//     reg signed [WIDTH-1:0]    max_w;
//     reg        [pred_W-1:0]   idx_w;
//     integer k;

//     // lane 抽出（符号付き）
//     function signed [WIDTH-1:0] lane_val;
//         input integer lane_i;
//         integer base;
//         begin
//             if (MSB_FIRST) base = (VEC_ELEMS-1-lane_i) * WIDTH; // lane0がMSB
//             else           base = lane_i * WIDTH;               // lane0がLSB
//             lane_val = $signed(pb_vec_r[base +: WIDTH]);
//         end
//     endfunction

//     // label_i(0..LABEL_N-1) を pb_vec の lane(LABEL_BASE + label_i) から読む
//     function signed [WIDTH-1:0] label_val;
//         input integer label_i;
//         integer lane_i;
//         begin
//             lane_i = LABEL_BASE + label_i;
//             label_val = lane_val(lane_i);
//         end
//     endfunction

//     always @* begin
//         max_w = label_val(0);
//         idx_w = {pred_W{1'b0}};
//         for (k = 1; k < LABEL_N; k = k + 1) begin
//             if (label_val(k) > max_w) begin
//                 max_w = label_val(k);
//                 idx_w = k[pred_W-1:0];
//             end
//         end
//     end

//     // ------------------------------------------------------------
//     // Stage2: output (2 cycles after en)
//     // ------------------------------------------------------------
//     always @(posedge clk) begin
//         if (reset) begin
//             pb_vec_r <= {(WIDTH*VEC_ELEMS){1'b0}};
//             v0       <= 1'b0;

//             max_r    <= {WIDTH{1'b0}};
//             idx_r    <= {pred_W{1'b0}};
//             v1       <= 1'b0;

//             pred     <= {OUT_WIDTH{1'b0}};
//             valid    <= 1'b0;
//         end else begin
//             // Stage0
//             if (en) begin
//                 pb_vec_r <= pb_vec;
//                 v0       <= 1'b1;
//             end else begin
//                 v0       <= 1'b0;
//             end

//             // Stage1
//             if (v0) begin
//                 max_r <= max_w;
//                 idx_r <= idx_w;
//                 v1    <= 1'b1;
//             end else begin
//                 v1    <= 1'b0;
//             end

//             // Stage2
//             valid <= v1;
//             if (v1) begin
//                 pred <= idx_r[OUT_WIDTH-1:0]; // OUT_WIDTH>=pred_W推奨
//             end
//         end
//     end

// endmodule


module argmax #(
    parameter integer WIDTH      = 16,
    parameter integer LABEL_N    = 10,
    parameter integer VEC_ELEMS  = 32,
    parameter integer OUT_WIDTH  = 4
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       en,       // start pulse
    input  wire [WIDTH*VEC_ELEMS-1:0] pb_vec,

    output reg  [OUT_WIDTH-1:0]       pred,
    output reg                        valid
);
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

    localparam integer pred_W = clog2(LABEL_N);

    // ------------------------------------------------------------
    // Stage0: input register (cuts pb_vec routing delay)
    // ------------------------------------------------------------
    reg [WIDTH*VEC_ELEMS-1:0] pb_vec_r;
    reg                      v0;

    // ------------------------------------------------------------
    // Stage1: partial argmax (0..4) and (5..9) -> regs
    // ------------------------------------------------------------
    reg signed [WIDTH-1:0] max0_r, max1_r;
    reg        [pred_W-1:0] idx0_r, idx1_r;
    reg                     v1;

    // Stage1 comb (driven from pb_vec_r)
    reg signed [WIDTH-1:0] max0_w, max1_w;
    reg        [pred_W-1:0] idx0_w, idx1_w;
    integer k;

    always @* begin
        // defaults
        max0_w = $signed(pb_vec_r[0*WIDTH +: WIDTH]);
        idx0_w = {pred_W{1'b0}};

        // group0: 0..4
        for (k = 1; k <= 4; k = k + 1) begin
            if ($signed(pb_vec_r[k*WIDTH +: WIDTH]) > max0_w) begin
                max0_w = $signed(pb_vec_r[k*WIDTH +: WIDTH]);
                idx0_w = k[pred_W-1:0];
            end
        end

        // group1: 5..9
        max1_w = $signed(pb_vec_r[5*WIDTH +: WIDTH]);
        idx1_w = {pred_W{1'b0}} | 5; // Verilog-2001 safe constant assign

        for (k = 6; k <= 9; k = k + 1) begin
            if ($signed(pb_vec_r[k*WIDTH +: WIDTH]) > max1_w) begin
                max1_w = $signed(pb_vec_r[k*WIDTH +: WIDTH]);
                idx1_w = k[pred_W-1:0];
            end
        end
    end

    // ------------------------------------------------------------
    // Stage2: final compare -> pred
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            pb_vec_r <= {(WIDTH*VEC_ELEMS){1'b0}};
            v0       <= 1'b0;

            max0_r   <= {WIDTH{1'b0}};
            max1_r   <= {WIDTH{1'b0}};
            idx0_r   <= {pred_W{1'b0}};
            idx1_r   <= {pred_W{1'b0}};
            v1       <= 1'b0;

            pred     <= {OUT_WIDTH{1'b0}};
            valid    <= 1'b0;
        end else begin
            // -------------------------
            // Stage0: capture pb_vec
            // -------------------------
            if (en) begin
                pb_vec_r <= pb_vec;
                v0       <= 1'b1;
            end else begin
                v0       <= 1'b0;
            end

            // -------------------------
            // Stage1: capture partial results (1 cycle after en)
            // -------------------------
            if (v0) begin
                max0_r <= max0_w;
                idx0_r <= idx0_w;
                max1_r <= max1_w;
                idx1_r <= idx1_w;
                v1     <= 1'b1;
            end else begin
                v1     <= 1'b0;
            end

            // -------------------------
            // Stage2: output (2 cycles after en)
            // -------------------------
            valid <= v1;
            if (v1) begin
                if (max1_r > max0_r) pred <= idx1_r[OUT_WIDTH-1:0];
                else                 pred <= idx0_r[OUT_WIDTH-1:0];
            end
        end
    end

endmodule