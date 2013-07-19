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

module ALUtester(

	input KEY[2:1],
	input [15:0] SW,

	output [3:0] LEDG,
	output [15:0] LEDR,

	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX7

);

	reg [15:0] regs [3:0];
	reg [3:0] r = 0;

	SEG_HEX h7(r, HEX7);

	wire [15:0] out2;
	assign LEDR[15:0] = out2[15:0];

	wire [15:0] out1;
	SEG_HEX h3(out1[15:12], HEX3),
            h2(out1[11:8], HEX2),
            h1(out1[7:4], HEX1),
            h0(out1[3:0], HEX0);

	always_ff @(negedge KEY[1])
	begin
		r[1:0] <= r[1:0] + 2'h1;
	end
	
	always_ff @(negedge KEY[2])
	begin
		regs[r] <= SW;
	end

	ALU alu(regs[0][4:0], regs[1], regs[2], regs[3], out1, out2, LEDG[0], LEDG[1], LEDG[2], LEDG[3]);

endmodule
