`timescale 1ns/1ps

module DPUfc1ch0 #(
    parameter integer N            = 8,
    parameter integer ACT_WIDTH    = 8,
    parameter integer WEIGHT_WIDTH = 8,
    parameter integer DEPTH        = 25,
    parameter integer STAGE_DEPTH  = 3,
    parameter integer MULT_W       = 16,
    parameter integer ACC_W        = 32
)(
    input  wire                        clk,
    input  wire                        reset,
    input  wire                        in_valid,
    input  wire                        wen,
    input  wire [ACT_WIDTH*N-1:0]      a_vec,
    output reg  signed [ACC_W-1:0]     out,
    output reg                         out_valid
);
    // en
    wire en = wen & in_valid;
    // ---------------------------------------------------------
    // ROM用のアドレス更新
    // ---------------------------------------------------------
    localparam integer ADDR_W     = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam integer SAFE_STAGE = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;

    reg [ADDR_W-1:0] wmem_addr;
    always @(posedge clk) begin
        if (reset)        wmem_addr <= {ADDR_W{1'b0}};
        else if (en)      wmem_addr <= (wmem_addr == DEPTH-1) ? {ADDR_W{1'b0}} : (wmem_addr + 1'b1);
    end
    
    // ---------------------------------------------------------
    // 固定重みベクトル (内部レジスタ = ROM) -13588
    // ---------------------------------------------------------
    localparam integer ROW_W = WEIGHT_WIDTH * N;
    localparam signed [ROW_W-1:0] w0  = {8'sd2, -8'sd2, 8'sd0, 8'sd2, -8'sd9, -8'sd1, -8'sd2, 8'sd6};
    localparam signed [ROW_W-1:0] w1  = {-8'sd2, -8'sd3, 8'sd2, -8'sd5, -8'sd12, 8'sd0, -8'sd9, 8'sd5};
    localparam signed [ROW_W-1:0] w2  = {-8'sd4, -8'sd7, -8'sd5, 8'sd1, -8'sd3, 8'sd1, 8'sd7, 8'sd7};
    localparam signed [ROW_W-1:0] w3  = {-8'sd5, -8'sd10, 8'sd2, -8'sd1, -8'sd10, 8'sd7, 8'sd3, 8'sd6};
    localparam signed [ROW_W-1:0] w4  = {8'sd2, -8'sd5, -8'sd6, -8'sd10, -8'sd8, 8'sd8, -8'sd2, 8'sd0};
    localparam signed [ROW_W-1:0] w5  = {8'sd0, 8'sd2, 8'sd0, -8'sd1, 8'sd6, 8'sd2, 8'sd4, 8'sd1};
    localparam signed [ROW_W-1:0] w6  = {-8'sd2, -8'sd3, 8'sd0, 8'sd5, 8'sd2, 8'sd1, -8'sd2, 8'sd3};
    localparam signed [ROW_W-1:0] w7  = {-8'sd3, -8'sd8, -8'sd2, -8'sd4, -8'sd3, 8'sd3, -8'sd6, 8'sd9};
    localparam signed [ROW_W-1:0] w8  = {-8'sd5, -8'sd1, 8'sd1, -8'sd8, -8'sd6, 8'sd9, -8'sd7, -8'sd12};
    localparam signed [ROW_W-1:0] w9  = {8'sd9, -8'sd7, 8'sd3, 8'sd3, -8'sd4, 8'sd10, -8'sd6, 8'sd4};
    localparam signed [ROW_W-1:0] w10 = {8'sd3, 8'sd1, 8'sd6, -8'sd2, 8'sd14, 8'sd4, -8'sd2, 8'sd4};
    localparam signed [ROW_W-1:0] w11 = {8'sd2, -8'sd1, -8'sd1, -8'sd4, 8'sd8, -8'sd6, -8'sd10, 8'sd3};
    localparam signed [ROW_W-1:0] w12 = {-8'sd11, 8'sd8, -8'sd12, -8'sd14, 8'sd7, -8'sd20, -8'sd8, -8'sd11};
    localparam signed [ROW_W-1:0] w13 = {8'sd14, -8'sd11, -8'sd9, -8'sd9, 8'sd1, 8'sd0, -8'sd9, -8'sd5};
    localparam signed [ROW_W-1:0] w14 = {8'sd18, -8'sd1, -8'sd5, 8'sd9, 8'sd2, 8'sd9, -8'sd6, -8'sd3};
    localparam signed [ROW_W-1:0] w15 = {8'sd8, 8'sd0, 8'sd1, -8'sd11, 8'sd9, 8'sd2, -8'sd28, -8'sd4};
    localparam signed [ROW_W-1:0] w16 = {8'sd5, -8'sd2, 8'sd0, -8'sd3, 8'sd11, -8'sd2, -8'sd11, -8'sd2};
    localparam signed [ROW_W-1:0] w17 = {-8'sd9, 8'sd0, -8'sd4, 8'sd12, 8'sd8, 8'sd4, -8'sd5, 8'sd0};
    localparam signed [ROW_W-1:0] w18 = {8'sd3, 8'sd8, -8'sd3, 8'sd3, 8'sd5, 8'sd2, -8'sd3, -8'sd8};
    localparam signed [ROW_W-1:0] w19 = {8'sd15, 8'sd9, 8'sd3, -8'sd2, 8'sd5, 8'sd2, 8'sd3, 8'sd3};
    localparam signed [ROW_W-1:0] w20 = {8'sd4, -8'sd3, 8'sd5, -8'sd4, 8'sd9, 8'sd3, -8'sd25, -8'sd6};
    localparam signed [ROW_W-1:0] w21 = {-8'sd2, -8'sd10, -8'sd6, -8'sd6, 8'sd3, 8'sd11, -8'sd8, -8'sd13};
    localparam signed [ROW_W-1:0] w22 = {-8'sd20, -8'sd1, 8'sd12, 8'sd8, -8'sd6, 8'sd6, 8'sd11, -8'sd9};
    localparam signed [ROW_W-1:0] w23 = {-8'sd22, 8'sd0, -8'sd1, 8'sd0, -8'sd1, -8'sd2, 8'sd11, 8'sd12};
    localparam signed [ROW_W-1:0] w24 = {-8'sd9, 8'sd11, 8'sd3, -8'sd12, -8'sd4, -8'sd22, 8'sd0, 8'sd7};

    reg  signed [ROW_W-1:0] w_vec_const;
    always @* begin
    case (wmem_addr)
        0:  w_vec_const = w0;   1:  w_vec_const = w1;   2:  w_vec_const = w2;   3:  w_vec_const = w3;
        4:  w_vec_const = w4;   5:  w_vec_const = w5;   6:  w_vec_const = w6;   7:  w_vec_const = w7;
        8:  w_vec_const = w8;   9:  w_vec_const = w9;   10: w_vec_const = w10;  11: w_vec_const = w11;
        12: w_vec_const = w12;  13: w_vec_const = w13;  14: w_vec_const = w14;  15: w_vec_const = w15;
        16: w_vec_const = w16;  17: w_vec_const = w17;  18: w_vec_const = w18;  19: w_vec_const = w19;
        20: w_vec_const = w20;  21: w_vec_const = w21;  22: w_vec_const = w22;  23: w_vec_const = w23;
        24: w_vec_const = w24;
        default: w_vec_const = {ROW_W{1'b0}};
    endcase
    end
    // reg [WEIGHT_WIDTH*N-1:0] wmem [0:DEPTH-1];
    // // fc ch=0
    // initial begin
    //     wmem[0] = {8'sd2, -8'sd2, 8'sd0, 8'sd2, -8'sd9, -8'sd1, -8'sd2, 8'sd6};
    //     wmem[1] = {-8'sd2, -8'sd3, 8'sd2, -8'sd5, -8'sd12, 8'sd0, -8'sd9, 8'sd5};
    //     wmem[2] = {-8'sd4, -8'sd7, -8'sd5, 8'sd1, -8'sd3, 8'sd1, 8'sd7, 8'sd7};
    //     wmem[3] = {-8'sd5, -8'sd10, 8'sd2, -8'sd1, -8'sd10, 8'sd7, 8'sd3, 8'sd6};
    //     wmem[4] = {8'sd2, -8'sd5, -8'sd6, -8'sd10, -8'sd8, 8'sd8, -8'sd2, 8'sd0};
    //     wmem[5] = {8'sd0, 8'sd2, 8'sd0, -8'sd1, 8'sd6, 8'sd2, 8'sd4, 8'sd1};
    //     wmem[6] = {-8'sd2, -8'sd3, 8'sd0, 8'sd5, 8'sd2, 8'sd1, -8'sd2, 8'sd3};
    //     wmem[7] = {-8'sd3, -8'sd8, -8'sd2, -8'sd4, -8'sd3, 8'sd3, -8'sd6, 8'sd9};
    //     wmem[8] = {-8'sd5, -8'sd1, 8'sd1, -8'sd8, -8'sd6, 8'sd9, -8'sd7, -8'sd12};
    //     wmem[9] = {8'sd9, -8'sd7, 8'sd3, 8'sd3, -8'sd4, 8'sd10, -8'sd6, 8'sd4};
    //     wmem[10] = {8'sd3, 8'sd1, 8'sd6, -8'sd2, 8'sd14, 8'sd4, -8'sd2, 8'sd4};
    //     wmem[11] = {8'sd2, -8'sd1, -8'sd1, -8'sd4, 8'sd8, -8'sd6, -8'sd10, 8'sd3};
    //     wmem[12] = {-8'sd11, 8'sd8, -8'sd12, -8'sd14, 8'sd7, -8'sd20, -8'sd8, -8'sd11};
    //     wmem[13] = {8'sd14, -8'sd11, -8'sd9, -8'sd9, 8'sd1, 8'sd0, -8'sd9, -8'sd5};
    //     wmem[14] = {8'sd18, -8'sd1, -8'sd5, 8'sd9, 8'sd2, 8'sd9, -8'sd6, -8'sd3};
    //     wmem[15] = {8'sd8, 8'sd0, 8'sd1, -8'sd11, 8'sd9, 8'sd2, -8'sd28, -8'sd4};
    //     wmem[16] = {8'sd5, -8'sd2, 8'sd0, -8'sd3, 8'sd11, -8'sd2, -8'sd11, -8'sd2};
    //     wmem[17] = {-8'sd9, 8'sd0, -8'sd4, 8'sd12, 8'sd8, 8'sd4, -8'sd5, 8'sd0};
    //     wmem[18] = {8'sd3, 8'sd8, -8'sd3, 8'sd3, 8'sd5, 8'sd2, -8'sd3, -8'sd8};
    //     wmem[19] = {8'sd15, 8'sd9, 8'sd3, -8'sd2, 8'sd5, 8'sd2, 8'sd3, 8'sd3};
    //     wmem[20] = {8'sd4, -8'sd3, 8'sd5, -8'sd4, 8'sd9, 8'sd3, -8'sd25, -8'sd6};
    //     wmem[21] = {-8'sd2, -8'sd10, -8'sd6, -8'sd6, 8'sd3, 8'sd11, -8'sd8, -8'sd13};
    //     wmem[22] = {-8'sd20, -8'sd1, 8'sd12, 8'sd8, -8'sd6, 8'sd6, 8'sd11, -8'sd9};
    //     wmem[23] = {-8'sd22, 8'sd0, -8'sd1, 8'sd0, -8'sd1, -8'sd2, 8'sd11, 8'sd12};
    //     wmem[24] = {-8'sd9, 8'sd11, 8'sd3, -8'sd12, -8'sd4, -8'sd22, 8'sd0, 8'sd7};
    // end


    // ---------------------------------------------------------
    // 被乗算ベクトルのレジスタ
    // ---------------------------------------------------------
    reg [ACT_WIDTH*N-1:0]    a_vec_reg;
    reg signed [WEIGHT_WIDTH*N-1:0] w_vec_reg;
    always @(posedge clk) begin
        a_vec_reg <= reset ? 0 : (en ? a_vec : a_vec_reg);
        w_vec_reg <= reset ? 0 : (en ? w_vec_const : w_vec_reg);
    end

// reg delay_valid;
// always @(posedge clk) begin delay_valid <= in_valid; end
// always @(posedge clk) begin
//     if (delay_valid) begin
//         // 直接個別の要素を表示（10進数符号なし）
//         $display("a_vec_reg: %d %d %d %d %d %d %d %d", a_vec_reg[ACT_WIDTH*0 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*1 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*2 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*3 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*4 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*5 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*6 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*7 +: ACT_WIDTH]);
//         $display("w_vec_reg: %d %d %d %d %d %d %d %d",  $signed(w_vec_reg[ACT_WIDTH*0 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*1 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*2 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*3 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*4 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*5 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*6 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*7 +: ACT_WIDTH]));
//         $display("--------------------------------------------------");
//     end
// end



    // ---------------------------------------------------------
    // 乗算結果ベクトル
    // ---------------------------------------------------------
    wire [MULT_W*N-1:0] mult_vec;
    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : G_MUL
            assign mult_vec[MULT_W*k +: MULT_W] =
                $signed(w_vec_reg[WEIGHT_WIDTH*k +: WEIGHT_WIDTH]) *
                // $signed(w_vec_reg[WEIGHT_WIDTH*(N-k-1) +: WEIGHT_WIDTH]) *
                $signed({1'b0, a_vec_reg [ACT_WIDTH*k +: ACT_WIDTH]});
        end
    endgenerate

    // ---------------------------------------------------------
    // 加算木
    // ---------------------------------------------------------
    localparam STAGES_NUM = $clog2(N);
    localparam ODATA_WIDTH = MULT_W + STAGES_NUM;
    // adder_tree_out の宣言を修正
    wire signed [ODATA_WIDTH-1:0] adder_tree_out;  // 1つの信号として出力を保持

    AdderTree #(
        .INPUTS_NUM (N),
        .IDATA_WIDTH(MULT_W),
        .STAGE_DEPTH(STAGE_DEPTH)
        //,.ODATA_WIDTH(ACC_W)  // ODATA_WIDTH は内部で自動計算されているため、省略可
    ) adder_tree (
        .clk  (clk),
        .reset(reset),
        .wen  (wen),
        .idata(mult_vec),
        .odata(adder_tree_out)  // 配列ではなく、単一信号として出力
    );

    // 出力の符号拡張を行う
    wire [ACC_W-1:0] tree_out_se;
    assign tree_out_se = {{(ACC_W-ODATA_WIDTH){adder_tree_out[ODATA_WIDTH-1]}}, adder_tree_out};


    // ---------------------------------------------------------
    // out_valid の遅延
    // ---------------------------------------------------------
    localparam integer SAFE_STAGE_DEPTH = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;
    localparam integer PIPE_DEPTH       = ($clog2(N)) / SAFE_STAGE_DEPTH + 1;
    wire core_valid;
    generate
        if (PIPE_DEPTH == 0) begin : G_NOP
            assign core_valid = en;
        end else begin : G_PIP
            PipelineDelay #(
                .DEPTH(PIPE_DEPTH)
                ) u_vld (
                .clk(clk), 
                .reset(reset), 
                .wen(wen), 
                .din(en), 
                .dout(core_valid)
            );
        end
    endgenerate

    // ---------------------------------------------------------
    // アキュムレータ(25回分)
    // ---------------------------------------------------------
    reg  signed [ACC_W-1:0] acc_sum;
    reg  [ADDR_W-1:0]       acc_cnt;
    wire signed [ACC_W-1:0] next_sum_w =
        (acc_cnt == {ADDR_W{1'b0}}) ? tree_out_se : (acc_sum + tree_out_se);

    always @(posedge clk) begin
        if (reset) begin
            acc_sum   <= {ACC_W{1'b0}};
            acc_cnt   <= {ADDR_W{1'b0}};
            out       <= {ACC_W{1'b0}};
            out_valid <= 1'b0;
        end else begin
            out_valid <= 1'b0;
            if (core_valid) begin
                if (acc_cnt == DEPTH-1) begin
                    out       <= next_sum_w;
                    out_valid <= 1'b1;
                    acc_sum   <= {ACC_W{1'b0}};
                    acc_cnt   <= {ADDR_W{1'b0}};
                end else begin
                    acc_sum <= next_sum_w;
                    acc_cnt <= acc_cnt + 1'b1;
                end
            end
        end
    end

endmodule

// `timescale 1ns/1ps

