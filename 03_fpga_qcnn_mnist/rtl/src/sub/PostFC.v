// File: PostFC_100MHz.v  (mul 2-cycle version)
// WNS 改善版: 32x32 乗算を 16x32×2 回に分解（レイテンシ +1）
`timescale 1ns/1ps

module PostFC (
  input  wire               clk,
  input  wire               reset,        // Active-High sync reset
  input  wire               in_valid,

  // C: rq = requantize_spec(sum, M, r)
  input  wire signed [31:0] acc_i,        // sum (from FC MAC)
  input  wire       [31:0]  rq_mult,      // M (unsigned)
  input  wire       [5:0]   rq_rshift,    // r: 0..63
  input  wire signed [31:0] bias_i,       // bias (signed)

  output reg                out_valid,
  output reg  signed [31:0] out_i32       // rq + bias（最終層は signed 出力）
);

  // -------- s0a: 入力整形（|acc|/sign/r/mult/bias） -----------------------
  reg        v0a;
  reg        sign_s0a;
  reg [31:0] mag_s0a, mult_s0a;
  reg [5:0]  r_s0a;
  reg signed [31:0] bias_s0a;
  always @(posedge clk) begin
    if (reset) begin
      v0a<=1'b0; sign_s0a<=1'b0; mag_s0a<=32'd0; mult_s0a<=32'd0; r_s0a<=6'd0; bias_s0a<=32'sd0;
    end else begin
      v0a      <= in_valid;
      sign_s0a <= acc_i[31];
      mag_s0a  <= acc_i[31] ? (~acc_i + 32'sd1) : acc_i;
      mult_s0a <= rq_mult;
      r_s0a    <= rq_rshift;
      bias_s0a <= bias_i;
    end
  end

  // -------- s0b: 乗算入力 もう一段 ----------------------------------------
  reg        v0b;
  reg        sign_s0b;
  reg [31:0] mag_s0b, mult_s0b;
  reg [5:0]  r_s0b;
  reg signed [31:0] bias_s0b;
  always @(posedge clk) begin
    if (reset) begin
      v0b<=1'b0; sign_s0b<=1'b0; mag_s0b<=32'd0; mult_s0b<=32'd0; r_s0b<=6'd0; bias_s0b<=32'sd0;
    end else begin
      v0b      <= v0a;
      sign_s0b <= sign_s0a;
      mag_s0b  <= mag_s0a;
      mult_s0b <= mult_s0a;
      r_s0b    <= r_s0a;
      bias_s0b <= bias_s0a;
    end
  end

  // -------- s0c: 乗算直前レジスタ ----------------------------------------
  reg        v0c;
  reg        sign_s0c;
  reg [31:0] mag_s0c, mult_s0c;
  reg [5:0]  r_s0c;
  reg signed [31:0] bias_s0c;
  always @(posedge clk) begin
    if (reset) begin
      v0c<=1'b0; sign_s0c<=1'b0; mag_s0c<=32'd0; mult_s0c<=32'd0; r_s0c<=6'd0; bias_s0c<=32'sd0;
    end else begin
      v0c      <= v0b;
      sign_s0c <= sign_s0b;
      mag_s0c  <= mag_s0b;
      mult_s0c <= mult_s0b;
      r_s0c    <= r_s0b;
      bias_s0c <= bias_s0b;
    end
  end

  // ====== 変更点ここから：乗算を 2 サイクル化（s0d0 → s0d1） =============

  // -------- s0d0: 部分積 (low16 * 32) とラウンド定数の前計算 ------------
  (* multstyle = "dsp" *) reg [47:0] pp_lo_s0d0;   // 16x32 -> 48bit
  reg [15:0] x_hi_s0d0;
  reg [31:0] mult_s0d0;
  reg [63:0] round_s0d0;
  reg        v0d0;
  reg        sign_s0d0;
  reg [5:0]  r_s0d0;
  reg signed [31:0] bias_s0d0;
  always @(posedge clk) begin
    if (reset) begin
      v0d0<=1'b0; sign_s0d0<=1'b0;
      pp_lo_s0d0<=48'd0; x_hi_s0d0<=16'd0; mult_s0d0<=32'd0;
      round_s0d0<=64'd0; r_s0d0<=6'd0; bias_s0d0<=32'sd0;
    end else begin
      v0d0      <= v0c;
      sign_s0d0 <= sign_s0c;
      r_s0d0    <= r_s0c;
      bias_s0d0 <= bias_s0c;

      // 入力 32bit を [hi:lo] に分割
      x_hi_s0d0 <= mag_s0c[31:16];
      mult_s0d0 <= mult_s0c;

      // 低位部分積: (lo16 * 32) → 48bit
      pp_lo_s0d0 <= $unsigned(mag_s0c[15:0]) * $unsigned(mult_s0c);

      // 丸め定数（次段まで保持）
      round_s0d0<= (r_s0c==0) ? 64'd0 : (64'd1 << (r_s0c-1));
    end
  end

  // -------- s0d1: 部分積 (hi16 * 32) と合成 → 64bit 積 -------------------
  (* multstyle = "dsp" *) reg [47:0] pp_hi_s0d1;   // 16x32 -> 48bit
  reg [63:0] prod_s0d1;
  reg        v0d1;
  reg        sign_s0d1;
  reg [63:0] round_s0d1;
  reg [5:0]  r_s0d1;
  reg signed [31:0] bias_s0d1;
  always @(posedge clk) begin
    if (reset) begin
      v0d1<=1'b0; sign_s0d1<=1'b0;
      pp_hi_s0d1<=48'd0; prod_s0d1<=64'd0;
      round_s0d1<=64'd0; r_s0d1<=6'd0; bias_s0d1<=32'sd0;
    end else begin
      v0d1      <= v0d0;
      sign_s0d1 <= sign_s0d0;
      r_s0d1    <= r_s0d0;
      bias_s0d1 <= bias_s0d0;
      round_s0d1<= round_s0d0;

      // 高位部分積
      pp_hi_s0d1 <= $unsigned(x_hi_s0d0) * $unsigned(mult_s0d0);

      // 合成： (lo * 1) + (hi * 2^16)
      // pp_lo_s0d0: 48bit -> 配置 [47:0]
      // pp_hi_s0d1: 48bit -> 左 16bit シフトして [63:16] に重畳
      prod_s0d1 <= {16'd0, pp_lo_s0d0} + ({pp_hi_s0d1, 16'd0});
    end
  end

  // ====== 以降は従来通り（段数が +1 される） =============================

  // -------- s1a: +round だけ ---------------------------------------------
  reg        v1a;
  reg        sign_s1a;
  reg [63:0] sum_s1a;
  reg [5:0]  r_s1a;
  reg signed [31:0] bias_s1a;
  always @(posedge clk) begin
    if (reset) begin
      v1a<=1'b0; sign_s1a<=1'b0; sum_s1a<=64'd0; r_s1a<=6'd0; bias_s1a<=32'sd0;
    end else begin
      v1a      <= v0d1;
      sign_s1a <= sign_s0d1;
      r_s1a    <= r_s0d1;
      bias_s1a <= bias_s0d1;
      sum_s1a  <= prod_s0d1 + round_s0d1; // r==0 でも round=0 なので互換
    end
  end

  // -------- s1b: 論理右シフトだけ ----------------------------------------
  reg        v1b;
  reg        sign_s1b;
  reg [63:0] q_u_s1b;
  reg signed [31:0] bias_s1b;
  always @(posedge clk) begin
    if (reset) begin
      v1b<=1'b0; sign_s1b<=1'b0; q_u_s1b<=64'd0; bias_s1b<=32'sd0;
    end else begin
      v1b      <= v1a;
      sign_s1b <= sign_s1a;
      bias_s1b <= bias_s1a;
      q_u_s1b  <= (r_s1a==0) ? sum_s1a : (sum_s1a >> r_s1a);
    end
  end

  // -------- s2: 符号復元（65bit） ----------------------------------------
  reg        v2;
  reg signed [64:0] s65_s2;
  reg signed [31:0] bias_s2;
  always @(posedge clk) begin
    if (reset) begin
      v2<=1'b0; s65_s2<=65'sd0; bias_s2<=32'sd0;
    end else begin
      v2      <= v1b;
      bias_s2 <= bias_s1b;
      s65_s2  <= sign_s1b ? -$signed({1'b0,q_u_s1b}) : $signed({1'b0,q_u_s1b});
    end
  end

  // -------- s3: 32bit 飽和 -----------------------------------------------
  reg        v3;
  reg signed [31:0] rq32_s3;
  reg signed [31:0] bias_s3;
  always @(posedge clk) begin
    if (reset) begin
      v3<=1'b0; rq32_s3<=32'sd0; bias_s3<=32'sd0;
    end else begin
      v3      <= v2;
      bias_s3 <= bias_s2;
      if      (s65_s2 >  65'sd2147483647) rq32_s3 <= 32'sh7fffffff;
      else if (s65_s2 < -65'sd2147483648) rq32_s3 <= 32'sh80000000;
      else                                 rq32_s3 <= s65_s2[31:0];
    end
  end

  // -------- s4: +bias → 出力（元仕様を厳守：飽和後にbias） ----------------
  always @(posedge clk) begin
    if (reset) begin
      out_valid <= 1'b0; out_i32 <= 32'sd0;
    end else begin
      out_valid <= v3;  // 総レイテンシ: 既存+1（s0d0, s0d1 が 2 段）
      if (v3) out_i32 <= rq32_s3 + bias_s3;
    end
  end

endmodule


// // File: PostFC_100MHz.v
// `timescale 1ns/1ps

