module ring_fifo #(
    parameter integer WIDTH = 256,
    parameter integer DEPTH = 2
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             wr_en,
    input  wire [WIDTH-1:0] wr_data,
    input  wire             rd_en,
    output reg  [WIDTH-1:0] rd_data,
    output reg              rd_valid,
    output wire             full
    // --- dbg ---
    // , output wire [9:0]    wptr_dbg
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

    localparam integer AW = clog2(DEPTH);
    localparam integer UW = clog2(DEPTH + 1); // 0..DEPTH を表せる幅

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [AW-1:0]    wptr, rptr;

    function [AW-1:0] inc_ptr;
        input [AW-1:0] p;
        begin
            inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
        end
    endfunction

    // 占有数（外部制御なしでも壊れにくいよう saturate）
    reg [UW-1:0] used;
    assign full = (used == DEPTH[UW-1:0]);

    always @(posedge clk) begin
        if (reset) begin
            wptr     <= {AW{1'b0}};
            rptr     <= {AW{1'b0}};
            rd_data  <= {WIDTH{1'b0}};
            rd_valid <= 1'b0;
            used     <= {UW{1'b0}};
        end else begin
            rd_valid <= rd_en;

            // write（挙動はそのまま：wr_enで必ず書いて進める）
            if (wr_en) begin
                mem[wptr] <= wr_data;
                wptr <= inc_ptr(wptr);
            end

            // read（挙動はそのまま：rd_enで必ず読んで進める）
            if (rd_en) begin
                rd_data <= mem[rptr];
                rptr <= inc_ptr(rptr);
            end

            // used更新（wr/rdの影響を出すだけ。動作は変えない）
            case ({wr_en, rd_en})
                2'b10: begin
                    if (used < DEPTH[UW-1:0]) used <= used + 1'b1; // saturate
                end
                2'b01: begin
                    if (used > 0) used <= used - 1'b1;             // saturate
                end
                default: begin
                    used <= used; // 00 or 11
                end
            endcase
        end
    end

    // --- dbg ---
    // assign wptr_dbg = { { (10-AW){1'b0} } , wptr };

endmodule
