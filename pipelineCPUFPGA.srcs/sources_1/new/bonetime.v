`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 12:21:46
// Design Name: 
// Module Name: bonetime
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


module bonetime(
    input clk,
    input x_in,
    output x_pos
    );
    //wire x_pos;
    reg x_d1,x_d2,x_d3;
    always@(posedge clk) begin
    x_d1<=x_in;
    x_d2<=x_d1;
    x_d3<=x_d2;
    end
    assign x_pos = x_d2 & ~x_d3; 
endmodule