`timescale 1ns/1ps

module requant #(
    // Dimensions
    parameter integer PE_NUM    = 32,
    parameter integer ACC_SIZE  = 16,       // int16 inputs
    parameter integer MUL_PARL  = 32,       // 32 for speed
    parameter integer WIDTH     = 4,        // uint4 outputs
    
    // Hardcoded Quantization Parameters (Override at Instantiation)
    parameter signed [11:0] SCALE_VAL = 12'sd396, // Default (e.g. FC1)
    parameter integer       SHIFT_VAL = 15,       // Default
    parameter integer       ZP_VAL    = 0         // Default
)(
    input  wire                         clk,
    input  wire                         reset,

    // Data Path
    input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,     // int16 lanes
    input  wire                         in_valid,

    output reg  [WIDTH*PE_NUM-1:0]      out_vec,    // uint4 lanes
    output reg                          out_valid
);

    // ------------------------------------------------------------
    // Pipeline Depth Calculation
    // ------------------------------------------------------------
    localparam integer DEPTH = (PE_NUM + MUL_PARL - 1) / MUL_PARL;

    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction

    localparam integer IDX_W = (DEPTH <= 1) ? 1 : clog2(DEPTH);
    localparam integer GLB_W = ((DEPTH*MUL_PARL) <= 1) ? 1 : clog2(DEPTH*MUL_PARL);

    // ------------------------------------------------------------
    // Control (no ready/valid handshake)
    // ------------------------------------------------------------
    reg busy;
    wire accept = in_valid && !busy;

    // issue_cnt = 次に処理するチャンクidx（busy中のみ有効）
    reg [IDX_W-1:0] issue_cnt;

    // このサイクルに Stage1 へ投入するか
    wire fire0 = accept || busy;

    // このサイクルに処理するチャンクidx
    wire [IDX_W-1:0] idx0_w = accept ? {IDX_W{1'b0}} : issue_cnt;

    // このサイクルに参照する入力ベクタ
    // (accept の最初のチャンクは in_vec を直接使用してゼロ化を防止)
    wire [ACC_SIZE*PE_NUM-1:0] x_vec0_w = accept ? in_vec : x_vec_r;

    // ------------------------------------------------------------
    // Pipeline Registers
    // ------------------------------------------------------------
    // Input capture (for chunks after the first)
    reg [ACC_SIZE*PE_NUM-1:0] x_vec_r;

    // Stage 1: Multiply
    reg [28*MUL_PARL-1:0]     mul_vec_r;
    reg [IDX_W-1:0]           idx1;
    reg                       v1;

    // Stage 2: Round & Shift
    reg [28*MUL_PARL-1:0]     rnd_vec_r;
    reg [IDX_W-1:0]           idx2;
    reg                       v2;

    // Stage 3: Add ZP & Clip
    reg [WIDTH*MUL_PARL-1:0]  q_vec_r;
    reg [IDX_W-1:0]           idx3;
    reg                       v3;

    reg out_valid_d;

    // Helper to extract 16-bit lane from arbitrary vector
    function automatic [15:0] get_lane_val;
        input [ACC_SIZE*PE_NUM-1:0] vec;
        input integer lane;
        begin
            get_lane_val = vec[ACC_SIZE*lane +: ACC_SIZE];
        end
    endfunction

    // ============================================================
    // Stage 1 Combinational: Multiply
    // ============================================================
    wire [28*MUL_PARL-1:0] mul_vec_w;

    genvar i;
    generate
        for (i = 0; i < MUL_PARL; i = i + 1) begin : GEN_MUL
            wire [GLB_W-1:0]     global_lane_idx;
            wire signed [15:0]   x_val;
            wire signed [27:0]   mul_res;

            assign global_lane_idx = ({{(GLB_W-IDX_W){1'b0}}, idx0_w} * MUL_PARL) + i[GLB_W-1:0];

            assign x_val = (global_lane_idx < PE_NUM) ?
                           $signed(get_lane_val(x_vec0_w, global_lane_idx)) : 16'sd0;

            // int16 * int12 = 28bit
            assign mul_res = x_val * SCALE_VAL;

            assign mul_vec_w[28*i +: 28] = mul_res;
        end
    endgenerate

    // ============================================================
    // Stage 2 Combinational: Rounding Add (Half Up)
    // ============================================================
    wire [28*MUL_PARL-1:0] rnd_vec_w;

    localparam signed [27:0] ROUND_BIAS =
        (SHIFT_VAL == 0) ? 28'sd0 : (28'sd1 <<< (SHIFT_VAL - 1));

    genvar j;
    generate
        for (j = 0; j < MUL_PARL; j = j + 1) begin : GEN_RND
            wire signed [27:0] m_val;
            wire signed [27:0] r_val;

            assign m_val = $signed(mul_vec_r[28*j +: 28]);
            assign r_val = m_val + ROUND_BIAS;

            assign rnd_vec_w[28*j +: 28] = r_val;
        end
    endgenerate

    // ============================================================
    // Stage 3 Combinational: Shift + Add ZP + Clip
    // ============================================================
    wire [WIDTH*MUL_PARL-1:0] out_chunk_w;

    genvar k;
    generate
        for (k = 0; k < MUL_PARL; k = k + 1) begin : GEN_QUANT
            wire signed [27:0] r_val;
            wire signed [27:0] shifted;
            wire signed [28:0] with_zp;
            wire [3:0]         clipped;

            assign r_val   = $signed(rnd_vec_r[28*k +: 28]);
            assign shifted = r_val >>> SHIFT_VAL;
            assign with_zp = shifted + $signed({25'd0, ZP_VAL[3:0]});

            assign clipped = (with_zp < 29'sd0)   ? 4'd0 :
                             (with_zp > 29'sd15)  ? 4'd15 :
                             with_zp[3:0];

            assign out_chunk_w[WIDTH*k +: WIDTH] = clipped;
        end
    endgenerate

    // ============================================================
    // Sequential Logic
    // ============================================================
    integer p;
    integer lane_ptr;

    always @(posedge clk) begin
        if (reset) begin
            busy        <= 1'b0;
            issue_cnt   <= {IDX_W{1'b0}};

            x_vec_r     <= {(ACC_SIZE*PE_NUM){1'b0}};

            mul_vec_r   <= {(28*MUL_PARL){1'b0}};
            idx1        <= {IDX_W{1'b0}};
            v1          <= 1'b0;

            rnd_vec_r   <= {(28*MUL_PARL){1'b0}};
            idx2        <= {IDX_W{1'b0}};
            v2          <= 1'b0;

            q_vec_r     <= {(WIDTH*MUL_PARL){1'b0}};
            idx3        <= {IDX_W{1'b0}};
            v3          <= 1'b0;

            out_vec     <= {(WIDTH*PE_NUM){1'b0}};
            out_valid   <= 1'b0;
            out_valid_d <= 1'b0;
        end else begin
            // Pulse output
            out_valid   <= out_valid_d;
            out_valid_d <= 1'b0;

            // -----------------------------
            // Control
            // -----------------------------
            if (accept) begin
                x_vec_r <= in_vec;

                if (DEPTH > 1) begin
                    busy      <= 1'b1;
                    issue_cnt <= {{(IDX_W-1){1'b0}}, 1'b1}; // next chunk = 1
                end else begin
                    busy      <= 1'b0;
                    issue_cnt <= {IDX_W{1'b0}};
                end
            end else if (busy) begin
                if (issue_cnt == DEPTH - 1) begin
                    busy      <= 1'b0;
                    issue_cnt <= {IDX_W{1'b0}};
                end else begin
                    issue_cnt <= issue_cnt + 1'b1;
                end
            end

            // -----------------------------
            // Pipeline
            // -----------------------------
            // Stage 1: Latch Multiply (fire0 = accept || busy)
            if (fire0) begin
                mul_vec_r <= mul_vec_w;
                idx1      <= idx0_w;
                v1        <= 1'b1;
            end else begin
                v1 <= 1'b0;
            end

            // Stage 2: Latch Round
            if (v1) begin
                rnd_vec_r <= rnd_vec_w;
                idx2      <= idx1;
                v2        <= 1'b1;
            end else begin
                v2 <= 1'b0;
            end

            // Stage 3: Latch Quant Result
            if (v2) begin
                q_vec_r <= out_chunk_w;
                idx3    <= idx2;
                v3      <= 1'b1;
            end else begin
                v3 <= 1'b0;
            end

            // -----------------------------
            // Writeback
            // -----------------------------
            if (v3) begin
                for (p = 0; p < MUL_PARL; p = p + 1) begin
                    lane_ptr = idx3 * MUL_PARL + p;
                    if (lane_ptr < PE_NUM) begin
                        out_vec[WIDTH*lane_ptr +: WIDTH] <= q_vec_r[WIDTH*p +: WIDTH];
                    end
                end

                if (idx3 == DEPTH - 1) begin
                    out_valid_d <= 1'b1;
                end
            end
        end
    end

endmodule





// `timescale 1ns/1ps

