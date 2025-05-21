module ID_ALU(
    input clk,
    input rst,
    input stall,
    input branch,
    input [5:0] inst_index,
    input [31:0] read_data_1,
    input [31:0] read_data_2,
    input [31:0] imm_data,
    input [4:0] rd_index,
    input [31:0] pc,
    output reg [5:0] inst_index_out,
    output reg [31:0] read_data_1_out,
    output reg [31:0] read_data_2_out,
    output reg [31:0] imm_data_out,
    output reg [4:0] rd_index_out,
    output reg [31:0] pc_out
);

    reg [5:0] inst_index_next;  
    reg [31:0] read_data_1_next; 
    reg [31:0] read_data_2_next; 
    reg [31:0] imm_data_next;    
    reg [4:0] rd_index_next;    
    reg [31:0] pc_next;          

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            inst_index_out <= 6'b111111;
            read_data_1_out <= 32'b0;
            read_data_2_out <= 32'b0;
            imm_data_out <= 32'b0;
            rd_index_out <= 5'b00000;
            pc_out <= 32'b0;
        end
        else if (stall) begin
            inst_index_out <= 6'b111111;
            read_data_1_out <= 32'b0;
            read_data_2_out <= 32'b0;
            imm_data_out <= 32'b0;
            rd_index_out <= 5'b00000;
            pc_out <= 32'b0;
        end
        else if (branch) begin
            inst_index_out <= 6'b111111;
            read_data_1_out <= 32'b0;
            read_data_2_out <= 32'b0;
            imm_data_out <= 32'b0;
            rd_index_out <= 5'b00000;
            pc_out <= 32'b0;
        end
        else if (!stall) begin
            inst_index_out <=  inst_index_next;
            read_data_1_out <= read_data_1_next;
            read_data_2_out <= read_data_2_next;
            imm_data_out <=    imm_data_next;
            rd_index_out <=    rd_index_next;
            pc_out <=          pc_next;
        end
    end
    always @(*) begin
        inst_index_next <= inst_index;
        read_data_1_next <= read_data_1;
        read_data_2_next <= read_data_2;
        imm_data_next <= imm_data;
        rd_index_next <= rd_index;
        pc_next <= pc;
    end
endmodule
