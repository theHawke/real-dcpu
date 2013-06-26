module LED_HEX(input [3:0] num, output [6:0] HEX);

    always_comb
    case(num) // 0 = on, 1 = off
        4'h0: HEX <= 7'b1000000;
        4'h1: HEX <= 7'b1111001;
        4'h2: HEX <= 7'b0100100;
        4'h3: HEX <= 7'b0110000;
        4'h4: HEX <= 7'b0011001;
        4'h5: HEX <= 7'b0010010;
        4'h6: HEX <= 7'b0000010;
        4'h7: HEX <= 7'b1111000;
        4'h8: HEX <= 7'b0000000;
        4'h9: HEX <= 7'b0010000;
        4'hA: HEX <= 7'b0001000;
        4'hB: HEX <= 7'b0000011;
        4'hC: HEX <= 7'b1000110;
        4'hD: HEX <= 7'b0100001;
        4'hE: HEX <= 7'b0000110;
        4'hF: HEX <= 7'b0001110;
        default: HEX <= 7'b1111111;
    endcase

endmodule
