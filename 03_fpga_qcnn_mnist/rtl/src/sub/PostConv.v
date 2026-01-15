// // File: PostConv_100MHz.v
// `timescale 1ns/1ps

// module PostConv #(
//     parameter OUT_U8 = 1
// )(
//     input  wire               clk,
//     input  wire               reset,       // Active-High synchronous reset
//     input  wire               in_valid,
//     input  wire signed [31:0] acc_i,       // from DPU (signed)
//     input  wire       [31:0]  rq_mult,     // unsigned
//     input  wire       [5:0]   rq_rshift,   // 0..63
//     input  wire signed [31:0] bias_i,

//     output reg                out_valid,
//     output reg        [7:0]   out_u8
// );

//   // ---------------- s0a: 入力整形(|acc|/sign/r/mult/bias) ----------------
//   reg         v0a;
//   reg         sign_s0a;
//   reg [31:0]  mag_s0a, mult_s0a;
//   reg  [5:0]  r_s0a;
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

//   // ---------------- s0b: 乗算入力 もう一段（DSP前の配線短縮） ------------
//   reg         v0b;
//   reg         sign_s0b;
//   reg [31:0]  mag_s0b, mult_s0b;
//   reg  [5:0]  r_s0b;
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

//   // ---------------- s1a: 32x32 乗算（DSP） -------------------------------
//   reg         v1a;
//   reg         sign_s1a;
//   reg  [5:0]  r_s1a;
//   reg signed [31:0] bias_s1a;
//   // DSP 利用と再レジスタ許可（デバイス/バージョンにより最適化が働く）
//   (* multstyle = "dsp" *)
//   reg [63:0] prod_s1a;
//   always @(posedge clk) begin
//     if (reset) begin
//       v1a<=1'b0; sign_s1a<=1'b0; r_s1a<=6'd0; bias_s1a<=32'sd0; prod_s1a<=64'd0;
//     end else begin
//       v1a      <= v0b;
//       sign_s1a <= sign_s0b;
//       r_s1a    <= r_s0b;
//       bias_s1a <= bias_s0b;
//       prod_s1a <= $unsigned(mag_s0b) * $unsigned(mult_s0b);
//     end
//   end

//   // ---------------- s1b: 乗算出力FF + 丸め定数を前段で生成 ---------------
//   reg         v1b;
//   reg         sign_s1b;
//   reg  [5:0]  r_s1b;
//   reg signed [31:0] bias_s1b;
//   reg [63:0] prod_s1b;
//   reg [63:0] round_s1b; // rに基づく丸め定数（r==0なら0）
//   always @(posedge clk) begin
//     if (reset) begin
//       v1b<=1'b0; sign_s1b<=1'b0; r_s1b<=6'd0; bias_s1b<=32'sd0; prod_s1b<=64'd0; round_s1b<=64'd0;
//     end else begin
//       v1b      <= v1a;
//       sign_s1b <= sign_s1a;
//       r_s1b    <= r_s1a;
//       bias_s1b <= bias_s1a;
//       prod_s1b <= prod_s1a;
//       round_s1b<= (r_s1a==0) ? 64'd0 : (64'd1 << (r_s1a-1));
//     end
//   end

//   // ---------------- s2a: 丸め定数生成済 → 加算のみ（無シフト） -----------
//   reg         v2a;
//   reg         sign_s2a;
//   reg  [5:0]  r_s2a;
//   reg signed [31:0] bias_s2a;
//   reg [63:0] sum_s2a;   // prod + round
//   always @(posedge clk) begin
//     if (reset) begin
//       v2a<=1'b0; sign_s2a<=1'b0; r_s2a<=6'd0; bias_s2a<=32'sd0; sum_s2a<=64'd0;
//     end else begin
//       v2a      <= v1b;
//       sign_s2a <= sign_s1b;
//       r_s2a    <= r_s1b;
//       bias_s2a <= bias_s1b;
//       sum_s2a  <= prod_s1b + round_s1b; // ここは加算のみ
//     end
//   end

