`timescale 1ns/1ps

module postProc #(
    parameter integer PE_NUM   = 32,
    parameter integer ACC_SIZE = 16,
    
    // Hardcoded Bias Vector (512-bit for 32x16)
    // Override this parameter at instantiation
    parameter [ACC_SIZE*PE_NUM-1:0] BIAS_VALS = {ACC_SIZE*PE_NUM{1'b0}}
)(
    input  wire                          clk,
    input  wire                          reset,
    
    input  wire [ACC_SIZE*PE_NUM-1:0]    in_vec,   // Accumulator inputs
    input  wire                          in_valid,
    
    output reg  [ACC_SIZE*PE_NUM-1:0]    out_vec,  // Saturated results
    output reg                           out_valid
);

    // ------------------------------------------------------------
    // Saturation Constants (int16)
    // ------------------------------------------------------------
    localparam signed [15:0] INT16_MAX = 16'sh7FFF; //  32767
    localparam signed [15:0] INT16_MIN = 16'sh8000; // -32768

    // ------------------------------------------------------------
    // Per-lane Add + Saturate Logic
    // ------------------------------------------------------------
    wire [ACC_SIZE*PE_NUM-1:0] sat_vec_w;

    genvar i;
    generate
        for (i = 0; i < PE_NUM; i = i + 1) begin : GEN_LANE
            // 1. Extract Accumulator Lane
            wire signed [15:0] acc_s;
            assign acc_s = $signed(in_vec[ACC_SIZE*i +: ACC_SIZE]);

            // 2. Extract Hardcoded Bias Lane
            wire signed [15:0] bias_s;
            assign bias_s = $signed(BIAS_VALS[ACC_SIZE*i +: ACC_SIZE]);

            // 3. Add with 17-bit width to capture overflow/underflow safely
            wire signed [16:0] sum17;
            assign sum17 = {acc_s[15], acc_s} + {bias_s[15], bias_s};

            // 4. Saturation Logic
            // sum17 ranges from -65536 to +65534. 
            // We need to clamp to -32768 to +32767.
            wire signed [15:0] res_s;
            
            assign res_s = (sum17 > INT16_MAX) ? INT16_MAX :
                           (sum17 < INT16_MIN) ? INT16_MIN :
                           sum17[15:0];

            assign sat_vec_w[ACC_SIZE*i +: ACC_SIZE] = res_s;
        end
    endgenerate

    // ------------------------------------------------------------
    // Pipeline Register (1 cycle latency)
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            out_vec   <= {(ACC_SIZE*PE_NUM){1'b0}};
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                out_vec <= sat_vec_w;
            end
        end
    end

endmodule