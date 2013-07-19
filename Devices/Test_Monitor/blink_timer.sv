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

module blink_timer (
	input CLOCK_25M,
	input RST,

	output reg blinker
);

	reg [23:0] C;
	
	always_ff @(posedge CLOCK_25M or posedge RST)
	begin
		if (RST) begin
			C <= 0;
			blinker <= 1'b0;
		end
		else begin
			C <= C + 24'd1;
			if (C == 24'd1)
				blinker <= ~blinker;
		end
	end

endmodule		
		