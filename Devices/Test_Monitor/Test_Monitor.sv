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

module Test_Monitor (

	// CLOCK
	input CLOCK_50,

	// VGA
	output VGA_CLK,
	output VGA_SYNC_N,
	output VGA_BLANK_N,
	output VGA_VS,
	output VGA_HS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,

	// DMA
	input DMA_CLOCK,
	output [15:0] DMA_addr,
	output [15:0] DMA_data,
	output DMA_wren,
	input [15:0] DMA_q
	
);

	/* global reset signal */
	wire RESET;
	resetDelay rst(CLOCK_50, RESET);

	/* getting the proper clock */
	wire CLK, Mem_CLK;
	VGAclocker clk(CLOCK_50, CLK);
	assign VGA_CLK = CLK;

	wire [3:0] borderC = 4'b1000;

	wire scr_Mem_CLK;
	wire [8:0] scr_VRAM_addr;
	wire [15:0] scr_VRAM_data;
	wire [7:0] scr_FROM_addr;
	wire [15:0] scr_FROM_data;
	wire [3:0] scr_PROM_addr;
	wire [15:0] scr_PROM_data;

	dcpuScrControll sc(
		.CLOCK_25M(CLK), .RST(RESET),
		.blank_n(VGA_BLANK_N), .VSync(VGA_VS), .HSync(VGA_HS), .R_Data(VGA_R), .G_Data(VGA_G), .B_Data(VGA_B),
		.borderColour(borderC),
		.Mem_CLK(scr_Mem_CLK),
		.VRAM_addr(scr_VRAM_addr), .VRAM_data(scr_VRAM_data),
		.FROM_addr(scr_FROM_addr), .FROM_data(scr_FROM_data),
		.PROM_addr(scr_PROM_addr), .PROM_data(scr_PROM_data)
	);

	assign VGA_SYNC_N = VGA_HS ^ VGA_VS;

	VRAM cells(.rdclock(scr_Mem_CLK), .rdaddress(scr_VRAM_addr), .q(scr_VRAM_data), .data(DMA_q), .wraddress(VRAM_counter[8:0]), .wrclock(DMA_CLOCK), .wren(1'b1));
	FROM font_rom(.clock_a(scr_Mem_CLK), .address_a(scr_FROM_addr), .q_a(scr_FROM_data));
	PROM pal_rom(.clock_a(scr_Mem_CLK), .address_a(scr_PROM_addr), .q_a(scr_PROM_data));

	reg [15:0] VRAM_base = 16'hF000;
	reg [15:0] VRAM_counter = 16'h0000;

	always_ff @(negedge DMA_CLOCK)
	begin
		if (RESET || VRAM_counter == 16'h0180) VRAM_counter <= 16'h0000;
		else VRAM_counter <= VRAM_counter + 16'h0001;
	end

	assign DMA_addr = VRAM_base + VRAM_counter;
	assign DMA_data = 16'h0000;
	assign DMA_wren = 1'b0;

endmodule
