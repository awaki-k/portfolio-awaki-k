//
// Conformal-LEC: Version 11.10-s200 (28-Feb-2012) (64 bit executable)
//
module XOR3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  xor U$1(Y, A, B, C);
endmodule

module XOR3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  xor U$1(Y, A, B, C);
endmodule

module XOR2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xor U$1(Y, A, B);
endmodule

module XOR2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xor U$1(Y, A, B);
endmodule

module XOR2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xor U$1(Y, A, B);
endmodule

module XOR2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xor U$1(Y, A, B);
endmodule

module XNOR3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  xnor U$1(Y, A, B, C);
endmodule

module XNOR3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  xnor U$1(Y, A, B, C);
endmodule

module XNOR2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xnor U$1(Y, A, B);
endmodule

module XNOR2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xnor U$1(Y, A, B);
endmodule

module XNOR2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xnor U$1(Y, A, B);
endmodule

module XNOR2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  xnor U$1(Y, A, B);
endmodule

module TTLATXL(D, G, OE, Q);
input  D, G, OE;
output Q;
wire  D, G, OE, IQ, IQN, Q;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  bufif1 U$2(Q, IQ, OE);
endmodule

module TTLATX4(D, G, OE, Q);
input  D, G, OE;
output Q;
wire  D, G, OE, IQ, IQN, Q;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  bufif1 U$2(Q, IQ, OE);
endmodule

module TTLATX2(D, G, OE, Q);
input  D, G, OE;
output Q;
wire  D, G, OE, IQ, IQN, Q;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  bufif1 U$2(Q, IQ, OE);
endmodule

module TTLATX1(D, G, OE, Q);
input  D, G, OE;
output Q;
wire  D, G, OE, IQ, IQN, Q;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  bufif1 U$2(Q, IQ, OE);
endmodule

module TLATXL(D, G, Q, QN);
input  D, G;
output Q, QN;
wire  D, G, IQ, IQN, Q, QN;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module TLATX4(D, G, Q, QN);
input  D, G;
output Q, QN;
wire  D, G, IQ, IQN, Q, QN;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module TLATX2(D, G, Q, QN);
input  D, G;
output Q, QN;
wire  D, G, IQ, IQN, Q, QN;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module TLATX1(D, G, Q, QN);
input  D, G;
output Q, QN;
wire  D, G, IQ, IQN, Q, QN;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module TLATSXL(D, G, SN, Q, QN);
input  D, G, SN;
output Q, QN;
wire  D, G, SN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module TLATSX4(D, G, SN, Q, QN);
input  D, G, SN;
output Q, QN;
wire  D, G, SN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module TLATSX2(D, G, SN, Q, QN);
input  D, G, SN;
output Q, QN;
wire  D, G, SN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module TLATSX1(D, G, SN, Q, QN);
input  D, G, SN;
output Q, QN;
wire  D, G, SN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module TLATSRXL(D, G, SN, RN, Q, QN);
input  D, G, SN, RN;
output Q, QN;
wire  D, G, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module TLATSRX4(D, G, SN, RN, Q, QN);
input  D, G, SN, RN;
output Q, QN;
wire  D, G, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module TLATSRX2(D, G, SN, RN, Q, QN);
input  D, G, SN, RN;
output Q, QN;
wire  D, G, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module TLATSRX1(D, G, SN, RN, Q, QN);
input  D, G, SN, RN;
output Q, QN;
wire  D, G, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module TLATRXL(D, G, RN, Q, QN);
input  D, G, RN;
output Q, QN;
wire  D, G, RN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module TLATRX4(D, G, RN, Q, QN);
input  D, G, RN;
output Q, QN;
wire  D, G, RN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module TLATRX2(D, G, RN, Q, QN);
input  D, G, RN;
output Q, QN;
wire  D, G, RN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module TLATRX1(D, G, RN, Q, QN);
input  D, G, RN;
output Q, QN;
wire  D, G, RN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(G), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module TLATNXL(D, GN, Q, QN);
input  D, GN;
output Q, QN;
wire  D, GN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, GN);
endmodule

module TLATNX4(D, GN, Q, QN);
input  D, GN;
output Q, QN;
wire  D, GN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, GN);
endmodule

module TLATNX2(D, GN, Q, QN);
input  D, GN;
output Q, QN;
wire  D, GN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, GN);
endmodule

module TLATNX1(D, GN, Q, QN);
input  D, GN;
output Q, QN;
wire  D, GN, IQ, IQN, Q, QN, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, GN);
endmodule

module TLATNSXL(D, GN, SN, Q, QN);
input  D, GN, SN;
output Q, QN;
wire  D, GN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, GN);
endmodule

module TLATNSX4(D, GN, SN, Q, QN);
input  D, GN, SN;
output Q, QN;
wire  D, GN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, GN);
endmodule

module TLATNSX2(D, GN, SN, Q, QN);
input  D, GN, SN;
output Q, QN;
wire  D, GN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, GN);
endmodule

module TLATNSX1(D, GN, SN, Q, QN);
input  D, GN, SN;
output Q, QN;
wire  D, GN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, GN);
endmodule

module TLATNSRXL(D, GN, SN, RN, Q, QN);
input  D, GN, SN, RN;
output Q, QN;
wire  D, GN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, GN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module TLATNSRX4(D, GN, SN, RN, Q, QN);
input  D, GN, SN, RN;
output Q, QN;
wire  D, GN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, GN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module TLATNSRX2(D, GN, SN, RN, Q, QN);
input  D, GN, SN, RN;
output Q, QN;
wire  D, GN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, GN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module TLATNSRX1(D, GN, SN, RN, Q, QN);
input  D, GN, SN, RN;
output Q, QN;
wire  D, GN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, GN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module TLATNRXL(D, GN, RN, Q, QN);
input  D, GN, RN;
output Q, QN;
wire  D, GN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, GN);
endmodule

module TLATNRX4(D, GN, RN, Q, QN);
input  D, GN, RN;
output Q, QN;
wire  D, GN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, GN);
endmodule

module TLATNRX2(D, GN, RN, Q, QN);
input  D, GN, RN;
output Q, QN;
wire  D, GN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, GN);
endmodule

module TLATNRX1(D, GN, RN, Q, QN);
input  D, GN, RN;
output Q, QN;
wire  D, GN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, GN);
endmodule

module TIELO(Y);
// dont_use
output Y;
wire  Y;
  assign Y = 1'b0;
endmodule

module TIEHI(Y);
// dont_use
output Y;
wire  Y;
  assign Y = 1'b1;
endmodule

