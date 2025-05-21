module IF(
    input clk,
    input [31:0] pc,
    output wire [31:0] inst,
    output reg [31:0] pc_out
);
    // determine the inst
    I_mem imem(
        .clka(~clk),
        .wea(1'b0),
        .addra(pc[15:2]),
        .dina(32'b0),
        .douta(inst)
    );

    // determine the pc_out
    always @(posedge clk) begin
        pc_out <= pc;
    end
endmodule