// module PostFC (
//   input  wire               clk,
//   input  wire               reset,        // Active-High sync reset
//   input  wire               in_valid,

//   // C: rq = requantize_spec(sum, M, r)
//   input  wire signed [31:0] acc_i,        // sum (from FC MAC)
//   input  wire       [31:0]  rq_mult,      // M (unsigned)
//   input  wire       [5:0]   rq_rshift,    // r: 0..63
//   input  wire signed [31:0] bias_i,       // bias (signed)

//   output reg                out_valid,
//   output reg  signed [31:0] out_i32       // rq + bias（最終層は signed 出力）
// );

//   // -------- s0a: 入力整形（|acc|/sign/r/mult/bias） -----------------------
//   reg        v0a;
//   reg        sign_s0a;
//   reg [31:0] mag_s0a, mult_s0a;
//   reg [5:0]  r_s0a;
//   reg signed [31:0] bias_s0a;
//   always @(posedge clk) begin
//     if (reset) begin
//       v0a<=1'b0; sign_s0a<=1'b0; mag_s0a<=32'd0; mult_s0a<=32'd0; r_s0a<=6'd0; bias_s0a<=32'sd0;
//     end else begin
//       v0a      <= in_valid;
//       sign_s0a <= acc_i[31];
//       mag_s0a  <= acc_i[31] ? (~acc_i + 32'sd1) : acc_i;
//       mult_s0a <= rq_mult;
//       r_s0a    <= rq_rshift;
//       bias_s0a <= bias_i;
//     end
//   end

