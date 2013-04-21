module ALU (
	input [3:0] fn,
	input [15:0] b,
	input [15:0] a,
	input [15:0] EXin, // for the ADX and SBX instructions
	output [15:0] q,
	output [15:0] EXout, // for ADD, SUB, MUL/MLI, DIV/DVI, SHR, ASR, SHL instructions
	output cl, // IFC, get IFB = !cl
	output eq, // IFE, get IFN = !eq
	output lt, // IFL, unsigned, get IFG = !eq&!lt
	output un // IFU, signed, get IFA = !eq&!un
);

	wire and_or, add_EX, add_sub, shift_dir;
	wire [3:0] out_mux;
	
	always_comb
	begin
		case(fn)
			4'h0: begin // ADD
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0000;
			end
			4'h1: begin // SUB
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b1;
				shift_dir <= 1'b0;
				out_mux <= 4'b0000;
			end
			4'h2: begin // ADX
				and_or <= 1'b0;
				add_EX <= 1'b1;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0000;
			end
			4'h3: begin // SBX
				and_or <= 1'b0;
				add_EX <= 1'b1;
				add_sub <= 1'b1;
				shift_dir <= 1'b0;
				out_mux <= 4'b0000;
			end
			4'h4: begin // MUL
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1000;
			end
			4'h5: begin // MLI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1010;
			end
			4'h6: begin // DIV
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1100;
			end
			4'h7: begin // DVI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1101;
			end
			4'h8: begin // MOD
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1110;
			end
			4'h9: begin // MDI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b1111;
			end
			4'hA: begin // AND
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0100;
			end
			4'hB: begin // BOR
				and_or <= 1'b1;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0100;
			end
			4'hC: begin // XOR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0101;
			end
			4'hD: begin // SHR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b1;
				out_mux <= 4'b0110;
			end
			4'hE: begin // ASR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0111;
			end
			4'hF: begin // ADD
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0110;
			end
			default: begin
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				out_mux <= 4'b0000;
			end
		endcase
	end

	wire [15:0] b_in = b ^ {16{and_or}};
	wire [15:0] a_in = a ^ {16{and_or | add_sub}};

	wire [15:0] add_out, add_out_EX, add_q, and_out, and_q, xor_q, sh_out, sh_q, ash_q, mul_q, mli_q, div_q, dvi_q, mod_q, mdi_q;
	wire [15:0] addsub_EX, sh_EX, ash_EX, mul_EX, mli_EX, div_EX, dvi_EX;

	// ADD, ADX, SUB, SBX
	wire cr, EX_cr, of;
	add16 addsub(add_sub, b, a_in, add_out, cr),
			addEX(0, add_out, EXin, add_out_EX, EX_cr);
	assign add_q = add_EX ? add_out_EX : add_out;
	assign addsub_EX = add_sub ? (add_EX ? (cr == EX_cr ? (cr ? 16'h0001 : 16'hFFFF) : 16'h0000) : 
														(cr ? 16'h0000 : 16'hFFFF)) : 
										  (add_EX ? (cr == EX_cr ? (cr ? 16'h0002 : 16'h0000) : 16'h0001) : 
														(cr ? 16'h0001 : 16'h0000));
	assign of = (b[15] == a[15]^(&a[14:0] & add_sub)) & (b[15] != add_out);
	assign eq = ~|add_q;
	assign lt = !cr; // underflow happens when there is no carry
	assign un = add_q[15_0] != of; // sign flag != overflow flag

	// AND, BOR
	assign and_out = b_in & a_in;
	assign and_q = and_out ^ {16{and_or}};
	assign cl = ~|and_q;

	// XOR
	assign xor_q = b_in ^ a_in;

	// SHR, SHL
	wire [31:0] sh_b;
	assign sh_b[31:16] = shift_dir ? b : 16'd0;
	assign sh_b[15:0] = shift_dir ? 15'd0 : b;
	shift16 shifter(sh_b, shift_dir, a[3:0], sh_out);
	assign sh_q = shift_dir ? sh_out[31:16] : sh_out[15:0];
	assign sh_EX = shift_dir ? sh_out[15:0] : sh_out[31:16];

	// ASR
	ashift16 ashifter({b, 16'd0}, a[3:0], {ash_q, ash_EX});

	// MUL
	mult16 multiplier(b, a, {mul_EX, mul_q});

	// MLI
	smult16 smultiplier(b, a, {mli_EX, mli_q});

	// DIV
	div16 divider({b, 16'd0}, a, {div_q, div_EX});

	// DVI
	sdiv16 sdivider({b, 16'd0}, a, {dvi_q, dvi_EX});

	// MOD
	wire [15:0] mod_quo;
	mod16 modulo(b, a, mod_quo, mod_q);

	// MDI
	wire [15:0] mdi_quo;
	smod16 smodulo(b, a, mdi_quo, mdi_q);

	assign q = out_mux[3] ? (out_mux[2] ? (out_mux[1] ? (out_mux[0] ? mdi_q : mod_q) : (out_mux[0] ? dvi_q : div_q)) : (out_mux[1] ? mli_q : mul_q)) :
									(out_mux[2] ? (out_mux[1] ? (out_mux[0] ? ash_q : sh_q) : (out_mux[0] ? xor_q : and_q)) : add_q);

	assign EXout = out_mux[3] ? (out_mux[2] ? (out_mux[0] ? dvi_EX : div_EX) : (out_mux[1] ? mli_EX : mul_EX)) : (out_mux[2] ? (out_mux[0] ? ash_EX : sh_EX) : addsub_EX);

endmodule

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
		  a2(carry2, a[11:8], b[11:8], q[11:8], carry2),
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
