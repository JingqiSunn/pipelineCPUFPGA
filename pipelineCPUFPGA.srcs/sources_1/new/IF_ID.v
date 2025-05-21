module IF_ID(
    input rst,
    input clk,
    input stall,
    input branch,
    input [31:0] inst,
    input [31:0] pc,
    output reg [31:0] inst_out,
    output reg [31:0] pc_out
);  
    reg [31:0] next_inst;
    reg [31:0] next_pc;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            inst_out <= 32'b0;
            pc_out <= 32'b0;
        end else if (stall) begin
            inst_out <=  inst_out;
            pc_out <= pc_out;
        end else if (branch) begin
            inst_out <= 32'b0;
            pc_out <= 32'b0;
        end else begin
            inst_out <= next_inst;
            pc_out <= next_pc;
        end  
    end
    always @(*) begin
        next_inst = inst;
        next_pc = pc;
    end
endmodule