module TBUFXL(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX8(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX4(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX3(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX20(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX2(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX16(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX12(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFX1(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y;
  bufif1 U$1(Y, A, OE);
endmodule

module TBUFIXL(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX8(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX4(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX3(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX20(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX2(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX16(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX12(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module TBUFIX1(A, OE, Y);
input  A, OE;
output Y;
wire  A, OE, Y, n$1;
  bufif1 U$1(Y, n$1, OE);
  not U$2(n$1, A);
endmodule

module SEDFFXL(SI, SE, D, CK, E, Q, QN);
input  SI, SE, D, CK, E;
output Q, QN;
wire  SI, SE, D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, D);
  and U$10(n$7, n$8, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFX4(SI, SE, D, CK, E, Q, QN);
input  SI, SE, D, CK, E;
output Q, QN;
wire  SI, SE, D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, D);
  and U$10(n$7, n$8, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFX2(SI, SE, D, CK, E, Q, QN);
input  SI, SE, D, CK, E;
output Q, QN;
wire  SI, SE, D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, D);
  and U$10(n$7, n$8, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFX1(SI, SE, D, CK, E, Q, QN);
input  SI, SE, D, CK, E;
output Q, QN;
wire  SI, SE, D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, D);
  and U$10(n$7, n$8, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFTRXL(SI, SE, D, CK, E, RN, Q, QN);
input  SI, SE, D, CK, E, RN;
output Q, QN;
wire  SI, SE, D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, RN, D);
  and U$10(n$7, n$8, RN, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFTRX4(SI, SE, D, CK, E, RN, Q, QN);
input  SI, SE, D, CK, E, RN;
output Q, QN;
wire  SI, SE, D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, RN, D);
  and U$10(n$7, n$8, RN, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFTRX2(SI, SE, D, CK, E, RN, Q, QN);
input  SI, SE, D, CK, E, RN;
output Q, QN;
wire  SI, SE, D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, RN, D);
  and U$10(n$7, n$8, RN, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFTRX1(SI, SE, D, CK, E, RN, Q, QN);
input  SI, SE, D, CK, E, RN;
output Q, QN;
wire  SI, SE, D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, n$5);
  not U$7(n$4, SE);
  or U$8(n$5, n$6, n$7);
  and U$9(n$6, E, RN, D);
  and U$10(n$7, n$8, RN, IQ);
  not U$11(n$8, E);
endmodule

module SEDFFHQXL(SI, SE, D, CK, E, Q);
input  SI, SE, D, CK, E;
output Q;
wire  SI, SE, D, CK, E, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, n$5);
  not U$6(n$4, SE);
  or U$7(n$5, n$6, n$7);
  and U$8(n$6, E, D);
  and U$9(n$7, n$8, IQ);
  not U$10(n$8, E);
endmodule

module SEDFFHQX4(SI, SE, D, CK, E, Q);
input  SI, SE, D, CK, E;
output Q;
wire  SI, SE, D, CK, E, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, n$5);
  not U$6(n$4, SE);
  or U$7(n$5, n$6, n$7);
  and U$8(n$6, E, D);
  and U$9(n$7, n$8, IQ);
  not U$10(n$8, E);
endmodule

module SEDFFHQX2(SI, SE, D, CK, E, Q);
input  SI, SE, D, CK, E;
output Q;
wire  SI, SE, D, CK, E, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, n$5);
  not U$6(n$4, SE);
  or U$7(n$5, n$6, n$7);
  and U$8(n$6, E, D);
  and U$9(n$7, n$8, IQ);
  not U$10(n$8, E);
endmodule

module SEDFFHQX1(SI, SE, D, CK, E, Q);
input  SI, SE, D, CK, E;
output Q;
wire  SI, SE, D, CK, E, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, n$5);
  not U$6(n$4, SE);
  or U$7(n$5, n$6, n$7);
  and U$8(n$6, E, D);
  and U$9(n$7, n$8, IQ);
  not U$10(n$8, E);
endmodule

module SDFFXL(SI, SE, D, CK, Q, QN);
input  SI, SE, D, CK;
output Q, QN;
wire  SI, SE, D, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, D);
  not U$7(n$4, SE);
endmodule

module SDFFX4(SI, SE, D, CK, Q, QN);
input  SI, SE, D, CK;
output Q, QN;
wire  SI, SE, D, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, D);
  not U$7(n$4, SE);
endmodule

module SDFFX2(SI, SE, D, CK, Q, QN);
input  SI, SE, D, CK;
output Q, QN;
wire  SI, SE, D, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, D);
  not U$7(n$4, SE);
endmodule

module SDFFX1(SI, SE, D, CK, Q, QN);
input  SI, SE, D, CK;
output Q, QN;
wire  SI, SE, D, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, D);
  not U$7(n$4, SE);
endmodule

module SDFFTRXL(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, RN, D);
  not U$7(n$4, SE);
endmodule

module SDFFTRX4(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, RN, D);
  not U$7(n$4, SE);
endmodule

module SDFFTRX2(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, RN, D);
  not U$7(n$4, SE);
endmodule

module SDFFTRX1(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, SE, SI);
  and U$6(n$3, n$4, RN, D);
  not U$7(n$4, SE);
endmodule

module SDFFSXL(SI, SE, D, CK, SN, Q, QN);
input  SI, SE, D, CK, SN;
output Q, QN;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFSX4(SI, SE, D, CK, SN, Q, QN);
input  SI, SE, D, CK, SN;
output Q, QN;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFSX2(SI, SE, D, CK, SN, Q, QN);
input  SI, SE, D, CK, SN;
output Q, QN;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFSX1(SI, SE, D, CK, SN, Q, QN);
input  SI, SE, D, CK, SN;
output Q, QN;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFSRXL(SI, SE, D, CK, SN, RN, Q, QN);
input  SI, SE, D, CK, SN, RN;
output Q, QN;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
  not U$10(n$7, n$1);
  and U$11(n$8, n$7, n$2);
endmodule

module SDFFSRX4(SI, SE, D, CK, SN, RN, Q, QN);
input  SI, SE, D, CK, SN, RN;
output Q, QN;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
  not U$10(n$7, n$1);
  and U$11(n$8, n$7, n$2);
endmodule

module SDFFSRX2(SI, SE, D, CK, SN, RN, Q, QN);
input  SI, SE, D, CK, SN, RN;
output Q, QN;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
  not U$10(n$7, n$1);
  and U$11(n$8, n$7, n$2);
endmodule

module SDFFSRX1(SI, SE, D, CK, SN, RN, Q, QN);
input  SI, SE, D, CK, SN, RN;
output Q, QN;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
  not U$10(n$7, n$1);
  and U$11(n$8, n$7, n$2);
endmodule

module SDFFSRHQXL(SI, SE, D, CK, SN, RN, Q);
input  SI, SE, D, CK, SN, RN;
output Q;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  or U$5(n$3, n$4, n$5);
  and U$6(n$4, SE, SI);
  and U$7(n$5, n$6, D);
  not U$8(n$6, SE);
  not U$9(n$7, n$1);
  and U$10(n$8, n$7, n$2);
endmodule

module SDFFSRHQX4(SI, SE, D, CK, SN, RN, Q);
input  SI, SE, D, CK, SN, RN;
output Q;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  or U$5(n$3, n$4, n$5);
  and U$6(n$4, SE, SI);
  and U$7(n$5, n$6, D);
  not U$8(n$6, SE);
  not U$9(n$7, n$1);
  and U$10(n$8, n$7, n$2);
endmodule

module SDFFSRHQX2(SI, SE, D, CK, SN, RN, Q);
input  SI, SE, D, CK, SN, RN;
output Q;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  or U$5(n$3, n$4, n$5);
  and U$6(n$4, SE, SI);
  and U$7(n$5, n$6, D);
  not U$8(n$6, SE);
  not U$9(n$7, n$1);
  and U$10(n$8, n$7, n$2);
endmodule

module SDFFSRHQX1(SI, SE, D, CK, SN, RN, Q);
input  SI, SE, D, CK, SN, RN;
output Q;
wire  SI, SE, D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$8), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  or U$5(n$3, n$4, n$5);
  and U$6(n$4, SE, SI);
  and U$7(n$5, n$6, D);
  not U$8(n$6, SE);
  not U$9(n$7, n$1);
  and U$10(n$8, n$7, n$2);
endmodule

module SDFFSHQXL(SI, SE, D, CK, SN, Q);
input  SI, SE, D, CK, SN;
output Q;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFSHQX4(SI, SE, D, CK, SN, Q);
input  SI, SE, D, CK, SN;
output Q;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFSHQX2(SI, SE, D, CK, SN, Q);
input  SI, SE, D, CK, SN;
output Q;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFSHQX1(SI, SE, D, CK, SN, Q);
input  SI, SE, D, CK, SN;
output Q;
wire  SI, SE, D, CK, SN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFRXL(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFRX4(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFRX2(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFRX1(SI, SE, D, CK, RN, Q, QN);
input  SI, SE, D, CK, RN;
output Q, QN;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFRHQXL(SI, SE, D, CK, RN, Q);
input  SI, SE, D, CK, RN;
output Q;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFRHQX4(SI, SE, D, CK, RN, Q);
input  SI, SE, D, CK, RN;
output Q;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFRHQX2(SI, SE, D, CK, RN, Q);
input  SI, SE, D, CK, RN;
output Q;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFRHQX1(SI, SE, D, CK, RN, Q);
input  SI, SE, D, CK, RN;
output Q;
wire  SI, SE, D, CK, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
  or U$4(n$2, n$3, n$4);
  and U$5(n$3, SE, SI);
  and U$6(n$4, n$5, D);
  not U$7(n$5, SE);
endmodule

module SDFFNXL(SI, SE, D, CKN, Q, QN);
input  SI, SE, D, CKN;
output Q, QN;
wire  SI, SE, D, CKN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFNX4(SI, SE, D, CKN, Q, QN);
input  SI, SE, D, CKN;
output Q, QN;
wire  SI, SE, D, CKN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFNX2(SI, SE, D, CKN, Q, QN);
input  SI, SE, D, CKN;
output Q, QN;
wire  SI, SE, D, CKN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFNX1(SI, SE, D, CKN, Q, QN);
input  SI, SE, D, CKN;
output Q, QN;
wire  SI, SE, D, CKN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
  or U$5(n$2, n$3, n$4);
  and U$6(n$3, SE, SI);
  and U$7(n$4, n$5, D);
  not U$8(n$5, SE);
endmodule

module SDFFNSXL(SI, SE, D, CKN, SN, Q, QN);
input  SI, SE, D, CKN, SN;
output Q, QN;
wire  SI, SE, D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNSX4(SI, SE, D, CKN, SN, Q, QN);
input  SI, SE, D, CKN, SN;
output Q, QN;
wire  SI, SE, D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNSX2(SI, SE, D, CKN, SN, Q, QN);
input  SI, SE, D, CKN, SN;
output Q, QN;
wire  SI, SE, D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNSX1(SI, SE, D, CKN, SN, Q, QN);
input  SI, SE, D, CKN, SN;
output Q, QN;
wire  SI, SE, D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNSRXL(SI, SE, D, CKN, SN, RN, Q, QN);
input  SI, SE, D, CKN, SN, RN;
output Q, QN;
wire  SI, SE, D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$9), .CK(n$3), .D(n$4));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  or U$7(n$4, n$5, n$6);
  and U$8(n$5, SE, SI);
  and U$9(n$6, n$7, D);
  not U$10(n$7, SE);
  not U$11(n$8, n$1);
  and U$12(n$9, n$8, n$2);
endmodule

module SDFFNSRX4(SI, SE, D, CKN, SN, RN, Q, QN);
input  SI, SE, D, CKN, SN, RN;
output Q, QN;
wire  SI, SE, D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$9), .CK(n$3), .D(n$4));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  or U$7(n$4, n$5, n$6);
  and U$8(n$5, SE, SI);
  and U$9(n$6, n$7, D);
  not U$10(n$7, SE);
  not U$11(n$8, n$1);
  and U$12(n$9, n$8, n$2);
endmodule

module SDFFNSRX2(SI, SE, D, CKN, SN, RN, Q, QN);
input  SI, SE, D, CKN, SN, RN;
output Q, QN;
wire  SI, SE, D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$9), .CK(n$3), .D(n$4));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  or U$7(n$4, n$5, n$6);
  and U$8(n$5, SE, SI);
  and U$9(n$6, n$7, D);
  not U$10(n$7, SE);
  not U$11(n$8, n$1);
  and U$12(n$9, n$8, n$2);
endmodule

module SDFFNSRX1(SI, SE, D, CKN, SN, RN, Q, QN);
input  SI, SE, D, CKN, SN, RN;
output Q, QN;
wire  SI, SE, D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, 
    n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$9), .CK(n$3), .D(n$4));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  or U$7(n$4, n$5, n$6);
  and U$8(n$5, SE, SI);
  and U$9(n$6, n$7, D);
  not U$10(n$7, SE);
  not U$11(n$8, n$1);
  and U$12(n$9, n$8, n$2);
endmodule

module SDFFNRXL(SI, SE, D, CKN, RN, Q, QN);
input  SI, SE, D, CKN, RN;
output Q, QN;
wire  SI, SE, D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNRX4(SI, SE, D, CKN, RN, Q, QN);
input  SI, SE, D, CKN, RN;
output Q, QN;
wire  SI, SE, D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNRX2(SI, SE, D, CKN, RN, Q, QN);
input  SI, SE, D, CKN, RN;
output Q, QN;
wire  SI, SE, D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFNRX1(SI, SE, D, CKN, RN, Q, QN);
input  SI, SE, D, CKN, RN;
output Q, QN;
wire  SI, SE, D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
  or U$6(n$3, n$4, n$5);
  and U$7(n$4, SE, SI);
  and U$8(n$5, n$6, D);
  not U$9(n$6, SE);
endmodule

module SDFFHQXL(SI, SE, D, CK, Q);
input  SI, SE, D, CK;
output Q;
wire  SI, SE, D, CK, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, D);
  not U$6(n$4, SE);
endmodule

module SDFFHQX4(SI, SE, D, CK, Q);
input  SI, SE, D, CK;
output Q;
wire  SI, SE, D, CK, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, D);
  not U$6(n$4, SE);