// module DPUfc1ch0 #(
//     parameter integer N            = 8,
//     parameter integer ACT_WIDTH    = 8,
//     parameter integer WEIGHT_WIDTH = 8,
//     parameter integer DEPTH        = 25,
//     parameter integer STAGE_DEPTH  = 3,
//     parameter integer MULT_W       = 16,
//     parameter integer ACC_W        = 32
// )(
//     input  wire                        clk,
//     input  wire                        reset,
//     input  wire                        in_valid,
//     input  wire                        wen,
//     input  wire [ACT_WIDTH*N-1:0]      a_vec,
//     output reg  signed [ACC_W-1:0]     out,
//     output reg                         out_valid
// );

//     // ---------------------------------------------------------
//     // 固定重みベクトル (内部レジスタ = ROM) -13588
//     // ---------------------------------------------------------
//     reg [WEIGHT_WIDTH*N-1:0] wmem [0:DEPTH-1];
//     // fc ch=0
//     initial begin
//         // wmem[0] = {8'sd6, 8'sd5, 8'sd7, 8'sd6, 8'sd0, 8'sd1, 8'sd3, 8'sd9};
//         // wmem[1] = {-8'sd12, 8'sd4, 8'sd4, 8'sd3, -8'sd11, -8'sd5, -8'sd3, -8'sd4};
//         // wmem[2] = {-8'sd2, 8'sd0, -8'sd8, 8'sd3, -8'sd6, -8'sd13, -8'sd9, 8'sd12};
//         // wmem[3] = {8'sd7, -8'sd2, -8'sd9, 8'sd7, 8'sd3, -8'sd2, 8'sd4, -8'sd2};
//         // wmem[4] = {-8'sd6, -8'sd7, -8'sd6, -8'sd2, -8'sd10, -8'sd8, -8'sd9, -8'sd6};
//         // wmem[5] = {-8'sd28, -8'sd11, -8'sd5, -8'sd3, 8'sd3, -8'sd25, -8'sd8, 8'sd11};
//         // wmem[6] = {8'sd11, 8'sd0, -8'sd1, 8'sd0, 8'sd1, 8'sd7, 8'sd8, 8'sd2};
//         // wmem[7] = {8'sd1, 8'sd3, 8'sd9, 8'sd10, 8'sd4, -8'sd6, -8'sd20, 8'sd0};
//         // wmem[8] = {8'sd9, 8'sd2, -8'sd2, 8'sd4, 8'sd2, 8'sd2, 8'sd3, 8'sd11};
//         // wmem[9] = {8'sd6, -8'sd2, -8'sd22, -8'sd9, -8'sd12, -8'sd3, -8'sd10, -8'sd8};
//         // wmem[10] = {8'sd6, 8'sd2, -8'sd3, -8'sd6, -8'sd4, 8'sd14, 8'sd8, 8'sd7};
//         // wmem[11] = {8'sd1, 8'sd2, 8'sd9, 8'sd11, 8'sd8, 8'sd5, 8'sd5, 8'sd9};
//         // wmem[12] = {8'sd3, -8'sd6, -8'sd1, -8'sd4, 8'sd2, -8'sd5, 8'sd1, -8'sd1};
//         // wmem[13] = {-8'sd10, -8'sd1, 8'sd5, -8'sd4, -8'sd8, 8'sd3, -8'sd2, -8'sd4};
//         // wmem[14] = {-8'sd14, -8'sd9, 8'sd9, -8'sd11, -8'sd3, 8'sd12, 8'sd3, -8'sd2};
//         // wmem[15] = {-8'sd4, -8'sd6, 8'sd8, 8'sd0, -8'sd12, 8'sd0, 8'sd2, -8'sd5};
//         // wmem[16] = {8'sd2, -8'sd6, 8'sd0, 8'sd0, -8'sd2, 8'sd1, 8'sd3, 8'sd6};
//         // wmem[17] = {-8'sd1, -8'sd12, -8'sd9, -8'sd5, 8'sd1, 8'sd0, -8'sd4, -8'sd3};
//         // wmem[18] = {8'sd3, 8'sd5, -8'sd6, 8'sd12, -8'sd1, 8'sd3, -8'sd2, -8'sd3};
//         // wmem[19] = {-8'sd7, -8'sd10, -8'sd5, 8'sd2, -8'sd3, -8'sd8, -8'sd1, -8'sd7};
//         // wmem[20] = {8'sd1, -8'sd1, 8'sd8, -8'sd11, -8'sd1, 8'sd0, -8'sd2, 8'sd0};
//         // wmem[21] = {8'sd8, 8'sd9, -8'sd3, -8'sd10, -8'sd1, 8'sd0, 8'sd11, 8'sd2};
//         // wmem[22] = {-8'sd2, -8'sd4, -8'sd5, 8'sd2, 8'sd0, -8'sd2, -8'sd3, -8'sd5};
//         // wmem[23] = {8'sd9, 8'sd3, 8'sd2, -8'sd11, 8'sd14, 8'sd18, 8'sd8, 8'sd5};
//         // wmem[24] = {-8'sd9, 8'sd3, 8'sd15, 8'sd4, -8'sd2, -8'sd20, -8'sd22, -8'sd9};

