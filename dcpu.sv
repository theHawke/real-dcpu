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

module dcpu(

	// CLOCK
	input CLOCK_50,

	// LED
	output [8:0] LEDG,
	output [17:0] LEDR,

	// KEY
	input [3:0] KEY,

	// SW
	input [17:0] SW,

	// SEG7
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,

	// PS2 for Keyboard and Mouse
	inout PS2_CLK,
	inout PS2_CLK2,
	inout PS2_DAT,
	inout PS2_DAT2,

	// VGA
	output VGA_CLK,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output VGA_HS,
	output VGA_VS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);

	wire [15:0] CPU_RAM_addr, CPU_RAM_data, CPU_RAM_q;
	wire [15:0] DEV_RAM_addr, DEV_RAM_data, DEV_RAM_q;
	wire CPU_RAM_wren, DEV_RAM_wren;
	wire Core_CLOCK, DMA_CLOCK;
	wire RESET;

	wire halt;
	wire debug_flag;
	wire [15:0] PC;

	resetDelay rst(CLOCK_50, RESET);
	clocker core(.inclk0(CLOCK_50), .c0(Core_CLOCK), .c1(DMA_CLOCK));

	CPU cpu(
		.CORE_CLK(Core_CLOCK),
		.RESET(RESET || !KEY[0]),
		.RAM_addr(CPU_RAM_addr),
		.RAM_data(CPU_RAM_data),
		.RAM_wr(CPU_RAM_wren),
		.RAM_q(CPU_RAM_q),
		.DBG_flag(debug_flag),
		.DBG_halt(halt),
		.DBG_PC(PC));

	Test_Monitor tm(
		.CLOCK_50(CLOCK_50),
		.VGA_CLK(VGA_CLK),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_VS(VGA_VS),
		.VGA_HS(VGA_HS),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.DMA_CLOCK(DMA_CLOCK),
		.DMA_addr(DEV_RAM_addr),
		.DMA_data(DEV_RAM_data),
		.DMA_wren(DEV_RAM_wren),
		.DMA_q(DEV_RAM_q));

	RAM ram(.address_a(CPU_RAM_addr),
		.clock_a(Core_CLOCK),
		.data_a(CPU_RAM_data),
		.wren_a(CPU_RAM_wren),
		.q_a(CPU_RAM_q),
		.address_b(DEV_RAM_addr),
		.clock_b(DMA_CLOCK),
		.data_b(DEV_RAM_data),
		.wren_b(DEV_RAM_wren),
		.q_b(DEV_RAM_q));

	assign LEDG = 0;
	assign LEDR = 0;
	assign HEX7 = halt ? 7'b0001011 : 7'h7F;
	assign HEX6 = debug_flag ? 7'b0100001 : 7'h7F;
	assign HEX5 = 7'h7F;
	assign HEX4 = 7'h7F;

	SEG_HEX h3(PC[15:12], HEX3),
			  h2(PC[11:8], HEX2),
			  h1(PC[7:4], HEX1),
			  h0(PC[3:0], HEX0);

endmodule
