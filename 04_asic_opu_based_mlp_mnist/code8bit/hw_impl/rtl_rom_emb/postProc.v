module postProc #(
    parameter integer PE_NUM   = 32,
    parameter integer ACC_SIZE = 32
)(
    input  wire                          clk,
    input  wire                          reset,
    input  wire [ACC_SIZE*PE_NUM-1:0]    acc_vec,
    input  wire [ACC_SIZE*PE_NUM-1:0]    bias_vec,
    input  wire                          bias_valid,
    output reg  [ACC_SIZE*PE_NUM-1:0]    pb_vec,
    output reg                           pb_valid
);
    // ------------------------------------------------------------
    // saturation constants (int32)
    // ------------------------------------------------------------
    localparam [31:0] INT32_MIN = 32'h8000_0000;
    localparam [31:0] INT32_MAX = 32'h7FFF_FFFF;

    // ------------------------------------------------------------
    // per-lane add + overflow detect + saturate
    // ------------------------------------------------------------
    wire [ACC_SIZE*PE_NUM-1:0] sat_vec;

    genvar gi;
    generate
        for (gi = 0; gi < PE_NUM; gi = gi + 1) begin : GEN_BIAS_CLIP
            wire signed [ACC_SIZE-1:0] acc_s;
            wire signed [ACC_SIZE-1:0] bias_s;

            // sum32 (requested)
            wire signed [ACC_SIZE-1:0] sum32;
            wire                       ovf;
            wire signed [ACC_SIZE-1:0] clip_sum;

            assign acc_s  = $signed(acc_vec [ACC_SIZE*gi +: ACC_SIZE]);
            assign bias_s = $signed(bias_vec[ACC_SIZE*gi +: ACC_SIZE]);

            // sum of acc and bias
            assign sum32 = acc_s + bias_s;

            // overflow detection: if signs of acc and bias differ, and the sum has a different sign, overflow
            assign ovf = (~(acc_s[ACC_SIZE-1] ^ bias_s[ACC_SIZE-1])) & (sum32[ACC_SIZE-1] ^ acc_s[ACC_SIZE-1]);

            // saturation logic
            assign clip_sum = ovf ? (acc_s[ACC_SIZE-1] ? $signed(INT32_MIN) : $signed(INT32_MAX)) : sum32;

            // assign the saturated result to the corresponding lane in pb_vec
            assign sat_vec[ACC_SIZE*gi +: ACC_SIZE] = clip_sum;
        end
    endgenerate

    // ------------------------------------------------------------
    // control: issue pb_valid when all computations are complete
    // ------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pb_vec      <= {ACC_SIZE*PE_NUM{1'b0}};  // reset all output to 0
            pb_valid    <= 1'b0;                      // reset valid signal
        end else begin
            if (bias_valid) begin
                pb_vec <= sat_vec;  // output the saturated result
                pb_valid <= 1'b1;   // mark the output as valid
            end else begin
                pb_valid <= 1'b0;   // keep pb_valid low until bias_valid
            end
        end
    end

endmodule



// module postProc #(
//     parameter integer PE_NUM   = 32,
//     parameter integer ACC_SIZE = 32  // int32
// )(
//     input  wire                          clk,
//     input  wire                          reset,

//     // trigger: end of inner loop
//     input  wire                          li_end,

//     // accumulator output (vector of int32)
//     input  wire [ACC_SIZE*PE_NUM-1:0]    acc_vec,

//     // bias fifo output (vector of int32)
//     input  wire [ACC_SIZE*PE_NUM-1:0]    bias_vec,
//     input  wire                          bias_valid,

//     // bias fifo read enable (1-cycle pulse on li_end)
//     output reg                           bias_rd_en,

//     // saturated output (vector of int32)
//     output reg  [ACC_SIZE*PE_NUM-1:0]    yout_sat_vec,
//     output reg                           yout_sat_valid
// );

//     // ------------------------------------------------------------
//     // internal state: latch acc at li_end, wait bias_valid
//     // ------------------------------------------------------------
//     reg  [ACC_SIZE*PE_NUM-1:0] acc_latched;
//     reg                        pending;

//     // use acc_vec directly if bias_valid comes same cycle as li_end,
//     // otherwise use latched acc.
//     wire [ACC_SIZE*PE_NUM-1:0] acc_use_vec;
//     assign acc_use_vec = li_end ? acc_vec : acc_latched;

//     // ------------------------------------------------------------
//     // saturation constants (int32)
//     // ------------------------------------------------------------
//     localparam [31:0] INT32_MIN = 32'h8000_0000;
//     localparam [31:0] INT32_MAX = 32'h7FFF_FFFF;

//     // ------------------------------------------------------------
//     // per-lane add + overflow detect + saturate
//     // ------------------------------------------------------------
//     wire [ACC_SIZE*PE_NUM-1:0] sat_vec;

//     genvar gi;
//     generate
//         for (gi = 0; gi < PE_NUM; gi = gi + 1) begin : GEN_SAT
//             wire signed [ACC_SIZE-1:0] acc_s;
//             wire signed [ACC_SIZE-1:0] bias_s;

//             // sum32 (requested)
//             wire signed [ACC_SIZE-1:0] sum32;
//             wire               ovf;
//             wire signed [ACC_SIZE-1:0] sat_sum;

//             assign acc_s  = $signed(acc_use_vec[ACC_SIZE*gi +: ACC_SIZE]);
//             assign bias_s = $signed(bias_vec   [ACC_SIZE*gi +: ACC_SIZE]);

//             // requested: wire signed [31:0] sum32 = acc + bias;
//             assign sum32 = acc_s + bias_s;

//             // requested: wire ovf = (~(acc[31] ^ bias[31])) & (sum32[31] ^ acc[31]);
//             assign ovf = (~(acc_s[ACC_SIZE-1] ^ bias_s[ACC_SIZE-1])) & (sum32[ACC_SIZE-1] ^ acc_s[ACC_SIZE-1]);

//             // requested: sat_sum = ovf ? (acc[31] ? MIN : MAX) : sum32;
//             assign sat_sum = ovf ? (acc_s[ACC_SIZE-1] ? $signed(INT32_MIN) : $signed(INT32_MAX)) : sum32;

//             assign sat_vec[ACC_SIZE*gi +: ACC_SIZE] = sat_sum;
//         end
//     endgenerate

//     // ------------------------------------------------------------
//     // control: issue bias rd_en at li_end, output result when bias_valid
//     // ------------------------------------------------------------
//     always @(posedge clk) begin
//         if (reset) begin
//             bias_rd_en       <= 1'b0;
//             acc_latched      <= {ACC_SIZE*PE_NUM{1'b0}};
//             pending          <= 1'b0;
//             yout_sat_vec     <= {ACC_SIZE*PE_NUM{1'b0}};
//             yout_sat_valid   <= 1'b0;
//         end else begin
//             // default
//             bias_rd_en     <= li_end;  // 1-cycle pulse
//             yout_sat_valid <= 1'b0;

//             // latch acc at end of inner loop
//             if (li_end) begin
//                 acc_latched <= acc_vec;
//                 pending     <= 1'b1;
//             end

//             // when bias arrives, compute + clip and publish
//             if ((pending || li_end) && bias_valid) begin
//                 yout_sat_vec   <= sat_vec;
//                 yout_sat_valid <= 1'b1;
//                 pending        <= 1'b0;
//             end
//         end
//     end

// endmodule
