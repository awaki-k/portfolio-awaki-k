module ring_fifo_vecpush_scalarpop #(
    parameter integer WIDTH     = 8,
    parameter integer DEPTH     = 64,
    parameter integer VEC_ELEMS = 32
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       wr_en,
    input  wire [WIDTH*VEC_ELEMS-1:0] wr_vec_data,
    input  wire                       rd_en,
    output reg  [WIDTH-1:0]           rd_data,
    output reg                        rd_valid,
    output wire                       full
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

    localparam integer VDEPTH = (VEC_ELEMS == 0) ? 1 : (DEPTH / VEC_ELEMS);
    localparam integer AW     = clog2(VDEPTH);
    localparam integer LW     = clog2(VEC_ELEMS);
    localparam integer UW     = clog2(DEPTH + 1);

    reg [WIDTH*VEC_ELEMS-1:0] mem [0:VDEPTH-1];
    reg [AW-1:0]              wptr, rptr;

    function [AW-1:0] inc_vptr;
        input [AW-1:0] p;
        begin
            inc_vptr = (p == VDEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
        end
    endfunction

    // 使用中スカラ数
    reg [UW-1:0] used;

    // full 判定（ベクトル 1 本追加可能か）
    wire [UW:0] used_ext  = {1'b0, used};
    wire [UW:0] depth_ext = DEPTH[UW:0];
    wire [UW:0] vec_ext   = VEC_ELEMS[UW:0];

    assign full = (VEC_ELEMS > DEPTH) ? 1'b1
                                      : ((used_ext + vec_ext) > depth_ext);

    // ベクトル内 lane
    reg [LW-1:0] lane;

    // 実トランザクション
    wire wr_fire = (wr_en && !full);
    wire rd_fire = (rd_en && (used != 0));  // have_vec は不要。used!=0 を空判定に使う

    integer delta;
    integer next_used;

    always @(posedge clk) begin
        if (reset) begin
            wptr     <= {AW{1'b0}};
            rptr     <= {AW{1'b0}};
            used     <= {UW{1'b0}};
            rd_data  <= {WIDTH{1'b0}};
            rd_valid <= 1'b0;
            lane     <= {LW{1'b0}};
        end else begin
            // 書き込み（ベクトル単位）
            if (wr_fire) begin
                mem[wptr] <= wr_vec_data;
                wptr      <= inc_vptr(wptr);
            end

            // used の next を先に計算
            delta = 0;
            if (wr_fire) delta = delta + VEC_ELEMS;
            if (rd_fire) delta = delta - 1;
            next_used = used + delta;

            // 読み出し（スカラ）
            rd_valid <= 1'b0;
            if (rd_fire) begin
                rd_data  <= mem[rptr][WIDTH*lane +: WIDTH];
                rd_valid <= 1'b1;

                if (lane == (VEC_ELEMS-1)) begin
                    lane <= {LW{1'b0}};
                    // 今の vec を出し切ったので次 vec に進む
                    rptr <= inc_vptr(rptr);
                end else begin
                    lane <= lane + 1'b1;
                end
            end

            // used を 0〜DEPTH でサチュレート
            if (next_used < 0)
                used <= {UW{1'b0}};
            else if (next_used > DEPTH)
                used <= DEPTH[UW-1:0];
            else
                used <= next_used[UW-1:0];
        end
    end

endmodule



// module ring_fifo_vecpush_scalarpop #(
//     parameter integer WIDTH     = 8,
//     parameter integer DEPTH     = 64,
//     parameter integer VEC_ELEMS = 32
// )(
//     input  wire                       clk,
//     input  wire                       reset,
//     input  wire                       wr_en,
//     input  wire [WIDTH*VEC_ELEMS-1:0] wr_vec_data,
//     input  wire                       rd_en,
//     output reg  [WIDTH-1:0]           rd_data,
//     output reg                        rd_valid,
//     output wire                       full
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

//     localparam integer VDEPTH = (VEC_ELEMS == 0) ? 1 : (DEPTH / VEC_ELEMS);
//     localparam integer AW = clog2(VDEPTH);
//     localparam integer LW = clog2(VEC_ELEMS);
//     localparam integer UW = clog2(DEPTH + 1);

//     reg [WIDTH*VEC_ELEMS-1:0] mem [0:VDEPTH-1];
//     reg [AW-1:0] wptr, rptr;

//     function [AW-1:0] inc_vptr;
//         input [AW-1:0] p;
//         begin
//             inc_vptr = (p == VDEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     reg [UW-1:0] used;

//     wire [UW:0] used_ext  = {1'b0, used};
//     wire [UW:0] depth_ext = DEPTH[UW:0];
//     wire [UW:0] vec_ext   = VEC_ELEMS[UW:0];

//     assign full = (VEC_ELEMS > DEPTH) ? 1'b1
//                                       : ((used_ext + vec_ext) > depth_ext);

//     reg [WIDTH*VEC_ELEMS-1:0] out_vec;
//     reg [LW-1:0]              lane;
//     reg                       have_vec;

//     wire wr_fire = (wr_en && !full);
//     wire rd_fire = (rd_en && have_vec);

//     integer delta;
//     integer next_used;

//     always @(posedge clk) begin
//         if (reset) begin
//             wptr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             used     <= {UW{1'b0}};
//             rd_data  <= {WIDTH{1'b0}};
//             rd_valid <= 1'b0;
//             out_vec  <= {(WIDTH*VEC_ELEMS){1'b0}};
//             lane     <= {LW{1'b0}};
//             have_vec <= 1'b0;
//         end else begin
//             if (wr_fire) begin
//                 mem[wptr] <= wr_vec_data;
//                 wptr <= inc_vptr(wptr);
//             end

//             // 内部の「空判定」は必須（used!=0）
//             if (!have_vec && (used != 0)) begin
//                 out_vec  <= mem[rptr];
//                 rptr     <= inc_vptr(rptr);
//                 lane     <= {LW{1'b0}};
//                 have_vec <= 1'b1;
//             end

//             rd_valid <= 1'b0;
//             if (rd_fire) begin
//                 rd_data  <= out_vec[WIDTH*lane +: WIDTH];
//                 rd_valid <= 1'b1;

//                 if (lane == (VEC_ELEMS-1)) begin
//                     lane     <= {LW{1'b0}};
//                     have_vec <= 1'b0;
//                 end else begin
//                     lane <= lane + 1'b1;
//                 end
//             end

//             delta = 0;
//             if (wr_fire) delta = delta + VEC_ELEMS;
//             if (rd_fire) delta = delta - 1;

//             next_used = used + delta;

//             if (next_used < 0)
//                 used <= {UW{1'b0}};
//             else if (next_used > DEPTH)
//                 used <= DEPTH[UW-1:0];
//             else
//                 used <= next_used[UW-1:0];
//         end
//     end

// endmodule
