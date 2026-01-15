// ============================================================
// memory_bank.v
// - ring_fifo を 10 本 (X1/W1/W2/W3/B1/B2/B3/SC/SH/ZP) 束ねる
// - li と lo 用の FIFO を追加
// - exec_ready = AND(all_full)
// ============================================================

module memory_bank_rom #(
    parameter integer X1_WIDTH      = 4,
    parameter integer X1_DEPTH      = 14*14,
    parameter integer X2_WIDTH      = 4,
    parameter integer X2_DEPTH      = 32,
    parameter integer X2_VEC_ELEMS  = 32,
    parameter integer X3_WIDTH      = 4,
    parameter integer X3_DEPTH      = 16,
    parameter integer X3_VEC_ELEMS  = 16,
    // parameter integer X3_VEC_ELEMS  = 32,

    parameter integer W1_WIDTH      = 4*32,
    parameter integer W1_DEPTH      = 14*14,
    parameter integer W2_WIDTH      = 4*32,
    parameter integer W2_DEPTH      = 32,
    parameter integer W3_WIDTH      = 4*32,
    parameter integer W3_DEPTH      = 16,
    
    // parameter integer B1_WIDTH      = 16*32,
    // parameter integer B1_DEPTH      = 1,
    // parameter integer B2_WIDTH      = 16*32,
    // parameter integer B2_DEPTH      = 1,
    // parameter integer B3_WIDTH      = 16*32,
    // parameter integer B3_DEPTH      = 1,
    
    // parameter integer SC_WIDTH      = 24,
    // parameter integer SC_DEPTH      = 3,
    // parameter integer SH_WIDTH      = 8,
    // parameter integer SH_DEPTH      = 3,
    // parameter integer ZP_WIDTH      = 8,
    // parameter integer ZP_DEPTH      = 3,

    parameter integer LI_WIDTH      = 8,
    parameter integer LI_DEPTH      = 3,
    parameter integer LO_WIDTH      = 1,
    parameter integer LO_DEPTH      = 3
)(
    input  wire clk,
    input  wire reset,

    // ----------------------------
    // Write Ports
    // ----------------------------
    input  wire                             x1_wr_en,
    input  wire [X1_WIDTH-1:0]              x1_wr_data,

    input  wire                             x2_wr_en,
    input  wire [X2_WIDTH*X2_VEC_ELEMS-1:0] x2_wr_vec_data,

    input  wire                             x3_wr_en,
    input  wire [X3_WIDTH*X3_VEC_ELEMS-1:0] x3_wr_vec_data,


    // ----------------------------
    // Read Ports
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

    // input  wire                             b1_rd_en,
    // output wire [B1_WIDTH-1:0]              b1_rd_data,
    // output wire                             b1_rd_valid,

    // input  wire                             b2_rd_en,
    // output wire [B2_WIDTH-1:0]              b2_rd_data,
    // output wire                             b2_rd_valid,

    // input  wire                             b3_rd_en,
    // output wire [B3_WIDTH-1:0]              b3_rd_data,
    // output wire                             b3_rd_valid,

    // input  wire                             sc_rd_en,
    // output wire [SC_WIDTH-1:0]              sc_rd_data,
    // output wire                             sc_rd_valid,

    // input  wire                             sh_rd_en,
    // output wire [SH_WIDTH-1:0]              sh_rd_data,
    // output wire                             sh_rd_valid,

    // input  wire                             zp_rd_en,
    // output wire [ZP_WIDTH-1:0]              zp_rd_data,
    // output wire                             zp_rd_valid,

    input  wire                             li_rd_en,
    output wire [LI_WIDTH-1:0]              li_rd_data,
    output wire                             li_rd_valid,
    
    input  wire                             lo_rd_en,
    output wire [LO_WIDTH-1:0]              lo_rd_data,
    output wire                             lo_rd_valid,

    // ----------------------------
    // status
    // ----------------------------
    output wire [2:0]                       exec_ready

    // --- dbg ---
    , output wire [9:0]                    x1_wptr_dbg
);

    // full flags from each fifo
    wire x1_full, x2_full, x3_full;

    // exec_ready = AND(*_full)
    assign exec_ready = {x3_full, x2_full, x1_full};

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
        // --- dbg ---
        , .wptr_dbg  (x1_wptr_dbg)
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
    W1_ring_fifo_rom #(
        .WIDTH(W1_WIDTH), 
        .DEPTH(W1_DEPTH)
    ) w1_ring_fifo_rom_inst (
        .clk        (clk), 
        .reset      (reset),
        .rd_en      (w1_rd_en), 
        .rd_data    (w1_rd_data), 
        .rd_valid   (w1_rd_valid)
    );
    // W2
    W2_ring_fifo_rom #(
        .WIDTH(W2_WIDTH), 
        .DEPTH(W2_DEPTH)
    ) w2_ring_fifo_rom_inst (
        .clk        (clk), 
        .reset      (reset),
        .rd_en      (w2_rd_en), 
        .rd_data    (w2_rd_data), 
        .rd_valid   (w2_rd_valid)
    );
    // W3
    W3_ring_fifo_rom #(
        .WIDTH(W3_WIDTH), 
        .DEPTH(W3_DEPTH)
    ) w3_ring_fifo_rom_inst (
        .clk        (clk), 
        .reset      (reset),
        .rd_en      (w3_rd_en), 
        .rd_data    (w3_rd_data), 
        .rd_valid   (w3_rd_valid)
    );
    // // B1
    // B1_ring_fifo_rom #(
    //     .WIDTH(B1_WIDTH), 
    //     .DEPTH(B1_DEPTH)
    // ) b1_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (b1_rd_en), 
    //     .rd_data    (b1_rd_data), 
    //     .rd_valid   (b1_rd_valid)
    // );
    // // B2
    // B2_ring_fifo_rom #(
    //     .WIDTH(B2_WIDTH), 
    //     .DEPTH(B2_DEPTH)
    // ) b2_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (b2_rd_en), 
    //     .rd_data    (b2_rd_data), 
    //     .rd_valid   (b2_rd_valid)
    // );
    // // B3
    // B3_ring_fifo_rom #(
    //     .WIDTH(B3_WIDTH), 
    //     .DEPTH(B3_DEPTH)
    // ) b3_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (b3_rd_en), 
    //     .rd_data    (b3_rd_data), 
    //     .rd_valid   (b3_rd_valid)
    // );
    // // SC
    // SC_ring_fifo_rom #(
    //     .WIDTH(SC_WIDTH), 
    //     .DEPTH(SC_DEPTH)
    // ) sc_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (sc_rd_en), 
    //     .rd_data    (sc_rd_data), 
    //     .rd_valid   (sc_rd_valid)
    // );
    // // SH
    // SH_ring_fifo_rom #(
    //     .WIDTH(SH_WIDTH), 
    //     .DEPTH(SH_DEPTH)
    // ) sh_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (sh_rd_en), 
    //     .rd_data    (sh_rd_data), 
    //     .rd_valid   (sh_rd_valid)
    // );
    // // ZP
    // ZP_ring_fifo_rom #(
    //     .WIDTH(ZP_WIDTH), 
    //     .DEPTH(ZP_DEPTH)
    // ) zp_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (zp_rd_en), 
    //     .rd_data    (zp_rd_data), 
    //     .rd_valid   (zp_rd_valid)
    // );
    // // LI
    // LI_ring_fifo_rom #(
    //     .WIDTH(LI_WIDTH), 
    //     .DEPTH(LI_DEPTH)
    // ) li_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (li_rd_en), 
    //     .rd_data    (li_rd_data), 
    //     .rd_valid   (li_rd_valid)
    // );
    // // LO
    // LO_ring_fifo_rom #(
    //     .WIDTH(LO_WIDTH), 
    //     .DEPTH(LO_DEPTH)
    // ) lo_ring_fifo_rom_inst (
    //     .clk        (clk), 
    //     .reset      (reset),
    //     .rd_en      (lo_rd_en), 
    //     .rd_data    (lo_rd_data), 
    //     .rd_valid   (lo_rd_valid)
    // );

