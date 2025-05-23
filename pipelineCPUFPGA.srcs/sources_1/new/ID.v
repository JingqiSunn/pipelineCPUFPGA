module ID(
    input wire clk,
    input wire rst,
    input wire branch,
    input wire done,
    input wire [31:0] inst,
    input wire [32*32-1:0] regs,
    input wire [31:0] pc,
    input wire [31:0] ALU_result,
    input wire [31:0] ALU_MEM_result,
    input wire [31:0] data,
    output reg stall,
    output reg ecall,
    output reg [31*3-1:0] reg_status,
    output reg [5:0] inst_index,
    output reg [31:0] read_data_1,
    output reg [31:0] read_data_2,
    output reg [31:0] imm_data,
    output reg [4:0] rd_index,
    output reg [31:0] pc_out
);
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [4:0] rd = inst[11:7];
    wire [16:0] opcode_funct7_funct3 = {opcode, funct7, funct3};
    wire [2:0] x_17_reg_status = reg_status[16*3 +: 3];
    wire [31:0] x_17_reg_data = regs[17*32 +: 32];
    reg [31*3-1:0] reg_status_next;

    // Control the ecall signal
    always @(*) begin
        case (opcode_funct7_funct3)
            17'b1110011_0000000_000: begin // ECALL
                ecall <= 1'b1;
            end
            default: begin
                ecall <= 1'b0;
            end
        endcase
    end

    // Control the stalls
    always @(*) 
    begin
        if ((rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) || (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b101)) begin
            stall = 1'b1;
        end else if (ecall == 1'b1 && done == 1'b0) begin
            stall = 1'b1;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000001 && x_17_reg_status == 3'b101)begin 
            stall = 1'b1;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000006 && x_17_reg_status == 3'b101)begin 
            stall = 1'b1;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000002 && x_17_reg_status == 3'b101)begin 
            stall = 1'b1;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000007 && x_17_reg_status == 3'b101)begin 
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

    // Control the reg_status
    always @(posedge clk, negedge rst) begin
        if (~rst) begin
            reg_status <= 93'b0;
        end else begin
            reg_status <= reg_status_next;
        end
    end

    // Control the reg_status_next
    // 000 means there is no data hazard
    // 001 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_result
    // 010 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_MEM_result
    // 101 means the data hazard is caused by L type, which is not currently replaceable, so we need to stall here
    // 110 means the data hazard is caused by L type, which can be replaced by ALU_MEM_result
    integer i;
    always @(*) begin
        reg_status_next = reg_status;
        for (i = 1; i <= 31; i = i + 1) begin
            if (reg_status[(i-1)*3 +: 3] == 3'b001)
                reg_status_next[(i-1)*3 +: 3] = 3'b010;
            else if (reg_status[(i-1)*3 +: 3] == 3'b010)
                reg_status_next[(i-1)*3 +: 3] = 3'b000;
            else if (reg_status[(i-1)*3 +: 3] == 3'b101)
                reg_status_next[(i-1)*3 +: 3] = 3'b110;
            else if (reg_status[(i-1)*3 +: 3] == 3'b110)
                reg_status_next[(i-1)*3 +: 3] = 3'b000;
        end
        casez(opcode_funct7_funct3)
            17'b0110011_???????_???: begin // R-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
            17'b0010011_???????_???: begin // I-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
            17'b0000011_???????_???: begin // I-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b101;
                end
            end  
            17'b1100111_???????_???: begin // I-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
            17'b0110111_???????_???: begin // U-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
            17'b0010111_???????_???: begin // U-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
            17'b1101111_???????_???: begin // J-type
                if (rd != 5'b0 && stall == 1'b0 && branch == 1'b0) begin
                    reg_status_next[((rd-1)*3) +: 3] = 3'b001;
                end
            end
        endcase 
        if (ecall == 1'b1 && stall == 1'b0 && x_17_reg_data == 32'h00000001 && branch == 1'b0) begin
            reg_status_next[9*3 +: 3] = 3'b001;
        end else if (ecall == 1'b1 && stall == 1'b0 && x_17_reg_data == 32'h00000002 && branch == 1'b0) begin
            reg_status_next[9*3 +: 3] = 3'b001;
        end else if (ecall == 1'b1 && stall == 1'b0 && x_17_reg_data == 32'h00000006 && branch == 1'b0) begin
            reg_status_next[9*3 +: 3] = 3'b001;
        end else if (ecall == 1'b1 && stall == 1'b0 && x_17_reg_data == 32'h00000007 && branch == 1'b0) begin
            reg_status_next[9*3 +: 3] = 3'b001;
        end 
    end
    // Control the control_* signals
    always @(*) begin
        casez(opcode_funct7_funct3)
            17'b0110011_0000000_000: begin // ADD
                inst_index <= 6'b000000;
            end
            17'b0110011_0100000_000: begin // SUB
                inst_index <= 6'b000001;
            end
            17'b0110011_0000000_100: begin // XOR
                inst_index <= 6'b000010;
            end
            17'b0110011_0000000_110: begin // OR
                inst_index <= 6'b000011;
            end
            17'b0110011_0000000_111: begin // AND
                inst_index <= 6'b000100;
            end
            17'b0110011_0000000_001: begin // SLL
                inst_index <= 6'b000101;
            end
            17'b0110011_0000000_101: begin // SRL
                inst_index <= 6'b000110;
            end
            17'b0110011_0100000_101: begin // SRA
                inst_index <= 6'b000111;
            end
            17'b0110011_0000000_010: begin // SLT
                inst_index <= 6'b001000;
            end
            17'b0110011_0000000_011: begin // SLTU
                inst_index <= 6'b001001;
            end
            17'b0010011_???????_000: begin // ADDI
                inst_index <= 6'b001010;
            end
            17'b0010011_???????_100: begin // XORI
                inst_index <= 6'b001011;
            end
            17'b0010011_???????_110: begin // ORI
                inst_index <= 6'b001100;
            end
            17'b0010011_???????_111: begin // ANDI
                inst_index <= 6'b001101;
            end
            17'b0010011_0000000_001: begin // SLLI
                inst_index <= 6'b001110;
            end
            17'b0010011_0000000_101: begin // SRLI
                inst_index <= 6'b001111;
            end
            17'b0010011_0100000_101: begin // SRAI
                inst_index <= 6'b010000;
            end
            17'b0010011_???????_010: begin // SLTI
                inst_index <= 6'b010001;
            end
            17'b0010011_???????_011: begin // SLTIU
                inst_index <= 6'b010010;
            end
            17'b0000011_???????_000: begin // LB
                inst_index <= 6'b010011;
            end
            17'b0000011_???????_001: begin // LH
                inst_index <= 6'b010100;
            end
            17'b0000011_???????_010: begin // LW
                inst_index <= 6'b010101;
            end
            17'b0000011_???????_100: begin // LBU
                inst_index <= 6'b010110;
            end
            17'b0000011_???????_101: begin // LHU
                inst_index <= 6'b010111;
            end
            17'b0100011_???????_000: begin // SB
                inst_index <= 6'b011000;
            end
            17'b0100011_???????_001: begin // SH
                inst_index <= 6'b011001;
            end
            17'b0100011_???????_010: begin // SW
                inst_index <= 6'b011010;
            end
            17'b1100011_???????_000: begin // BEQ
                inst_index <= 6'b011011;
            end
            17'b1100011_???????_001: begin // BNE
                inst_index <= 6'b011100;
            end
            17'b1100011_???????_100: begin // BLT
                inst_index <= 6'b011101;
            end
            17'b1100011_???????_101: begin // BGE
                inst_index <= 6'b011110;
            end
            17'b1100011_???????_110: begin // BLTU
                inst_index <= 6'b011111;
            end
            17'b1100011_???????_111: begin // BGEU
                inst_index <= 6'b100000;
            end
            17'b1101111_???????_???: begin // JAL
                inst_index <= 6'b100001;
            end
            17'b1100111_???????_000: begin // JALR
                inst_index <= 6'b100010;
            end
            17'b0110111_???????_???: begin // LUI
                inst_index <= 6'b100011;
            end
            17'b0010111_???????_???: begin // AUIPC
                inst_index <= 6'b100100;
            end
            default: begin // Default case
                inst_index <= 6'b111111;
            end
        endcase
        if (ecall == 1'b1 && x_17_reg_data == 32'h00000001) begin
            inst_index <= 6'b000000;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000002) begin
            inst_index <= 6'b000000;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000006) begin
            inst_index <= 6'b000000;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000007) begin
            inst_index <= 6'b000000;
        end 
    end
    // determine the read data 1
    // 000 means there is no data hazard
    // 001 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_result
    // 010 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_MEM_result
    // 101 means the data hazard is caused by L type, which is not currently replaceable, so we need to stall here
    // 110 means the data hazard is caused by L type, which can be replaced by ALU_MEM_result
    always @(*) begin
        case(opcode)
            7'b0110011: begin // R-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            7'b0010011: begin // I-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            7'b0000011: begin // I-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            7'b1100111: begin // I-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            7'b0100011: begin // S-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            7'b1100011: begin // B-type
                if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b001) begin
                    read_data_1 = ALU_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b010) begin
                    read_data_1 = ALU_MEM_result;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b101) begin
                    read_data_1 = 32'b0;
                end else if (rs1 != 5'b0 && reg_status[(rs1-1)*3 +: 3] == 3'b110) begin
                    read_data_1 = ALU_MEM_result;
                end else begin
                    read_data_1 = regs[rs1*32 +: 32];
                end
            end
            default: begin // Default case
                read_data_1 = 32'b0;
            end
        endcase
        if (ecall == 1'b1 && x_17_reg_data == 32'h00000001) begin
            read_data_1 = data; 
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000002) begin
            read_data_1 = data; 
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000006) begin
            read_data_1 = data; 
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000007) begin
            read_data_1 = data; 
        end
    end

    // determine the read data 1
    // 000 means there is no data hazard
    // 001 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_result
    // 010 means the data hazard is caused by R, I, J, U type, which can be replaced by ALU_MEM_result
    // 101 means the data hazard is caused by L type, which is not currently replaceable, so we need to stall here
    // 110 means the data hazard is caused by L type, which can be replaced by ALU_MEM_result
    always @(*) begin
        case(opcode)
            7'b0110011: begin //R-type
                if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b001) begin
                    read_data_2 <= ALU_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b010) begin
                    read_data_2 <= ALU_MEM_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b101) begin
                    read_data_2 <= 32'b0;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b110) begin
                    read_data_2 <= ALU_MEM_result;
                end else begin
                    read_data_2 <= regs[rs2*32 +: 32];
                end
            end
            7'b0100011: begin // S-type
                if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b001) begin
                    read_data_2 <= ALU_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b010) begin
                    read_data_2 <= ALU_MEM_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b101) begin
                    read_data_2 <= 32'b0;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b110) begin
                    read_data_2 <= ALU_MEM_result;
                end else begin
                    read_data_2 <= regs[rs2*32 +: 32];
                end
            end
            7'b1100011: begin // B-type
                if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b001) begin
                    read_data_2 <= ALU_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b010) begin
                    read_data_2 <= ALU_MEM_result;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b101) begin
                    read_data_2 <= 32'b0;
                end else if (rs2 != 5'b0 && reg_status[(rs2-1)*3 +: 3] == 3'b110) begin
                    read_data_2 <= ALU_MEM_result;
                end else begin
                    read_data_2 <= regs[rs2*32 +: 32];
                end
            end
            default: begin // Default case
                read_data_2 <= 32'b0;
            end
        endcase
    end

    // Read immediate data
    always @(*) begin
        casez(opcode_funct7_funct3)
            17'b0110011_???????_???: begin // R-type
                imm_data <= 32'b0;
            end
            17'b0010011_???????_000: begin // ADDI
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0010011_???????_100: begin // XORI
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0010011_???????_110: begin // ORI
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0010011_???????_111: begin // ANDI
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0010011_0000000_001: begin // SLLI
                imm_data <= {{27{inst[24]}}, inst[24:20]};
            end
            17'b0010011_0000000_101: begin // SRLI
                imm_data <= {{27{inst[24]}}, inst[24:20]};
            end
            17'b0010011_0100000_101: begin // SRAI
                imm_data <= {{27{inst[24]}}, inst[24:20]};
            end
            17'b0010011_???????_010: begin // SLTI
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0010011_???????_011: begin // SLTIU
                imm_data <= {{20{1'b0}}, inst[31:20]};
            end
            17'b0000011_???????_000: begin // LB
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0000011_???????_001: begin // LH
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0000011_???????_010: begin // LW
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0000011_???????_100: begin // LBU
                imm_data <= {{20{1'b0}}, inst[31:20]};
            end
            17'b0000011_???????_101: begin // LHU
                imm_data <= {{20{1'b0}}, inst[31:20]};
            end
            17'b0100011_???????_???: begin // S-type
                imm_data <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            17'b1100011_???????_000: begin // BEQ
                imm_data <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1100011_???????_001: begin // BNE
                imm_data <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1100011_???????_100: begin // BLT
                imm_data <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1100011_???????_101: begin // BGE
                imm_data <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1100011_???????_110: begin // BLTU
                imm_data <= {{19{1'b0}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1100011_???????_111: begin // BGEU
                imm_data <= {{19{1'b0}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            17'b1101111_???????_???: begin // JAL
                imm_data <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            17'b1100111_???????_000: begin // JALR
                imm_data <= {{20{inst[31]}}, inst[31:20]};
            end
            17'b0110111_???????_???: begin // LUI
                imm_data <= {inst[31:12], 12'b0};
            end
            17'b0010111_???????_???: begin // AUIPC
                imm_data <= {inst[31:12], 12'b0};
            end
            default:
                imm_data <= 32'b0;
        endcase
    end
    // Read rd_index
    always @(*) begin
        casez(opcode_funct7_funct3)
            17'b0110011_???????_???: begin // R-type
                rd_index = rd;
            end
            17'b0010011_???????_???: begin // I-type
                rd_index = rd;
            end
            17'b0000011_???????_???: begin // I-type
                rd_index = rd;
            end
            17'b1100111_???????_???: begin // I-type
                rd_index = rd;
            end
            17'b0100011_???????_???: begin // S-type
                rd_index = 5'b0;
            end
            17'b1100011_???????_???: begin // B-type
                rd_index = 5'b0;
            end
            17'b1101111_???????_???: begin // J-type
                rd_index = rd;
            end
            17'b0110111_???????_???: begin // U-type
                rd_index = rd;
            end
            17'b0010111_???????_???: begin // U-type
                rd_index = rd;
            end
        endcase
        if (ecall == 1'b1 && x_17_reg_data == 32'h00000001) begin
            rd_index = 5'b01010;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000002) begin
            rd_index = 5'b01010;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000006) begin
            rd_index = 5'b01010;
        end else if (ecall == 1'b1 && x_17_reg_data == 32'h00000007) begin
            rd_index = 5'b01010;
        end
    end
    // Read pc_out
    always @(*) begin
        pc_out = pc;
    end
endmodule