// module requant #(
//     // Dimensions
//     parameter integer PE_NUM    = 32,
//     parameter integer ACC_SIZE  = 16,       // int16 inputs
//     parameter integer MUL_PARL  = 32,       // 32 for speed
//     parameter integer WIDTH     = 4,        // uint4 outputs
    
//     // Hardcoded Quantization Parameters (Override at Instantiation)
//     parameter signed [11:0] SCALE_VAL = 12'sd396, // Default (e.g. FC1)
//     parameter integer       SHIFT_VAL = 15,       // Default
//     parameter integer       ZP_VAL    = 0         // Default
// )(
//     input  wire                         clk,
//     input  wire                         reset,

//     // Data Path
//     input  wire [ACC_SIZE*PE_NUM-1:0]   in_vec,     // int16 lanes
//     input  wire                         in_valid,
//     output wire                         in_ready,

//     output reg  [WIDTH*PE_NUM-1:0]      out_vec,    // uint4 lanes
//     output reg                          out_valid
// );

//     // ------------------------------------------------------------
//     // Pipeline Depth Calculation
//     // ------------------------------------------------------------
//     localparam integer DEPTH = (PE_NUM + MUL_PARL - 1) / MUL_PARL;
    
//     function integer clog2;
//         input integer value;
//         integer v;
//         begin
//             v = value - 1;
//             clog2 = 0;
//             while (v > 0) begin
//                 v = v >> 1;
//                 clog2 = clog2 + 1;
//             end
//         end
//     endfunction
//     localparam integer IDX_W = (DEPTH <= 1) ? 1 : clog2(DEPTH);

