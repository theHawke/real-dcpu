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

	reg [3:0] wait_tick = 4'h0; // stall processor to keep correct cycle count (1 cycle = 4 ticks)

	reg [15:0] GP [7:0], PC = 16'h0000, SP = 16'h0000, EX, IA = 16'h0000; // GP and special registers
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
					6'h08,6'h09,6'h0A,6'h0B,6'h0C,6'h0D,6'h0E,6'h0F,: RAM_addr <= GP[IB[12:10]];
					6'h18,6'h19: RAM_addr <= SP; // POP / PEEK
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E,6'h1F: RAM_addr <= PC;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end

			nextword_a: begin
				case(IB[15:10])
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17: RAM_addr <= GP[IB[12:10]] + NW;
					6'h1A: RAM_addr <= SP + NW; // PICK
					6'h1E: RAM_addr <= NW;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end

			fetch_b: begin
				case(IB[9:5])
					5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,: RAM_addr <= GP[IB[7:5]];
					5'h18: RAM_addr <= SP - 16'h0001; // PUSH
					5'h19: RAM_addr <= SP; // PEEK
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E,5'h1F: RAM_addr <= PC;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end

			nextword_b: begin
				case(IB[9:5])
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17: RAM_addr <= GP[IB[7:5]] + NW;
					5'h1A: RAM_addr <= SP + NW;
					5'h1E: RAM_addr <= NW;
					default: RAM_addr <= 16'h0000;
				endcase
				RAM_out <= 16'h0000;
				RAM_wr <= 0;
			end

			set_write,arith_write: begin
				case(IB[9:5])
					5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F: begin
						RAM_addr <= GP[IB[7:5]];
						RAM_wr <= 1'b1;
					end
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17: begin
						RAM_addr <= GP[IB[7:5]] + NW;
						RAM_wr <= 1'b1;
					end
					5'h18,5'h19: begin
						RAM_addr <= SP;
						RAM_wr <= 1'b1;
					end
					5'h1A: begin
						RAM_addr <= SP + NW;
						RAM_wr <= 1'b1;
					end
					5'h1E: begin
						RAM_addr <= NW;
						RAM_wr <= 1'b1;
					end
					default: begin
						RAM_addr <= 16'h0000;
						RAM_wr <= 1'b0;
					end
				endcase
				
				if (S == set_write)
					RAM_out <= a;
				else // if (S == arith_write)
					RAM_out <= ALU_q;
			end

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
						6'h00,6'h01,6'h02,6'h03,6'h04,6'h05,6'h06,6'h07: a <= GP[IB[12:10]];
						6'h08,6'h09,6'h0A,6'h0B,6'h0C,6'h0D,6'h0E,6'h0F,6'h19: a <= RAM_data;
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: begin
							NW <= RAM_data;
							PC <= PC + 16'h0001;
						end
						6'h18: begin //POP
							a <= RAM_data;
							SP <= SP + 16'0001;
						end
						6'h1B: a <= SP;
						6'h1C: a <= PC;
						6'h1D: a <= EX;
						6'h1F: begin
							a <= RAM_data;
							PC <= PC + 16'h0001;
							wait_tick <= 4'h4;
						end
						default: a <= {10{0},IB[15:10]} - 16'h0021;
					endcase

					//nextstate
					case(IB[15:10])
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: S <= nextword_a;
						default:
							if (
							S <= fetch_b;
					endcase
				end

				nextword_a: begin
					a <= RAM_data;
					S <= fetch_b;
					wait_tick <= 4'h3;
				end

				fetch_b: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: b <= GP[IB[7:5]];
						5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,5'h19: b <= RAM_data;
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: begin
							NW <= RAM_data;
							PC <= PC + 16'h0001;
						end
						5'h18: begin // PUSH
							b <= RAM_data;
							SP <= SP - 16'h0001;
						end
						5'h1B: b <= SP;
						5'h1C: b <= PC;
						5'h1D: b <= EX;
						5'h1F: begin
							b <= RAM_data;
							PC <= PC + 16'h0001;
							wait_tick <= 4'h4;
						end
					endcase
					case(IB[9:5])
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: S <= nextword_b;
						default:
							case(IB[4:0])
								5'h01: S <= set_write;
								default: S <= arith_write;
							endcase
					endcase
					
				end

				nextword_b: begin
					b <= RAM_data;
					S <= fetch_b;
					wait_tick <= 4'h3;
				end

				set_write: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: GP[IB[7:5]] <= a;
						5'h1b: SP <= a;
						5'h1c: PC <= a;
						5'h1d: EX <= a;
					endcase
					S <= fetch;
				end

				arith_write: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: GP[IB[7:5]] <= ALU_q;
						5'h1b: SP <= ALU_q;
						5'h1c: PC <= ALU_q;
						5'h1d: EX <= ALU_q;
					endcase
					S <= fetch;
				end

				default: begin
					S <= halt;
				end
			endcase
		end
	end

endmodule