//   // -------- s0b: 乗算入力 もう一段 ----------------------------------------
//   reg        v0b;
//   reg        sign_s0b;
//   reg [31:0] mag_s0b, mult_s0b;
//   reg [5:0]  r_s0b;
//   reg signed [31:0] bias_s0b;
//   always @(posedge clk) begin
//     if (reset) begin
//       v0b<=1'b0; sign_s0b<=1'b0; mag_s0b<=32'd0; mult_s0b<=32'd0; r_s0b<=6'd0; bias_s0b<=32'sd0;
//     end else begin
//       v0b      <= v0a;
//       sign_s0b <= sign_s0a;
//       mag_s0b  <= mag_s0a;
//       mult_s0b <= mult_s0a;
//       r_s0b    <= r_s0a;
//       bias_s0b <= bias_s0a;
//     end
//   end

//   // -------- s0c: 乗算直前レジスタ ----------------------------------------
//   reg        v0c;
//   reg        sign_s0c;
//   reg [31:0] mag_s0c, mult_s0c;
//   reg [5:0]  r_s0c;
//   reg signed [31:0] bias_s0c;
//   always @(posedge clk) begin
//     if (reset) begin
//       v0c<=1'b0; sign_s0c<=1'b0; mag_s0c<=32'd0; mult_s0c<=32'd0; r_s0c<=6'd0; bias_s0c<=32'sd0;
//     end else begin
//       v0c      <= v0b;
//       sign_s0c <= sign_s0b;
//       mag_s0c  <= mag_s0b;
//       mult_s0c <= mult_s0b;
//       r_s0c    <= r_s0b;
//       bias_s0c <= bias_s0b;
//     end
//   end