//         wmem[0] = {8'sd2, -8'sd2, 8'sd0, 8'sd2, -8'sd9, -8'sd1, -8'sd2, 8'sd6};
//         wmem[1] = {-8'sd2, -8'sd3, 8'sd2, -8'sd5, -8'sd12, 8'sd0, -8'sd9, 8'sd5};
//         wmem[2] = {-8'sd4, -8'sd7, -8'sd5, 8'sd1, -8'sd3, 8'sd1, 8'sd7, 8'sd7};
//         wmem[3] = {-8'sd5, -8'sd10, 8'sd2, -8'sd1, -8'sd10, 8'sd7, 8'sd3, 8'sd6};
//         wmem[4] = {8'sd2, -8'sd5, -8'sd6, -8'sd10, -8'sd8, 8'sd8, -8'sd2, 8'sd0};
//         wmem[5] = {8'sd0, 8'sd2, 8'sd0, -8'sd1, 8'sd6, 8'sd2, 8'sd4, 8'sd1};
//         wmem[6] = {-8'sd2, -8'sd3, 8'sd0, 8'sd5, 8'sd2, 8'sd1, -8'sd2, 8'sd3};
//         wmem[7] = {-8'sd3, -8'sd8, -8'sd2, -8'sd4, -8'sd3, 8'sd3, -8'sd6, 8'sd9};
//         wmem[8] = {-8'sd5, -8'sd1, 8'sd1, -8'sd8, -8'sd6, 8'sd9, -8'sd7, -8'sd12};
//         wmem[9] = {8'sd9, -8'sd7, 8'sd3, 8'sd3, -8'sd4, 8'sd10, -8'sd6, 8'sd4};
//         wmem[10] = {8'sd3, 8'sd1, 8'sd6, -8'sd2, 8'sd14, 8'sd4, -8'sd2, 8'sd4};
//         wmem[11] = {8'sd2, -8'sd1, -8'sd1, -8'sd4, 8'sd8, -8'sd6, -8'sd10, 8'sd3};
//         wmem[12] = {-8'sd11, 8'sd8, -8'sd12, -8'sd14, 8'sd7, -8'sd20, -8'sd8, -8'sd11};
//         wmem[13] = {8'sd14, -8'sd11, -8'sd9, -8'sd9, 8'sd1, 8'sd0, -8'sd9, -8'sd5};
//         wmem[14] = {8'sd18, -8'sd1, -8'sd5, 8'sd9, 8'sd2, 8'sd9, -8'sd6, -8'sd3};
//         wmem[15] = {8'sd8, 8'sd0, 8'sd1, -8'sd11, 8'sd9, 8'sd2, -8'sd28, -8'sd4};
//         wmem[16] = {8'sd5, -8'sd2, 8'sd0, -8'sd3, 8'sd11, -8'sd2, -8'sd11, -8'sd2};
//         wmem[17] = {-8'sd9, 8'sd0, -8'sd4, 8'sd12, 8'sd8, 8'sd4, -8'sd5, 8'sd0};
//         wmem[18] = {8'sd3, 8'sd8, -8'sd3, 8'sd3, 8'sd5, 8'sd2, -8'sd3, -8'sd8};
//         wmem[19] = {8'sd15, 8'sd9, 8'sd3, -8'sd2, 8'sd5, 8'sd2, 8'sd3, 8'sd3};
//         wmem[20] = {8'sd4, -8'sd3, 8'sd5, -8'sd4, 8'sd9, 8'sd3, -8'sd25, -8'sd6};
//         wmem[21] = {-8'sd2, -8'sd10, -8'sd6, -8'sd6, 8'sd3, 8'sd11, -8'sd8, -8'sd13};
//         wmem[22] = {-8'sd20, -8'sd1, 8'sd12, 8'sd8, -8'sd6, 8'sd6, 8'sd11, -8'sd9};
//         wmem[23] = {-8'sd22, 8'sd0, -8'sd1, 8'sd0, -8'sd1, -8'sd2, 8'sd11, 8'sd12};
//         wmem[24] = {-8'sd9, 8'sd11, 8'sd3, -8'sd12, -8'sd4, -8'sd22, 8'sd0, 8'sd7};
//     end
//     // en
//     wire en = wen & in_valid;

