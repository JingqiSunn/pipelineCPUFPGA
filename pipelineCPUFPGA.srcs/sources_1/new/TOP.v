module TOP (
    input clk,
    input rst,
    input done,
    input [31:0] data,
    output wire ecall,
    output reg [31:0] x10,
    output reg [31:0] x17,
    output wire K1,
    output wire H6,
    output wire H5,
    output wire J5,
    output wire K6,
    output wire L1,
    output wire M1,
    output wire K3
);
    wire stall;
    wire branch;
    wire [31:0] ALU_pc;
    wire [32*32-1:0] regs;
    wire [31*3-1:0] reg_status;
    wire [31:0] ALU_result;
    wire [31:0] ALU_MEM_result;
    wire [31:0] BEFORE_IF_IF_pc;
    wire [31:0] IF_IF_ID_inst;
    wire [31:0] IF_IF_ID_pc;
    wire [31:0] IF_ID_ID_inst;
    wire [31:0] IF_ID_ID_pc;
    wire [5:0] ID_ID_ALU_inst_index;
    wire [31:0] ID_ID_ALU_read_data_1;
    wire [31:0] ID_ID_ALU_read_data_2;
    wire [31:0] ID_ID_ALU_imm_data;
    wire [4:0] ID_ID_ALU_rd_index;
    wire [31:0] ID_ID_ALU_pc;
    wire [5:0] ID_ALU_ALU_inst_index; 
    wire [31:0] ID_ALU_ALU_read_data_1;
    wire [31:0] ID_ALU_ALU_read_data_2;
    wire [31:0] ID_ALU_ALU_imm_data;
    wire [4:0] ID_ALU_ALU_rd_index;
    wire [31:0] ID_ALU_ALU_pc;
    wire [4:0] ALU_ALU_MEM_rd_index;
    wire [31:0] ALU_ALU_MEM_read_data_2;
    wire [5:0] ALU_ALU_MEM_inst_index;
    wire [31:0] ALU_MEM_MEM_ALU_result;
    wire [4:0] ALU_MEM_MEM_rd_index;
    wire [31:0] ALU_MEM_MEM_read_data_2;
    wire [5:0] ALU_MEM_MEM_inst_index;
    wire [5:0] MEM_MEM_WB_inst_index;
    wire [4:0] MEM_MEM_WB_rd_index;
    wire [5:0] MEM_WB_WB_inst_index;
    wire [31:0] MEM_WB_WB_ALU_MEM_result;
    wire [4:0] MEM_WB_WB_rd_index;
    assign {K1, H6, H5, J5, K6, L1, M1,K3} = BEFORE_IF_IF_pc[9:2];
    
//determine the value of x10
always @(*) begin
    x10 = regs[10*32 +: 32];
end
//determine the value of x17
always @(*) begin   
    x17 = regs[17*32 +: 32];
end

BEFORE_IF before_if_0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch(branch),
    .ALU_pc(ALU_pc),
    //output
    .pc_out(BEFORE_IF_IF_pc)
);
    
IF if_0(
    //input
    .clk(clk),
    .pc(BEFORE_IF_IF_pc),
    //output
    .inst(IF_IF_ID_inst),
    .pc_out(IF_IF_ID_pc)
);
    
IF_ID if_id_0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch(branch),
    .inst(IF_IF_ID_inst),
    .pc(IF_IF_ID_pc),
    //output
    .inst_out(IF_ID_ID_inst),
    .pc_out(IF_ID_ID_pc)
);
    
ID id_0(
    //input
    .clk(clk),
    .rst(rst),
     .done(done),
    .inst(IF_ID_ID_inst),
    .regs(regs),
    .pc(IF_ID_ID_pc),
    .ALU_result(ALU_result),
    .ALU_MEM_result(ALU_MEM_result),
    .data(data),
    //output
    .ecall(ecall),
    .stall(stall),
    .reg_status(reg_status),
    .inst_index(ID_ID_ALU_inst_index),
    .read_data_1(ID_ID_ALU_read_data_1),
    .read_data_2(ID_ID_ALU_read_data_2),
    .imm_data(ID_ID_ALU_imm_data),
    .rd_index(ID_ID_ALU_rd_index),
    .pc_out(ID_ID_ALU_pc)
);
    
