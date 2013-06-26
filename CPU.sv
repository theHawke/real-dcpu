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
		fetch_a,
		nextword_a,
		fetch_b,
		nextword_b,
		set_write,
		arith_write
	} S;

	reg [3:0] wait_tick = 4'h0; // stall processor to keep correct cycle count (1 cycle = XX ticks)

	reg [15:0] A, B, C, X, Y, Z, I, J, PC = 16'h0000, SP = 16'h0000, EX, IA = 16'h0000; // GP and special registers
	reg [15:0] IB; // instruction buffer
	reg [15:0] NW; // nextword buffer

	reg [15:0] b, a; // operand values
	
	// ALU
	wire [15:0] ALU_q, ALU_EX;
	wire ALU_cl, ALU_eq, ALU_lt, ALU_un;
	ALU alu(.op(IB[4:0]),
			  .b(b),
			  .a(a),
			  .EXin(EX),
			  .q(ALU_q),
			  .EXout(ALU_EX),
			  .cl(ALU_cl),
			  .eq(ALU_eq),
			  .lt(ALU_lt),
			  .un(ALU_un)
			  );

	// preperations for memory access
	always_comb
	begin
		case(S)
			fetch:
				RAM_addr <= PC;
			fetch_a: begin
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
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end
			nextword_a: begin
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
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end
			fetch_b: begin
				case(IB[9:5])
					5'h08: RAM_addr <= A;
					5'h09: RAM_addr <= B;
					5'h0A: RAM_addr <= C;
					5'h0B: RAM_addr <= X;
					5'h0C: RAM_addr <= Y;
					5'h0D: RAM_addr <= Z;
					5'h0E: RAM_addr <= I;
					5'h0F: RAM_addr <= J;
					5'h18: RAM_addr <= SP - 16'h0001; // PUSH
					5'h19: RAM_addr <= SP;
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E,5'h1F: RAM_addr <= PC;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end
			nextword_b: begin
				case(IB[9:5])
					5'h10: RAM_addr <= A + NW;
					5'h11: RAM_addr <= B + NW;
					5'h12: RAM_addr <= C + NW;
					5'h13: RAM_addr <= X + NW;
					5'h14: RAM_addr <= Y + NW;
					5'h15: RAM_addr <= Z + NW;
					5'h16: RAM_addr <= I + NW;
					5'h17: RAM_addr <= J + NW;
					5'h1A: RAM_addr <= SP + NW;
					5'h1E: RAM_addr <= NW;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end
			set_write: begin
				RAM_out <= a;
				case(IB[9:5])
					5'h08: begin
						RAM_addr <= A;
						RAM_wr <= 1'b1;
					end
					5'h09: begin
						RAM_addr <= B;
						RAM_wr <= 1'b1;
					end
					5'h0A: begin
						RAM_addr <= C;
						RAM_wr <= 1'b1;
					end
					5'h0B: begin
						RAM_addr <= X;
						RAM_wr <= 1'b1;
					end
					5'h0C: begin
						RAM_addr <= Y;
						RAM_wr <= 1'b1;
					end
					5'h0D: begin
						RAM_addr <= Z;
						RAM_wr <= 1'b1;
					end
					5'h0E: begin
						RAM_addr <= I;
						RAM_wr <= 1'b1;
					end
					5'h0F: begin
						RAM_addr <= J;
						RAM_wr <= 1'b1;
					end
					5'h10: begin
						RAM_addr <= A + NW;
						RAM_wr <= 1'b1;
					end
					5'h11: begin
						RAM_addr <= B + NW;
						RAM_wr <= 1'b1;
					end
					5'h12: begin
						RAM_addr <= C + NW;
						RAM_wr <= 1'b1;
					end
					5'h13: begin
						RAM_addr <= X + NW;
						RAM_wr <= 1'b1;
					end
					5'h14: begin
						RAM_addr <= Y + NW;
						RAM_wr <= 1'b1;
					end
					5'h15: begin
						RAM_addr <= Z + NW;
						RAM_wr <= 1'b1;
					end
					5'h16: begin
						RAM_addr <= I + NW;
						RAM_wr <= 1'b1;
					end
					5'h17: begin
						RAM_addr <= J + NW;
						RAM_wr <= 1'b1;
					end
				endcase
			end	
			arith_write:
				//TODO
			default: begin
				RAM_addr <= 16'h0000;
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end
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
					S <= fetch_a;
				end
				fetch_a: begin
					// ALU a input
					case(IB[15:10])
						6'h00: a <= A;
						6'h01: a <= B;
						6'h02: a <= C;
						6'h03: a <= X;
						6'h04: a <= Y;
						6'h05: a <= Z;
						6'h06: a <= I;
						6'h07: a <= J;
						6'h1B: a <= SP;
						6'h1C: a <= PC;
						6'h1D: a <= EX;
						6'h08,6'h09,6'h0A,6'h0B,6'h0C,6'h0D,6'h0E,6'h0F,6'h19,6'h1F: a <= RAM_data;
						6'h18: begin //POP
							a <= RAM_data;
							SP <= SP + 16'0001;
						end
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: NW <= RAM_data;
						default: a <= {10{0},IB[15:10]} - 16'h0021;
					endcase

					//nextstate
					case(IB[15:10])
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: S <= nextword_a;
						default:
							case(IB[4:0]) //TODO
								5'h01: S <= set_write
								default: S <= fetch_b;
							endcase
					endcase
				end
				nextword_a: begin
					a <= RAM_data;
					S <= fetch_b;
					PC <= PC + 16'h0001;
					wait_tick = 4'hX; //TODO
				end
				fetch_b: begin
					case(IB[9:5])
						5'h00: b <= A;
						5'h01: b <= B;
						5'h02: b <= C;
						5'h03: b <= X;
						5'h04: b <= Y;
						5'h05: b <= Z;
						5'h06: b <= I;
						5'h07: b <= J;
						5'h1B: b <= SP;
						5'h1C: b <= PC;
						5'h1D: b <= EX;
						5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,5'h19,5'h1F: b <= RAM_data;
						5'h18: begin // PUSH
							b <= RAM_data;
							SP <= SP - 16'h0001;
						end
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: NW <= RAM_data;
					endcase
					case(IB[9:5])
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: S <= nextword_b;
						default:
							case(IB[4:0])
								//TODO
								default: S <= arith_write;
							endcase
					endcase
					
				end
				default: begin
					S <= halt;
				end
			endcase
		end
	end

endmodule
