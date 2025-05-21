module debounce(
input clk,
input rst,        
input run_stop,     // Control whether the module is running (1'b1 is running)
input key_in,       // Input key signal
output reg key_out  // Output key signal
);
reg key_reg1, key_reg2; 
reg [20:0] delay_cnt;   
parameter DELAY_TIME = 21'd600_000; 


always @(posedge clk or negedge rst) begin
   if (!run_stop || ~rst) begin
       key_reg1 <= 1'b0;
       key_reg2 <= 1'b0;
   end else begin
       key_reg1 <= key_in;
       key_reg2 <= key_reg1;
   end
end


always @(posedge clk or negedge rst) begin
   if (!run_stop || ~rst) begin
       delay_cnt <= 21'b0;
   end else if (key_reg1 != key_reg2) begin 
       delay_cnt <= DELAY_TIME;
   end else if (delay_cnt > 0) begin
       delay_cnt <= delay_cnt - 1'b1;
   end
end


always @(posedge clk or negedge rst) begin
   if (!run_stop || ~rst) begin
       key_out <= 1'b0;
   end else if (delay_cnt == 0 && key_reg2 == 1'b1) begin
       key_out <= 1'b1; 
   end else if (key_reg2 == 1'b0) begin
       key_out <= 1'b0; 
   end
end
endmodule