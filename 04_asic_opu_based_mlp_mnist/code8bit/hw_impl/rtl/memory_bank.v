// ============================================================
// memory_bank.v
// - ring_fifo を 10 本 (X1/W1/W2/W3/B1/B2/B3/SC/SH/ZP) 束ねる
// - li と lo 用の FIFO を追加
// - exec_ready = AND(all_full)
// ============================================================

module memory_bank #(
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
    parameter integer W2_DEPTH      = 64,
    parameter integer W3_WIDTH      = 8*32,
    parameter integer W3_DEPTH      = 32,
    
    parameter integer B1_WIDTH      = 32*32,
    parameter integer B1_DEPTH      = 2,
    parameter integer B2_WIDTH      = 32*32,
    parameter integer B2_DEPTH      = 1,
    parameter integer B3_WIDTH      = 32*32,
    parameter integer B3_DEPTH      = 1,
    
    parameter integer SC_WIDTH      = 24,
    parameter integer SC_DEPTH      = 3,
    parameter integer SH_WIDTH      = 8,
    parameter integer SH_DEPTH      = 3,
    parameter integer ZP_WIDTH      = 8,
    parameter integer ZP_DEPTH      = 3,

    parameter integer LI_WIDTH = 12,
    parameter integer LI_DEPTH = 3,
    parameter integer LO_WIDTH = 4,
    parameter integer LO_DEPTH = 3
)(
    input  wire clk,
    input  wire reset,

    // ----------------------------
    // TB -> memory_bank write ports
    // ----------------------------
    input  wire                             x1_wr_en,
    input  wire [X1_WIDTH-1:0]              x1_wr_data,

    input  wire                             x2_wr_en,
    input  wire [X2_WIDTH*X2_VEC_ELEMS-1:0] x2_wr_vec_data,

    input  wire                             x3_wr_en,
    input  wire [X3_WIDTH*X3_VEC_ELEMS-1:0] x3_wr_vec_data,

    input  wire                             w1_wr_en,
    input  wire [W1_WIDTH-1:0]              w1_wr_data,

    input  wire                             w2_wr_en,
    input  wire [W2_WIDTH-1:0]              w2_wr_data,

    input  wire                             w3_wr_en,
    input  wire [W3_WIDTH-1:0]              w3_wr_data,

    input  wire                             b1_wr_en,
    input  wire [B1_WIDTH-1:0]              b1_wr_data,

    input  wire                             b2_wr_en,
    input  wire [B2_WIDTH-1:0]              b2_wr_data,

    input  wire                             b3_wr_en,
    input  wire [B3_WIDTH-1:0]              b3_wr_data,

    input  wire                             sc_wr_en,
    input  wire [SC_WIDTH-1:0]              sc_wr_data,

    input  wire                             sh_wr_en,
    input  wire [SH_WIDTH-1:0]              sh_wr_data,

    input  wire                             zp_wr_en,
    input  wire [ZP_WIDTH-1:0]              zp_wr_data,

    input  wire                             li_wr_en,
    input  wire [LI_WIDTH-1:0]              li_wr_data,
    
    input  wire                             lo_wr_en,
    input  wire [LO_WIDTH-1:0]              lo_wr_data,

    // ----------------------------
    // (optional) read ports
    // ----------------------------
    input  wire                             x1_rd_en,
    output wire [X1_WIDTH-1:0]              x1_rd_data,
    output wire                             x1_rd_valid,

    input  wire                             x2_rd_en,
    output wire [X2_WIDTH-1:0]              x2_rd_data,
    output wire                             x2_rd_valid,

    input  wire                             x3_rd_en,
    output wire [X3_WIDTH-1:0]              x3_rd_data,
    output wire                             x3_rd_valid,
    
    input  wire                             w1_rd_en,
    output wire [W1_WIDTH-1:0]              w1_rd_data,
    output wire                             w1_rd_valid,

    input  wire                             w2_rd_en,
    output wire [W2_WIDTH-1:0]              w2_rd_data,
    output wire                             w2_rd_valid,

    input  wire                             w3_rd_en,
    output wire [W3_WIDTH-1:0]              w3_rd_data,
    output wire                             w3_rd_valid,

    input  wire                             b1_rd_en,
    output wire [B1_WIDTH-1:0]              b1_rd_data,
    output wire                             b1_rd_valid,

    input  wire                             b2_rd_en,
    output wire [B2_WIDTH-1:0]              b2_rd_data,
    output wire                             b2_rd_valid,

    input  wire                             b3_rd_en,
    output wire [B3_WIDTH-1:0]              b3_rd_data,
    output wire                             b3_rd_valid,

    input  wire                             sc_rd_en,
    output wire [SC_WIDTH-1:0]              sc_rd_data,
    output wire                             sc_rd_valid,

    input  wire                             sh_rd_en,
    output wire [SH_WIDTH-1:0]              sh_rd_data,
    output wire                             sh_rd_valid,

    input  wire                             zp_rd_en,
    output wire [ZP_WIDTH-1:0]              zp_rd_data,
    output wire                             zp_rd_valid,

    input  wire                             li_rd_en,
    output wire [LI_WIDTH-1:0]              li_rd_data,
    output wire                             li_rd_valid,
    
    input  wire                             lo_rd_en,
    output wire [LO_WIDTH-1:0]              lo_rd_data,
    output wire                             lo_rd_valid,

    // ----------------------------
    // status
    // ----------------------------
    output wire                             fc0_exec_ready,
    output wire                             fc1_exec_ready,
    output wire                             fc2_exec_ready

    // --- dbg ---
    // , output wire                           x1_full_dbg
    // , output wire                           x2_full_dbg
    // , output wire                           x3_full_dbg
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

    // full flags from each fifo
    wire x1_full, x2_full, x3_full;
    wire w1_full, w2_full, w3_full;
    wire b1_full, b2_full, b3_full;
    wire sc_full, sh_full, zp_full;
    
    wire li_full, lo_full;

    // exec_ready = AND(*_full)
    assign fc0_exec_ready = x1_full & w1_full & b1_full & sc_full & sh_full & zp_full & li_full & lo_full;
    assign fc1_exec_ready = x2_full & w2_full & b2_full;
    assign fc2_exec_ready = x3_full & w3_full & b3_full;

    // X1
    ring_fifo #(
        .WIDTH(X1_WIDTH), 
        .DEPTH(X1_DEPTH)
    ) x1_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (x1_wr_en), 
        .wr_data    (x1_wr_data),
        .rd_en      (x1_rd_en), 
        .rd_data    (x1_rd_data), 
        .rd_valid   (x1_rd_valid),
        .full       (x1_full)
    );
    // X2
    ring_fifo_vecpush_scalarpop #(
        .WIDTH     (X2_WIDTH),
        .DEPTH     (X2_DEPTH),
        .VEC_ELEMS (X2_VEC_ELEMS)
    ) x2_fifo_inst (
        .clk        (clk),
        .reset      (reset),
        .wr_en      (x2_wr_en),
        .wr_vec_data(x2_wr_vec_data),
        .rd_en      (x2_rd_en),
        .rd_data    (x2_rd_data),
        .rd_valid   (x2_rd_valid),
        .full       (x2_full)
    );
    // X3
    ring_fifo_vecpush_scalarpop #(
        .WIDTH     (X3_WIDTH),
        .DEPTH     (X3_DEPTH),
        .VEC_ELEMS (X3_VEC_ELEMS)
    ) x3_fifo_inst (
        .clk        (clk),
        .reset      (reset),
        .wr_en      (x3_wr_en),
        .wr_vec_data(x3_wr_vec_data),
        .rd_en      (x3_rd_en),
        .rd_data    (x3_rd_data),
        .rd_valid   (x3_rd_valid),
        .full       (x3_full)
    );
    // W1
    ring_fifo #(
        .WIDTH(W1_WIDTH), 
        .DEPTH(W1_DEPTH)
    ) w1_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (w1_wr_en), 
        .wr_data    (w1_wr_data),
        .rd_en      (w1_rd_en), 
        .rd_data    (w1_rd_data), 
        .rd_valid   (w1_rd_valid),
        .full       (w1_full)
    );
    // W2
    ring_fifo #(
        .WIDTH(W2_WIDTH), 
        .DEPTH(W2_DEPTH)
    ) w2_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (w2_wr_en), 
        .wr_data    (w2_wr_data),
        .rd_en      (w2_rd_en), 
        .rd_data    (w2_rd_data), 
        .rd_valid   (w2_rd_valid),
        .full       (w2_full)
    );
    // W3
    ring_fifo #(
        .WIDTH(W3_WIDTH), 
        .DEPTH(W3_DEPTH)
    ) w3_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (w3_wr_en), 
        .wr_data    (w3_wr_data),
        .rd_en      (w3_rd_en), 
        .rd_data    (w3_rd_data), 
        .rd_valid   (w3_rd_valid),
        .full       (w3_full)
    );
    // B1
    ring_fifo #(
        .WIDTH(B1_WIDTH), 
        .DEPTH(B1_DEPTH)
    ) b1_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (b1_wr_en), 
        .wr_data    (b1_wr_data),
        .rd_en      (b1_rd_en), 
        .rd_data    (b1_rd_data), 
        .rd_valid   (b1_rd_valid),
        .full       (b1_full)
    );
    // B2
    ring_fifo #(
        .WIDTH(B2_WIDTH), 
        .DEPTH(B2_DEPTH)
    ) b2_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (b2_wr_en), 
        .wr_data    (b2_wr_data),
        .rd_en      (b2_rd_en), 
        .rd_data    (b2_rd_data), 
        .rd_valid   (b2_rd_valid),
        .full       (b2_full)
    );
    // B3
    ring_fifo #(
        .WIDTH(B3_WIDTH), 
        .DEPTH(B3_DEPTH)
    ) b3_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (b3_wr_en), 
        .wr_data    (b3_wr_data),
        .rd_en      (b3_rd_en), 
        .rd_data    (b3_rd_data), 
        .rd_valid   (b3_rd_valid),
        .full       (b3_full)
    );
    // SC
    ring_fifo #(
        .WIDTH(SC_WIDTH), 
        .DEPTH(SC_DEPTH)
    ) sc_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (sc_wr_en), 
        .wr_data    (sc_wr_data),
        .rd_en      (sc_rd_en), 
        .rd_data    (sc_rd_data), 
        .rd_valid   (sc_rd_valid),
        .full       (sc_full)
    );
    // SH
    ring_fifo #(
        .WIDTH(SH_WIDTH), 
        .DEPTH(SH_DEPTH)
    ) sh_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (sh_wr_en), 
        .wr_data    (sh_wr_data),
        .rd_en      (sh_rd_en), 
        .rd_data    (sh_rd_data), 
        .rd_valid   (sh_rd_valid),
        .full       (sh_full)
    );
    // ZP
    ring_fifo #(
        .WIDTH(ZP_WIDTH), 
        .DEPTH(ZP_DEPTH)
    ) zp_ring_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (zp_wr_en), 
        .wr_data    (zp_wr_data),
        .rd_en      (zp_rd_en), 
        .rd_data    (zp_rd_data), 
        .rd_valid   (zp_rd_valid),
        .full       (zp_full)
    );
    // LI
    ring_fifo #(
        .WIDTH(LI_WIDTH), 
        .DEPTH(LI_DEPTH)
    ) li_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (li_wr_en), 
        .wr_data    (li_wr_data),
        .rd_en      (li_rd_en), 
        .rd_data    (li_rd_data), 
        .rd_valid   (li_rd_valid),
        .full       (li_full)
    );
    // LO
    ring_fifo #(
        .WIDTH(LO_WIDTH), 
        .DEPTH(LO_DEPTH)
    ) lo_fifo_inst (
        .clk        (clk), 
        .reset      (reset),
        .wr_en      (lo_wr_en), 
        .wr_data    (lo_wr_data),
        .rd_en      (lo_rd_en), 
        .rd_data    (lo_rd_data), 
        .rd_valid   (lo_rd_valid),
        .full       (lo_full)
    );

    // --- dbg ---
    // assign x1_full_dbg = x1_full;
    // assign x2_full_dbg = x2_full;
    // assign x3_full_dbg = x3_full;
    // assign w1_full_dbg = w1_full;
    // assign w2_full_dbg = w2_full;
    // assign w3_full_dbg = w3_full;
    // assign b1_full_dbg = b1_full;
    // assign b2_full_dbg = b2_full;
    // assign b3_full_dbg = b3_full;
    // assign sc_full_dbg = sc_full;
    // assign sh_full_dbg = sh_full;
    // assign zp_full_dbg = zp_full;
    // assign li_full_dbg = li_full;
    // assign lo_full_dbg = lo_full;

endmodule