//     // ---------------------------------------------------------
//     // ROM用のアドレス更新
//     // ---------------------------------------------------------
//     localparam integer ADDR_W     = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
//     localparam integer SAFE_STAGE = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;

//     reg [ADDR_W-1:0] wmem_addr;
//     always @(posedge clk) begin
//         if (reset)        wmem_addr <= {ADDR_W{1'b0}};
//         else if (en)      wmem_addr <= (wmem_addr == DEPTH-1) ? {ADDR_W{1'b0}} : (wmem_addr + 1'b1);
//     end

//     // ---------------------------------------------------------
//     // 被乗算ベクトルのレジスタ
//     // ---------------------------------------------------------
//     reg [ACT_WIDTH*N-1:0]    a_vec_reg;
//     reg signed [WEIGHT_WIDTH*N-1:0] w_vec_reg;
//     always @(posedge clk) begin
//         a_vec_reg <= reset ? 0 : (en ? a_vec : a_vec_reg);
//         w_vec_reg <= reset ? 0 : (en ? wmem[wmem_addr] : w_vec_reg);
//     end

// // reg delay_valid;
// // always @(posedge clk) begin delay_valid <= in_valid; end
// // always @(posedge clk) begin
// //     if (delay_valid) begin
// //         // 直接個別の要素を表示（10進数符号なし）
// //         $display("a_vec_reg: %d %d %d %d %d %d %d %d", a_vec_reg[ACT_WIDTH*0 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*1 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*2 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*3 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*4 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*5 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*6 +: ACT_WIDTH], a_vec_reg[ACT_WIDTH*7 +: ACT_WIDTH]);
// //         $display("w_vec_reg: %d %d %d %d %d %d %d %d",  $signed(w_vec_reg[ACT_WIDTH*0 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*1 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*2 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*3 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*4 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*5 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*6 +: ACT_WIDTH]), $signed(w_vec_reg[ACT_WIDTH*7 +: ACT_WIDTH]));
// //         $display("--------------------------------------------------");
// //     end
// // end