//   // -------- s0d: DSP 乗算 + 丸め定数 --------------------------------------
//   (* multstyle = "dsp" *) reg [63:0] prod_s0d;
//   reg [63:0] round_s0d;
//   reg        v0d;
//   reg        sign_s0d;
//   reg [5:0]  r_s0d;
//   reg signed [31:0] bias_s0d;
//   always @(posedge clk) begin
//     if (reset) begin
//       v0d<=1'b0; sign_s0d<=1'b0; prod_s0d<=64'd0; round_s0d<=64'd0; r_s0d<=6'd0; bias_s0d<=32'sd0;
//     end else begin
//       v0d      <= v0c;
//       sign_s0d <= sign_s0c;
//       prod_s0d <= $unsigned(mag_s0c) * $unsigned(mult_s0c);
//       round_s0d<= (r_s0c==0) ? 64'd0 : (64'd1 << (r_s0c-1));
//       r_s0d    <= r_s0c;
//       bias_s0d <= bias_s0c;
//     end
//   end

//   // -------- s1a: +round だけ ---------------------------------------------
//   reg        v1a;
//   reg        sign_s1a;
//   reg [63:0] sum_s1a;
//   reg [5:0]  r_s1a;
//   reg signed [31:0] bias_s1a;
//   always @(posedge clk) begin
//     if (reset) begin
//       v1a<=1'b0; sign_s1a<=1'b0; sum_s1a<=64'd0; r_s1a<=6'd0; bias_s1a<=32'sd0;
//     end else begin
//       v1a      <= v0d;
//       sign_s1a <= sign_s0d;
//       r_s1a    <= r_s0d;
//       bias_s1a <= bias_s0d;
//       sum_s1a  <= prod_s0d + round_s0d; // r==0のときround=0なので動作互換
//     end
//   end

//   // -------- s1b: 論理右シフトだけ ----------------------------------------
//   reg        v1b;
//   reg        sign_s1b;
//   reg [63:0] q_u_s1b;
//   reg signed [31:0] bias_s1b;
//   always @(posedge clk) begin
//     if (reset) begin
//       v1b<=1'b0; sign_s1b<=1'b0; q_u_s1b<=64'd0; bias_s1b<=32'sd0;
//     end else begin
//       v1b      <= v1a;
//       sign_s1b <= sign_s1a;
//       bias_s1b <= bias_s1a;
//       q_u_s1b  <= (r_s1a==0) ? sum_s1a : (sum_s1a >> r_s1a);
//     end
//   end

//   // -------- s2: 符号復元（65bit） ----------------------------------------
//   reg        v2;
//   reg signed [64:0] s65_s2;
//   reg signed [31:0] bias_s2;
//   always @(posedge clk) begin
//     if (reset) begin
//       v2<=1'b0; s65_s2<=65'sd0; bias_s2<=32'sd0;
//     end else begin
//       v2      <= v1b;
//       bias_s2 <= bias_s1b;
//       s65_s2  <= sign_s1b ? -$signed({1'b0,q_u_s1b}) : $signed({1'b0,q_u_s1b});
//     end
//   end

//   // -------- s3: 32bit 飽和 -----------------------------------------------
//   reg        v3;
//   reg signed [31:0] rq32_s3;
//   reg signed [31:0] bias_s3;
//   always @(posedge clk) begin
//     if (reset) begin
//       v3<=1'b0; rq32_s3<=32'sd0; bias_s3<=32'sd0;
//     end else begin
//       v3      <= v2;
//       bias_s3 <= bias_s2;
//       if      (s65_s2 >  65'sd2147483647) rq32_s3 <= 32'sh7fffffff;
//       else if (s65_s2 < -65'sd2147483648) rq32_s3 <= 32'sh80000000;
//       else                                 rq32_s3 <= s65_s2[31:0];
//     end
//   end

//   // -------- s4: +bias → 出力（元仕様を厳守：飽和後にbias） ----------------
//   always @(posedge clk) begin
//     if (reset) begin
//       out_valid <= 1'b0; out_i32 <= 32'sd0;
//     end else begin
//       out_valid <= v3;  // 総レイテンシ: s0a,s0b,s0c,s0d,s1a,s1b,s2,s3,s4 の計9段相当
//       if (v3) out_i32 <= rq32_s3 + bias_s3;
//     end
//   end

// endmodule