module BEFORE_IF(
    input clk,
    input rst,
    input stall,
    input branch,
    input [31:0] ALU_pc,
    output reg [31:0] pc_out
);
    // determine the next PC
    reg[31:0] pc_next;
    always @(posedge clk, negedge rst) begin
        if (~rst) begin
            pc_out = 32'b0;
        end
        else begin 
            if (stall) begin
                pc_out = pc_out;
            end
            else if (branch) begin
                pc_out = ALU_pc;
            end
            else begin
                pc_out = pc_next;
            end
        end 
    end
    always @(*) begin
        pc_next = pc_out + 4;
    end 
endmodule