//     // ------------------------------------------------------------
//     // Handshake & Control
//     // ------------------------------------------------------------
//     reg busy;
//     assign in_ready = !busy;
//     wire accept = in_valid && in_ready;

//     reg [IDX_W-1:0] issue_cnt;

//     // ------------------------------------------------------------
//     // Pipeline Registers
//     // ------------------------------------------------------------
//     // Stage 0: Input Capture
//     reg [ACC_SIZE*PE_NUM-1:0] x_vec_r;
//     reg [IDX_W-1:0]           idx0;
//     reg                       v0;

//     // Stage 1: Multiply
//     reg [28*MUL_PARL-1:0]     mul_vec_r;
//     reg [IDX_W-1:0]           idx1;
//     reg                       v1;

//     // Stage 2: Round & Shift
//     reg [28*MUL_PARL-1:0]     rnd_vec_r;
//     reg [IDX_W-1:0]           idx2;
//     reg                       v2;

//     // Stage 3: Add ZP & Clip
//     reg [WIDTH*MUL_PARL-1:0]  q_vec_r;
//     reg [IDX_W-1:0]           idx3;
//     reg                       v3;

//     reg out_valid_d;

//     // Helper to extract 16-bit lane
//     function [15:0] get_lane_val;
//         input integer lane;
//         begin
//             get_lane_val = x_vec_r[ACC_SIZE*lane +: ACC_SIZE];
//         end
//     endfunction

//     // ============================================================
//     // Stage 1 Combinational: Multiply
//     // ============================================================
//     wire [28*MUL_PARL-1:0] mul_vec_w;

//     genvar i;
//     generate
//         for (i = 0; i < MUL_PARL; i = i + 1) begin : GEN_MUL
//             wire [IDX_W+5:0] global_lane_idx;
//             wire signed [15:0] x_val;
//             wire signed [27:0] mul_res;

//             assign global_lane_idx = {6'b0, idx0} * MUL_PARL + i;
            
//             assign x_val = (global_lane_idx < PE_NUM) ? 
//                            $signed(get_lane_val(global_lane_idx)) : 16'sd0;

//             // int16 * int12 = 28bit (Hardcoded Parameter)
//             assign mul_res = x_val * SCALE_VAL;
            
//             assign mul_vec_w[28*i +: 28] = mul_res;
//         end
//     endgenerate

//     // ============================================================
//     // Stage 2 Combinational: Rounding Add (Half Up)
//     // ============================================================
//     wire [28*MUL_PARL-1:0] rnd_vec_w;
    
//     // Hardcoded Rounding Constant
//     localparam signed [27:0] ROUND_BIAS = (SHIFT_VAL == 0) ? 28'sd0 : (28'sd1 <<< (SHIFT_VAL - 1));

//     genvar j;
//     generate
//         for (j = 0; j < MUL_PARL; j = j + 1) begin : GEN_RND
//             wire signed [27:0] m_val;
//             wire signed [27:0] r_val;
            
//             assign m_val = $signed(mul_vec_r[28*j +: 28]);
//             assign r_val = m_val + ROUND_BIAS;
            
//             assign rnd_vec_w[28*j +: 28] = r_val;
//         end
//     endgenerate

