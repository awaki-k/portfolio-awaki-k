module top #(
    // -----------------------------
    // memory-bank width/depth
    // -----------------------------
    parameter integer X1_WIDTH      = 8,
    parameter integer X1_DEPTH      = 28*28,
    parameter integer X2_WIDTH      = 8,
    parameter integer X2_DEPTH      = 64,
    parameter integer X2_VEC_ELEMS  = 32,
    parameter integer X3_WIDTH      = 8,
    parameter integer X3_DEPTH      = 32,
    parameter integer X3_VEC_ELEMS  = 32,

    parameter integer W1_WIDTH      = 8*32,
    parameter integer W1_DEPTH      = 28*28*2,
    parameter integer W2_WIDTH      = 8*32,
    parameter integer W2_DEPTH      = 1,
    parameter integer W3_WIDTH      = 8*32,
    parameter integer W3_DEPTH      = 1,

    parameter integer B1_WIDTH      = 32*32,
    parameter integer B1_DEPTH      = 2,
    parameter integer B2_WIDTH      = 32*32,
    parameter integer B2_DEPTH      = 1,
    parameter integer B3_WIDTH      = 32*32,
    parameter integer B3_DEPTH      = 1,

    parameter integer SC_WIDTH      = 24,
    parameter integer SC_DEPTH      = 4,
    parameter integer SH_WIDTH      = 8,
    parameter integer SH_DEPTH      = 4,
    parameter integer ZP_WIDTH      = 8,
    parameter integer ZP_DEPTH      = 4,

    parameter integer LI_WIDTH      = 12,
    parameter integer LI_DEPTH      = 3,
    parameter integer LO_WIDTH      = 4,
    parameter integer LO_DEPTH      = 3,

    // -----------------------------
    // processing configurations
    // -----------------------------
    parameter integer PE_NUM     = 32,
    parameter integer WIDTH      = 8,
    parameter integer ACC_SIZE   = 32,
    parameter integer LABEL_N    = 10,
    parameter integer OUT_WIDTH  = 4,
    parameter integer STATE_SIZE = 4
)(
    input  wire                         clk,
    input  wire                         reset,

    // X1
    input  wire                         x1_wr_en,
    input  wire [X1_WIDTH-1:0]          x1_wr_data,
    // W1
    input  wire                         w1_wr_en,
    input  wire [W1_WIDTH-1:0]          w1_wr_data,
    // W2
    input  wire                         w2_wr_en,
    input  wire [W2_WIDTH-1:0]          w2_wr_data,
    // W3
    input  wire                         w3_wr_en,
    input  wire [W3_WIDTH-1:0]          w3_wr_data,
    // B1
    input  wire                         b1_wr_en,
    input  wire [B1_WIDTH-1:0]          b1_wr_data,
    // B2
    input  wire                         b2_wr_en,
    input  wire [B2_WIDTH-1:0]          b2_wr_data,
    // B3
    input  wire                         b3_wr_en,
    input  wire [B3_WIDTH-1:0]          b3_wr_data,
    // SC
    input  wire                         sc_wr_en,
    input  wire [SC_WIDTH-1:0]          sc_wr_data,
    // SH
    input  wire                         sh_wr_en,
    input  wire [SH_WIDTH-1:0]          sh_wr_data,
    // ZP
    input  wire                         zp_wr_en,
    input  wire [ZP_WIDTH-1:0]          zp_wr_data,
    // LI
    input  wire                         li_wr_en,
    input  wire [LI_WIDTH-1:0]          li_wr_data,
    // LO
    input  wire                         lo_wr_en,
    input  wire [LO_WIDTH-1:0]          lo_wr_data,
    // Controller-Inputs
    input  wire                         exec,
    input  wire                         tready,

    // MLP-Outputs
    output wire [OUT_WIDTH-1:0]         argmx_out,
    output wire                         tvalid

    // --- dbg ---
    // , output wire [2:0]                     exec_ready_dbg
    // , output wire                           fc0_exec_ready_dbg
    // , output wire                           fc1_exec_ready_dbg
    // , output wire                           fc2_exec_ready_dbg
    // , output wire                           xw1_rd_en_dbg
    // , output wire [X1_WIDTH-1:0]            x1_rd_data_dbg
    // , output wire                           x1_rd_valid_dbg
    // , output wire                           xw2_rd_en_dbg
    // , output wire [X2_WIDTH-1:0]            x2_rd_data_dbg
    // , output wire                           x2_rd_valid_dbg
    // , output wire                           xw3_rd_en_dbg
    // , output wire [X3_WIDTH-1:0]            x3_rd_data_dbg
    // , output wire                           x3_rd_valid_dbg
    // , output wire [W1_WIDTH-1:0]            w1_rd_data_dbg
    // , output wire                           w1_rd_valid_dbg
    // , output wire [W2_WIDTH-1:0]            w2_rd_data_dbg
    // , output wire                           w2_rd_valid_dbg
    // , output wire [W3_WIDTH-1:0]            w3_rd_data_dbg
    // , output wire                           w3_rd_valid_dbg
    // , output wire                           b1_rd_en_dbg
    // , output wire [B1_WIDTH-1:0]            b1_rd_data_dbg
    // , output wire                           b1_rd_valid_dbg
    // , output wire                           b2_rd_en_dbg
    // , output wire [B2_WIDTH-1:0]            b2_rd_data_dbg
    // , output wire                           b2_rd_valid_dbg
    // , output wire                           b3_rd_en_dbg
    // , output wire [B3_WIDTH-1:0]            b3_rd_data_dbg
    // , output wire                           b3_rd_valid_dbg
    // , output wire                           rq_rd_en_dbg
    // , output wire [SC_WIDTH-1:0]            sc_rd_data_dbg 
    // , output wire                           sc_rd_valid_dbg
    // , output wire [SH_WIDTH-1:0]            sh_rd_data_dbg 
    // , output wire                           sh_rd_valid_dbg
    // , output wire [ZP_WIDTH-1:0]            zp_rd_data_dbg 
    // , output wire                           zp_rd_valid_dbg
    // , output wire                           x2_wr_en_dbg
    // , output wire                           x3_wr_en_dbg
    // , output wire [LI_WIDTH-1:0]            li_cnt_dbg
    // , output wire [LO_WIDTH-1:0]            lo_cnt_dbg
    // , output wire [LI_WIDTH-1:0]            li_out_dbg
    // , output wire [LO_WIDTH-1:0]            lo_out_dbg
    // , output wire                           li_rd_en_dbg
    // , output wire                           lo_rd_en_dbg
    // , output wire [LI_WIDTH-1:0]            li_rd_data_dbg
    // , output wire [LO_WIDTH-1:0]            lo_rd_data_dbg
    // , output wire                           li_rd_valid_dbg
    // , output wire                           lo_rd_valid_dbg
    // , output wire                           li_end_dbg
    // , output wire                           lo_end_dbg
    // , output wire                           acc_en_dbg
    // , output wire                           acc_sel_dbg
    // , output wire [STATE_SIZE-1:0]          state_dbg
    // , output wire [STATE_SIZE-1:0]          next_state_dbg
    // , output wire                           li_clear_dbg
    // , output wire                           li_incr_dbg
    // , output wire                           lo_clear_dbg
    // , output wire                           lo_incr_dbg
    // , output wire [ACC_SIZE*PE_NUM-1:0]     acc_out_dbg
    // , output wire [ACC_SIZE*PE_NUM-1:0]     pb_out_dbg
    // , output wire                           pb_valid_dbg
    // , output wire                           x1_full_dbg
    // , output wire                           w1_full_dbg
    // , output wire                           w2_full_dbg
    // , output wire                           w3_full_dbg
    // , output wire                           b1_full_dbg
    // , output wire                           b2_full_dbg
    // , output wire                           b3_full_dbg
    // , output wire                           sc_full_dbg
    // , output wire                           sh_full_dbg
    // , output wire                           zp_full_dbg
    // , output wire                           li_full_dbg
    // , output wire                           lo_full_dbg
    
);

    // ---------------------------------
    // Internal signals
    // ---------------------------------
    wire fc0_exec_ready, fc1_exec_ready, fc2_exec_ready;

    // tmp wr_en
    wire x2_wr_en, x3_wr_en;

    // rd_en
    wire xw1_rd_en, xw2_rd_en, xw3_rd_en;
    wire b1_rd_en,  b2_rd_en,  b3_rd_en;
    wire rq1_rd_en, rq2_rd_en;

    // rd_data/valid
    wire [X1_WIDTH-1:0] x_rd_data;  wire x_rd_valid;
    wire [X1_WIDTH-1:0] x1_rd_data; wire x1_rd_valid;
    wire [X2_WIDTH-1:0] x2_rd_data; wire x2_rd_valid;
    wire [X3_WIDTH-1:0] x3_rd_data; wire x3_rd_valid;

    wire [W1_WIDTH-1:0] w_rd_data;  wire w_rd_valid;
    wire [W1_WIDTH-1:0] w1_rd_data; wire w1_rd_valid;
    wire [W2_WIDTH-1:0] w2_rd_data; wire w2_rd_valid;
    wire [W3_WIDTH-1:0] w3_rd_data; wire w3_rd_valid;

    wire [B1_WIDTH-1:0] b_rd_data;  wire b_rd_valid;
    wire [B1_WIDTH-1:0] b1_rd_data; wire b1_rd_valid;
    wire [B1_WIDTH-1:0] b2_rd_data; wire b2_rd_valid;
    wire [B1_WIDTH-1:0] b3_rd_data; wire b3_rd_valid;

    wire [SC_WIDTH-1:0] sc_rd_data; wire sc_rd_valid;
    wire [SH_WIDTH-1:0] sh_rd_data; wire sh_rd_valid;
    wire [ZP_WIDTH-1:0] zp_rd_data; wire zp_rd_valid;

    wire [LI_WIDTH-1:0] li_rd_data; wire li_rd_valid;
    wire [LO_WIDTH-1:0] lo_rd_data; wire lo_rd_valid;
    wire li_rd_en, li_clear, li_incr, li_end;
    wire lo_rd_en, lo_clear, lo_incr, lo_end;

    wire [ACC_SIZE*PE_NUM-1:0]  acc_out;
    wire [ACC_SIZE*PE_NUM-1:0]  pb_out;
    wire                        pb_valid;
    wire [X1_WIDTH*PE_NUM-1:0]  rq_out;
    wire                        rq_valid;
    wire                        argmx_en;
    wire                        argmx_valid;

    wire acc_en, acc_sel;

    assign x_rd_data = (x1_rd_valid) ? x1_rd_data :
                       (x2_rd_valid) ? x2_rd_data :
                       (x3_rd_valid) ? x3_rd_data : {X1_WIDTH{1'b0}};

    assign w_rd_data = (w1_rd_valid) ? w1_rd_data :
                       (w2_rd_valid) ? w2_rd_data :
                       (w3_rd_valid) ? w3_rd_data : {W1_WIDTH{1'b0}}; 

    assign b_rd_valid = (b1_rd_valid) | (b2_rd_valid) | (b3_rd_valid);
    assign b_rd_data = (b1_rd_valid) ? b1_rd_data :
                       (b2_rd_valid) ? b2_rd_data :
                       (b3_rd_valid) ? b3_rd_data : {B1_WIDTH{1'b0}}; 

    // ---------------------------------
    // Controller
    // ---------------------------------
    Controller #(
        .STATE_SIZE   (4),
        .FSM_IN_SIZE  (4+10),
        .FSM_OUT_SIZE (19)
    ) controller_inst (
        .clk         (clk),
        .reset       (reset),

        .exec_ready  ({fc2_exec_ready, fc1_exec_ready, fc0_exec_ready}),
        .exec_valid  (exec),
        .li_end      (li_end),
        .lo_end      (lo_end),
        .pb_valid    (pb_valid),
        .rq_valid    (rq_valid),
        .argmx_valid (argmx_valid),
        .tready      (tready),

        .li_rd_en    (li_rd_en),
        .lo_rd_en    (lo_rd_en),
        .xw_rd_en    ({xw3_rd_en, xw2_rd_en, xw1_rd_en}),   // [2:0]
        .acc_en      (acc_en),
        .acc_sel     (acc_sel),
        .li_incr     (li_incr),
        .li_clear    (li_clear),
        .lo_incr     (lo_incr),
        .lo_clear    (lo_clear),
        .b_rd_en     ({b3_rd_en, b2_rd_en, b1_rd_en}),      // [2:0]
        .rq_rd_en    (rq_rd_en),
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
        .BLOOP(LI_WIDTH)
    ) u_inner_counter (
        .clk            (clk),
        .reset          (reset),
        .lp_load        (li_rd_valid),
        .loop_in        (li_rd_data),
        .lp_clear       (li_clear),
        .lp_incr        (li_incr),
        .lp_end         (li_end)
        // --- dbg ---
        // , .loop_cnt_dbg (li_cnt_dbg)
        // , .loop_out_dbg (li_out_dbg)
    );

    Counter #(
        .BLOOP(LO_WIDTH)
    ) u_outer_counter (
        .clk            (clk),
        .reset          (reset),
        .lp_load        (lo_rd_valid),
        .loop_in        (lo_rd_data),
        .lp_clear       (lo_clear),
        .lp_incr        (lo_incr),
        .lp_end         (lo_end)
        // --- dbg ---
        // , .loop_cnt_dbg (lo_cnt_dbg)
        // , .loop_out_dbg (lo_out_dbg)
    );

    // ---------------------------------
    // Memory Bank 
    // ---------------------------------
    memory_bank #(
        .X1_WIDTH (X1_WIDTH), .X1_DEPTH (X1_DEPTH),
        .X2_WIDTH (X2_WIDTH), .X2_DEPTH (X2_DEPTH), .X2_VEC_ELEMS (X2_VEC_ELEMS),
        .X3_WIDTH (X3_WIDTH), .X3_DEPTH (X3_DEPTH), .X3_VEC_ELEMS (X3_VEC_ELEMS),
        .W1_WIDTH (W1_WIDTH), .W1_DEPTH (W1_DEPTH),
        .W2_WIDTH (W2_WIDTH), .W2_DEPTH (W2_DEPTH),
        .W3_WIDTH (W3_WIDTH), .W3_DEPTH (W3_DEPTH),
        .B1_WIDTH (B1_WIDTH), .B1_DEPTH (B1_DEPTH),
        .B2_WIDTH (B2_WIDTH), .B2_DEPTH (B2_DEPTH),
        .B3_WIDTH (B3_WIDTH), .B3_DEPTH (B3_DEPTH),
        .SC_WIDTH (SC_WIDTH), .SC_DEPTH (SC_DEPTH),
        .SH_WIDTH (SH_WIDTH), .SH_DEPTH (SH_DEPTH),
        .ZP_WIDTH (ZP_WIDTH), .ZP_DEPTH (ZP_DEPTH),
        .LI_WIDTH (LI_WIDTH), .LI_DEPTH (LI_DEPTH),
        .LO_WIDTH (LO_WIDTH), .LO_DEPTH (LO_DEPTH)
    ) u_mem_bank (
        .clk    (clk),
        .reset  (reset),

        // writes
        .x1_wr_en(x1_wr_en), .x1_wr_data(x1_wr_data),

        .x2_wr_en(x2_wr_en), .x2_wr_vec_data(rq_out),
        .x3_wr_en(x3_wr_en), .x3_wr_vec_data(rq_out),

        .w1_wr_en(w1_wr_en), .w1_wr_data(w1_wr_data),
        .w2_wr_en(w2_wr_en), .w2_wr_data(w2_wr_data),
        .w3_wr_en(w3_wr_en), .w3_wr_data(w3_wr_data),

        .b1_wr_en(b1_wr_en), .b1_wr_data(b1_wr_data),
        .b2_wr_en(b2_wr_en), .b2_wr_data(b2_wr_data),
        .b3_wr_en(b3_wr_en), .b3_wr_data(b3_wr_data),

        .sc_wr_en(sc_wr_en), .sc_wr_data(sc_wr_data),
        .sh_wr_en(sh_wr_en), .sh_wr_data(sh_wr_data),
        .zp_wr_en(zp_wr_en), .zp_wr_data(zp_wr_data),

        .li_wr_en(li_wr_en), .li_wr_data(li_wr_data),
        .lo_wr_en(lo_wr_en), .lo_wr_data(lo_wr_data),

        // reads
        .x1_rd_en(xw1_rd_en), .x1_rd_data(x1_rd_data), .x1_rd_valid(x1_rd_valid),
        .x2_rd_en(xw2_rd_en), .x2_rd_data(x2_rd_data), .x2_rd_valid(x2_rd_valid),
        .x3_rd_en(xw3_rd_en), .x3_rd_data(x3_rd_data), .x3_rd_valid(x3_rd_valid),

        .w1_rd_en(xw1_rd_en), .w1_rd_data(w1_rd_data), .w1_rd_valid(w1_rd_valid),
        .w2_rd_en(xw2_rd_en), .w2_rd_data(w2_rd_data), .w2_rd_valid(w2_rd_valid),
        .w3_rd_en(xw3_rd_en), .w3_rd_data(w3_rd_data), .w3_rd_valid(w3_rd_valid),

        .b1_rd_en(b1_rd_en), .b1_rd_data(b1_rd_data), .b1_rd_valid(b1_rd_valid),
        .b2_rd_en(b2_rd_en), .b2_rd_data(b2_rd_data), .b2_rd_valid(b2_rd_valid),
        .b3_rd_en(b3_rd_en), .b3_rd_data(b3_rd_data), .b3_rd_valid(b3_rd_valid),

        .sc_rd_en(rq_rd_en), .sc_rd_data(sc_rd_data), .sc_rd_valid(sc_rd_valid),
        .sh_rd_en(rq_rd_en), .sh_rd_data(sh_rd_data), .sh_rd_valid(sh_rd_valid),
        .zp_rd_en(rq_rd_en), .zp_rd_data(zp_rd_data), .zp_rd_valid(zp_rd_valid),
        
        .li_rd_en(li_rd_en), .li_rd_data(li_rd_data), .li_rd_valid(li_rd_valid),
        .lo_rd_en(lo_rd_en), .lo_rd_data(lo_rd_data), .lo_rd_valid(lo_rd_valid),

        // status (new)
        .fc0_exec_ready(fc0_exec_ready),
        .fc1_exec_ready(fc1_exec_ready),
        .fc2_exec_ready(fc2_exec_ready)

        // --- dbg ---
        // , .x1_full_dbg(x1_full_dbg)
        // , .w1_full_dbg(w1_full_dbg)
        // , .w2_full_dbg(w2_full_dbg)
        // , .w3_full_dbg(w3_full_dbg)
        // , .b1_full_dbg(b1_full_dbg)
        // , .b2_full_dbg(b2_full_dbg)
        // , .b3_full_dbg(b3_full_dbg)
        // , .sc_full_dbg(sc_full_dbg)
        // , .sh_full_dbg(sh_full_dbg)
        // , .zp_full_dbg(zp_full_dbg)
        // , .li_full_dbg(li_full_dbg)
        // , .lo_full_dbg(lo_full_dbg)
    );

    // ---------------------------------
    // OPU / postProc / requant?��既存�?
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

    postProc #(
        .PE_NUM(PE_NUM),
        .ACC_SIZE(ACC_SIZE)
    ) pb_inst (
        .clk            (clk),
        .reset          (reset),
        .acc_vec        (acc_out),
        .bias_vec       (b_rd_data),
        .bias_valid     (b_rd_valid),
        .pb_vec         (pb_out),
        .pb_valid       (pb_valid)
    );

    requant #(
        .PE_NUM         (PE_NUM),
        .ACC_SIZE       (ACC_SIZE)
    ) requant_inst (
        .clk            (clk),
        .reset          (reset),
        .scale_load     (sc_rd_valid),
        .scale_in       (sc_rd_data),
        .shift_load     (sh_rd_valid),
        .shift_in       (sh_rd_data),
        .zp_load        (zp_rd_valid),
        .zp_in          (zp_rd_data),
        .in_vec         (pb_out),
        .in_valid       (sc_rd_valid & sh_rd_valid & zp_rd_valid),
        .out_vec        (rq_out),
        .out_valid      (rq_valid)
    );

    argmax #(
        .WIDTH      (ACC_SIZE),
        .LABEL_N    (LABEL_N),
        .VEC_ELEMS  (X3_VEC_ELEMS),
        .OUT_WIDTH  (OUT_WIDTH)
    ) argmax_inst (
        .clk            (clk),
        .reset          (reset),
        .en             (argmx_en),
        .pb_vec         (pb_out),
        .label          (argmx_out),
        .valid          (argmx_valid)
    );

    // --- dbg ---
    
    // assign exec_ready_dbg = {fc2_exec_ready, fc1_exec_ready, fc0_exec_ready};
    // assign fc0_exec_ready_dbg = fc0_exec_ready;
    // assign fc1_exec_ready_dbg = fc1_exec_ready;
    // assign fc2_exec_ready_dbg = fc2_exec_ready;

    // assign xw1_rd_en_dbg    = xw1_rd_en;
    // assign xw2_rd_en_dbg    = xw2_rd_en;
    // assign xw3_rd_en_dbg    = xw3_rd_en;

    // assign x1_rd_data_dbg  = x1_rd_data;
    // assign x1_rd_valid_dbg = x1_rd_valid;
    // assign x2_rd_data_dbg   = x2_rd_data;
    // assign x2_rd_valid_dbg  = x2_rd_valid;
    // assign x3_rd_data_dbg   = x3_rd_data;
    // assign x3_rd_valid_dbg  = x3_rd_valid;

    // assign w1_rd_data_dbg  = w1_rd_data;
    // assign w1_rd_valid_dbg = w1_rd_valid;
    // assign w2_rd_data_dbg  = w2_rd_data;
    // assign w2_rd_valid_dbg = w2_rd_valid;
    // assign w3_rd_data_dbg  = w3_rd_data;
    // assign w3_rd_valid_dbg = w3_rd_valid;

    // assign b1_rd_en_dbg    = b1_rd_en;
    // assign b1_rd_data_dbg  = b1_rd_data;
    // assign b1_rd_valid_dbg = b1_rd_valid;
    // assign b2_rd_en_dbg    = b2_rd_en;
    // assign b2_rd_data_dbg  = b2_rd_data;
    // assign b2_rd_valid_dbg = b2_rd_valid;
    // assign b3_rd_en_dbg    = b3_rd_en;
    // assign b3_rd_data_dbg  = b3_rd_data;
    // assign b3_rd_valid_dbg = b3_rd_valid;

    // assign rq_rd_en_dbg    = rq_rd_en;
    // assign sc_rd_data_dbg  = sc_rd_data;
    // assign sc_rd_valid_dbg = sc_rd_valid;
    // assign sh_rd_data_dbg  = sh_rd_data;
    // assign sh_rd_valid_dbg = sh_rd_valid;
    // assign zp_rd_data_dbg  = zp_rd_data;
    // assign zp_rd_valid_dbg = zp_rd_valid;

    // assign x2_wr_en_dbg   = x2_wr_en;
    // assign x3_wr_en_dbg   = x3_wr_en;

    // assign acc_en_dbg      = acc_en;
    // assign acc_sel_dbg     = acc_sel;

    // assign li_rd_en_dbg     = li_rd_en;
    // assign lo_rd_en_dbg     = lo_rd_en;
    // assign li_rd_data_dbg   = li_rd_data;
    // assign lo_rd_data_dbg   = lo_rd_data;
    // assign li_rd_valid_dbg  = li_rd_valid;
    // assign lo_rd_valid_dbg  = lo_rd_valid;
    // assign li_end_dbg       = li_end;
    // assign lo_end_dbg       = lo_end;
    // assign li_clear_dbg     = li_clear;
    // assign li_incr_dbg      = li_incr;
    // assign lo_clear_dbg     = lo_clear;
    // assign lo_incr_dbg      = lo_incr;

    // assign acc_out_dbg     = acc_out;
    // assign pb_out_dbg      = pb_out;
    // assign pb_valid_dbg    = pb_valid;

endmodule
