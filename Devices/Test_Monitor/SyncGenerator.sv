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

module SyncGenerator(
	input CLK,
	input reset,
	
	output blank_n,
	output HSync,
	output VSync
);

	parameter H_line = 800;
	parameter H_front = 16;
	parameter H_sync = 96;
	parameter H_back = 48;
	parameter V_frame = 525;
	parameter V_front = 10;
	parameter V_sync = 2;
	parameter V_back = 33;

	reg [9:0] pixelC;
	reg [9:0] lineC;

	always_ff @(posedge CLK or posedge reset)
	begin
		if (reset) begin
			pixelC <= 0;
			lineC <= 0;
		end
		else begin
			if (pixelC == H_line-1) begin
				pixelC <= 0;
				if (lineC == V_frame-1)
					lineC <= 0;
				else
					lineC <= lineC + 10'd1;
			end
			else
				pixelC <= pixelC + 10'd1;
		end
	end

	assign VSync = ~(lineC < V_sync); // active low
	assign HSync = ~(pixelC < H_sync); // active low
	
	assign blank_n = (lineC >= V_sync+V_back) && (lineC < V_frame-V_front) && (pixelC >= H_sync+H_back) && (pixelC < H_line-H_front);

endmodule
