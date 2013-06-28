module dcpuScrControll (
	// CLOCK and reset
	input CLOCK_25M,
	input RST,

	// VGA output
	output blank_n,
	output reg VSync,
	output reg HSync,
	output [7:0] R_Data,
	output [7:0] G_Data,
	output [7:0] B_Data,

	// border colour input
	input [3:0] borderColour,

	// ROM/RAM acess ports
	output Mem_CLK,
	output [8:0] VRAM_addr,
	input [15:0] VRAM_data,
	output [7:0] FROM_addr,
	input [15:0] FROM_data,
	output [3:0] PROM_addr,
	input [15:0] PROM_data
);

	wire HS, VS, PixelEnable;
	SyncGenerator sync(.CLK(CLOCK_25M), .reset(RST), .HSync(HS), .VSync(VS), .blank_n(PixelEnable));
	
	wire blinker;
	blink_timer bl(.CLOCK_25M(CLOCK_25M), .RST(RST), .blinker(blinker));

	assign Mem_CLK = ~CLOCK_25M;

	reg [9:0] pixel;
	reg [8:0] line;
	always_ff @(posedge CLOCK_25M)
	begin
		if (RST || ~VS) begin
			line <= 0;
			pixel <= 0;
		end
		else if (~HS && pixel != 0) begin
			line <= line + 9'd1;
			pixel <= 0;
		end
		else if (PixelEnable) begin
			pixel <= pixel + 10'd1;
		end
	end

	/* the pixel fetching pipeline needs to  be two pixels ahead */
	wire [9:0] pre_pixel;
	wire [8:0] pre_line;
	always_comb
	begin
		if (pixel >= 638) begin
			pre_pixel <= pixel - 10'd638;
			pre_line <= line + 9'd1;
		end
		else begin
			pre_pixel <= pixel + 10'd2;
			pre_line <= line;
		end
	end

	/* pixel upscaling 4x4 */
	wire [7:0] scr_pixel = pre_pixel[9:2];
	wire [6:0] scr_line = pre_line[8:2];

	/* pixel in the display area */
	wire [7:0] img_pixel = scr_pixel[7:0] - 8'd16;
	wire [6:0] img_line = scr_line[6:0] - 7'd12;

	/* each cell is 4x8 pixels */
	assign VRAM_addr[4:0] = img_pixel[6:2];
	assign VRAM_addr[8:5] = img_line[6:3];

	/* the wordSel bit needs to be buffered one, the bitSel bit twice */
	reg f_wordSel_B1;
	reg [3:0] f_bitSel_B1, f_bitSel_B2;
	always_ff @(negedge CLOCK_25M)
	begin
		f_wordSel_B1 <= img_pixel[1];
		f_bitSel_B2 <= f_bitSel_B1;
		f_bitSel_B1 <= {~img_pixel[0],img_line[2:0]};
	end

	/* loading the corect half of the character from memory */
	assign FROM_addr[7:1] = VRAM_data[6:0];
	assign FROM_addr[0] = f_wordSel_B1;
	
	wire fgbg = FROM_data[f_bitSel_B2];

	/* FG, BG & B parts of the cell_data need to be buffered once */
	reg [3:0] FG_ind_B1, BG_ind_B1;
	reg blink_B1;
	always_ff @(negedge CLOCK_25M)
	begin
		FG_ind_B1 <= VRAM_data[15:12];
		BG_ind_B1 <= VRAM_data[11:8];
		blink_B1 <= VRAM_data[7];
	end

	/* the border bit needs to be buffered twice */
	wire border_B1, border_B2;
	always_ff @(negedge CLOCK_25M)
	begin
		border_B2 <= border_B1;
		border_B1 <= scr_pixel < 16 || scr_pixel >= 144 || scr_line < 12 || scr_line >= 108;
	end

	/* the bit from the font decides on FG / BG (with blinking) */
	assign PROM_addr = border_B2 ? borderColour : (fgbg & ~(blink_B1 & blinker) ? FG_ind_B1 : BG_ind_B1);

	assign R_Data = {PROM_data[11:8],PROM_data[11:8]};
	assign G_Data = {PROM_data[7:4],PROM_data[7:4]};
	assign B_Data = {PROM_data[3:0],PROM_data[3:0]};

	assign blank_n = PixelEnable;
	
	always_ff @(posedge CLOCK_25M)
	begin
		VSync <= VS;
		HSync <= HS;
	end
		
endmodule