//     // ---------------------------------------------------------
//     // 乗算結果ベクトル
//     // ---------------------------------------------------------
//     wire [MULT_W*N-1:0] mult_vec;
//     genvar k;
//     generate
//         for (k = 0; k < N; k = k + 1) begin : G_MUL
//             assign mult_vec[MULT_W*k +: MULT_W] =
//                 $signed(w_vec_reg[WEIGHT_WIDTH*k +: WEIGHT_WIDTH]) *
//                 // $signed(w_vec_reg[WEIGHT_WIDTH*(N-k-1) +: WEIGHT_WIDTH]) *
//                 $signed({1'b0, a_vec_reg [ACT_WIDTH*k +: ACT_WIDTH]});
//         end
//     endgenerate

//     // ---------------------------------------------------------
//     // 加算木
//     // ---------------------------------------------------------
//     localparam STAGES_NUM = $clog2(N);
//     localparam ODATA_WIDTH = MULT_W + STAGES_NUM;
//     // adder_tree_out の宣言を修正
//     wire signed [ODATA_WIDTH-1:0] adder_tree_out;  // 1つの信号として出力を保持

//     AdderTree #(
//         .INPUTS_NUM (N),
//         .IDATA_WIDTH(MULT_W),
//         .STAGE_DEPTH(STAGE_DEPTH)
//         //,.ODATA_WIDTH(ACC_W)  // ODATA_WIDTH は内部で自動計算されているため、省略可
//     ) adder_tree (
//         .clk  (clk),
//         .reset(reset),
//         .wen  (wen),
//         .idata(mult_vec),
//         .odata(adder_tree_out)  // 配列ではなく、単一信号として出力
//     );