endmodule

module W1_ring_fifo_rom #(
    parameter integer WIDTH = 128,
    parameter integer DEPTH = 196
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             rd_en,
    output reg  [WIDTH-1:0] rd_data,
    output reg              rd_valid
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

    // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
    reg [AW-1:0] addr;
    // 次の読み位置（リングバッファのポインタ）
    reg [AW-1:0] rptr;

    // リング用インクリメント
    function [AW-1:0] inc_ptr;
        input [AW-1:0] p;
        begin
            inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
        end
    endfunction

    // ポインタ & valid 制御
    //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
    always @(posedge clk) begin
        if (reset) begin
            addr     <= {AW{1'b0}};
            rptr     <= {AW{1'b0}};
            rd_valid <= 1'b0;
        end else begin
            if (rd_en) begin
                addr     <= rptr;          // 今の rptr をこのサイクルで使う
                rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
                rd_valid <= 1'b1;
            end else begin
                rd_valid <= 1'b0;
            end
        end
    end

    // ROM 本体（ここに Python 生成の case 文を貼る）
    always @* begin
        case (addr)
            // =================================================
            // AUTO-GENERATED ROM DATA BEGIN
            // =================================================

// Auto-generated ROM table for fc1 weights (4-bit)
// Width: 4 bits * 32 lanes = 128 bits
// addr -> rd_data (one 32-lane vector per address)

        0: rd_data = 128'h0000f0f0f0001000000000000010f00f;
        1: rd_data = 128'h00f00f00f0000f0000001eff1011f011;
        2: rd_data = 128'heff02001e1effe1f10020f002213e112;
        3: rd_data = 128'heeef2f13e0e0fe1f0f020ff03233e222;
        4: rd_data = 128'hcced3e13e1f1fd1e3f031dff4433c323;
        5: rd_data = 128'hbbee3df4c3f2eb2f10f51c0f4443c345;
        6: rd_data = 128'hcbde4cf3c202eb3ef2140d0f3434b334;
        7: rd_data = 128'hdbfd4ef2d000fd2ee312de311412c233;
        8: rd_data = 128'hedfd4de2ef10fc3fe211fd201421e143;
        9: rd_data = 128'hedde2e03d0f1ec3ff202fd0e3333d233;
        10: rd_data = 128'hedde3d13c1f1fd1de002fc0e2233c334;
        11: rd_data = 128'hfedf2ef2d110ee1ff0111d1f1323d333;
        12: rd_data = 128'hff0f1fe1e02f1f21e011fe110211e012;
        13: rd_data = 128'hff000fe00f101f10e0110f11f10f0000;
        14: rd_data = 128'h10f10000000f1111f000f0000f00000f;
        15: rd_data = 128'h00f0110100f0f10001ffffff0012f001;
        16: rd_data = 128'h1d001102ef00f12ee21fe01ff0f10f20;
        17: rd_data = 128'h0c1f20f2ef100e3ff211fe100212ef33;
        18: rd_data = 128'h0b2e3ef2ef10fe2111120d211232df33;
        19: rd_data = 128'h0b3f3ed2df2ffd4102232c202232cf34;
        20: rd_data = 128'h0b2f4ec3ce2dfe40f3221c211223de33;
        21: rd_data = 128'hfc1040d3dc0efe40e421ed201332c023;
        22: rd_data = 128'hfe1f30f2dc01ef40f320fd1f1132f112;
        23: rd_data = 128'hed002013eb02d02f0210fc0e2133e213;
        24: rd_data = 128'hfee02f24db03d02ef10ffd0f2113f213;
        25: rd_data = 128'heecf3f23ede2effe1000fdf0211304f3;
        26: rd_data = 128'h0fe11f11edf2ef000010fef02122f202;
        27: rd_data = 128'h10011101fff00f21f1001fff2120e001;
        28: rd_data = 128'h1110000100010111010f110ff0f0f010;
        29: rd_data = 128'h102020e2f1100120e20ee00fd0ef1e3e;
        30: rd_data = 128'h1f1021d3f011f02fe22fe010e0e02d3f;
        31: rd_data = 128'h1e3f10e10f11f12ff2300e1fe1f01c30;
        32: rd_data = 128'h1f4f00e1002ff01212201f1100200c21;
        33: rd_data = 128'h2e4f01000f1d0022223220110120fd00;
        34: rd_data = 128'h2e3f100f001c102212322121012fee11;
        35: rd_data = 128'h2e2f11000e1c101222221032121ff1f2;
        36: rd_data = 128'h0f2011001f1f0f1122322f21223101e3;
        37: rd_data = 128'h0e00001f0e010f1102100e11222212d2;
        38: rd_data = 128'hffd2102ffdf200ff1200fe12121213c2;
        39: rd_data = 128'hefd2013f0ee4f0ee102eedf1301323b1;
        40: rd_data = 128'h10e2f241fed2f1ff122dddef2f0424d1;
        41: rd_data = 128'h30f10232ffd01121022e0efe2f22f4d1;
        42: rd_data = 128'h011f1fd1122f0112fff11e0f0000ee30;
        43: rd_data = 128'h012e2fc103300110d11f0f2fdfdf0c3f;
        44: rd_data = 128'h002f21d20331f12ff23e0e0fefe00d2f;
        45: rd_data = 128'h212f10e22330022012302e0f0f00fc11;
        46: rd_data = 128'h214001022220021111301e0f1f00fe10;
        47: rd_data = 128'h32510211121e1123211020001020fe00;
        48: rd_data = 128'h214211002e1d112410f11321232eef10;
        49: rd_data = 128'h215112102b0c102310d12311123dff00;
        50: rd_data = 128'h3221020e2c0e001321d3121f122e0ff0;
        51: rd_data = 128'h2201f2fd101ff11101101101101e0fe0;
        52: rd_data = 128'h2302020e0200f101021f1001100ff0d0;
        53: rd_data = 128'h12e2d12d23f3f0f1213f0de12ef313c2;
        54: rd_data = 128'h30c3d3610fc2e101333deddf3e1406c3;
        55: rd_data = 128'h40e2e343dfc10132033ddeef2e02f4c2;
        56: rd_data = 128'h111f1ed1123e0121ef012f1f00ffed3f;
        57: rd_data = 128'h111e3fc3f53e1121e23f2f1fe0eeec4f;
        58: rd_data = 128'h112e21e2043e1130f2402f1fffeeec20;
        59: rd_data = 128'h312d1102130e1211013f30ff0fffee11;
        60: rd_data = 128'h2120f222230e11121f202000100fe011;
        61: rd_data = 128'h3121f121131e21f31f1f22f0201ef101;
        62: rd_data = 128'h1220f101200e20020ee12200121ee010;
        63: rd_data = 128'h132111df0f2e2113d0d2223f131ddd4f;
        64: rd_data = 128'h1211f1ee10301222ffe0221f011dfd3e;
        65: rd_data = 128'h3212f3ee231f01221120310f1f0e0dff;
        66: rd_data = 128'h322102ff020ef22301202f0010feffe1;
        67: rd_data = 128'h3302d22e23e0f112202f3ddf2e01f2c1;
        68: rd_data = 128'h52d6a5510fb1c123333b3cbc5c35c5b4;
        69: rd_data = 128'h62e4d554ccbfe243e52afede4c13d3b2;
        70: rd_data = 128'h122e1dc3033e1133d0f13f0efffece3f;
        71: rd_data = 128'h323d10d3f42d0032d13f2f1efffddb3f;
        72: rd_data = 128'h222d010222fe1110f12f310ff0feed1f;
        73: rd_data = 128'h220fd34212c022e02e1f22e01f1f01f1;
        74: rd_data = 128'h2200d23113c013d12e0f12e01f00f3d1;
        75: rd_data = 128'h1412c13213c213c12d0021e02f0214e0;
        76: rd_data = 128'h13c2e21211c2f2f00f003ede2f13d4f1;
        77: rd_data = 128'h24d233e2d1ee3221d1ee023fe2d0bf30;
        78: rd_data = 128'h131011e113212421f00f1210deff1d3e;
        79: rd_data = 128'h322ff2ef222f03120f132201ee0f1e2e;
        80: rd_data = 128'h231df2d0121d02021f033111f11e0f0f;
        81: rd_data = 128'h230ef00f21fd00f20b1331f0011fd2f2;
        82: rd_data = 128'h50d4d431efccdf140d0e4dcc4033b4b4;
        83: rd_data = 128'h61d6f643bcbde153c3290fcd4d13c2b1;
        84: rd_data = 128'h132d0ed3042f1122df003e0defeede3e;
        85: rd_data = 128'h241ef2e4121f2212d00f320ffdedec4e;
        86: rd_data = 128'h130fd32321c1f4d01fe012df1d1f0eff;
        87: rd_data = 128'hf3f1c23311c2f4d12ed111de1d0222ef;
        88: rd_data = 128'h0212d22311e3e3e010e001e1fe0322ff;
        89: rd_data = 128'h0f22d2221ef5d3f02ff0ffdf1d2432f1;
        90: rd_data = 128'h2ee20330ead2e11e112fe0f02f2214d2;
        91: rd_data = 128'h31e12323ddc0452de21ed534c1def4ff;
        92: rd_data = 128'h232f033401e3240f1f00e311dd00212d;
        93: rd_data = 128'h211f03021ff0f2011f021311fe0e3f1e;
        94: rd_data = 128'h020c00011eff02d12d042212f10f2110;
        95: rd_data = 128'hc0fb0d012e00f09029f41f000312e311;
        96: rd_data = 128'hedec1df000fefdb139042e011322c204;
        97: rd_data = 128'h11111f0df00d2e11ef4e0243f2eefff0;
        98: rd_data = 128'h010010d2f20f0021e11f1e0ffff1ee21;
        99: rd_data = 128'h033f01f101010210e20ef100efde1d1d;
        100: rd_data = 128'he21ff1022f02e1d01fd100e11f002e0f;
        101: rd_data = 128'hc110f0111e24c2d01fd210f110133f00;
        102: rd_data = 128'hef21ff011c24d2f010d2ffe111122e11;
        103: rd_data = 128'hfd42f11f2b24d0012003fde1214231f2;
        104: rd_data = 128'h3d213320ece11f2f124fd223031023e3;
        105: rd_data = 128'h21004333d0e1331d023fd343d4d02301;
        106: rd_data = 128'h1330f132201313ff2f00f211eef1313e;
        107: rd_data = 128'h023011021013f2111ff100f0ee013e3e;
        108: rd_data = 128'he11f21f30f13e2000fe11eef0f011f2f;
        109: rd_data = 128'hdffe2ff31f02d0e10dd21eee0013f130;
        110: rd_data = 128'hee0e2ee1f02f0c010ef21e001322ef23;
        111: rd_data = 128'hff4d2cdb225d4c21ef520454c5ec1c3f;
        112: rd_data = 128'h1f0020f1010ff01fe20fff00fff10e20;
        113: rd_data = 128'h2f2141c0e01eff41e32de011e1ef1c2f;
        114: rd_data = 128'hff3110df1f40de22f1001ff1120f2b00;
        115: rd_data = 128'hd01f0e001c23e0e11e010f0101013ef1;
        116: rd_data = 128'he11c0e2f192300d02c04201102202111;
        117: rd_data = 128'hff3dfe3f2c1220e13c14203213200202;
        118: rd_data = 128'hf11e3120020f31fe1040e133f4ef13f2;
        119: rd_data = 128'hf1201231121222ee112ed123f1df422f;
        120: rd_data = 128'h0251d2203033f2122f111101fe004f2e;
        121: rd_data = 128'h104110011123d21211001eff01111d31;
        122: rd_data = 128'hff2020f10022f01010f10efe00110d21;
        123: rd_data = 128'h0f2020f2ff10ef22020f2f0f1112fe20;
        124: rd_data = 128'h0d3f2eee013c1c22f1310f2213100c22;
        125: rd_data = 128'hee5c1bda346b4b22f0540455d6ec1b51;
        126: rd_data = 128'h100101e202f0e110f10f1efe0f12fd10;
        127: rd_data = 128'h3d3231d1e02def41d31cee1f0100fc2f;
        128: rd_data = 128'h2e2210de0e3ddd33f22e1e0f211f1bf1;
        129: rd_data = 128'h1e1200ff1c1dee1110202ff121213dc1;
        130: rd_data = 128'h0f0e0f1e0d0d0e012d2220111221f2f3;
        131: rd_data = 128'hfefd1e10110e1ee02c242e211333c303;
        132: rd_data = 128'hd00f2021041020f00e20ff2203e2f212;
        133: rd_data = 128'he1221212122212f0000ff11201e21021;
        134: rd_data = 128'h0f3121120012e02211011e0122331f12;
        135: rd_data = 128'h1e202101ff10f01103110e1012210f12;
        136: rd_data = 128'h1e1000010e0eff1112100f1112110e02;
        137: rd_data = 128'h1d202000ff1d1d22132f1f113221fd02;
        138: rd_data = 128'hfc2e1e0d023c2c1110400132241e0b13;
        139: rd_data = 128'hdd3e0ddb133c3b020f330243e4dc0b32;
        140: rd_data = 128'h2e1201f10200df20f1f01e0f1011ed11;
        141: rd_data = 128'h2d2230d0f02ede21e32ffe100100fb21;
        142: rd_data = 128'h2e1110fd0e2cec22f3201e21221f0de1;
        143: rd_data = 128'h3f0110fd0e0ced22123f1f21131efed2;
        144: rd_data = 128'h1d0120fff01c0d1102211e102310e0e3;
        145: rd_data = 128'h0ef01f0ff21ffd2200121d103324d113;
        146: rd_data = 128'hff0f20130212f0011ff22d1f3225d223;
        147: rd_data = 128'h0f002113f113f11111010e101323f224;
        148: rd_data = 128'h1d102112f012f02f02110f021222f013;
        149: rd_data = 128'h0d3f1011ff101e200230ff111210f002;
        150: rd_data = 128'h1e2000300e1e1d11133ff0223220fee2;
        151: rd_data = 128'h0d10e02e1f0d0d121230ff12322efde3;
        152: rd_data = 128'hfd20fe1d012d1e02102f0022130e0b02;
        153: rd_data = 128'hfe1f0eed023d2d12f0210122f3fdfc21;
        154: rd_data = 128'h1f1120e1f01fee11021ffd0f10110f11;
        155: rd_data = 128'h2d1220e0ef1dee21f31dee201101ee22;
        156: rd_data = 128'h1e1120eff02cfe10e200ff2102ffde10;
        157: rd_data = 128'h110020edf02d1e12f1211120030eee00;
        158: rd_data = 128'h121110fd110e0f01f1100111120f0ff1;
        159: rd_data = 128'h1111f1ff211e0001110220101110f0f2;
        160: rd_data = 128'h101ff21022fe0212211330f02130e3e3;
        161: rd_data = 128'h21000211120f0021212220002120f2e3;
        162: rd_data = 128'h1011111102ff0010132f01011100f2e2;
        163: rd_data = 128'h0d31013f01001f1f233ee013120000e1;
        164: rd_data = 128'hfd30e02f10101e00313fd01322101ed0;
        165: rd_data = 128'hff30df3d2f1f0ef22f10f001211e0de0;
        166: rd_data = 128'hff30ef2d111f1ff21f01f111121d0d0f;
        167: rd_data = 128'h0e0f1f0fe10f1f10f110f0000100fe10;
        168: rd_data = 128'h1f0011020ffff010f100f00f0011f001;
        169: rd_data = 128'h202323d3f00fd122e3ed0dfd0f01ec30;
        170: rd_data = 128'h222313c4ef11e222c2de00fdfde0ec4d;
        171: rd_data = 128'h122122d3ff100312e2ee11feddeefd3c;
        172: rd_data = 128'h222212e20f00f322f2ff11fefd0e0f2f;
        173: rd_data = 128'h322202f200fff243020f21fe0f2df010;
        174: rd_data = 128'h403203f2120df234021f30fd1f2de011;
        175: rd_data = 128'h3131f202130e0133010030ff1f1de101;
        176: rd_data = 128'h3131e22112ff0113010021000f1ef00f;
        177: rd_data = 128'h3132e22111e0110201ed1201001dffde;
        178: rd_data = 128'h1131c23f1eef12e100edf321000d1edd;
        179: rd_data = 128'h1032e12e1fff00f20fefe211101e0dee;
        180: rd_data = 128'h1030f00ff00f0f110fff0101101ffe0f;
        181: rd_data = 128'hff0f1ffff0101e0ff210d01211000f11;
        182: rd_data = 128'h0f0001000ff0f00011000010010010f0;
        183: rd_data = 128'h0211e3f12f00f3010fd111fefe000e2e;
        184: rd_data = 128'h0331e4f31f1013f2eed012eeecfd1d1c;
        185: rd_data = 128'h3331f3d31e201323dfde13fdddfd1e3c;
        186: rd_data = 128'h4241e4d31e2e1343d0dd230eddec0d2d;
        187: rd_data = 128'h5332e5e30e1d0343d0ee23fefdfc0e2d;
        188: rd_data = 128'h6240e4e32e1c0344efde23fdfd0cfe3e;
        189: rd_data = 128'h5430d3d3201c1434decf43fcfc0cde3c;
        190: rd_data = 128'h6440d3d31f0b1325bfcf620bfd0dcd3d;
        191: rd_data = 128'h5431e3e21fdc2326cfde531cee1cdc4c;
        192: rd_data = 128'h5243e4010fdd1204dfce230efe2dfd1d;
        193: rd_data = 128'h3223e2010fee0213dfde21fd0e10fe0e;
        194: rd_data = 128'h2112f201efef0113e0ee10ff1f1ffff0;
        195: rd_data = 128'hf00f100f0f101f01f0110001110f0011;

            // =================================================
            // AUTO-GENERATED ROM DATA END
            // =================================================
            default: rd_data = {WIDTH{1'b0}};
        endcase
    end
endmodule


module W2_ring_fifo_rom #(
    parameter integer WIDTH = 128,
    parameter integer DEPTH = 32
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             rd_en,
    output reg  [WIDTH-1:0] rd_data,
    output reg              rd_valid
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

    // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
    reg [AW-1:0] addr;
    // 次の読み位置（リングバッファのポインタ）
    reg [AW-1:0] rptr;

    // リング用インクリメント
    function [AW-1:0] inc_ptr;
        input [AW-1:0] p;
        begin
            inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
        end
    endfunction

    // ポインタ & valid 制御
    //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
    always @(posedge clk) begin
        if (reset) begin
            addr     <= {AW{1'b0}};
            rptr     <= {AW{1'b0}};
            rd_valid <= 1'b0;
        end else begin
            if (rd_en) begin
                addr     <= rptr;          // 今の rptr をこのサイクルで使う
                rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
                rd_valid <= 1'b1;
            end else begin
                rd_valid <= 1'b0;
            end
        end
    end

    // ROM 本体（ここに Python 生成の case 文を貼る）
    always @* begin
        case (addr)
            // =================================================
            // AUTO-GENERATED ROM DATA BEGIN
            // =================================================

// Auto-generated ROM table for fc2 weights (4-bit)
// Width: 4 bits * 32 lanes = 128 bits
// addr -> rd_data (one 32-lane vector per address)

        0: rd_data = 128'h0000000000000000e111e21d0220113f;
        1: rd_data = 128'h0000000000000000321e3101d1df1101;
        2: rd_data = 128'h0000000000000000dd30cd2f113e1f20;
        3: rd_data = 128'h0000000000000000fd2331c3340f1c0c;
        4: rd_data = 128'h0000000000000000d212f11fd010332e;
        5: rd_data = 128'h0000000000000000e1012f0e0202f222;
        6: rd_data = 128'h0000000000000000022e031e23f12020;
        7: rd_data = 128'h0000000000000000e2f1001f13221220;
        8: rd_data = 128'h00000000000000000e3ff2f030ff1d1e;
        9: rd_data = 128'h00000000000000002f2e032f21ef1ef0;
        10: rd_data = 128'h00000000000000002e2d10023ff2eee2;
        11: rd_data = 128'h000000000000000023ef1e0ff221f023;
        12: rd_data = 128'h0000000000000000001e21edf21ee133;
        13: rd_data = 128'h00000000000000002113f02d301e0e2d;
        14: rd_data = 128'h000000000000000011f3e22e2fe2f1ed;
        15: rd_data = 128'h0000000000000000f0221fe001210f30;
        16: rd_data = 128'h000000000000000012e121111111f122;
        17: rd_data = 128'h000000000000000022f2132e1ee2f200;
        18: rd_data = 128'h00000000000000002f211f03fd20f0e1;
        19: rd_data = 128'h00000000000000003e1d010120fe2d21;
        20: rd_data = 128'h0000000000000000e02230e3d12d31ed;
        21: rd_data = 128'h000000000000000022f043d0f2ee100e;
        22: rd_data = 128'h000000000000000056ff211cf2095b4b;
        23: rd_data = 128'h000000000000000010f13ee20220f021;
        24: rd_data = 128'h000000000000000000310f32eeff2201;
        25: rd_data = 128'h0000000000000000ef32fe2221101f10;
        26: rd_data = 128'h00000000000000001f1210212e2202f1;
        27: rd_data = 128'h0000000000000000201f023d0fd132ff;
        28: rd_data = 128'h0000000000000000e1d3f1121e1203ef;
        29: rd_data = 128'h0000000000000000222231021201f011;
        30: rd_data = 128'h000000000000000030ef1e030e210de2;
        31: rd_data = 128'h000000000000000021f2f0102e02f002;


            // =================================================
            // AUTO-GENERATED ROM DATA END
            // =================================================
            default: rd_data = {WIDTH{1'b0}};
        endcase
    end
endmodule


module W3_ring_fifo_rom #(
    parameter integer WIDTH = 128,
    parameter integer DEPTH = 16
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             rd_en,
    output reg  [WIDTH-1:0] rd_data,
    output reg              rd_valid
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

    // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
    reg [AW-1:0] addr;
    // 次の読み位置（リングバッファのポインタ）
    reg [AW-1:0] rptr;

    // リング用インクリメント
    function [AW-1:0] inc_ptr;
        input [AW-1:0] p;
        begin
            inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
        end
    endfunction

    // ポインタ & valid 制御
    //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
    always @(posedge clk) begin
        if (reset) begin
            addr     <= {AW{1'b0}};
            rptr     <= {AW{1'b0}};
            rd_valid <= 1'b0;
        end else begin
            if (rd_en) begin
                addr     <= rptr;          // 今の rptr をこのサイクルで使う
                rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
                rd_valid <= 1'b1;
            end else begin
                rd_valid <= 1'b0;
            end
        end
    end

    // ROM 本体（ここに Python 生成の case 文を貼る）
    always @* begin
        case (addr)
            // =================================================
            // AUTO-GENERATED ROM DATA BEGIN
            // =================================================
// Auto-generated ROM table for fc3 weights (4-bit)
// Width: 4 bits * 32 lanes = 128 bits
// addr -> rd_data (one 32-lane vector per address)

        0: rd_data = 128'h0000000000000000000000533de9fbb2;
        1: rd_data = 128'h0000000000000000000000f4d3ffc3c2;
        2: rd_data = 128'h0000000000000000000000ebe12d4c04;
        3: rd_data = 128'h00000000000000000000009c4510b14d;
        4: rd_data = 128'h00000000000000000000002feb5c4c14;
        5: rd_data = 128'h0000000000000000000000020023adc4;
        6: rd_data = 128'h00000000000000000000001ec3f2c4d3;
        7: rd_data = 128'h000000000000000000000024a90fe34c;
        8: rd_data = 128'h00000000000000000000006a2b03deec;
        9: rd_data = 128'h0000000000000000000000d1f03c2c4b;
        10: rd_data = 128'h0000000000000000000000db10cc454f;
        11: rd_data = 128'h00000000000000000000002c40e31293;
        12: rd_data = 128'h0000000000000000000000d1cf533dae;
        13: rd_data = 128'h000000000000000000000023d6c3002b;
        14: rd_data = 128'h0000000000000000000000ae313c33b3;
        15: rd_data = 128'h0000000000000000000000f16baf223b;

            // =================================================
            // AUTO-GENERATED ROM DATA END
            // =================================================
            default: rd_data = {WIDTH{1'b0}};
        endcase
    end
endmodule


// module B1_ring_fifo_rom #(
//     parameter integer WIDTH = 512,
//     parameter integer DEPTH = 1
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

// // Auto-generated ROM table for fc1 bias (16-bit)
// // Width: 16 bits * 32 lanes = 512 bits
// // addr -> rd_data (one 32-lane vector per address)

//         0: rd_data = 512'h00030022001f002e001a00270010002700110008000f0027fffe001f000f0018fffb0012ffeeffe2000200090009fffb001c0011000c001a000afffb00190003;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module B2_ring_fifo_rom #(
//     parameter integer WIDTH = 512,
//     parameter integer DEPTH = 1
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

// // Auto-generated ROM table for fc2 bias (16-bit)
// // Width: 16 bits * 32 lanes = 512 bits
// // addr -> rd_data (one 32-lane vector per address)

//         0: rd_data = 512'h0000000000000000000000000000000000000000000000000000000000000000000200000001ffff00010002000200050001000100020003000400010000ffff;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module B3_ring_fifo_rom #(
//     parameter integer WIDTH = 512,
//     parameter integer DEPTH = 1
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

// // Auto-generated ROM table for fc3 bias (16-bit)
// // Width: 16 bits * 32 lanes = 512 bits
// // addr -> rd_data (one 32-lane vector per address)

//         0: rd_data = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010002ffff00000000ffff;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module SC_ring_fifo_rom #(
//     parameter integer WIDTH = 24,
//     parameter integer DEPTH = 4
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

//             0: rd_data = 24'h067797;
//             1: rd_data = 24'h067797;
//             2: rd_data = 24'h377E80;
//             3: rd_data = 24'h24179E;


//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module SH_ring_fifo_rom #(
//     parameter integer WIDTH = 8,
//     parameter integer DEPTH = 4
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

//             0: rd_data = 8'h1E;
//             1: rd_data = 8'h1E;
//             2: rd_data = 8'h1E;
//             3: rd_data = 8'h1E;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module ZP_ring_fifo_rom #(
//     parameter integer WIDTH = 8,
//     parameter integer DEPTH = 4
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction


//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

//             0: rd_data = 8'h00;
//             1: rd_data = 8'h00;
//             2: rd_data = 8'h00;
//             3: rd_data = 8'h9B;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule


// module LI_ring_fifo_rom #(
//     parameter integer WIDTH = 8,
//     parameter integer DEPTH = 3
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

//             0: rd_data = 8'hc4;
//             1: rd_data = 8'h20;
//             2: rd_data = 8'h10;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule



// module LO_ring_fifo_rom #(
//     parameter integer WIDTH = 1,
//     parameter integer DEPTH = 3
// )(
//     input  wire             clk,
//     input  wire             reset,
//     input  wire             rd_en,
//     output reg  [WIDTH-1:0] rd_data,
//     output reg              rd_valid
// );


//     function integer clog2;
//         input integer v;
//         integer i;
//         begin
//             v = v - 1;
//             for (i = 0; v > 0; i = i + 1)
//                 v = v >> 1;
//             clog2 = (i < 1) ? 1 : i;
//         end
//     endfunction

//     localparam integer AW = clog2(DEPTH);

//     // 実際に ROM を引くアドレス（FIFO の「今読む位置」）
//     reg [AW-1:0] addr;
//     // 次の読み位置（リングバッファのポインタ）
//     reg [AW-1:0] rptr;

//     // リング用インクリメント
//     function [AW-1:0] inc_ptr;
//         input [AW-1:0] p;
//         begin
//             inc_ptr = (p == DEPTH-1) ? {AW{1'b0}} : (p + 1'b1);
//         end
//     endfunction

//     // ポインタ & valid 制御
//     //  - 初回 rd_en=1 のサイクルで addr=0 が出るようにしてある
//     always @(posedge clk) begin
//         if (reset) begin
//             addr     <= {AW{1'b0}};
//             rptr     <= {AW{1'b0}};
//             rd_valid <= 1'b0;
//         end else begin
//             if (rd_en) begin
//                 addr     <= rptr;          // 今の rptr をこのサイクルで使う
//                 rptr     <= inc_ptr(rptr); // 次の位置へ進めておく
//                 rd_valid <= 1'b1;
//             end else begin
//                 rd_valid <= 1'b0;
//             end
//         end
//     end

//     // ROM 本体（ここに Python 生成の case 文を貼る）
//     always @* begin
//         case (addr)
//             // =================================================
//             // AUTO-GENERATED ROM DATA BEGIN
//             // =================================================

//             0: rd_data = 1'h1;
//             1: rd_data = 1'h1;
//             2: rd_data = 1'h1;

//             // =================================================
//             // AUTO-GENERATED ROM DATA END
//             // =================================================
//             default: rd_data = {WIDTH{1'b0}};
//         endcase
//     end
// endmodule