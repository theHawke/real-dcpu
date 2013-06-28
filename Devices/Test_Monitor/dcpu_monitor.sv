/* TEST-moduöe to operate the screen on its own */
module dcpu_monitor(

	//////////// CLOCK //////////
	input CLOCK_50,

	//////////// VGA //////////
	output VGA_CLK,
	output VGA_SYNC_N,
	output VGA_BLANK_N,
	output reg VGA_VS,
	output reg VGA_HS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);

//=======================================================
//  Components
//=======================================================

	/* global reset signal */
	wire RESET;
	resetDelay rst(CLOCK_50, RESET);

	/* getting the proper clock */
	wire CLK, Mem_CLK;
	clocker clk(CLOCK_50, CLK);
	assign VGA_CLK = CLK;

	wire [3:0] borderC = 4'b0010;

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

	VRAM cells(.rdclock(scr_Mem_CLK), .rdaddress(scr_VRAM_addr), .q(scr_VRAM_data));
	FROM font_rom(.clock_a(scr_Mem_CLK), .address_a(scr_FROM_addr), .q_a(scr_FROM_data));
	PROM pal_rom(.clock_a(scr_Mem_CLK), .address_a(scr_PROM_addr), .q_a(scr_PROM_data));

endmodule

`timescale 10ns/1ns
module TESTER();

	reg CLOCK = 0;
	
	always
	begin
		#1 CLOCK <= ~CLOCK;
	end
	
	wire clk, sync, blank, vs, hs, r, g, b;
	ScreenControll scrcn(CLOCK, clk, sync, blank, vs, hs, r, g, b);

endmodule
