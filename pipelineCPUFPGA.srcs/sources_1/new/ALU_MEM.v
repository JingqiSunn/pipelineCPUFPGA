module ALU_MEM(
    input clk,
    input rst,
    input [31:0] ALU_result,
    input [4:0] rd_index,
    input [31:0] read_data_2,
    input [5:0] inst_index,
    output reg [31:0] ALU_result_out,
    output reg [4:0] rd_index_out,
    output reg [31:0] read_data_2_out,
    output reg [5:0] inst_index_out
);
    reg [31:0] ALU_result_next;
    reg [4:0] rd_index_next;
    reg [31:0] read_data_2_next;
    reg [5:0] inst_index_next;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            ALU_result_out <= 32'b0;
            rd_index_out <= 5'b0;
            read_data_2_out <= 32'b0;
            inst_index_out <= 6'b111111;
        end else begin
            ALU_result_out <= ALU_result_next;
            rd_index_out <= rd_index_next;
            read_data_2_out <= read_data_2_next;
            inst_index_out <= inst_index_next;
        end
    end
    always @(*) begin
        ALU_result_next = ALU_result;
        rd_index_next = rd_index;
        read_data_2_next = read_data_2;
        inst_index_next = inst_index;
    end
endmodule
