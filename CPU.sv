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

module CPU (
	// clock, reset, ...
	input CORE_CLK,
	input RESET,
	output halt,

	// RAM access
	output [15:0] RAM_addr,
	output [15:0] RAM_data,
	output RAM_wr,
	input  [15:0] RAM_q

	//
	
);

	enum {
		S_halt,
		S_fetch,
		S_fetch_a,
		S_nextword_a,
		S_fetch_b,
		S_nextword_b,
		S_set_write,
		S_arith_write,
		S_inc_ij,
		S_dec_ij
	} S;

	assign halt = S == S_halt;

	reg [3:0] wait_tick = 4'h0; // stall processor to keep correct cycle count (1 cycle = 4 ticks)

	reg [15:0] GP [7:0], PC = 16'h0000, SP = 16'h0000, EX, IA = 16'h0000; // GP and special registers
	reg [15:0] IB; // instruction buffer
	wire spop = ~|IB[4:0]; // special opcode
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
		RAM_addr <= 16'h0000;
		RAM_data <= 16'h0000;
		RAM_wr <= 1'b0;
		case(S)
			S_fetch:
				RAM_addr <= PC;

			S_fetch_a: begin
				case(IB[15:10])
					6'h08,6'h09,6'h0A,6'h0B,6'h0C,6'h0D,6'h0E,6'h0F: RAM_addr <= GP[IB[12:10]];
					6'h18,6'h19: RAM_addr <= SP; // POP / PEEK
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E,6'h1F: RAM_addr <= PC;
				endcase
			end

			S_nextword_a: begin
				case(IB[15:10])
					6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17: RAM_addr <= GP[IB[12:10]] + NW;
					6'h1A: RAM_addr <= SP + NW; // PICK
					6'h1E: RAM_addr <= NW;
				endcase
			end

			S_fetch_b: begin
				case(IB[9:5])
					5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F: RAM_addr <= GP[IB[7:5]];
					5'h18: RAM_addr <= SP - 16'h0001; // PUSH
					5'h19: RAM_addr <= SP; // PEEK
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E,5'h1F: RAM_addr <= PC;
				endcase
			end

			S_nextword_b: begin
				case(IB[9:5])
					5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17: RAM_addr <= GP[IB[7:5]] + NW;
					5'h1A: RAM_addr <= SP + NW;
					5'h1E: RAM_addr <= NW;
				endcase
			end

			S_set_write: begin
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
				endcase
				RAM_data <= a;
			end

			S_arith_write: begin
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
				endcase
				RAM_data <= ALU_q;
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
			S <= S_fetch;
		end
		else if (|wait_tick) // wait_tick != 0
			wait_tick <= wait_tick - 4'h1;
		else begin
			case(S)
				S_fetch: begin
					IB <= RAM_q;
					PC <= PC + 16'h0001;
					S <= S_fetch_a;
				end

				S_fetch_a: begin
					case(IB[15:10])
						6'h00,6'h01,6'h02,6'h03,6'h04,6'h05,6'h06,6'h07: a <= GP[IB[12:10]];
						6'h08,6'h09,6'h0A,6'h0B,6'h0C,6'h0D,6'h0E,6'h0F,6'h19: a <= RAM_q;
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: begin
							NW <= RAM_q;
							PC <= PC + 16'h0001;
						end
						6'h18: begin //POP
							a <= RAM_q;
							SP <= SP + 16'h0001;
						end
						6'h1B: a <= SP;
						6'h1C: a <= PC;
						6'h1D: a <= EX;
						6'h1F: begin
							a <= RAM_q;
							PC <= PC + 16'h0001;
							wait_tick <= 4'h4;
						end
						default: a <= {{10{1'b0}},IB[15:10]} - 16'h0021;
					endcase

					case(IB[15:10])
						6'h10,6'h11,6'h12,6'h13,6'h14,6'h15,6'h16,6'h17,6'h1A,6'h1E: S <= S_nextword_a;
						default: 
							if (spop) S <= S_halt;
							else S <= S_fetch_b;
					endcase
				end

				S_nextword_a: begin
					a <= RAM_q;
					S <= S_fetch_b;
					wait_tick <= 4'h3;
				end

				S_fetch_b: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: b <= GP[IB[7:5]];
						5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,5'h19: b <= RAM_q;
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: begin
							NW <= RAM_q;
							PC <= PC + 16'h0001;
						end
						5'h18: begin // PUSH
							b <= RAM_q;
							SP <= SP - 16'h0001;
						end
						5'h1B: b <= SP;
						5'h1C: b <= PC;
						5'h1D: b <= EX;
						5'h1F: begin
							b <= RAM_q;
							PC <= PC + 16'h0001;
							wait_tick <= 4'h4;
						end
					endcase
					case(IB[9:5])
						5'h10,5'h11,5'h12,5'h13,5'h14,5'h15,5'h16,5'h17,5'h1A,5'h1E: S <= S_nextword_b;
						default:
							case(IB[4:0])
								5'h01,5'h1E,5'h1F: S <= S_set_write;
								5'h02,5'h03,5'h04,5'h05,5'h06,5'h07,5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,5'h1A,5'h1B: S <= S_arith_write;
								default: S <= S_halt;
							endcase
					endcase
					
				end

				S_nextword_b: begin
					b <= RAM_q;
					wait_tick <= 4'h3;
					case(IB[4:0])
						5'h01,5'h1E,5'h1F: S <= S_set_write;
						5'h02,5'h03,5'h04,5'h05,5'h06,5'h07,5'h08,5'h09,5'h0A,5'h0B,5'h0C,5'h0D,5'h0E,5'h0F,5'h1A,5'h1B: S <= S_arith_write;
						default: S <= S_halt;
					endcase
				end

				S_set_write: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: GP[IB[7:5]] <= a;
						5'h1b: SP <= a;
						5'h1c: PC <= a;
						5'h1d: EX <= a;
					endcase
					case(IB[4:0])
						5'h1e: S <= S_inc_ij;
						5'h1f: S <= S_dec_ij;
						default: S <= S_fetch;
					endcase
				end

				S_arith_write: begin
					case(IB[9:5])
						5'h00,5'h01,5'h02,5'h03,5'h04,5'h05,5'h06,5'h07: GP[IB[7:5]] <= ALU_q;
						5'h1b: SP <= ALU_q;
						5'h1c: PC <= ALU_q;
						5'h1d: EX <= ALU_q;
					endcase
					S <= S_fetch;
					case(IB[4:0])
						5'h02,5'h03,5'h04,5'h05: wait_tick <= 4'h4;
						5'h06,5'h07,5'h08,5'h09: wait_tick <= 4'h8;
					endcase
				end

				S_inc_ij: begin
					GP[6] <= GP[6] + 16'h0001; // I++
					GP[7] <= GP[7] + 16'h0001; // J++
					wait_tick <= 4'h3;
					S <= S_fetch;
				end

				S_dec_ij: begin
					GP[6] <= GP[6] - 16'h0001; // I--
					GP[7] <= GP[7] - 16'h0001; // J--
					wait_tick <= 4'h3;
					S <= S_fetch;
				end

				default: begin
					S <= S_halt;
				end
			endcase
		end
	end

endmodule
