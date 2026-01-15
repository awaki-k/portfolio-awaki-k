// ------------------------------------------------------------
// SHIFTはすべて0x1E(30)だから、ROM化せずに、requantモジュールにレジスタ保持。
// ------------------------------------------------------------

module mlp #(
// -----------------------------
    // memory-bank width/depth
    // -----------------------------
    // Input Image (14x14 = 196 pixels, 4-bit)
    parameter integer X1_WIDTH      = 4,
    parameter integer X1_DEPTH      = 14*14, // 196

    // Hidden Layer 1 Output (32 nodes, 4-bit)
    parameter integer X2_WIDTH      = 4,
    parameter integer X2_DEPTH      = 32,
    parameter integer X2_VEC_ELEMS  = 32,

    // Hidden Layer 2 Output (16 nodes, 4-bit)
    parameter integer X3_WIDTH      = 4,
    parameter integer X3_DEPTH      = 16,
    parameter integer X3_VEC_ELEMS  = 16, // Keep aligned to PE_NUM
    // parameter integer X3_VEC_ELEMS  = 32, // Keep aligned to PE_NUM

    // Weights (4-bit * 32 parallel = 128 bit width)
    // W1: In=196
    parameter integer W1_WIDTH      = 4*32, // 128
    parameter integer W1_DEPTH      = 196,
    // W2: In=32
    parameter integer W2_WIDTH      = 4*32, // 128
    parameter integer W2_DEPTH      = 32,
    // W3: In=16
    parameter integer W3_WIDTH      = 4*32, // 128
    parameter integer W3_DEPTH      = 16,

    // Loop Counters (Optimized bit widths)
    parameter integer LI_WIDTH      = 8, // Enough for 196 (max input)
    parameter integer LI_DEPTH      = 3, // 3 layers
    parameter integer LO_WIDTH      = 6, // Enough for 32 (max output)
    parameter integer LO_DEPTH      = 3,

    // -----------------------------
    // processing configurations
    // -----------------------------
    parameter integer PE_NUM     = 32,
    parameter integer WIDTH      = 4,  // Data: 4-bit
    parameter integer ACC_SIZE   = 16, // Acc: 16-bit
    parameter integer LABEL_N    = 10,
    parameter integer OUT_WIDTH  = 4,  // 0-9 needs 4 bits
    parameter integer STATE_SIZE = 4
)(
    input  wire                         clk,
    input  wire                         reset,

    // Read Ports
    input  wire                         x1_wr_en,
    input  wire [X1_WIDTH-1:0]          x1_wr_data,

    // MLP-Inputs
    input  wire                         exec,
    input  wire                         tready,

    // MLP-Outputs
    output wire [OUT_WIDTH-1:0]         pred_out,
    output wire                         tvalid

    // --- dbg ---
        // , output wire [2:0]                     exec_ready_dbg
        // , output wire [9:0]                     x1_wptr_dbg

        // , output wire [X1_WIDTH-1:0]            x_rd_data_dbg
        // , output wire [W1_WIDTH-1:0]            w_rd_data_dbg
        
        // , output wire                           xw1_rd_en_dbg
        // , output wire [X1_WIDTH-1:0]            x1_rd_data_dbg
        // , output wire                           x1_rd_valid_dbg
        // , output wire [W1_WIDTH-1:0]            w1_rd_data_dbg
        // , output wire                           w1_rd_valid_dbg

        // , output wire                           xw2_rd_en_dbg
        // , output wire [X2_WIDTH-1:0]            x2_rd_data_dbg
        // , output wire                           x2_rd_valid_dbg
        // , output wire [W2_WIDTH-1:0]            w2_rd_data_dbg
        // , output wire                           w2_rd_valid_dbg

        // , output wire                           xw3_rd_en_dbg
        // , output wire [X3_WIDTH-1:0]            x3_rd_data_dbg
        // , output wire                           x3_rd_valid_dbg
        // , output wire [W3_WIDTH-1:0]            w3_rd_data_dbg
        // , output wire                           w3_rd_valid_dbg

        // , output wire [STATE_SIZE-1:0]          state_dbg
        // , output wire [STATE_SIZE-1:0]          next_state_dbg
        
        // , output wire                           acc_en_dbg
        // , output wire                           acc_sel_dbg
        // , output wire [ACC_SIZE*PE_NUM-1:0]     acc_out_dbg
        
        // , output wire                           pb1_en_dbg
        // , output wire                           pb2_en_dbg
        // , output wire                           pb3_en_dbg
        // , output wire [ACC_SIZE*PE_NUM-1:0]     pb1_out_dbg
        // , output wire [ACC_SIZE*PE_NUM-1:0]     pb2_out_dbg
        // , output wire [ACC_SIZE*PE_NUM-1:0]     pb3_out_dbg
        // , output wire                           pb1_valid_dbg
        // , output wire                           pb2_valid_dbg
        // , output wire                           pb3_valid_dbg

        // , output wire                           rq1_en_dbg    
        // , output wire [WIDTH*PE_NUM-1:0]        rq1_out_dbg   
        // , output wire                           rq1_valid_dbg 
        // , output wire                           rq2_en_dbg    
        // , output wire [WIDTH*PE_NUM-1:0]        rq2_out_dbg   
        // , output wire                           rq2_valid_dbg 
        
        // , output wire                              lp1_clear_dbg
        // , output wire                              lp1_incr_dbg
        // , output wire                              lp1_end_dbg
        // , output wire                              lp2_clear_dbg
        // , output wire                              lp2_incr_dbg
        // , output wire                              lp2_end_dbg
        // , output wire                              lp3_clear_dbg
        // , output wire                              lp3_incr_dbg
        // , output wire                              lp3_end_dbg
        // , output wire [7:0]                        cnt1_dbg
        // , output wire [7:0]                        cnt2_dbg 
        // , output wire [7:0]                        cnt3_dbg 
);

    // ---------------------------------
    // Internal signals
    // ---------------------------------
    wire[2:0] exec_ready;
    wire xw1_rd_en, xw2_rd_en, xw3_rd_en;
    wire    pb1_en,    pb2_en,    pb3_en;
    wire    rq1_en,    rq2_en           ;
    wire             x2_wr_en,  x3_wr_en;

    // rd_data/valid
    wire [X1_WIDTH-1:0] x_rd_data;  wire x_rd_valid;
    wire [X1_WIDTH-1:0] x1_rd_data; wire x1_rd_valid;
    wire [X2_WIDTH-1:0] x2_rd_data; wire x2_rd_valid;
    wire [X3_WIDTH-1:0] x3_rd_data; wire x3_rd_valid;

    wire [W1_WIDTH-1:0] w_rd_data;  wire w_rd_valid;
    wire [W1_WIDTH-1:0] w1_rd_data; wire w1_rd_valid;
    wire [W2_WIDTH-1:0] w2_rd_data; wire w2_rd_valid;
    wire [W3_WIDTH-1:0] w3_rd_data; wire w3_rd_valid;

    wire lp1_clear, lp1_incr, lp1_end;
    wire lp2_clear, lp2_incr, lp2_end;
    wire lp3_clear, lp3_incr, lp3_end;

    wire acc_en, acc_sel;
    wire [ACC_SIZE*PE_NUM-1:0]  acc_out;

    wire [ACC_SIZE*PE_NUM-1:0]    pb1_out,   pb2_out,   pb3_out;
    wire                        pb1_valid, pb2_valid, pb3_valid;
    wire [WIDTH*PE_NUM-1:0]       rq1_out,   rq2_out           ;
    wire                        rq1_valid, rq2_valid           ;
    
    wire                        argmx_en;
    wire                        argmx_valid;

    assign x_rd_data = (x1_rd_valid) ? x1_rd_data :
                       (x2_rd_valid) ? x2_rd_data :
                       (x3_rd_valid) ? x3_rd_data : {X1_WIDTH{1'b0}};

    assign w_rd_data = (w1_rd_valid) ? w1_rd_data :
                       (w2_rd_valid) ? w2_rd_data :
                       (w3_rd_valid) ? w3_rd_data : {W1_WIDTH{1'b0}}; 

    // ---------------------------------
    // Controller
    // ---------------------------------
    Controller #(
        .STATE_SIZE   (4),
        .FSM_IN_SIZE  (4+14),
        .FSM_OUT_SIZE (20)
    ) controller_inst (
        .clk         (clk),
        .reset       (reset),

        .exec_ready  (exec_ready),                          // [2:0]
        .exec_valid  (exec),
        .lp_end      ({lp3_end, lp2_end, lp1_end}),         // [2:0]
        .pb_valid    ({pb3_valid, pb2_valid, pb1_valid}),   // [2:0]
        .rq_valid    ({rq2_valid,rq1_valid}),               // [1:0]
        .argmx_valid (argmx_valid),
        .tready      (tready),

        .xw_rd_en    ({xw3_rd_en, xw2_rd_en, xw1_rd_en}),   // [2:0]
        .acc_en      (acc_en),
        .acc_sel     (acc_sel),
        .lp_incr     ({lp3_incr, lp2_incr, lp1_incr}),      // [2:0]
        .lp_clear    ({lp3_clear, lp2_clear, lp1_clear}),   // [2:0]
        .pb_en       ({pb3_en, pb2_en, pb1_en}),            // [2:0]
        .rq_en       ({rq2_en, rq1_en}),                    // [1:0]
        .x_wr_en     ({x3_wr_en, x2_wr_en}),                // [1:0]
        .argmx_en    (argmx_en),
        .tvalid      (tvalid)
        // --- dbg ---
            // , .state_dbg      (state_dbg)
            // , .next_state_dbg (next_state_dbg)
    );

    // ---------------------------------
    // Counters
    // ---------------------------------
    Counter #(
        .BLOOP(8),
        .LIMIT(196)
    ) lp1_inst (
        .clk        (clk),
        .reset      (reset),
        .lp_clear   (lp1_clear),
        .lp_incr    (lp1_incr),
        .lp_end     (lp1_end)
        // --- dbg ---
            // , .cnt_dbg    (cnt1_dbg)
    );

    Counter #(
        .BLOOP(8),
        .LIMIT(32)
    ) lp2_inst (
        .clk        (clk),
        .reset      (reset),
        .lp_clear   (lp2_clear),
        .lp_incr    (lp2_incr),
        .lp_end     (lp2_end)
        // --- dbg ---
            // , .cnt_dbg    (cnt2_dbg)
    );
    
    Counter #(
        .BLOOP(8),
        .LIMIT(16)
    ) lp3_inst (
        .clk        (clk),
        .reset      (reset),
        .lp_clear   (lp3_clear),
        .lp_incr    (lp3_incr),
        .lp_end     (lp3_end)
        // --- dbg ---
            // , .cnt_dbg    (cnt3_dbg)
    );
    // ---------------------------------
    // Memory Bank 
    // ---------------------------------
    memory_bank_rom #(
        .X1_WIDTH (X1_WIDTH), .X1_DEPTH (X1_DEPTH),
        .X2_WIDTH (X2_WIDTH), .X2_DEPTH (X2_DEPTH), .X2_VEC_ELEMS (X2_VEC_ELEMS),
        .X3_WIDTH (X3_WIDTH), .X3_DEPTH (X3_DEPTH), .X3_VEC_ELEMS (X3_VEC_ELEMS),
        .W1_WIDTH (W1_WIDTH), .W1_DEPTH (W1_DEPTH),
        .W2_WIDTH (W2_WIDTH), .W2_DEPTH (W2_DEPTH),
        .W3_WIDTH (W3_WIDTH), .W3_DEPTH (W3_DEPTH)
    ) mem_bank_inst (
        .clk    (clk),
        .reset  (reset),

        // writes
        .x1_wr_en(x1_wr_en), .x1_wr_data(x1_wr_data),
        .x2_wr_en(x2_wr_en), .x2_wr_vec_data(rq1_out),
        .x3_wr_en(x3_wr_en), .x3_wr_vec_data(rq2_out),

        // reads
        .x1_rd_en(xw1_rd_en), .x1_rd_data(x1_rd_data), .x1_rd_valid(x1_rd_valid),
        .x2_rd_en(xw2_rd_en), .x2_rd_data(x2_rd_data), .x2_rd_valid(x2_rd_valid),
        .x3_rd_en(xw3_rd_en), .x3_rd_data(x3_rd_data), .x3_rd_valid(x3_rd_valid),

        .w1_rd_en(xw1_rd_en), .w1_rd_data(w1_rd_data), .w1_rd_valid(w1_rd_valid),
        .w2_rd_en(xw2_rd_en), .w2_rd_data(w2_rd_data), .w2_rd_valid(w2_rd_valid),
        .w3_rd_en(xw3_rd_en), .w3_rd_data(w3_rd_data), .w3_rd_valid(w3_rd_valid),

        // status
        .exec_ready(exec_ready)

        // --- dbg ---
            // , .x1_wptr_dbg (x1_wptr_dbg)
    );

    // ---------------------------------
    // MAC
    // ---------------------------------    
    OPU #(
        .PE_NUM  (PE_NUM),
        .SIZE    (WIDTH),
        .ACC_SIZE(ACC_SIZE)
    ) opu_inst (
        .clk     (clk),
        .reset   (reset),
        .acc_en  (acc_en),   
        .acc_sel (acc_sel),  
        .win     (w_rd_data),
        .xin     (x_rd_data),
        .yout    (acc_out)
    );

    // ---------------------------------
    // +Bias
    // ---------------------------------
    postProc #(
        .PE_NUM(PE_NUM),
        .ACC_SIZE(ACC_SIZE),
        .BIAS_VALS(512'h00030022001f002e001a00270010002700110008000f0027fffe001f000f0018fffb0012ffeeffe2000200090009fffb001c0011000c001a000afffb00190003)
    ) pb_fc1_inst (
        .clk            (clk),
        .reset          (reset),
        .in_vec         (acc_out),
        .in_valid       (pb1_en),
        .out_vec        (pb1_out),
        .out_valid      (pb1_valid)
    );

    postProc #(
        .PE_NUM(PE_NUM),
        .ACC_SIZE(ACC_SIZE),
        .BIAS_VALS(512'h0000000000000000000000000000000000000000000000000000000000000000000200000001ffff00010002000200050001000100020003000400010000ffff)
    ) pb_fc2_inst (
        .clk            (clk),
        .reset          (reset),
        .in_vec         (acc_out),
        .in_valid       (pb2_en),
        .out_vec        (pb2_out),
        .out_valid      (pb2_valid)
    );

    postProc #(
        .PE_NUM(PE_NUM),
        .ACC_SIZE(ACC_SIZE),
        .BIAS_VALS(512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010002ffff00000000ffff)
    ) pb_fc3_inst (
        .clk            (clk),
        .reset          (reset),
        .in_vec         (acc_out),
        .in_valid       (pb3_en),
        .out_vec        (pb3_out),
        .out_valid      (pb3_valid)
    );

    // ---------------------------------
    // Quantization
    // ---------------------------------
    requant #(
        .PE_NUM     (PE_NUM),
        .ACC_SIZE   (ACC_SIZE),
        .MUL_PARL   (8),
        .WIDTH      (WIDTH),
        .SCALE_VAL  (12'sd396),
        .SHIFT_VAL  (15),
        .ZP_VAL     (0)
    ) requant_fc1_inst (
        .clk         (clk),
        .reset       (reset),
        .in_vec      (pb1_out),     // int16 lanes
        .in_valid    (rq1_en),
        .out_vec     (rq1_out),    // uint4 lanes
        .out_valid   (rq1_valid)
    );
    
    requant #(
        .PE_NUM     (PE_NUM),
        .ACC_SIZE   (ACC_SIZE),
        .MUL_PARL   (8),
        .WIDTH      (WIDTH),
        .SCALE_VAL  (12'sd1234),
        .SHIFT_VAL  (14),
        .ZP_VAL     (0)
    ) requant_fc2_inst (
        .clk         (clk),
        .reset       (reset),
        .in_vec      (pb2_out),     // int16 lanes
        .in_valid    (rq2_en),
        .out_vec     (rq2_out),    // uint4 lanes
        .out_valid   (rq2_valid)
    );

    // ---------------------------------
    // Argmax
    // ---------------------------------
    argmax #(
        .WIDTH      (ACC_SIZE),
        .LABEL_N    (LABEL_N),
        .VEC_ELEMS  (X3_VEC_ELEMS),
        .OUT_WIDTH  (OUT_WIDTH)
    ) argmax_inst (
        .clk            (clk),
        .reset          (reset),
        .en             (argmx_en),
        .pb_vec         (pb3_out),
        .pred           (pred_out),
        .valid          (argmx_valid)
    );

    // --- dbg ---
        // assign exec_ready_dbg       = exec_ready;
        // assign x_rd_data_dbg        = x_rd_data;
        // assign w_rd_data_dbg        = w_rd_data;
        // assign xw1_rd_en_dbg    = xw1_rd_en;
        // assign xw2_rd_en_dbg    = xw2_rd_en;
        // assign xw3_rd_en_dbg    = xw3_rd_en;

        // assign x1_rd_data_dbg  = x1_rd_data;
        // assign x1_rd_valid_dbg = x1_rd_valid;
        // assign w1_rd_data_dbg  = w1_rd_data;
        // assign w1_rd_valid_dbg = w1_rd_valid;

        // assign x2_rd_data_dbg   = x2_rd_data;
        // assign x2_rd_valid_dbg  = x2_rd_valid;
        // assign w2_rd_data_dbg   = w2_rd_data;
        // assign w2_rd_valid_dbg  = w2_rd_valid;

        // assign x3_rd_data_dbg   = x3_rd_data;
        // assign x3_rd_valid_dbg  = x3_rd_valid;
        // assign w3_rd_data_dbg   = w3_rd_data;
        // assign w3_rd_valid_dbg  = w3_rd_valid;

        // assign acc_en_dbg       = acc_en;
        // assign acc_sel_dbg      = acc_sel;
        // assign acc_out_dbg      = acc_out;

        // assign pb1_en_dbg       = pb1_en;    
        // assign pb2_en_dbg       = pb2_en;    
        // assign pb3_en_dbg       = pb3_en;    
        // assign pb1_out_dbg      = pb1_out;
        // assign pb2_out_dbg      = pb2_out;
        // assign pb3_out_dbg      = pb3_out;
        // assign pb1_valid_dbg    = pb1_valid;
        // assign pb2_valid_dbg    = pb2_valid;
        // assign pb3_valid_dbg    = pb3_valid;

        // assign rq1_en_dbg       = rq1_en;
        // assign rq1_out_dbg      = rq1_out;
        // assign rq1_valid_dbg    = rq1_valid;
        // assign rq2_en_dbg       = rq2_en;
        // assign rq2_out_dbg      = rq2_out;
        // assign rq2_valid_dbg    = rq2_valid;

        // assign lp1_clear_dbg    = lp1_clear;
        // assign lp1_incr_dbg     = lp1_incr;
        // assign lp1_end_dbg      = lp1_end;
        // assign lp2_clear_dbg    = lp2_clear;
        // assign lp2_incr_dbg     = lp2_incr;
        // assign lp2_end_dbg      = lp2_end;
        // assign lp3_clear_dbg    = lp3_clear;
        // assign lp3_incr_dbg     = lp3_incr;
        // assign lp3_end_dbg      = lp3_end;

endmodule
