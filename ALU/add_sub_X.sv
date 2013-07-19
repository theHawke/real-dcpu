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
	wire [15:0] add_out, add_out_EX;
	add16 addsub(sub, b, a^{16{sub}}, add_out, cr, of),
			addEX(1'b0, add_out, EXin, add_out_EX, EX_cr);
	assign q = X ? add_out_EX : add_out;
	assign EX = sub ? (X ? (cr == EX_cr ? (cr ? 16'h0001 : 16'hFFFF) : 16'h0000) : 
								  (cr ? 16'h0000 : 16'hFFFF)) : 
							(X ? (cr == EX_cr ? (cr ? 16'h0002 : 16'h0000) : 16'h0001) : 
								  (cr ? 16'h0001 : 16'h0000));
//	assign of = (b[15] == a[15] ^ sub) && (b[15] != add_out[15]);
	assign eq = ~|q;
	assign lt = !cr; // underflow happens when there is no carry
	assign un = q[15] != of; // sign flag != overflow flag

endmodule
