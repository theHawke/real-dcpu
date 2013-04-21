module CPU (
	// clock, reset
	input CORE_CLK,
	input RESET,

	// RAM access
	output RAM_addr,
	output RAM_out,
	output RAM_wr,
	input RAM_data

	//
	
);

	enum {
		halt,
		fetch,
		decode_op_fetch_a,
		nextword_a,
		fetch_b,
		nextword_b
	} S;

	reg [3:0] wait_tick = 4'h0; // stall processor to keep correct cycle count (1 cycle = XX ticks)

	reg [15:0] A, B, C, X, Y, Z, I, J, PC = 16'h0000, SP = 16'h0000, EX, IA = 16'h0000; // GP and special registers
	reg [15:0] IB; // instruction buffer
	reg [15:0] NW; // nextword buffer

	reg [15:0] b, a; // operand values
	reg [3:0] ALU_fn; // ALU function

	// preperations for memory access
	always_comb
	begin
		case(S)
			fetch:
				RAM_addr <= PC;
			decode_op_fetch_a:
				case(IB[15:10])
					6'h08: RAM_addr <= A;
					6'h09: RAM_addr <= B;
					6'h0A: RAM_addr <= C;
					6'h0B: RAM_addr <= X;
					6'h0C: RAM_addr <= Y;
					6'h0D: RAM_addr <= Z;
					6'h0E: RAM_addr <= I;
					6'h0F: RAM_addr <= J;
					6'h18,6'h19: RAM_addr <= SP;
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E,6'h1F: RAM_addr <= PC;
					default: RAM_addr <= 16'h0000;
				endcase
			nextword_a:
				case(IB[15:10])
					6'h10: RAM_addr <= A + NW;
					6'h11: RAM_addr <= B + NW;
					6'h12: RAM_addr <= C + NW;
					6'h13: RAM_addr <= X + NW;
					6'h14: RAM_addr <= Y + NW;
					6'h15: RAM_addr <= Z + NW;
					6'h16: RAM_addr <= I + NW;
					6'h17: RAM_addr <= J + NW;
					6'h1A: RAM_addr <= SP + NW;
					6'h1E: RAM_addr <= NW;
					default: RAM_addr <= 16'h0000;
				endcase
			fetch_b:
				case(IB[15:10])
					6'h08: RAM_addr <= A;
					6'h09: RAM_addr <= B;
					6'h0A: RAM_addr <= C;
					6'h0B: RAM_addr <= X;
					6'h0C: RAM_addr <= Y;
					6'h0D: RAM_addr <= Z;
					6'h0E: RAM_addr <= I;
					6'h0F: RAM_addr <= J;
					6'h18: RAM_addr <= SP - 16'h0001; // PUSH
					6'h19: RAM_addr <= SP;
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E,6'h1F: RAM_addr <= PC;
					default: RAM_addr <= 16'h0000;
				endcase
			nextword_b:
				case(IB[15:10])
					6'h10: RAM_addr <= A + NW;
					6'h11: RAM_addr <= B + NW;
					6'h12: RAM_addr <= C + NW;
					6'h13: RAM_addr <= X + NW;
					6'h14: RAM_addr <= Y + NW;
					6'h15: RAM_addr <= Z + NW;
					6'h16: RAM_addr <= I + NW;
					6'h17: RAM_addr <= J + NW;
					6'h1A: RAM_addr <= SP + NW;
					6'h1E: RAM_addr <= NW;
					default: RAM_addr <= 16'h0000;
				endcase
			default:
				RAM_addr <= 16'h0000;
		endcase
	end

	// falling-edge triggered to be on the opposite edge to the RAM clocking
	always_ff @(negedge CORE_CLK or posedge RESET)
	begin
		if (RESET) begin
			PC <= 16'h0000;
			SP <= 16'h0000;
			IA <= 16'h0000;
			S <= fetch;
		end
		else if (|wait_tick) // wait_tick != 0
			wait_tick <= wait_tick - 4'h1;
		else begin
			case(S)
				fetch: begin
					IB <= RAM_data;
					PC <= PC + 16'h0001;
				end
				decode_op_fetch_a: begin
					//TODO
				end
				default: begin
					S <= halt;
				end
			endcase
		end
	end

endmodule
