/**************************************************************************
 *  FPGA-implementation of the dcpu16
 *  Copyright (C) 2013  Hauke Neizel
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

module mul_div_mod (
	input [15:0] b,
	input [15:0] a,
	input sgn,
	output [15:0] mul_q,
	output [15:0] mul_EX,
	output [15:0] div_q,
	output [15:0] div_EX,
	output [15:0] mod_q
);

	wire sgn_b = b[15] && sgn; 
	wire sgn_a = a[15] && sgn;
	wire [15:0] unsigned_b = sgn_b ? -b : b;
	wire [15:0] unsigned_a = sgn_a ? -a : a;

	wire [31:0] mul_out;
	wire [15:0] div_out, div_out_ex, mod_out;
	wire divz;

	mult16 mul(unsigned_b, unsigned_a, mul_out);

	assign {mul_EX,mul_q} = sgn_b ^ sgn_a ? -mul_out : mul_out;

	div16 div(b, a, div_out, mod_out, div_out_ex, divz);

	assign {div_q,div_EX} = divz ? 32'd0 : (sgn_b ^ sgn_a ? -{div_out,div_out_ex} : {div_out,div_out_ex});

	assign mod_q = divz ? 16'd0 : (sgn_b ? -mod_out : mod_out);	

endmodule
