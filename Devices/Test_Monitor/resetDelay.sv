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
