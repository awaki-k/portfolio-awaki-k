// 3x3 window generator (single channel)
// One pixel per cycle. win_valid after row>=2 && col>=2.
module LineBuffer_3x3 #(
    parameter WIDTH = 28,        // pixels per line
    parameter DW    = 8
)(
    input  wire             clk,
    input  wire             reset,      // Active-High synchronous reset
    input  wire             in_valid,
    input  wire [DW-1:0]    in_pixel,

    output reg              win_valid,
    output reg  [DW*9-1:0]  win_flat    // {r2c2,r2c1,r2c0,r1c2,r1c1,r1c0,r0c2,r0c1,r0c0}
);

    // ----------------------------------------------------------------
    // Two line buffers (previous two rows), ping-pong assignment
    // ----------------------------------------------------------------
    reg [DW-1:0] bufA [0:WIDTH-1];
    reg [DW-1:0] bufB [0:WIDTH-1];

    // Column counter and "have at least 2 rows" counter
    localparam CW = (WIDTH <= 2) ? 2 : $clog2(WIDTH);
    reg [CW-1:0] col;
    reg [1:0]    rowcnt;   // 0,1,2 (saturates at 2)

    // Which buffer is row-1 / row-2 this line
    reg phase; // 0: r1=bufA, r2=bufB, write=>bufB ; 1: r1=bufB, r2=bufA, write=>bufA

    // Horizontal taps for 3 rows
    reg [DW-1:0] r0_d1, r0_d2;  // current row (stream)
    reg [DW-1:0] r1_d1, r1_d2;  // row-1
    reg [DW-1:0] r2_d1, r2_d2;  // row-2

    // Read current column from row-1 / row-2 BEFORE writing
    wire [DW-1:0] r1_now = phase ? bufB[col] : bufA[col];
    wire [DW-1:0] r2_now = phase ? bufA[col] : bufB[col];

    // ----------------------------------------------------------------
    // Main sequential logic
    // ----------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            col       <= {CW{1'b0}};
            rowcnt    <= 2'd0;
            phase     <= 1'b0;
            r0_d1     <= {DW{1'b0}}; r0_d2 <= {DW{1'b0}};
            r1_d1     <= {DW{1'b0}}; r1_d2 <= {DW{1'b0}};
            r2_d1     <= {DW{1'b0}}; r2_d2 <= {DW{1'b0}};
            win_valid <= 1'b0;
            win_flat  <= {DW*9{1'b0}};
        end else begin
            win_valid <= 1'b0; // default

            if (in_valid) begin
                // Compose 3x3 window from taps and current reads
                win_flat <= {
                    in_pixel,  r0_d1, r0_d2,
                    r1_now,    r1_d1, r1_d2,
                    r2_now,    r2_d1, r2_d2
                };
                // win_flat <= {
                //     r2_d2, r2_d1, r2_now,
                //     r1_d2, r1_d1, r1_now,
                //     r0_d2, r0_d1, in_pixel
                // };
                win_valid <= (rowcnt >= 2) && (col >= 2);

                // Shift horizontal taps
                r2_d2 <= r2_d1; r2_d1 <= r2_now;
                r1_d2 <= r1_d1; r1_d1 <= r1_now;
                r0_d2 <= r0_d1; r0_d1 <= in_pixel;

                // Write current row into the buffer that currently holds row-2
                if (phase) begin
                    // r1=bufB, r2=bufA -> write bufA
                    bufA[col] <= in_pixel;
                end else begin
                    // r1=bufA, r2=bufB -> write bufB
                    bufB[col] <= in_pixel;
                end

                // Advance column / end-of-line handling
                if (col == WIDTH-1) begin
                    col    <= {CW{1'b0}};
                    phase  <= ~phase;                  // swap row-1/row-2 roles
                    if (rowcnt != 2) rowcnt <= rowcnt + 1'b1;

                    // Clear horizontal taps at the start of each new line
                    r0_d1 <= {DW{1'b0}}; r0_d2 <= {DW{1'b0}};
                    r1_d1 <= {DW{1'b0}}; r1_d2 <= {DW{1'b0}};
                    r2_d1 <= {DW{1'b0}}; r2_d2 <= {DW{1'b0}};
                end else begin
                    col <= col + 1'b1;
                end
            end
        end
    end
endmodule
