module MEM(
    input clk,
    input [31:0] ALU_result,
    input [4:0] rd_index,
    input [31:0] read_data_2,
    input [5:0] inst_index,
    output reg [5:0] inst_index_out,
    output reg [31:0] ALU_MEM_result,
    output reg [4:0] rd_index_out
);
    reg [3:0] byte_writable;
    // determine the byte_writable
    always @(*)
    begin
        case(inst_index)
            6'b011000: // SB
            begin
                byte_writable = 4'b0001;
            end
            6'b011001: // SH
            begin
                byte_writable = 4'b0011;
            end
            6'b011010: // SW
            begin
                byte_writable = 4'b1111;
            end
            default: // default
            begin
                byte_writable = 4'b0000;
            end
        endcase
    end 

    wire [31:0] MEM_result;
    // determine the MEM_result
    D_mem dmem(
        .clka(~clk),
        .wea(byte_writable),
        .addra(ALU_result[15:2]),
        .dina(read_data_2),
        .douta(MEM_result)
    );

    // determine the ALU_MEM_result
    always @(*)  
    begin
        case(inst_index)
            6'b010011: // LB             
            begin
                ALU_MEM_result = {{24{MEM_result[7]}}, MEM_result[7:0]};
            end
            6'b010100: // LH
            begin
                ALU_MEM_result = {{16{MEM_result[15]}}, MEM_result[15:0]};
            end
            6'b010101: // LW
            begin
                ALU_MEM_result = MEM_result;
            end
            6'b010110: // LBU
            begin
                ALU_MEM_result = {24'b0, MEM_result[7:0]};
            end
            6'b010111: // LHU
            begin
                ALU_MEM_result = {16'b0, MEM_result[15:0]};
            end
            default: // default
            begin
                ALU_MEM_result = ALU_result;
            end
        endcase
    end
    
    // determine the rd_index_out
    always @(*)
    begin
        rd_index_out = rd_index;
    end

    // determine the inst_index_out
    always @(*)
    begin
        inst_index_out = inst_index;
    end
endmodule
