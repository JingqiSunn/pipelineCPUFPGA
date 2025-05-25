module tool_clock_divider_by_2 (
    input clk_in,
    input reset,
    output reg clk_2_out
);

    always @(posedge clk_in or negedge reset) begin
        if (!reset) begin
            clk_2_out <= 1'b0;
        end else begin
            clk_2_out <= ~clk_2_out;  
        end
    end

endmodule
