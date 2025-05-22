`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 07:09:57 PM
// Design Name: 
// Module Name: seven_seg_map
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg_map(input [5:0]sw, output reg [7:0] seg_out,output [7:0] seg_en);
    assign seg_en = 8'hff;
    always @ *
        case (sw)
       6'b000000: seg_out = 8'b11111100; // 0
       6'b000001: seg_out = 8'b01100000; // 1
       6'b000010: seg_out = 8'b11011010; // 2
       6'b000011: seg_out = 8'b11110010; // 3
       6'b000100: seg_out = 8'b01100110; // 4
       6'b000101: seg_out = 8'b10110110; // 5
       6'b000110: seg_out = 8'b10111110; // 6
       6'b000111: seg_out = 8'b11100000; // 7
       6'b001000: seg_out = 8'b11111110; // 8
       6'b001001: seg_out = 8'b11100110; // 9
       6'b001010: seg_out = 8'b11101110; // A
       6'b001011: seg_out = 8'b00111110; // B
       6'b001100: seg_out = 8'b10011100; // C
       6'b001101: seg_out = 8'b01111010; // D
       6'b001110: seg_out = 8'b10011110; // E
       6'b001111: seg_out = 8'b10001110; // F
       6'b010000: seg_out = 8'b11110110; // G
       6'b010001: seg_out = 8'b01101110; // H
       6'b010010: seg_out = 8'b01100000; // I
       6'b010011: seg_out = 8'b01111000; // J
       6'b010100: seg_out = 8'b00001110; // K
       6'b010101: seg_out = 8'b00011100; // L
       6'b010110: seg_out = 8'b10101000; // M
       6'b010111: seg_out = 8'b11101100; // N
       6'b011000: seg_out = 8'b11111100; // O
       6'b011001: seg_out = 8'b11001110; // P
       6'b011010: seg_out = 8'b11100110; // Q
       6'b011011: seg_out = 8'b10001100; // R
       6'b011100: seg_out = 8'b10110110; // S
       6'b011101: seg_out = 8'b00011110; // T
       6'b011110: seg_out = 8'b01111100; // U
       6'b011111: seg_out = 8'b00111000; // V
       6'b100000: seg_out = 8'b01010100; // W
       6'b100001: seg_out = 8'b01100010; // X
       6'b100010: seg_out = 8'b01110110; // Y
       6'b100011: seg_out = 8'b11011010; // Z
       6'b100100: seg_out = 8'b00000001; //.dp
       6'b100101: seg_out = 8'b00000000; //.empty
       6'b100110: seg_out = 8'b00000010; // -
       default:   seg_out = 8'b00000000; // empty
    endcase
    
endmodule
