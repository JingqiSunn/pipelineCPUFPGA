module MEM_WB(
    input clk,
    input rst,
    input [5:0] inst_index,
    input [31:0] ALU_MEM_result,
    input [4:0] rd_index,
    output reg [5:0] inst_index_out,
    output reg [31:0] ALU_MEM_result_out,
    output reg [4:0] rd_index_out
);
    reg [5:0] inst_index_next;
    reg [31:0] ALU_MEM_result_next;
    reg [4:0] rd_index_next;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            inst_index_out <= 6'b111111;
            ALU_MEM_result_out <= 32'b0;
            rd_index_out <= 5'b0;
        end else begin
            inst_index_out <= inst_index_next;
            ALU_MEM_result_out <= ALU_MEM_result_next;
            rd_index_out <= rd_index_next;
        end
    end
    always @(*) begin
        inst_index_next = inst_index;
        ALU_MEM_result_next = ALU_MEM_result;
        rd_index_next = rd_index;
    end
endmodule
