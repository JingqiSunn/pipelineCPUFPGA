module IM(
    input wire clk,
    input wire clk_original,
    input wire rst,
    input wire ecall,
    input wire [7:0] switch_left,
    input wire [2:0] switch_right,
    input wire confirm,
    input wire [31:0] x10,
    input wire [31:0] x17,
    output reg done,
    output reg [31:0] data,
    // output LED,
    output reg F6,
    output reg G4,
    output reg G3,
    output reg J4,
    output reg H4,
    output reg J3,
    output reg J2,
    output reg K2,
    //output tube
    output wire B4,
    output wire A4,
    output wire A3,
    output wire B1,
    output wire A1,
    output wire B3,
    output wire B2,
    output wire D5,
    output wire D4,
    output wire E3,
    output wire D3,
    output wire F4,
    output wire F3,
    output wire E2,
    output wire D2,
    output wire H2,
    output wire G2,
    output wire C2,
    output wire C1,
    output wire H1,
    output wire G1,
    output wire F1,
    output wire E1,
    output wire G6
);
    // determine the done
    reg done_next;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            done <= 1'b0;
        end else if (done == 1'b1) begin
            done <= 1'b0;
        end else begin
            done <= done_next;
        end
    end
    always @(*) begin
        if (confirm) begin
            done_next = 1'b1;
        end else begin
            done_next = 1'b0;
        end
    end
    // determine the data
    reg [31:0] data_next;  
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            data <= 32'b0;
        end else begin
            data <= data_next;
        end
    end
    always @(*) begin
        case (x17)
            32'h00000001: begin // input(8 bit unsigned)
                data_next = {24'b0, switch_left}; 
            end
            32'h00000006: begin // input(8 bit signed)
                data_next = {{24{switch_left[7]}}, switch_left}; 
            end
            32'h00000002: begin // input(4 bit)
                data_next = {28'b0, switch_left[3:0]};
            end
            32'h00000007: begin // input(8 bit)
                data_next = {{29'b0}, switch_right}; 
            end
            default: begin
                data_next = 32'b0;
            end
        endcase
    end
    // determine the tube
    // 6'b000000: seg_out = 8'b11111100; // 0
    // 6'b000001: seg_out = 8'b01100000; // 1
    // 6'b000010: seg_out = 8'b11011010; // 2
    // 6'b000011: seg_out = 8'b11110010; // 3
    // 6'b000100: seg_out = 8'b01100110; // 4
    // 6'b000101: seg_out = 8'b10110110; // 5
    // 6'b000110: seg_out = 8'b10111110; // 6
    // 6'b000111: seg_out = 8'b11100000; // 7
    // 6'b001000: seg_out = 8'b11111110; // 8
    // 6'b001001: seg_out = 8'b11100110; // 9
    // 6'b001010: seg_out = 8'b11101110; // A
    // 6'b001011: seg_out = 8'b00111110; // B
    // 6'b001100: seg_out = 8'b10011100; // C
    // 6'b001101: seg_out = 8'b01111010; // D
    // 6'b001110: seg_out = 8'b10011110; // E
    // 6'b001111: seg_out = 8'b10001110; // F
    // 6'b010000: seg_out = 8'b11110110; // G
    // 6'b010001: seg_out = 8'b01101110; // H
    // 6'b010010: seg_out = 8'b01100000; // I
    // 6'b010011: seg_out = 8'b01111000; // J
    // 6'b010100: seg_out = 8'b00001110; // K
    // 6'b010101: seg_out = 8'b00011100; // L
    // 6'b010110: seg_out = 8'b10101000; // M
    // 6'b010111: seg_out = 8'b11101100; // N
    // 6'b011000: seg_out = 8'b11111100; // O
    // 6'b011001: seg_out = 8'b11001110; // P
    // 6'b011010: seg_out = 8'b11100110; // Q
    // 6'b011011: seg_out = 8'b10001100; // R
    // 6'b011100: seg_out = 8'b10110110; // S
    // 6'b011101: seg_out = 8'b00011110; // T
    // 6'b011110: seg_out = 8'b01111100; // U
    // 6'b011111: seg_out = 8'b00111000; // V
    // 6'b100000: seg_out = 8'b01010100; // W
    // 6'b100001: seg_out = 8'b01100010; // X
    // 6'b100010: seg_out = 8'b01110110; // Y
    // 6'b100011: seg_out = 8'b11011010; // Z
    // 6'b100100: seg_out = 8'b00000001; //.dp
    // 6'b100101: seg_out = 8'b00000000; //.empty
    // default:   seg_out = 8'b00000000; // empty
    // determine the value of content_7 to content_0
    reg [5:0] content_7, content_6, content_5, content_4;
    reg [5:0] content_3, content_2, content_1, content_0;
    always @(*) begin
        case (x17)
            32'h00000003: begin // output(hex)
                content_7 = x10[3:0];   
                content_6 = x10[7:4];   
                content_5 = x10[11:8];  
                content_4 = x10[15:12]; 
                content_3 = x10[19:16];
                content_2 = x10[23:20]; 
                content_1 = x10[27:24]; 
                content_0 = x10[31:28]; 
            end
            32'h00000004: begin // output(decimal)
                content_7 = x10 % 10;                   
                content_6 = (x10 / 10) % 10;            
                content_5 = (x10 / 100) % 10;         
                content_4 = (x10 / 1000) % 10;          
                content_3 = (x10 / 10000) % 10;        
                content_2 = (x10 / 100000) % 10;        
                content_1 = (x10 / 1000000) % 10;       
                content_0 = (x10 / 10000000) % 10;      
            end
            32'h00000007: begin // input(choose question)
                content_7 = data_next % 10;   
                content_6 = 6'b100101;   
                content_5 = 6'b100101;  
                content_4 = 6'b100101; 
                content_3 = 6'b011101;
                content_2 = 6'b011100; 
                content_1 = 6'b001110; 
                content_0 = 6'b011101; 
            end
            32'h00000001: begin // input (8bits unsigned)
                content_7 = 6'b011110;   
                content_6 = 6'b100101;   
                content_5 = 6'b011100;  
                content_4 = 6'b011101; 
                content_3 = 6'b010010;
                content_2 = 6'b001011; 
                content_1 = 6'b100101; 
                content_0 = 6'b001000; 
            end
            32'h00000006: begin // input (8bits signed)
                content_7 = 6'b011100;   
                content_6 = 6'b100101;   
                content_5 = 6'b011100;  
                content_4 = 6'b011101; 
                content_3 = 6'b010010;
                content_2 = 6'b001011; 
                content_1 = 6'b100101; 
                content_0 = 6'b001000; 
            end
            32'h00000002: begin // input (4bits unsigned)
                content_7 = 6'b011110;   
                content_6 = 6'b100101;   
                content_5 = 6'b011100;  
                content_4 = 6'b011101; 
                content_3 = 6'b010010;
                content_2 = 6'b001011; 
                content_1 = 6'b100101; 
                content_0 = 6'b000100; 
            end
            default: begin
                content_7 = 6'b100101;
                content_6 = 6'b100101;
                content_5 = 6'b100101;
                content_4 = 6'b100101;
                content_3 = 6'b100101;
                content_2 = 6'b100101;
                content_1 = 6'b100101;
                content_0 = 6'b100101;
            end
        endcase
    end
    scan_seg scan_seg_1(
        .rst_n(rst),
        .clk(clk_original),
        .n0(content_0),
        .n1(content_1),
        .n2(content_2),
        .n3(content_3),
        .n4(content_4),
        .n5(content_5),
        .n6(content_6),
        .n7(content_7),
        .seg_en({G2, C2, C1, H1, G1, F1, E1, G6}),
        .seg_out0({B4, A4, A3, B1, A1, B3, B2, D5}),
        .seg_out1({D4, E3, D3, F4, F3, E2, D2, H2})
    );

    // determine the LED
    always @(*) begin
        case (x17)
            32'h00000005: begin // LED
                {F6, G4, G3, J4, H4, J3, J2, K2} = x10[7:0];
            end
            default: begin
                F6 = 1'b0;
                G4 = 1'b0;
                G3 = 1'b0;
                J4 = 1'b0;
                H4 = 1'b0;
                J3 = 1'b0;
                J2 = 1'b0;
                K2 = 1'b0;
            end
        endcase
    end
endmodule
