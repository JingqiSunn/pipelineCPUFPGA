 module WB(
    input clk, 
    input rst,
    input [5:0] inst_index,
    input [31:0] ALU_MEM_result,
    input [4:0] rd_index,
    output reg [32*32-1:0] regs_next
);
    // save the result to the register file
    reg [32*32-1:0] regs;
    always @(posedge clk, negedge rst) 
        begin
            if (~rst) begin 
                regs <= 0;
            end else begin
                regs <=regs_next;
            end
        end
    always @(*) begin 
        regs_next = regs;
        if (rd_index != 5'b0) begin
            case (inst_index)
                6'b000000: // ADD
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000001: // SUB
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000010: // XOR
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000011: // OR
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000100: // AND
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000101: // SLL
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000110: // SRL
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b000111: // SRA
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001000: // SLT
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001001: // SLTU
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001010: // ADDI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001011: // XORI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001100: // ORI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001101: // ANDI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001110: // SLLI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b001111: // SRLI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010000: // SRAI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010001: // SLTI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010010: // SLTIU
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010011: // LB
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010100: // LH
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010101: // LW
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010110: // LBU
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b010111: // LHU
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b100001: // JAL
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b100010: // JALR
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b100011: // LUI
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
                6'b100100: // AUIPC
                begin
                    regs_next[rd_index*32 +: 32] = ALU_MEM_result;
                end
            endcase 
        end
    end
endmodule
