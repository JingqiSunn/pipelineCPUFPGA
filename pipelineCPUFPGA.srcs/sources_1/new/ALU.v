module ALU(    
    input [5:0] inst_index,
    input [31:0] read_data_1,
    input [31:0] read_data_2,
    input [31:0] imm_data,
    input [4:0] rd_index,
    input [31:0] pc,
    output reg [31:0] ALU_result,
    output reg branch,
    output reg [4:0] rd_index_out,
    output reg [31:0] read_data_2_out,
    output reg [5:0] inst_index_out,
    output reg [31:0] pc_out 
);
    // determine the ALU result based on the inst_index
    always @(*)
    begin
        case(inst_index)
            6'b000000: // ADD
                ALU_result <= read_data_1 + read_data_2;
            6'b000001: // SUB
                ALU_result <= read_data_1 - read_data_2;
            6'b000010: // XOR
                ALU_result <= read_data_1 ^ read_data_2;
            6'b000011: // OR
                ALU_result <= read_data_1 | read_data_2;
            6'b000100: // AND
                ALU_result <= read_data_1 & read_data_2;
            6'b000101: // SLL
                ALU_result <= read_data_1 << read_data_2;
            6'b000110: // SRL
                ALU_result <= read_data_1 >> read_data_2;
            6'b000111: // SRA
                ALU_result <= read_data_1 >>> read_data_2;
            6'b001000: // SLT
                ALU_result <= ($signed(read_data_1) < $signed(read_data_2)) ? 32'b1 : 32'b0;
            6'b001001: // SLTU
                ALU_result <= ($unsigned(read_data_1) < $unsigned(read_data_2)) ? 32'b1 : 32'b0;
            6'b001010: // ADDI
                ALU_result <= read_data_1 + imm_data;
            6'b001011: // XORI
                ALU_result <= read_data_1 ^ imm_data;
            6'b001100: // ORI
                ALU_result <= read_data_1 | imm_data;
            6'b001101: // ANDI
                ALU_result <= read_data_1 & imm_data;
            6'b001110: // SLLI
                ALU_result <= read_data_1 << imm_data[4:0];
            6'b001111: // SRLI
                ALU_result <= read_data_1 >> imm_data[4:0];
            6'b010000: // SRAI
                ALU_result <= read_data_1 >>> imm_data[4:0];
            6'b010001: // SLTI
                ALU_result <= ($signed(read_data_1) < $signed(imm_data)) ? 32'b1 : 32'b0;
            6'b010010: // SLTIU
                ALU_result <= ($unsigned(read_data_1) < $unsigned(imm_data)) ? 32'b1 : 32'b0;
            6'b010011: // LB
                ALU_result <= read_data_1 + imm_data;
            6'b010100: // LH
                ALU_result <= read_data_1 + imm_data;
            6'b010101: // LW
                ALU_result <= read_data_1 + imm_data;
            6'b010110: // LBU
                ALU_result <= read_data_1 + imm_data;
            6'b010111: // LHU
                ALU_result <= read_data_1 + imm_data;
            6'b011000: // SB
                ALU_result <= read_data_1 + imm_data;
            6'b011001: // SH
                ALU_result <= read_data_1 + imm_data;
            6'b011010: // SW
                ALU_result <= read_data_1 + imm_data;
            6'b011011: // BEQ
                ALU_result <= 32'b0;
            6'b011100: // BNE
                ALU_result <= 32'b0;
            6'b011101: // BLT
                ALU_result <= 32'b0;
            6'b011110: // BGE
                ALU_result <= 32'b0;
            6'b011111: // BLTU
                ALU_result <= 32'b0;
            6'b100000: // BGEU
                ALU_result <= 32'b0;
            6'b100001: // JAL
                ALU_result <= pc + 4; 
            6'b100010: // JALR
                ALU_result <= pc + 4;
            6'b100011: // LUI
                ALU_result <= imm_data;
            6'b100100: // AUIPC
                ALU_result <= pc + imm_data;
            default: // NOP
                ALU_result <= 32'b0;
        endcase
    end
    // determine whether to branch or not
    always @(*)
    begin
        case(inst_index)
            6'b011011: // BEQ
                branch <= (read_data_1 == read_data_2) ? 1 : 0;
            6'b011100: // BNE
                branch <= (read_data_1 != read_data_2) ? 1 : 0; 
            6'b011101: // BLT
                branch <= ($signed(read_data_1) < $signed(read_data_2)) ? 1 : 0;
            6'b011110: // BGE
                branch <= ($signed(read_data_1) >= $signed(read_data_2)) ? 1 : 0;
            6'b011111: // BLTU
                branch <= ($unsigned(read_data_1) < $unsigned(read_data_2)) ? 1 : 0;
            6'b100000: // BGEU
                branch <= ($unsigned(read_data_1) >= $unsigned(read_data_2)) ? 1 : 0;
            6'b100001: // JAL
                branch <= 1;
            6'b100010: // JALR
                branch <= 1;
            default: // NOP
                branch <= 0;
        endcase
    end
    // determine the next pc value
    always @(*)
    begin
        case(inst_index)
            6'b011011: // BEQ
                pc_out <= pc + imm_data;
            6'b011100: // BNE
                pc_out <= pc + imm_data;
            6'b011101: // BLT
                pc_out <= pc + imm_data;
            6'b011110: // BGE
                pc_out <= pc + imm_data;
            6'b011111: // BLTU
                pc_out <= pc + imm_data;
            6'b100000: // BGEU
                pc_out <= pc + imm_data;
            6'b100001: // JAL
                pc_out <= pc + imm_data;
            6'b100010: // JALR
                pc_out <= read_data_1 + imm_data;
            6'b100100: // AUIPC
                pc_out <= pc + imm_data;
            default: // NOP
                pc_out <= 32'b0;
        endcase
    end
    // determine the rd_index_out value
    always @(*)
    begin
        rd_index_out <= rd_index;
    end
    // determine the read_data_2_out value
    always @(*)
    begin
        read_data_2_out <= read_data_2;
    end
    // determine the inst_index_out value
    always @(*)
    begin
        inst_index_out <= inst_index;
    end
endmodule
