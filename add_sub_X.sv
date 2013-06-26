module add_sub_X (
	input [15:0] b,
	input [15:0] a,
	input [15:0] EXin,
	input sub,
	input X,
	output [15:0] q,
	output [15:0] EX,
	output eq,
	output lt,
	output un
);

	wire cr, EX_cr, of;
	wire [15:0] add_out;
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
	assign un = add_q[15] != of; // sign flag != overflow flag

endmodule
