`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 07:11:13 PM
// Design Name: 
// Module Name: scan_seg
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

//show the information on the seg light
module scan_seg(rst_n,clk,seg_en,seg_out0,seg_out1,n0,n1,n2,n3,n4,n5,n6,n7);

    input rst_n;
    input clk; 
    input [5:0] n0;
    input [5:0] n1;
    input [5:0] n2;
    input [5:0] n3;
    input [5:0] n4;
    input [5:0] n5;
    input [5:0] n6;
    input [5:0] n7;
    
    reg [5:0] n_array [0:7];


    always @* begin
        n_array[0] = n7;
        n_array[1] = n6;
        n_array[2] = n5;
        n_array[3] = n4;
        n_array[4] = n3;
        n_array[5] = n2;
        n_array[6] = n1;
        n_array[7] = n0;
    end

    output reg [7:0] seg_en;
    output [7:0] seg_out0;
    output [7:0] seg_out1;
    
    reg clkout;
    reg [31:0] cnt;
    reg [2:0] scan_cnt;
    parameter period=200000;
    
    always @(posedge clk,negedge rst_n)
    begin
         if(!rst_n) begin
            cnt <=0;
            clkout <= 0;
         end
         else begin
            if(cnt == (period >>1)-1) begin
                clkout <= ~clkout;
                cnt <=0;
            end
            else begin
                cnt <= cnt+1;
            end
         end
    end

    always @(posedge clkout,negedge rst_n)
    begin
        if(~rst_n) begin
            scan_cnt <= 0;
        end
        else begin
            if(scan_cnt==3'd7) begin
                scan_cnt <=0;
            end
            else begin
                scan_cnt <= scan_cnt + 1;
            end
        end
    end

    always @(scan_cnt)
    begin
      case (scan_cnt)
        3'b000:seg_en=8'b00000001;
        3'b001:seg_en=8'b00000010;
        3'b010:seg_en=8'b00000100;
        3'b011:seg_en=8'b00001000;
        3'b100:seg_en=8'b00010000;
        3'b101:seg_en=8'b00100000;
        3'b110:seg_en=8'b01000000;
        3'b111:seg_en=8'b10000000;
        default:seg_en=8'b0;
      endcase
end

    wire useless0,useless1;
    seven_seg_map u0(.sw(n_array[scan_cnt]),.seg_out(seg_out0),.seg_en(useless0));
    seven_seg_map u1(.sw(n_array[scan_cnt]),.seg_out(seg_out1),.seg_en(useless1));

endmodule