endmodule

module SDFFHQX2(SI, SE, D, CK, Q);
input  SI, SE, D, CK;
output Q;
wire  SI, SE, D, CK, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, D);
  not U$6(n$4, SE);
endmodule

module SDFFHQX1(SI, SE, D, CK, Q);
input  SI, SE, D, CK;
output Q;
wire  SI, SE, D, CK, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  or U$3(n$1, n$2, n$3);
  and U$4(n$2, SE, SI);
  and U$5(n$3, n$4, D);
  not U$6(n$4, SE);
endmodule

module RFRDX4(RB, BRB);
// dont_use
input  RB;
output BRB;
wire  RB, BRB;
  not U$1(BRB, RB);
endmodule

module RFRDX2(RB, BRB);
// dont_use
input  RB;
output BRB;
wire  RB, BRB;
  not U$1(BRB, RB);
endmodule

module RFRDX1(RB, BRB);
// dont_use
input  RB;
output BRB;
wire  RB, BRB;
  not U$1(BRB, RB);
endmodule

module RF2R1WX2(WB, WW, R1W, R2W, R1B, R2B);
// dont_use
input  WB, WW, R1W, R2W;
output R1B, R2B;
wire  WB, WW, R1W, R2W, IQ, IQN, R1B, R2B, n$1;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(WW), .D(n$1));
  bufif1 U$2(R1B, IQ, R1W);
  bufif1 U$3(R2B, IQ, R2W);
  not U$4(n$1, WB);
endmodule

module RF1R1WX2(WW, WB, RW, RWN, RB);
// dont_use
input  WW, WB, RW, RWN;
output RB;
wire  WW, WB, RW, RWN, IQ, IQN, RB, n$1, n$2, n$3;
  _HDLAT_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(WW), .D(n$3));
  bufif1 U$2(RB, IQ, n$1);
  nand U$3(n$1, RWN, n$2);
  not U$4(n$2, RW);
  not U$5(n$3, WB);
endmodule

