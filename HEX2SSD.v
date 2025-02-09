`timescale 1ns / 1ps
module HEX2SSD(
     input [3:0]hex,
    output reg [6:0] seg
    );
    
    always @(*)
    begin
        case(hex)
            4'h0 : seg = 7'h3f; // 0
            4'h1 : seg = 7'h06; // 1
            4'h2 : seg = 7'h5b; // 2
            4'h3 : seg = 7'h4f; // 3
            4'h4 : seg = 7'h66; // 4
            4'h5 : seg = 7'h6d; // 5
            4'h6 : seg = 7'h7d; // 6
            4'h7 : seg = 7'h07; // 7
            4'h8 : seg = 7'h7f; // 8
            4'h9 : seg = 7'h67; // 9
            4'ha : seg = 7'h77; // 10
            4'hb : seg = 7'h7c; // 11
            4'hc : seg = 7'h39; // 12
            4'hd : seg = 7'h5e; // 13
            4'he : seg = 7'h79; // 14
            4'hf : seg = 7'h71; // 15
        endcase
    end
endmodule

