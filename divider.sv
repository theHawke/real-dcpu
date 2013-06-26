module div16( 
	input [15:0] dividend,
	input [15:0] divisor,
	output [15:0] quotient,
	output [15:0] modulus,
	output [15:0] EX,
	output divz
);

	wire [15:0] a = dividend;
	wire [15:0] b = divisor;
	wire [15:0] c;

	wire [15:0] dif [15:0];
	wire [15:0] s [15:0];
	wire u [15:0];

	assign c[15] = ~(u[15] | (|b[15:1]) );
	assign c[14] = ~(u[14] | (|b[15:2]) );
	assign c[13] = ~(u[13] | (|b[15:3]) );
	assign c[12] = ~(u[12] | (|b[15:4]) );
	assign c[11] = ~(u[11] | (|b[15:5]) );
	assign c[10] = ~(u[10] | (|b[15:6]) );
	assign c[9] = ~(u[9] | (|b[15:7]) );
	assign c[8] = ~(u[8] | (|b[15:8]) );
	assign c[7] = ~(u[7] | (|b[15:9]) );
	assign c[6] = ~(u[6] | (|b[15:10]) );
	assign c[5] = ~(u[5] | (|b[15:11]) );
	assign c[4] = ~(u[4] | (|b[15:12]) );
	assign c[3] = ~(u[3] | (|b[15:13]) );
	assign c[2] = ~(u[2] | (|b[15:14]) );
	assign c[1] = ~(u[1] | (|b[15:15]) );
	assign c[0] = ~u[0];

	assign s[15] = c[15] ? dif[15] : a;
	assign s[14] = c[14] ? dif[14] : s[15];
	assign s[13] = c[13] ? dif[13] : s[14];
	assign s[12] = c[12] ? dif[12] : s[13];
	assign s[11] = c[11] ? dif[11] : s[12];
	assign s[10] = c[10] ? dif[10] : s[11];
	assign s[9] = c[9] ? dif[9] : s[10];
	assign s[8] = c[8] ? dif[8] : s[9];
	assign s[7] = c[7] ? dif[7] : s[8];
	assign s[6] = c[6] ? dif[6] : s[7];
	assign s[5] = c[5] ? dif[5] : s[6];
	assign s[4] = c[4] ? dif[4] : s[5];
	assign s[3] = c[3] ? dif[3] : s[4];
	assign s[2] = c[2] ? dif[2] : s[3];
	assign s[1] = c[1] ? dif[1] : s[2];
	assign s[0] = c[0] ? dif[0] : s[1];

	sub16 sub15(.a(a), .b(b<<15), .q(dif[15]), .uf(u[15])),
			sub14(.a(s[15]), .b(b<<14), .q(dif[14]), .uf(u[14])),
			sub13(.a(s[14]), .b(b<<13), .q(dif[13]), .uf(u[13])),
			sub12(.a(s[13]), .b(b<<12), .q(dif[12]), .uf(u[12])),
			sub11(.a(s[12]), .b(b<<11), .q(dif[11]), .uf(u[11])),
			sub10(.a(s[11]), .b(b<<10), .q(dif[10]), .uf(u[10])),
			sub9(.a(s[10]), .b(b<<9), .q(dif[9]), .uf(u[9])),
			sub8(.a(s[9]), .b(b<<8), .q(dif[8]), .uf(u[8])),
			sub7(.a(s[8]), .b(b<<7), .q(dif[7]), .uf(u[7])),
			sub6(.a(s[7]), .b(b<<6), .q(dif[6]), .uf(u[6])),
			sub5(.a(s[6]), .b(b<<5), .q(dif[5]), .uf(u[5])),
			sub4(.a(s[5]), .b(b<<4), .q(dif[4]), .uf(u[4])),
			sub3(.a(s[4]), .b(b<<3), .q(dif[3]), .uf(u[3])),
			sub2(.a(s[3]), .b(b<<2), .q(dif[2]), .uf(u[2])),
			sub1(.a(s[2]), .b(b<<1), .q(dif[1]), .uf(u[1])),
			sub0(.a(s[1]), .b(b), .q(dif[0]), .uf(u[0]));

	assign quotient = c;
	assign modulus = s[0];
	assign divz = ~|b[15:0];

	wire [15:0] d;

	wire [15:0] fdif [15:0];
	wire [15:0] fs [15:0];
	wire fu [15:0];

	assign d[15] = ~fu[15] | s[0][15];
	assign d[14] = ~fu[14] | (d[15] ? fdif[15][15] : fs[15][15]);
	assign d[13] = ~fu[13] | (d[14] ? fdif[14][15] : fs[14][15]);
	assign d[12] = ~fu[12] | (d[13] ? fdif[13][15] : fs[13][15]);
	assign d[11] = ~fu[11] | (d[12] ? fdif[12][15] : fs[12][15]);
	assign d[10] = ~fu[10] | (d[11] ? fdif[11][15] : fs[11][15]);
	assign d[9] = ~fu[9] | (d[10] ? fdif[10][15] : fs[10][15]);
	assign d[8] = ~fu[8] | (d[9] ? fdif[9][15] : fs[9][15]);
	assign d[7] = ~fu[7] | (d[8] ? fdif[8][15] : fs[8][15]);
	assign d[6] = ~fu[6] | (d[7] ? fdif[7][15] : fs[7][15]);
	assign d[5] = ~fu[5] | (d[6] ? fdif[6][15] : fs[6][15]);
	assign d[4] = ~fu[4] | (d[5] ? fdif[5][15] : fs[5][15]);
	assign d[3] = ~fu[3] | (d[4] ? fdif[4][15] : fs[4][15]);
	assign d[2] = ~fu[2] | (d[3] ? fdif[3][15] : fs[3][15]);
	assign d[1] = ~fu[1] | (d[2] ? fdif[2][15] : fs[2][15]);
	assign d[0] = ~fu[0] | (d[1] ? fdif[1][15] : fs[1][15]);

	assign fs[15] = s[0]<<1;
	assign fs[14] = (d[15] ? fdif[15] : fs[15])<<1;
	assign fs[13] = (d[14] ? fdif[14] : fs[14])<<1;
	assign fs[12] = (d[13] ? fdif[13] : fs[13])<<1;
	assign fs[11] = (d[12] ? fdif[12] : fs[12])<<1;
	assign fs[10] = (d[11] ? fdif[11] : fs[11])<<1;
	assign fs[9] = (d[10] ? fdif[10] : fs[10])<<1;
	assign fs[8] = (d[9] ? fdif[9] : fs[9])<<1;
	assign fs[7] = (d[8] ? fdif[8] : fs[8])<<1;
	assign fs[6] = (d[7] ? fdif[7] : fs[7])<<1;
	assign fs[5] = (d[6] ? fdif[6] : fs[6])<<1;
	assign fs[4] = (d[5] ? fdif[5] : fs[5])<<1;
	assign fs[3] = (d[4] ? fdif[4] : fs[4])<<1;
	assign fs[2] = (d[3] ? fdif[3] : fs[3])<<1;
	assign fs[1] = (d[2] ? fdif[2] : fs[2])<<1;
	assign fs[0] = (d[1] ? fdif[1] : fs[1])<<1;

	sub16 subm1(.a(fs[15]), .b(b), .q(fdif[15]), .uf(fu[15])),
			subm2(.a(fs[14]), .b(b), .q(fdif[14]), .uf(fu[14])),
			subm3(.a(fs[13]), .b(b), .q(fdif[13]), .uf(fu[13])),
			subm4(.a(fs[12]), .b(b), .q(fdif[12]), .uf(fu[12])),
			subm5(.a(fs[11]), .b(b), .q(fdif[11]), .uf(fu[11])),
			subm6(.a(fs[10]), .b(b), .q(fdif[10]), .uf(fu[10])),
			subm7(.a(fs[9]), .b(b), .q(fdif[9]), .uf(fu[9])),
			subm8(.a(fs[8]), .b(b), .q(fdif[8]), .uf(fu[8])),
			subm9(.a(fs[7]), .b(b), .q(fdif[7]), .uf(fu[7])),
			subm10(.a(fs[6]), .b(b), .q(fdif[6]), .uf(fu[6])),
			subm11(.a(fs[5]), .b(b), .q(fdif[5]), .uf(fu[5])),
			subm12(.a(fs[4]), .b(b), .q(fdif[4]), .uf(fu[4])),
			subm13(.a(fs[3]), .b(b), .q(fdif[3]), .uf(fu[3])),
			subm14(.a(fs[2]), .b(b), .q(fdif[2]), .uf(fu[2])),
			subm15(.a(fs[1]), .b(b), .q(fdif[1]), .uf(fu[1])),
			subm16(.a(fs[0]), .b(b), .q(fdif[0]), .uf(fu[0]));
	
	assign EX = d;

endmodule

module sub16(
	input [15:0] a,
	input [15:0] b,
	output [15:0] q,
	output uf
);

	wire of;
	add16 adder(.cin(1'b1), .a(a), .b(~b), .q(q), .cout(of));
	assign uf = ~of;

endmodule