//   // ---------------- s2b: 論理右シフトのみ -------------------------------
//   reg         v2b;
//   reg         sign_s2b;
//   reg signed [31:0] bias_s2b;
//   reg [63:0] q_u_s2b;
//   always @(posedge clk) begin
//     if (reset) begin
//       v2b<=1'b0; sign_s2b<=1'b0; bias_s2b<=32'sd0; q_u_s2b<=64'd0;
//     end else begin
//       v2b      <= v2a;
//       sign_s2b <= sign_s2a;
//       bias_s2b <= bias_s2a;
//       q_u_s2b  <= (r_s2a==0) ? sum_s2a : (sum_s2a >> r_s2a);
//     end
//   end

//   // ---------------- s3: 符号復元 + bias 事前符号拡張（65bit） -------------
//   reg         v3;
//   reg signed [64:0] s65_s3;
//   reg signed [64:0] bias65_s3;
//   always @(posedge clk) begin
//     if (reset) begin
//       v3<=1'b0; s65_s3<=65'sd0; bias65_s3<=65'sd0;
//     end else begin
//       v3       <= v2b;
//       s65_s3   <= sign_s2b ? -$signed({1'b0, q_u_s2b}) : $signed({1'b0, q_u_s2b});
//       bias65_s3<= $signed({{33{bias_s2b[31]}}, bias_s2b}); // s4での加算を軽くするため前段で用意
//     end
//   end

//   // ---------------- s4: +bias（65bit） -----------------------------------
//   reg         v4;
//   reg signed [64:0] z65_s4;
//   always @(posedge clk) begin
//     if (reset) begin
//       v4<=1'b0; z65_s4<=65'sd0;
//     end else begin
//       v4     <= v3;
//       z65_s4 <= s65_s3 + bias65_s3;  // 加算のみ
//     end
//   end

//   // ---------------- s5: ReLU + clamp → 出力 -------------------------------
//   // 総レイテンシ: 9サイクル（s0a,s0b,s1a,s1b,s2a,s2b,s3,s4,s5）
//   always @(posedge clk) begin
//     if (reset) begin
//       out_valid <= 1'b0;
//       out_u8    <= 8'd0;
//     end else begin
//       out_valid <= v4;
//       if (!v4) begin
//         // hold
//       end else if (z65_s4 <= 65'sd0) begin
//         out_u8 <= 8'd0;
//       end else if (z65_s4 >= 65'sd255) begin
//         out_u8 <= 8'd255;
//       end else begin
//         out_u8 <= z65_s4[7:0];
//       end
//     end
//   end

// endmodule


