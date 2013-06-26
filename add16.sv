module add16 (
	input cin,
	input [15:0] a,
	input [15:0] b,
	output [15:0] q,
	output cout
);

	wire carry1, carry2, carry3;
	
	add4 a0(cin, a[3:0], b[3:0], q[3:0], carry1),
		  a1(carry1, a[7:4], b[7:4], q[7:4], carry2),
		  a2(carry2, a[11:8], b[11:8], q[11:8], carry3),
		  a3(carry3, a[15:12], b[15:12], q[15:12], cout);

endmodule

module halfAdder (
	input a,
	input b,
	output q,
	output c
);

	assign q = a^b;
	assign c = a&b;

endmodule

module add4 (
	input cin,
	input [3:0] a,
	input [3:0] b,
	output [3:0] q,
	output cout
);

	wire p0, p1, p2, p3, g0, g1, g2, g3;

	halfAdder ha0(a[0], b[0], p0, g0),
				 ha1(a[1], b[1], p1, g1),
				 ha2(a[2], b[2], p2, g2),
				 ha3(a[3], b[3], p3, g3);
	
	assign q[0] = p0^cin;

	wire p0c = p0&cin;
	assign q[1] = p1^(g0|p0c);

	wire p1g0 = p1&g0;
	wire p1p0c = p1&p0c;
	assign q[2] = p2^(g1|p1g0|p1p0c);

	wire p2p1 = p2&p1;
	wire p2g1 = p2&g1;
	wire p2p1g0 = p2&p1g0;
	wire p2p1p0c = p2p1&p0c;
	assign q[3] = p3^(g2|p2g1|p2p1g0|p2p1p0c);

	wire p3p2 = p3&p2;
	wire p3g2 = p3&g2;
	wire p3p2g1 = p3&p2g1;
	wire p3p2p1g0 = p3p2&p1g0;
	wire p3p2p1p0c = p3&p2p1p0c;
	assign cout = (g3|p3g2|p3p2g1|p3p2p1g0|p3p2p1p0c);

endmodule
