module dcpu(

	//////////// CLOCK //////////
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,

	//////////// LED //////////
	output [8:0] LEDG,
	output [17:0] LEDR,

	//////////// KEY //////////
	input [3:0] KEY,

	//////////// SW //////////
	input [17:0] SW,

	//////////// SEG7 //////////
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,

	//////////// PS2 for Keyboard and Mouse //////////
	inout PS2_CLK,
	inout PS2_CLK2,
	inout PS2_DAT,
	inout PS2_DAT2,

	//////////// VGA //////////
	output VGA_CLK,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output VGA_HS,
	output VGA_VS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);

//=======================================================
//  PARAMETER declarations
//=======================================================



//=======================================================
//  Structural coding
//=======================================================



endmodule
