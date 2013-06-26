module ALU (
	input [4:0] op,
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

	wire and_or, add_EX, add_sub, shift_dir, mul_div_sgn;
	wire [2:0] out_mux;
	
	always_comb
	begin
		case(op)
			5'h02: begin // ADD
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b000;
			end
			5'h03,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17: begin // SUB, IFE, IFN, IFG, IFA, IFL, IFU
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b1;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b000;
			end
			5'h1A: begin // ADX
				and_or <= 1'b0;
				add_EX <= 1'b1;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b000;
			end
			5'h1B: begin // SBX
				and_or <= 1'b0;
				add_EX <= 1'b1;
				add_sub <= 1'b1;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b000;
			end
			5'h04: begin // MUL
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b001;
			end
			5'h05: begin // MLI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b1;
				out_mux <= 3'b001;
			end
			5'h06: begin // DIV
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b010;
			end
			5'h07: begin // DVI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b1;
				out_mux <= 3'b010;
			end
			5'h08: begin // MOD
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b011;
			end
			5'h09: begin // MDI
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b1;
				out_mux <= 3'b011;
			end
			5'h0A,5'h10,5'h11: begin // AND, IFB, IFC
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b100;
			end
			5'h0B: begin // BOR
				and_or <= 1'b1;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b100;
			end
			5'h0C: begin // XOR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b101;
			end
			5'h0D: begin // SHR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b1;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b110;
			end
			5'h0E: begin // ASR
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b111;
			end
			5'h0F: begin // SHL
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b110;
			end
			default: begin
				and_or <= 1'b0;
				add_EX <= 1'b0;
				add_sub <= 1'b0;
				shift_dir <= 1'b0;
				mul_div_sgn <= 1'b0;
				out_mux <= 3'b000;
			end
		endcase
	end

	wire [15:0] b_in = b ^ {16{and_or}};
	wire [15:0] a_in = a ^ {16{and_or | add_sub}};

	wire [15:0] addsub_q, and_out, and_q, xor_q, sh_out, sh_q, ash_q, mul_q, div_q, mod_q;
	wire [15:0] addsub_EX, sh_EX, ash_EX, mul_EX, div_EX;

	// ADD, ADX, SUB, SBX
	add_sub_X addsub(b, a, EXin, add_sub, add_EX, addsub_q, addsub_EX, eq, lt, un);

	// MUL, MLI, DIV, DVI, MOD, MDI
	mul_div_mod mdm(b, a, mul_div_sgn, mul_q, mul_EX, div_q, div_EX, mod_q);

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

	always_comb
	begin
		case(out_mux)
			3'b000: q <= add_q;
			3'b001: q <= mul_q;
			3'b010: q <= div_q;
			3'b011: q <= mod_q;
			3'b100: q <= and_q;
			3'b101: q <= xor_q;
			3'b110: q <= sh_q;
			3'b111: q <= ash_q;
		endcase
	end

	always_comb
	begin
		case(out_mux)
			3'b000: EXout <= addsub_EX;
			3'b001: EXout <= mul_EX;
			3'b010: EXout <= div_EX;
			3'b110: EXout <= sh_EX;
			3'b111: EXout <= ash_EX;
			default: EXout <= 16'h0000;
		endcase
	end

endmodule