ID_ALU id_alu_0(
    //input
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch(branch),
    .inst_index(ID_ID_ALU_inst_index),
    .read_data_1(ID_ID_ALU_read_data_1),
    .read_data_2(ID_ID_ALU_read_data_2),
    .imm_data(ID_ID_ALU_imm_data),
    .rd_index(ID_ID_ALU_rd_index),
    .pc(ID_ID_ALU_pc),
    //output
    .inst_index_out(ID_ALU_ALU_inst_index),
    .read_data_1_out(ID_ALU_ALU_read_data_1),
    .read_data_2_out(ID_ALU_ALU_read_data_2),
    .imm_data_out(ID_ALU_ALU_imm_data),
    .rd_index_out(ID_ALU_ALU_rd_index),
    .pc_out(ID_ALU_ALU_pc)
);
    
ALU alu_0(    
    //input
    .inst_index(ID_ALU_ALU_inst_index),
    .read_data_1(ID_ALU_ALU_read_data_1),
    .read_data_2(ID_ALU_ALU_read_data_2),
    .imm_data(ID_ALU_ALU_imm_data),
    .rd_index(ID_ALU_ALU_rd_index),
    .pc(ID_ALU_ALU_pc),
    //output
    .ALU_result(ALU_result),
    .branch(branch),
    .rd_index_out(ALU_ALU_MEM_rd_index),
    .read_data_2_out(ALU_ALU_MEM_read_data_2),
    .inst_index_out(ALU_ALU_MEM_inst_index),
    .pc_out(ALU_pc)
);
    
ALU_MEM alu_mem_0(
    //input
    .clk(clk),
    .rst(rst),
    .ALU_result(ALU_result),
    .rd_index(ALU_ALU_MEM_rd_index),
    .read_data_2(ALU_ALU_MEM_read_data_2),
    .inst_index(ALU_ALU_MEM_inst_index),
    //output
    .ALU_result_out(ALU_MEM_MEM_ALU_result),
    .rd_index_out(ALU_MEM_MEM_rd_index),
    .read_data_2_out(ALU_MEM_MEM_read_data_2),
    .inst_index_out(ALU_MEM_MEM_inst_index)
);
    
MEM mem(
    //input 
    .clk(clk),
    .ALU_result(ALU_MEM_MEM_ALU_result),
    .rd_index(ALU_MEM_MEM_rd_index),
    .read_data_2(ALU_MEM_MEM_read_data_2),
    .inst_index(ALU_MEM_MEM_inst_index),
    //output
    .inst_index_out(MEM_MEM_WB_inst_index),
    .ALU_MEM_result(ALU_MEM_result),
    .rd_index_out(MEM_MEM_WB_rd_index)
);
    
MEM_WB mem_wb_0(
    //input
    .clk(clk),
    .rst(rst),
    .inst_index(MEM_MEM_WB_inst_index),
    .ALU_MEM_result(ALU_MEM_result),
    .rd_index(MEM_MEM_WB_rd_index),
    //output
    .inst_index_out(MEM_WB_WB_inst_index),
    .ALU_MEM_result_out(MEM_WB_WB_ALU_MEM_result),
    .rd_index_out(MEM_WB_WB_rd_index)
);
    
WB wb_0(
    //input
    .clk(clk),
    .rst(rst),
    .inst_index(MEM_WB_WB_inst_index),
    .ALU_MEM_result(MEM_WB_WB_ALU_MEM_result),
    .rd_index(MEM_WB_WB_rd_index),
    //output
    .regs_next(regs)
);
endmodule
