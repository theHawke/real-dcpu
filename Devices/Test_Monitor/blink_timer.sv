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
		