//     // ============================================================
//     // Stage 3 Combinational: Shift + Add ZP + Clip
//     // ============================================================
//     wire [WIDTH*MUL_PARL-1:0] out_chunk_w;

//     genvar k;
//     generate
//         for (k = 0; k < MUL_PARL; k = k + 1) begin : GEN_QUANT
//             wire signed [27:0] r_val;
//             wire signed [27:0] shifted;
//             wire signed [28:0] with_zp; // +1 bit for ZP safety
//             wire [3:0]         clipped;

//             assign r_val = $signed(rnd_vec_r[28*k +: 28]);
            
//             // Hardcoded Shift
//             assign shifted = r_val >>> SHIFT_VAL;

//             // Hardcoded ZP Addition
//             assign with_zp = shifted + $signed({25'd0, ZP_VAL[3:0]});

//             // Clip to [0, 15]
//             assign clipped = (with_zp < 29'sd0)  ? 4'd0 :
//                              (with_zp > 29'sd15) ? 4'd15 :
//                              with_zp[3:0];

//             assign out_chunk_w[WIDTH*k +: WIDTH] = clipped;
//         end
//     endgenerate

//     // ============================================================
//     // Sequential Logic
//     // ============================================================
//     integer p;
//     integer lane_ptr;

//     always @(posedge clk) begin
//         if (reset) begin
//             busy        <= 1'b0;
//             issue_cnt   <= {IDX_W{1'b0}};
            
//             x_vec_r     <= {(ACC_SIZE*PE_NUM){1'b0}};
//             idx0        <= {IDX_W{1'b0}};
//             v0          <= 1'b0;

//             mul_vec_r   <= {(28*MUL_PARL){1'b0}};
//             idx1        <= {IDX_W{1'b0}};
//             v1          <= 1'b0;

//             rnd_vec_r   <= {(28*MUL_PARL){1'b0}};
//             idx2        <= {IDX_W{1'b0}};
//             v2          <= 1'b0;

//             q_vec_r     <= {(WIDTH*MUL_PARL){1'b0}};
//             idx3        <= {IDX_W{1'b0}};
//             v3          <= 1'b0;

//             out_vec     <= {(WIDTH*PE_NUM){1'b0}};
//             out_valid   <= 1'b0;
//             out_valid_d <= 1'b0;
//         end else begin
//             // Pulse output
//             out_valid   <= out_valid_d;
//             out_valid_d <= 1'b0;

//             // -----------------------------------
//             // Issue Logic (Stage 0)
//             // -----------------------------------
//             v0 <= 1'b0; // Default

//             if (accept) begin
//                 x_vec_r   <= in_vec;
//                 busy      <= 1'b1;
//                 issue_cnt <= (DEPTH > 1) ? 1 : 0;
                
//                 idx0      <= {IDX_W{1'b0}}; // First chunk
//                 v0        <= 1'b1;
//             end else if (busy) begin
//                 idx0 <= issue_cnt;
//                 v0   <= 1'b1;

//                 if (issue_cnt == DEPTH - 1) begin
//                     busy      <= 1'b0;
//                     issue_cnt <= {IDX_W{1'b0}};
//                 end else begin
//                     issue_cnt <= issue_cnt + 1;
//                 end
//             end

//             // -----------------------------------
//             // Pipeline Stages
//             // -----------------------------------
            
//             // Stage 1: Latch Multiply
//             if (v0) begin
//                 mul_vec_r <= mul_vec_w;
//                 idx1      <= idx0;
//                 v1        <= 1'b1;
//             end else begin
//                 v1 <= 1'b0;
//             end

//             // Stage 2: Latch Round
//             if (v1) begin
//                 rnd_vec_r <= rnd_vec_w;
//                 idx2      <= idx1;
//                 v2        <= 1'b1;
//             end else begin
//                 v2 <= 1'b0;
//             end

//             // Stage 3: Latch Quant Result
//             if (v2) begin
//                 q_vec_r <= out_chunk_w;
//                 idx3    <= idx2;
//                 v3      <= 1'b1;
//             end else begin
//                 v3 <= 1'b0;
//             end

//             // -----------------------------------
//             // Writeback
//             // -----------------------------------
//             if (v3) begin
//                 for (p = 0; p < MUL_PARL; p = p + 1) begin
//                     lane_ptr = idx3 * MUL_PARL + p;
//                     if (lane_ptr < PE_NUM) begin
//                         out_vec[WIDTH*lane_ptr +: WIDTH] <= q_vec_r[WIDTH*p +: WIDTH];
//                     end
//                 end

//                 if (idx3 == DEPTH - 1) begin
//                     out_valid_d <= 1'b1;
//                 end
//             end
//         end
//     end

// endmodule