module OR4XL(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  or U$1(Y, A, B, C, D);
endmodule

module OR4X4(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  or U$1(Y, A, B, C, D);
endmodule

module OR4X2(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  or U$1(Y, A, B, C, D);
endmodule

module OR4X1(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  or U$1(Y, A, B, C, D);
endmodule

module OR3XL(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  or U$1(Y, A, B, C);
endmodule

module OR3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  or U$1(Y, A, B, C);
endmodule

module OR3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  or U$1(Y, A, B, C);
endmodule

module OR3X1(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  or U$1(Y, A, B, C);
endmodule

module OR2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  or U$1(Y, A, B);
endmodule

module OR2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  or U$1(Y, A, B);
endmodule

module OR2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  or U$1(Y, A, B);
endmodule

module OR2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  or U$1(Y, A, B);
endmodule

module OAI33XL(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1, B2);
endmodule

module OAI33X4(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1, B2);
endmodule

module OAI33X2(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1, B2);
endmodule

module OAI33X1(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1, B2);
endmodule

module OAI32XL(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1);
endmodule

module OAI32X4(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1);
endmodule

module OAI32X2(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1);
endmodule

module OAI32X1(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1, A2);
  or U$3(n$2, B0, B1);
endmodule

module OAI31XL(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1, A2);
endmodule

module OAI31X4(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1, A2);
endmodule

module OAI31X2(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1, A2);
endmodule

module OAI31X1(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1, A2);
endmodule

module OAI2BB2XL(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nand U$1(Y, n$1, n$4);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  or U$5(n$4, B0, B1);
endmodule

module OAI2BB2X4(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nand U$1(Y, n$1, n$4);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  or U$5(n$4, B0, B1);
endmodule

module OAI2BB2X2(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nand U$1(Y, n$1, n$4);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  or U$5(n$4, B0, B1);
endmodule

module OAI2BB2X1(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nand U$1(Y, n$1, n$4);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  or U$5(n$4, B0, B1);
endmodule

module OAI2BB1XL(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module OAI2BB1X4(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module OAI2BB1X2(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module OAI2BB1X1(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module OAI22XL(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI22X4(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI22X2(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI22X1(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI222XL(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, n$2, n$3);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
  or U$4(n$3, C0, C1);
endmodule

module OAI222X4(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, n$2, n$3);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
  or U$4(n$3, C0, C1);
endmodule

module OAI222X2(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, n$2, n$3);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
  or U$4(n$3, C0, C1);
endmodule

module OAI222X1(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nand U$1(Y, n$1, n$2, n$3);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
  or U$4(n$3, C0, C1);
endmodule

module OAI221XL(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C0);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI221X4(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C0);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI221X2(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C0);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI221X1(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C0);
  or U$2(n$1, A0, A1);
  or U$3(n$2, B0, B1);
endmodule

module OAI21XL(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI21X4(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI21X2(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI21X1(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nand U$1(Y, n$1, B0);
  or U$2(n$1, A0, A1);
endmodule

module OAI211XL(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module OAI211X4(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module OAI211X2(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module OAI211X1(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nand U$1(Y, n$1, B0, C0);
  or U$2(n$1, A0, A1);
endmodule

module NOR4XL(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nor U$1(Y, A, B, C, D);
endmodule

module NOR4X4(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nor U$1(Y, A, B, C, D);
endmodule

module NOR4X2(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nor U$1(Y, A, B, C, D);
endmodule

module NOR4X1(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nor U$1(Y, A, B, C, D);
endmodule

module NOR4BXL(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nor U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NOR4BX4(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nor U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NOR4BX2(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nor U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NOR4BX1(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nor U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NOR4BBXL(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NOR4BBX4(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NOR4BBX2(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NOR4BBX1(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NOR3XL(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nor U$1(Y, A, B, C);
endmodule

module NOR3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nor U$1(Y, A, B, C);
endmodule

module NOR3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nor U$1(Y, A, B, C);
endmodule

module NOR3X1(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nor U$1(Y, A, B, C);
endmodule

module NOR3BXL(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nor U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NOR3BX4(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nor U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NOR3BX2(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nor U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NOR3BX1(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nor U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NOR2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nor U$1(Y, A, B);
endmodule

module NOR2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nor U$1(Y, A, B);
endmodule

module NOR2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nor U$1(Y, A, B);
endmodule

module NOR2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nor U$1(Y, A, B);
endmodule

module NOR2BXL(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NOR2BX4(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NOR2BX2(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NOR2BX1(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nor U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND4XL(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nand U$1(Y, A, B, C, D);
endmodule

module NAND4X4(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nand U$1(Y, A, B, C, D);
endmodule

module NAND4X2(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nand U$1(Y, A, B, C, D);
endmodule

module NAND4X1(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  nand U$1(Y, A, B, C, D);
endmodule

module NAND4BXL(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nand U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NAND4BX4(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nand U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NAND4BX2(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nand U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NAND4BX1(AN, B, C, D, Y);
input  AN, B, C, D;
output Y;
wire  AN, B, C, D, Y, n$1;
  nand U$1(Y, n$1, B, C, D);
  not U$2(n$1, AN);
endmodule

module NAND4BBXL(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NAND4BBX4(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NAND4BBX2(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NAND4BBX1(AN, BN, C, D, Y);
input  AN, BN, C, D;
output Y;
wire  AN, BN, C, D, Y, n$1, n$2;
  nand U$1(Y, n$1, n$2, C, D);
  not U$2(n$1, AN);
  not U$3(n$2, BN);
endmodule

module NAND3XL(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nand U$1(Y, A, B, C);
endmodule

module NAND3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nand U$1(Y, A, B, C);
endmodule

module NAND3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nand U$1(Y, A, B, C);
endmodule

module NAND3X1(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  nand U$1(Y, A, B, C);
endmodule

module NAND3BXL(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND3BX4(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND3BX2(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND3BX1(AN, B, C, Y);
input  AN, B, C;
output Y;
wire  AN, B, C, Y, n$1;
  nand U$1(Y, n$1, B, C);
  not U$2(n$1, AN);
endmodule

module NAND2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nand U$1(Y, A, B);
endmodule

module NAND2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nand U$1(Y, A, B);
endmodule

module NAND2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nand U$1(Y, A, B);
endmodule

module NAND2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  nand U$1(Y, A, B);
endmodule

module NAND2BXL(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND2BX4(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND2BX2(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module NAND2BX1(AN, B, Y);
input  AN, B;
output Y;
wire  AN, B, Y, n$1;
  nand U$1(Y, n$1, B);
  not U$2(n$1, AN);
endmodule

module MXI4XL(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  nor U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MXI4X4(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  nor U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MXI4X2(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  nor U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MXI4X1(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  nor U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MXI2XL(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MXI2X4(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MXI2X2(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MXI2X1(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MX4XL(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  or U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MX4X4(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  or U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MX4X2(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  or U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MX4X1(S1, S0, D, C, B, A, Y);
input  A, B, C, D, S0, S1;
output Y;
wire  S1, S0, D, C, B, A, Y, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11;
  or U$1(Y, n$1, n$6);
  and U$2(n$1, S1, n$2);
  or U$3(n$2, n$3, n$4);
  and U$4(n$3, S0, D);
  and U$5(n$4, n$5, C);
  not U$6(n$5, S0);
  and U$7(n$6, n$7, n$8);
  not U$8(n$7, S1);
  or U$9(n$8, n$9, n$10);
  and U$10(n$9, S0, B);
  and U$11(n$10, n$11, A);
  not U$12(n$11, S0);
endmodule

module MX2XL(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  or U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MX2X4(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  or U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MX2X2(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  or U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module MX2X1(S0, B, A, Y);
input  A, B, S0;
output Y;
wire  S0, B, A, Y, n$1, n$2, n$3;
  or U$1(Y, n$1, n$2);
  and U$2(n$1, S0, B);
  and U$3(n$2, n$3, A);
  not U$4(n$3, S0);
endmodule

module JKFFXL(J, K, CK, Q, QN);
input  J, K, CK;
output Q, QN;
wire  J, K, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$4, n$6);
  and U$5(n$2, J, K, n$3);
  not U$6(n$3, IQ);
  and U$7(n$4, J, n$5);
  not U$8(n$5, K);
  and U$9(n$6, n$7, n$8, IQ);
  not U$10(n$7, J);
  not U$11(n$8, K);
endmodule

module JKFFX4(J, K, CK, Q, QN);
input  J, K, CK;
output Q, QN;
wire  J, K, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$4, n$6);
  and U$5(n$2, J, K, n$3);
  not U$6(n$3, IQ);
  and U$7(n$4, J, n$5);
  not U$8(n$5, K);
  and U$9(n$6, n$7, n$8, IQ);
  not U$10(n$7, J);
  not U$11(n$8, K);
endmodule

module JKFFX2(J, K, CK, Q, QN);
input  J, K, CK;
output Q, QN;
wire  J, K, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$4, n$6);
  and U$5(n$2, J, K, n$3);
  not U$6(n$3, IQ);
  and U$7(n$4, J, n$5);
  not U$8(n$5, K);
  and U$9(n$6, n$7, n$8, IQ);
  not U$10(n$7, J);
  not U$11(n$8, K);
endmodule

module JKFFX1(J, K, CK, Q, QN);
input  J, K, CK;
output Q, QN;
wire  J, K, CK, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$4, n$6);
  and U$5(n$2, J, K, n$3);
  not U$6(n$3, IQ);
  and U$7(n$4, J, n$5);
  not U$8(n$5, K);
  and U$9(n$6, n$7, n$8, IQ);
  not U$10(n$7, J);
  not U$11(n$8, K);
endmodule

module JKFFSXL(J, K, CK, SN, Q, QN);
input  J, K, CK, SN;
output Q, QN;
wire  J, K, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFSX4(J, K, CK, SN, Q, QN);
input  J, K, CK, SN;
output Q, QN;
wire  J, K, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFSX2(J, K, CK, SN, Q, QN);
input  J, K, CK, SN;
output Q, QN;
wire  J, K, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFSX1(J, K, CK, SN, Q, QN);
input  J, K, CK, SN;
output Q, QN;
wire  J, K, CK, SN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFSRXL(J, K, CK, SN, RN, Q, QN);
input  J, K, CK, SN, RN;
output Q, QN;
wire  J, K, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$12), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$6, n$8);
  and U$7(n$4, J, K, n$5);
  not U$8(n$5, IQ);
  and U$9(n$6, J, n$7);
  not U$10(n$7, K);
  and U$11(n$8, n$9, n$10, IQ);
  not U$12(n$9, J);
  not U$13(n$10, K);
  not U$14(n$11, n$1);
  and U$15(n$12, n$11, n$2);
endmodule

module JKFFSRX4(J, K, CK, SN, RN, Q, QN);
input  J, K, CK, SN, RN;
output Q, QN;
wire  J, K, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$12), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$6, n$8);
  and U$7(n$4, J, K, n$5);
  not U$8(n$5, IQ);
  and U$9(n$6, J, n$7);
  not U$10(n$7, K);
  and U$11(n$8, n$9, n$10, IQ);
  not U$12(n$9, J);
  not U$13(n$10, K);
  not U$14(n$11, n$1);
  and U$15(n$12, n$11, n$2);
endmodule

module JKFFSRX2(J, K, CK, SN, RN, Q, QN);
input  J, K, CK, SN, RN;
output Q, QN;
wire  J, K, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$12), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$6, n$8);
  and U$7(n$4, J, K, n$5);
  not U$8(n$5, IQ);
  and U$9(n$6, J, n$7);
  not U$10(n$7, K);
  and U$11(n$8, n$9, n$10, IQ);
  not U$12(n$9, J);
  not U$13(n$10, K);
  not U$14(n$11, n$1);
  and U$15(n$12, n$11, n$2);
endmodule

module JKFFSRX1(J, K, CK, SN, RN, Q, QN);
input  J, K, CK, SN, RN;
output Q, QN;
wire  J, K, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$12), .CK(CK), .D(n$3));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  or U$6(n$3, n$4, n$6, n$8);
  and U$7(n$4, J, K, n$5);
  not U$8(n$5, IQ);
  and U$9(n$6, J, n$7);
  not U$10(n$7, K);
  and U$11(n$8, n$9, n$10, IQ);
  not U$12(n$9, J);
  not U$13(n$10, K);
  not U$14(n$11, n$1);
  and U$15(n$12, n$11, n$2);
endmodule

module JKFFRXL(J, K, CK, RN, Q, QN);
input  J, K, CK, RN;
output Q, QN;
wire  J, K, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFRX4(J, K, CK, RN, Q, QN);
input  J, K, CK, RN;
output Q, QN;
wire  J, K, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFRX2(J, K, CK, RN, Q, QN);
input  J, K, CK, RN;
output Q, QN;
wire  J, K, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module JKFFRX1(J, K, CK, RN, Q, QN);
input  J, K, CK, RN;
output Q, QN;
wire  J, K, CK, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(n$2));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  or U$5(n$2, n$3, n$5, n$7);
  and U$6(n$3, J, K, n$4);
  not U$7(n$4, IQ);
  and U$8(n$5, J, n$6);
  not U$9(n$6, K);
  and U$10(n$7, n$8, n$9, IQ);
  not U$11(n$8, J);
  not U$12(n$9, K);
endmodule

module INVXL(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX8(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX4(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX3(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX20(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX2(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX16(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX12(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module INVX1(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module HOLDX1(Y);
inout  Y;
trireg   (medium) Y ;
endmodule

module EDFFXL(D, CK, E, Q, QN);
input  D, CK, E;
output Q, QN;
wire  D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, D);
  and U$6(n$3, n$4, IQ);
  not U$7(n$4, E);
endmodule

module EDFFX4(D, CK, E, Q, QN);
input  D, CK, E;
output Q, QN;
wire  D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, D);
  and U$6(n$3, n$4, IQ);
  not U$7(n$4, E);
endmodule

module EDFFX2(D, CK, E, Q, QN);
input  D, CK, E;
output Q, QN;
wire  D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, D);
  and U$6(n$3, n$4, IQ);
  not U$7(n$4, E);
endmodule

module EDFFX1(D, CK, E, Q, QN);
input  D, CK, E;
output Q, QN;
wire  D, CK, E, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, D);
  and U$6(n$3, n$4, IQ);
  not U$7(n$4, E);
endmodule

module EDFFTRXL(D, CK, E, RN, Q, QN);
input  D, CK, E, RN;
output Q, QN;
wire  D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, RN, D);
  and U$6(n$3, n$4, RN, IQ);
  not U$7(n$4, E);
endmodule

module EDFFTRX4(D, CK, E, RN, Q, QN);
input  D, CK, E, RN;
output Q, QN;
wire  D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, RN, D);
  and U$6(n$3, n$4, RN, IQ);
  not U$7(n$4, E);
endmodule

module EDFFTRX2(D, CK, E, RN, Q, QN);
input  D, CK, E, RN;
output Q, QN;
wire  D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, RN, D);
  and U$6(n$3, n$4, RN, IQ);
  not U$7(n$4, E);
endmodule

module EDFFTRX1(D, CK, E, RN, Q, QN);
input  D, CK, E, RN;
output Q, QN;
wire  D, CK, E, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  or U$4(n$1, n$2, n$3);
  and U$5(n$2, E, RN, D);
  and U$6(n$3, n$4, RN, IQ);
  not U$7(n$4, E);
endmodule

module DLY4X1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module DLY3X1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module DLY2X1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module DLY1X1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module DFFXL(D, CK, Q, QN);
input  D, CK;
output Q, QN;
wire  D, CK, IQ, IQN, Q, QN;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module DFFX4(D, CK, Q, QN);
input  D, CK;
output Q, QN;
wire  D, CK, IQ, IQN, Q, QN;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module DFFX2(D, CK, Q, QN);
input  D, CK;
output Q, QN;
wire  D, CK, IQ, IQN, Q, QN;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module DFFX1(D, CK, Q, QN);
input  D, CK;
output Q, QN;
wire  D, CK, IQ, IQN, Q, QN;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
endmodule

module DFFTRXL(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  and U$4(n$1, RN, D);
endmodule

module DFFTRX4(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  and U$4(n$1, RN, D);
endmodule

module DFFTRX2(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  and U$4(n$1, RN, D);
endmodule

module DFFTRX1(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(n$1));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  and U$4(n$1, RN, D);
endmodule

module DFFSXL(D, CK, SN, Q, QN);
input  D, CK, SN;
output Q, QN;
wire  D, CK, SN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module DFFSX4(D, CK, SN, Q, QN);
input  D, CK, SN;
output Q, QN;
wire  D, CK, SN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module DFFSX2(D, CK, SN, Q, QN);
input  D, CK, SN;
output Q, QN;
wire  D, CK, SN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module DFFSX1(D, CK, SN, Q, QN);
input  D, CK, SN;
output Q, QN;
wire  D, CK, SN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
endmodule

module DFFSRXL(D, CK, SN, RN, Q, QN);
input  D, CK, SN, RN;
output Q, QN;
wire  D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module DFFSRX4(D, CK, SN, RN, Q, QN);
input  D, CK, SN, RN;
output Q, QN;
wire  D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module DFFSRX2(D, CK, SN, RN, Q, QN);
input  D, CK, SN, RN;
output Q, QN;
wire  D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module DFFSRX1(D, CK, SN, RN, Q, QN);
input  D, CK, SN, RN;
output Q, QN;
wire  D, CK, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, n$1);
  and U$7(n$4, n$3, n$2);
endmodule

module DFFSRHQXL(D, CK, SN, RN, Q);
input  D, CK, SN, RN;
output Q;
wire  D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  not U$5(n$3, n$1);
  and U$6(n$4, n$3, n$2);
endmodule

module DFFSRHQX4(D, CK, SN, RN, Q);
input  D, CK, SN, RN;
output Q;
wire  D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  not U$5(n$3, n$1);
  and U$6(n$4, n$3, n$2);
endmodule

module DFFSRHQX2(D, CK, SN, RN, Q);
input  D, CK, SN, RN;
output Q;
wire  D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  not U$5(n$3, n$1);
  and U$6(n$4, n$3, n$2);
endmodule

module DFFSRHQX1(D, CK, SN, RN, Q);
input  D, CK, SN, RN;
output Q;
wire  D, CK, SN, RN, IQ, IQN, Q, n$1, n$2, n$3, n$4;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$4), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
  not U$4(n$2, RN);
  not U$5(n$3, n$1);
  and U$6(n$4, n$3, n$2);
endmodule

module DFFSHQXL(D, CK, SN, Q);
input  D, CK, SN;
output Q;
wire  D, CK, SN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
endmodule

module DFFSHQX4(D, CK, SN, Q);
input  D, CK, SN;
output Q;
wire  D, CK, SN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
endmodule

module DFFSHQX2(D, CK, SN, Q);
input  D, CK, SN;
output Q;
wire  D, CK, SN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
endmodule

module DFFSHQX1(D, CK, SN, Q);
input  D, CK, SN;
output Q;
wire  D, CK, SN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, SN);
endmodule

module DFFRXL(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module DFFRX4(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module DFFRX2(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module DFFRX1(D, CK, RN, Q, QN);
input  D, CK, RN;
output Q, QN;
wire  D, CK, RN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
endmodule

module DFFRHQXL(D, CK, RN, Q);
input  D, CK, RN;
output Q;
wire  D, CK, RN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
endmodule

module DFFRHQX4(D, CK, RN, Q);
input  D, CK, RN;
output Q;
wire  D, CK, RN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
endmodule

module DFFRHQX2(D, CK, RN, Q);
input  D, CK, RN;
output Q;
wire  D, CK, RN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
endmodule

module DFFRHQX1(D, CK, RN, Q);
input  D, CK, RN;
output Q;
wire  D, CK, RN, IQ, IQN, Q, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(CK), .D(D));
  buf U$2(Q, IQ);
  not U$3(n$1, RN);
endmodule

module DFFNXL(D, CKN, Q, QN);
input  D, CKN;
output Q, QN;
wire  D, CKN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
endmodule

module DFFNX4(D, CKN, Q, QN);
input  D, CKN;
output Q, QN;
wire  D, CKN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
endmodule

module DFFNX2(D, CKN, Q, QN);
input  D, CKN;
output Q, QN;
wire  D, CKN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
endmodule

module DFFNX1(D, CKN, Q, QN);
input  D, CKN;
output Q, QN;
wire  D, CKN, IQ, IQN, Q, QN, n$1;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(n$1), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, CKN);
endmodule

module DFFNSXL(D, CKN, SN, Q, QN);
input  D, CKN, SN;
output Q, QN;
wire  D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
endmodule

module DFFNSX4(D, CKN, SN, Q, QN);
input  D, CKN, SN;
output Q, QN;
wire  D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
endmodule

module DFFNSX2(D, CKN, SN, Q, QN);
input  D, CKN, SN;
output Q, QN;
wire  D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
endmodule

module DFFNSX1(D, CKN, SN, Q, QN);
input  D, CKN, SN;
output Q, QN;
wire  D, CKN, SN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(1'b0), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, CKN);
endmodule

module DFFNSRXL(D, CKN, SN, RN, Q, QN);
input  D, CKN, SN, RN;
output Q, QN;
wire  D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module DFFNSRX4(D, CKN, SN, RN, Q, QN);
input  D, CKN, SN, RN;
output Q, QN;
wire  D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module DFFNSRX2(D, CKN, SN, RN, Q, QN);
input  D, CKN, SN, RN;
output Q, QN;
wire  D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module DFFNSRX1(D, CKN, SN, RN, Q, QN);
input  D, CKN, SN, RN;
output Q, QN;
wire  D, CKN, SN, RN, IQ, IQN, Q, QN, n$1, n$2, n$3, n$4, n$5;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(n$1), .R(n$5), .CK(n$3), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, SN);
  not U$5(n$2, RN);
  not U$6(n$3, CKN);
  not U$7(n$4, n$1);
  and U$8(n$5, n$4, n$2);
endmodule

module DFFNRXL(D, CKN, RN, Q, QN);
input  D, CKN, RN;
output Q, QN;
wire  D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
endmodule

module DFFNRX4(D, CKN, RN, Q, QN);
input  D, CKN, RN;
output Q, QN;
wire  D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
endmodule

module DFFNRX2(D, CKN, RN, Q, QN);
input  D, CKN, RN;
output Q, QN;
wire  D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
endmodule

module DFFNRX1(D, CKN, RN, Q, QN);
input  D, CKN, RN;
output Q, QN;
wire  D, CKN, RN, IQ, IQN, Q, QN, n$1, n$2;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(n$1), .CK(n$2), .D(D));
  buf U$2(Q, IQ);
  buf U$3(QN, IQN);
  not U$4(n$1, RN);
  not U$5(n$2, CKN);
endmodule

module DFFHQXL(D, CK, Q);
input  D, CK;
output Q;
wire  D, CK, IQ, IQN, Q;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
endmodule

module DFFHQX4(D, CK, Q);
input  D, CK;
output Q;
wire  D, CK, IQ, IQN, Q;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
endmodule

module DFFHQX2(D, CK, Q);
input  D, CK;
output Q;
wire  D, CK, IQ, IQN, Q;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
endmodule

module DFFHQX1(D, CK, Q);
input  D, CK;
output Q;
wire  D, CK, IQ, IQN, Q;
  _HDFF_verplex U$1(.Q(IQ), .QN(IQN), .S(1'b0), .R(1'b0), .CK(CK), .D(D));
  buf U$2(Q, IQ);
endmodule

module CMPR42X2(A, B, C, D, ICI, S, ICO, CO);
input  A, B, C, D, ICI;
output S, ICO, CO;
wire  A, B, C, D, ICI, S, ICO, CO, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  xor U$1(S, n$1, C, D, ICI);
  xor U$2(n$1, A, B);
  or U$3(ICO, n$2, n$4);
  and U$4(n$2, n$3, C);
  xor U$5(n$3, A, B);
  and U$6(n$4, A, B);
  or U$7(CO, n$5, n$7, n$9);
  and U$8(n$5, D, n$6);
  xor U$9(n$6, A, B, C);
  and U$10(n$7, ICI, n$8);
  xor U$11(n$8, A, B, C);
  and U$12(n$9, D, ICI);
endmodule

module CMPR42X1(A, B, C, D, ICI, S, ICO, CO);
input  A, B, C, D, ICI;
output S, ICO, CO;
wire  A, B, C, D, ICI, S, ICO, CO, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9;
  xor U$1(S, n$1, C, D, ICI);
  xor U$2(n$1, A, B);
  or U$3(ICO, n$2, n$4);
  and U$4(n$2, n$3, C);
  xor U$5(n$3, A, B);
  and U$6(n$4, A, B);
  or U$7(CO, n$5, n$7, n$9);
  and U$8(n$5, D, n$6);
  xor U$9(n$6, A, B, C);
  and U$10(n$7, ICI, n$8);
  xor U$11(n$8, A, B, C);
  and U$12(n$9, D, ICI);
endmodule

module CMPR32X1(A, B, C, S, CO);
input  A, B, C;
output S, CO;
wire  A, B, C, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, C);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, C);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module CMPR22X1(A, B, S, CO);
input  A, B;
output S, CO;
wire  A, B, S, CO;
  xor U$1(S, A, B);
  and U$2(CO, A, B);
endmodule

module CLKINVXL(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX8(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX4(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX3(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX20(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX2(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX16(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX12(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKINVX1(A, Y);
input  A;
output Y;
wire  A, Y;
  not U$1(Y, A);
endmodule

module CLKBUFXL(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX8(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX4(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX3(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX20(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX2(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX16(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX12(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module CLKBUFX1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFXL(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX8(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX4(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX3(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX20(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX2(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX16(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX12(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BUFX1(A, Y);
input  A;
output Y;
wire  A, Y;
  buf U$1(Y, A);
endmodule

module BMXX1(X2, M0, A, S, M1, PP);
input  X2, M0, A, S, M1;
output PP;
wire  X2, M0, A, S, M1, PP, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, n$9, n$10, 
    n$11, n$12, n$13, n$14, n$15;
  or U$1(PP, n$1, n$8);
  and U$2(n$1, X2, n$2);
  or U$3(n$2, n$3, n$5);
  and U$4(n$3, M0, n$4);
  not U$5(n$4, A);
  and U$6(n$5, n$6, n$7);
  not U$7(n$6, M0);
  not U$8(n$7, S);
  and U$9(n$8, n$9, n$10);
  not U$10(n$9, X2);
  or U$11(n$10, n$11, n$13);
  and U$12(n$11, M1, n$12);
  not U$13(n$12, A);
  and U$14(n$13, n$14, n$15);
  not U$15(n$14, M1);
  not U$16(n$15, S);
endmodule

module BENCX4(M2, M1, M0, A, S, X2);
input  M2, M1, M0;
output A, S, X2;
wire  M2, M1, M0, A, S, X2, n$1, n$2, n$3, n$4, n$5;
  or U$1(A, M2, n$1);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, M1);
  not U$4(n$3, M0);
  or U$5(S, n$4, n$5);
  not U$6(n$4, M2);
  and U$7(n$5, M1, M0);
  xnor U$8(X2, M1, M0);
endmodule

module BENCX2(M2, M1, M0, A, S, X2);
input  M2, M1, M0;
output A, S, X2;
wire  M2, M1, M0, A, S, X2, n$1, n$2, n$3, n$4, n$5;
  or U$1(A, M2, n$1);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, M1);
  not U$4(n$3, M0);
  or U$5(S, n$4, n$5);
  not U$6(n$4, M2);
  and U$7(n$5, M1, M0);
  xnor U$8(X2, M1, M0);
endmodule

module BENCX1(M2, M1, M0, A, S, X2);
input  M2, M1, M0;
output A, S, X2;
wire  M2, M1, M0, A, S, X2, n$1, n$2, n$3, n$4, n$5;
  or U$1(A, M2, n$1);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, M1);
  not U$4(n$3, M0);
  or U$5(S, n$4, n$5);
  not U$6(n$4, M2);
  and U$7(n$5, M1, M0);
  xnor U$8(X2, M1, M0);
endmodule

module AOI33XL(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1, B2);
endmodule

module AOI33X4(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1, B2);
endmodule

module AOI33X2(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1, B2);
endmodule

module AOI33X1(A0, A1, A2, B0, B1, B2, Y);
input  A0, A1, A2, B0, B1, B2;
output Y;
wire  A0, A1, A2, B0, B1, B2, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1, B2);
endmodule

module AOI32XL(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1);
endmodule

module AOI32X4(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1);
endmodule

module AOI32X2(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1);
endmodule

module AOI32X1(A0, A1, A2, B0, B1, Y);
input  A0, A1, A2, B0, B1;
output Y;
wire  A0, A1, A2, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1, A2);
  and U$3(n$2, B0, B1);
endmodule

module AOI31XL(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module AOI31X4(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module AOI31X2(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module AOI31X1(A0, A1, A2, B0, Y);
input  A0, A1, A2, B0;
output Y;
wire  A0, A1, A2, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1, A2);
endmodule

module AOI2BB2XL(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nor U$1(Y, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  and U$5(n$4, B0, B1);
endmodule

module AOI2BB2X4(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nor U$1(Y, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  and U$5(n$4, B0, B1);
endmodule

module AOI2BB2X2(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nor U$1(Y, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  and U$5(n$4, B0, B1);
endmodule

module AOI2BB2X1(A0N, A1N, B0, B1, Y);
input  A0N, A1N, B0, B1;
output Y;
wire  A0N, A1N, B0, B1, Y, n$1, n$2, n$3, n$4;
  nor U$1(Y, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
  and U$5(n$4, B0, B1);
endmodule

module AOI2BB1XL(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module AOI2BB1X4(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module AOI2BB1X2(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module AOI2BB1X1(A0N, A1N, B0, Y);
input  A0N, A1N, B0;
output Y;
wire  A0N, A1N, B0, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, A0N);
  not U$4(n$3, A1N);
endmodule

module AOI22XL(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI22X4(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI22X2(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI22X1(A0, A1, B0, B1, Y);
input  A0, A1, B0, B1;
output Y;
wire  A0, A1, B0, B1, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI222XL(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2, n$3);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
  and U$4(n$3, C0, C1);
endmodule

module AOI222X4(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2, n$3);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
  and U$4(n$3, C0, C1);
endmodule

module AOI222X2(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2, n$3);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
  and U$4(n$3, C0, C1);
endmodule

module AOI222X1(A0, A1, B0, B1, C0, C1, Y);
input  A0, A1, B0, B1, C0, C1;
output Y;
wire  A0, A1, B0, B1, C0, C1, Y, n$1, n$2, n$3;
  nor U$1(Y, n$1, n$2, n$3);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
  and U$4(n$3, C0, C1);
endmodule

module AOI221XL(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C0);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI221X4(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C0);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI221X2(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C0);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI221X1(A0, A1, B0, B1, C0, Y);
input  A0, A1, B0, B1, C0;
output Y;
wire  A0, A1, B0, B1, C0, Y, n$1, n$2;
  nor U$1(Y, n$1, n$2, C0);
  and U$2(n$1, A0, A1);
  and U$3(n$2, B0, B1);
endmodule

module AOI21XL(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module AOI21X4(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module AOI21X2(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module AOI21X1(A0, A1, B0, Y);
input  A0, A1, B0;
output Y;
wire  A0, A1, B0, Y, n$1;
  nor U$1(Y, n$1, B0);
  and U$2(n$1, A0, A1);
endmodule

module AOI211XL(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nor U$1(Y, n$1, B0, C0);
  and U$2(n$1, A0, A1);
endmodule

module AOI211X4(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nor U$1(Y, n$1, B0, C0);
  and U$2(n$1, A0, A1);
endmodule

module AOI211X2(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nor U$1(Y, n$1, B0, C0);
  and U$2(n$1, A0, A1);
endmodule

module AOI211X1(A0, A1, B0, C0, Y);
input  A0, A1, B0, C0;
output Y;
wire  A0, A1, B0, C0, Y, n$1;
  nor U$1(Y, n$1, B0, C0);
  and U$2(n$1, A0, A1);
endmodule

module AND4XL(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  and U$1(Y, A, B, C, D);
endmodule

module AND4X4(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  and U$1(Y, A, B, C, D);
endmodule

module AND4X2(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  and U$1(Y, A, B, C, D);
endmodule

module AND4X1(A, B, C, D, Y);
input  A, B, C, D;
output Y;
wire  A, B, C, D, Y;
  and U$1(Y, A, B, C, D);
endmodule

module AND3XL(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  and U$1(Y, A, B, C);
endmodule

module AND3X4(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  and U$1(Y, A, B, C);
endmodule

module AND3X2(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  and U$1(Y, A, B, C);
endmodule

module AND3X1(A, B, C, Y);
input  A, B, C;
output Y;
wire  A, B, C, Y;
  and U$1(Y, A, B, C);
endmodule

module AND2XL(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  and U$1(Y, A, B);
endmodule

module AND2X4(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  and U$1(Y, A, B);
endmodule

module AND2X2(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  and U$1(Y, A, B);
endmodule

module AND2X1(A, B, Y);
input  A, B;
output Y;
wire  A, B, Y;
  and U$1(Y, A, B);
endmodule

module AHHCONX4(A, CI, S, CON);
input  A, CI;
output S, CON;
wire  A, CI, S, CON;
  xor U$1(S, A, CI);
  nand U$2(CON, A, CI);
endmodule

module AHHCONX2(A, CI, S, CON);
input  A, CI;
output S, CON;
wire  A, CI, S, CON;
  xor U$1(S, A, CI);
  nand U$2(CON, A, CI);
endmodule

module AHHCINX4(A, CIN, S, CO);
input  A, CIN;
output S, CO;
wire  A, CIN, S, CO, n$1, n$2;
  xor U$1(S, A, n$1);
  not U$2(n$1, CIN);
  and U$3(CO, A, n$2);
  not U$4(n$2, CIN);
endmodule

module AHHCINX2(A, CIN, S, CO);
input  A, CIN;
output S, CO;
wire  A, CIN, S, CO, n$1, n$2;
  xor U$1(S, A, n$1);
  not U$2(n$1, CIN);
  and U$3(CO, A, n$2);
  not U$4(n$2, CIN);
endmodule

module AFHCONX4(A, B, CI, S, CON);
input  A, B, CI;
output S, CON;
wire  A, B, CI, S, CON, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  nor U$2(CON, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module AFHCONX2(A, B, CI, S, CON);
input  A, B, CI;
output S, CON;
wire  A, B, CI, S, CON, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  nor U$2(CON, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module AFHCINX4(A, B, CIN, S, CO);
input  A, B, CIN;
output S, CO;
wire  A, B, CIN, S, CO, n$1, n$2, n$3, n$4, n$5;
  xor U$1(S, A, B, n$1);
  not U$2(n$1, CIN);
  or U$3(CO, n$2, n$5);
  and U$4(n$2, n$3, n$4);
  xor U$5(n$3, A, B);
  not U$6(n$4, CIN);
  and U$7(n$5, A, B);
endmodule

module AFHCINX2(A, B, CIN, S, CO);
input  A, B, CIN;
output S, CO;
wire  A, B, CIN, S, CO, n$1, n$2, n$3, n$4, n$5;
  xor U$1(S, A, B, n$1);
  not U$2(n$1, CIN);
  or U$3(CO, n$2, n$5);
  and U$4(n$2, n$3, n$4);
  xor U$5(n$3, A, B);
  not U$6(n$4, CIN);
  and U$7(n$5, A, B);
endmodule

module AFCSHCONX4(CS, A, B, CI0, CI1, S, CO0N, CO1N);
input  CS, A, B, CI0, CI1;
output S, CO0N, CO1N;
wire  CS, A, B, CI0, CI1, S, CO0N, CO1N, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11;
  or U$1(S, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, CS);
  xor U$4(n$3, A, B, CI0);
  and U$5(n$4, CS, n$5);
  xor U$6(n$5, A, B, CI1);
  nor U$7(CO0N, n$6, n$8);
  and U$8(n$6, n$7, CI0);
  xor U$9(n$7, A, B);
  and U$10(n$8, A, B);
  nor U$11(CO1N, n$9, n$11);
  and U$12(n$9, n$10, CI1);
  xor U$13(n$10, A, B);
  and U$14(n$11, A, B);
endmodule

module AFCSHCONX2(CS, A, B, CI0, CI1, S, CO0N, CO1N);
input  CS, A, B, CI0, CI1;
output S, CO0N, CO1N;
wire  CS, A, B, CI0, CI1, S, CO0N, CO1N, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11;
  or U$1(S, n$1, n$4);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, CS);
  xor U$4(n$3, A, B, CI0);
  and U$5(n$4, CS, n$5);
  xor U$6(n$5, A, B, CI1);
  nor U$7(CO0N, n$6, n$8);
  and U$8(n$6, n$7, CI0);
  xor U$9(n$7, A, B);
  and U$10(n$8, A, B);
  nor U$11(CO1N, n$9, n$11);
  and U$12(n$9, n$10, CI1);
  xor U$13(n$10, A, B);
  and U$14(n$11, A, B);
endmodule

module AFCSHCINX4(CS, A, B, CI0N, CI1N, S, CO0, CO1);
input  CS, A, B, CI0N, CI1N;
output S, CO0, CO1;
wire  CS, A, B, CI0N, CI1N, S, CO0, CO1, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12, n$13, n$14, n$15;
  or U$1(S, n$1, n$5);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, CS);
  xor U$4(n$3, A, B, n$4);
  not U$5(n$4, CI0N);
  and U$6(n$5, CS, n$6);
  xor U$7(n$6, A, B, n$7);
  not U$8(n$7, CI1N);
  or U$9(CO0, n$8, n$11);
  and U$10(n$8, n$9, n$10);
  xor U$11(n$9, A, B);
  not U$12(n$10, CI0N);
  and U$13(n$11, A, B);
  or U$14(CO1, n$12, n$15);
  and U$15(n$12, n$13, n$14);
  xor U$16(n$13, A, B);
  not U$17(n$14, CI1N);
  and U$18(n$15, A, B);
endmodule

module AFCSHCINX2(CS, A, B, CI0N, CI1N, S, CO0, CO1);
input  CS, A, B, CI0N, CI1N;
output S, CO0, CO1;
wire  CS, A, B, CI0N, CI1N, S, CO0, CO1, n$1, n$2, n$3, n$4, n$5, n$6, n$7, n$8, 
    n$9, n$10, n$11, n$12, n$13, n$14, n$15;
  or U$1(S, n$1, n$5);
  and U$2(n$1, n$2, n$3);
  not U$3(n$2, CS);
  xor U$4(n$3, A, B, n$4);
  not U$5(n$4, CI0N);
  and U$6(n$5, CS, n$6);
  xor U$7(n$6, A, B, n$7);
  not U$8(n$7, CI1N);
  or U$9(CO0, n$8, n$11);
  and U$10(n$8, n$9, n$10);
  xor U$11(n$9, A, B);
  not U$12(n$10, CI0N);
  and U$13(n$11, A, B);
  or U$14(CO1, n$12, n$15);
  and U$15(n$12, n$13, n$14);
  xor U$16(n$13, A, B);
  not U$17(n$14, CI1N);
  and U$18(n$15, A, B);
endmodule

module ADDHXL(A, B, S, CO);
input  A, B;
output S, CO;
wire  A, B, S, CO;
  xor U$1(S, A, B);
  and U$2(CO, A, B);
endmodule

module ADDHX4(A, B, S, CO);
input  A, B;
output S, CO;
wire  A, B, S, CO;
  xor U$1(S, A, B);
  and U$2(CO, A, B);
endmodule

module ADDHX2(A, B, S, CO);
input  A, B;
output S, CO;
wire  A, B, S, CO;
  xor U$1(S, A, B);
  and U$2(CO, A, B);
endmodule

module ADDHX1(A, B, S, CO);
input  A, B;
output S, CO;
wire  A, B, S, CO;
  xor U$1(S, A, B);
  and U$2(CO, A, B);
endmodule

module ADDFXL(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFX4(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFX2(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFX1(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFHXL(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFHX4(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFHX2(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module ADDFHX1(A, B, CI, S, CO);
input  A, B, CI;
output S, CO;
wire  A, B, CI, S, CO, n$1, n$2, n$3;
  xor U$1(S, A, B, CI);
  or U$2(CO, n$1, n$3);
  and U$3(n$1, n$2, CI);
  xor U$4(n$2, A, B);
  and U$5(n$3, A, B);
endmodule

module _HDFF_verplex(Q, QN, S, R, CK, D);
// verplex DFF
output  Q, QN;
input   S, R, CK, D;
wire   N1;
  DFF_UDP  i0(N1, S, R, CK, D);
  buf  (Q, N1);
  not  (QN, N1);
endmodule

primitive DFF_UDP(Q, S, R, CK, D);
output Q;
input  S, R, CK, D;
reg    Q;
  table
    1  0   ?    ?  :  ?  :  1; // Asserting preset
    *  0   ?    ?  :  1  :  1; // Changing preset
    ?  1   ?    ?  :  ?  :  0; // Asserting reset (dominates preset)
    0  *   ?    ?  :  0  :  0; // Changing reset
    0  ?   (01) 0  :  ?  :  0; // rising clock
    ?  0   (01) 1  :  ?  :  1; // rising clock 
    0  ?   p    0  :  0  :  0; // potential rising clock
    ?  0   p    1  :  1  :  1; // potential rising clock
    0  0   n    ?  :  ?  :  -; // Clock falling register output does not change
    0  0   ?    *  :  ?  :  -; // Changing Data
  endtable
endprimitive

module _HDLAT_verplex(Q, QN, S, R, CK, D);
// verplex DLAT
output  Q, QN;
input   S, R, CK, D;
wire   N1;
  DLAT_UDP i0(N1, S, R, CK, D);
  buf  (Q, N1);
  not  (QN, N1);
endmodule

primitive DLAT_UDP(Q, S, R, CK, D);
output Q;
input  S, R, CK, D;
reg    Q;
  table
    1  0   ?    ?  :  ?  :  1; // Asserting preset
    ?  1   ?    ?  :  ?  :  0; // Asserting reset (dominates preset)
    0  0   1    0  :  ?  :  0; // Data clocked
    0  ?   *    0  :  0  :  0; // Clock transitions
    0  *   0    ?  :  0  :  0; // Changing reset
    0  *   ?    0  :  0  :  0;
    0  0   1    1  :  ?  :  1; // Data clocked
    *  0   0    ?  :  1  :  1; // Changing preset
    *  0   ?    1  :  1  :  1;
    ?  0   *    1  :  1  :  1; // Clock transitions
    0  0   0    ?  :  ?  :  -; // Hold
  endtable
endprimitive

