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

module resetDelay(
	input CLK,
	output reg RST
);

	reg [15:0] C = 0;

	always_ff @(posedge CLK)
	begin
		if (C == 16'hFFFF)
			RST <= 1'b0;
		else begin
			C <= C + 16'h0001;
			RST <= 1'b1;
		end
	end

endmodule