// File: PostConv_100MHz.v
`timescale 1ns/1ps

module PostConv #(
    parameter OUT_U8 = 1
)(
    input  wire               clk,
    input  wire               reset,       // Active-High synchronous reset
    input  wire               in_valid,
    input  wire signed [31:0] acc_i,       // from DPU (signed)
    input  wire       [31:0]  rq_mult,     // unsigned
    input  wire       [5:0]   rq_rshift,   // 0..63
    input  wire signed [31:0] bias_i,

    output reg                out_valid,
    output reg        [7:0]   out_u8
);

  // ---------------- s0a: 入力整形(|acc|/sign/r/mult/bias) ----------------
  reg         v0a;
  reg         sign_s0a;
  reg [31:0]  mag_s0a, mult_s0a;
  reg  [5:0]  r_s0a;
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

  // ---------------- s0b: 乗算入力 もう一段（DSP前の配線短縮） ------------
  reg         v0b;
  reg         sign_s0b;
  reg [31:0]  mag_s0b, mult_s0b;
  reg  [5:0]  r_s0b;
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


  // ---------------- s1a: 32x32 乗算（DSP） -------------------------------
  reg         v1a;
  reg         sign_s1a;
  reg  [5:0]  r_s1a;
  reg signed [31:0] bias_s1a;
  (* multstyle = "dsp" *) reg [63:0] prod_s1a;
  always @(posedge clk) begin
    if (reset) begin
      v1a<=1'b0; sign_s1a<=1'b0; r_s1a<=6'd0; bias_s1a<=32'sd0; prod_s1a<=64'd0;
    end else begin
      v1a      <= v0b;
      sign_s1a <= sign_s0b;
      r_s1a    <= r_s0b;
      bias_s1a <= bias_s0b;
      prod_s1a <= $unsigned(mag_s0b) * $unsigned(mult_s0b);
    end
  end

  // ---------------- s1b: 乗算出力を更に1段（DSP出力側FF） ----------------
  reg         v1b;
  reg         sign_s1b;
  reg  [5:0]  r_s1b;
  reg signed [31:0] bias_s1b;
  reg [63:0] prod_s1b;
  always @(posedge clk) begin
    if (reset) begin
      v1b<=1'b0; sign_s1b<=1'b0; r_s1b<=6'd0; bias_s1b<=32'sd0; prod_s1b<=64'd0;
    end else begin
      v1b      <= v1a;
      sign_s1b <= sign_s1a;
      r_s1b    <= r_s1a;
      bias_s1b <= bias_s1a;
      prod_s1b <= prod_s1a;
    end
  end

  // ---------------- s2a: 丸め定数生成 + 加算（まだ無シフト） -------------
  reg         v2a;
  reg         sign_s2a;
  reg  [5:0]  r_s2a;
  reg signed [31:0] bias_s2a;
  reg [63:0] sum_s2a;   // prod + round
  always @(posedge clk) begin
    if (reset) begin
      v2a<=1'b0; sign_s2a<=1'b0; r_s2a<=6'd0; bias_s2a<=32'sd0; sum_s2a<=64'd0;
    end else begin
      v2a      <= v1b;
      sign_s2a <= sign_s1b;
      r_s2a    <= r_s1b;
      bias_s2a <= bias_s1b;
      // r==0 のとき丸め0（動作互換）
      sum_s2a  <= (r_s1b==0) ? prod_s1b : (prod_s1b + (64'd1 << (r_s1b-1)));
    end
  end

  // ---------------- s2b: 論理右シフトのみ -------------------------------
  reg         v2b;
  reg         sign_s2b;
  reg signed [31:0] bias_s2b;
  reg [63:0] q_u_s2b;
  always @(posedge clk) begin
    if (reset) begin
      v2b<=1'b0; sign_s2b<=1'b0; bias_s2b<=32'sd0; q_u_s2b<=64'd0;
    end else begin
      v2b      <= v2a;
      sign_s2b <= sign_s2a;
      bias_s2b <= bias_s2a;
      q_u_s2b  <= (r_s2a==0) ? sum_s2a : (sum_s2a >> r_s2a);
    end
  end

  // ---------------- s3: 符号復元のみ（65bit） -----------------------------
  reg         v3;
  reg signed [64:0] s65_s3;
  reg signed [31:0] bias_s3;
  always @(posedge clk) begin
    if (reset) begin
      v3<=1'b0; s65_s3<=65'sd0; bias_s3<=32'sd0;
    end else begin
      v3      <= v2b;
      bias_s3 <= bias_s2b;
      s65_s3  <= sign_s2b ? -$signed({1'b0, q_u_s2b}) : $signed({1'b0, q_u_s2b});
    end
  end

  // ---------------- s4: +bias（65bit） -----------------------------------
  reg         v4;
  reg signed [64:0] z65_s4;
  always @(posedge clk) begin
    if (reset) begin
      v4<=1'b0; z65_s4<=65'sd0;
    end else begin
      v4     <= v3;
      z65_s4 <= s65_s3 + $signed({{33{bias_s3[31]}}, bias_s3});
    end
  end

  // ---------------- s5: ReLU + clamp → 出力 -------------------------------
  always @(posedge clk) begin
    if (reset) begin
      out_valid <= 1'b0;
      out_u8    <= 8'd0;
    end else begin
      out_valid <= v4; // 総レイテンシ: 6サイクル（s0a,s0b,s1a,s1b,s2a,s2b,s3,s4,s5で実質9段の計算分離）
      if (!v4) begin
        // hold
      end else if (z65_s4 <= 65'sd0) begin
        out_u8 <= 8'd0;
      end else if (z65_s4 >= 65'sd255) begin
        out_u8 <= 8'd255;
      end else begin
        out_u8 <= z65_s4[7:0];
      end
    end
  end

endmodule