//     // 出力の符号拡張を行う
//     wire [ACC_W-1:0] tree_out_se;
//     assign tree_out_se = {{(ACC_W-ODATA_WIDTH){adder_tree_out[ODATA_WIDTH-1]}}, adder_tree_out};


//     // ---------------------------------------------------------
//     // out_valid の遅延
//     // ---------------------------------------------------------
//     localparam integer SAFE_STAGE_DEPTH = (STAGE_DEPTH < 1) ? 1 : STAGE_DEPTH;
//     localparam integer PIPE_DEPTH       = ($clog2(N)) / SAFE_STAGE_DEPTH + 1;
//     wire core_valid;
//     generate
//         if (PIPE_DEPTH == 0) begin : G_NOP
//             assign core_valid = en;
//         end else begin : G_PIP
//             PipelineDelay #(
//                 .DEPTH(PIPE_DEPTH)
//                 ) u_vld (
//                 .clk(clk), 
//                 .reset(reset), 
//                 .wen(wen), 
//                 .din(en), 
//                 .dout(core_valid)
//             );
//         end
//     endgenerate

//     // ---------------------------------------------------------
//     // アキュムレータ(25回分)
//     // ---------------------------------------------------------
//     reg  signed [ACC_W-1:0] acc_sum;
//     reg  [ADDR_W-1:0]       acc_cnt;
//     wire signed [ACC_W-1:0] next_sum_w =
//         (acc_cnt == {ADDR_W{1'b0}}) ? tree_out_se : (acc_sum + tree_out_se);

//     always @(posedge clk) begin
//         if (reset) begin
//             acc_sum   <= {ACC_W{1'b0}};
//             acc_cnt   <= {ADDR_W{1'b0}};
//             out       <= {ACC_W{1'b0}};
//             out_valid <= 1'b0;
//         end else begin
//             out_valid <= 1'b0;
//             if (core_valid) begin
//                 if (acc_cnt == DEPTH-1) begin
//                     out       <= next_sum_w;
//                     out_valid <= 1'b1;
//                     acc_sum   <= {ACC_W{1'b0}};
//                     acc_cnt   <= {ADDR_W{1'b0}};
//                 end else begin
//                     acc_sum <= next_sum_w;
//                     acc_cnt <= acc_cnt + 1'b1;
//                 end
//             end
//         end
//     end

// endmodule