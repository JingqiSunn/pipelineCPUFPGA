module Tool_clock_divider(
    input clk_in,            
    input reset,          
    output reg clk_10_out, 
    output reg clk_4_out   
);
    // Counter registers
    reg [3:0] counter_10;  // Counter for 10-division
    reg [3:0] counter_4;   // Counter for 4-division
    

    parameter DIV_4 = (4'd4 / 2 - 4'd1);   
    parameter DIV_10 = (4'd10 / 2 - 4'd1); 
    
    // 4-division logic
    always @(posedge clk_in or negedge reset) begin
        if (!reset) begin  
            counter_4 <= 4'd0;
            clk_4_out <= 1'd0;
        end
        else begin
            if (counter_4 == DIV_4) begin  
                counter_4 <= 4'd0;
                clk_4_out <= ~clk_4_out;    
            end
            else begin
                counter_4 <= counter_4 + 4'd1;
            end
        end
    end
    
    // 10-division logic
    always @(posedge clk_in or negedge reset) begin
        if (!reset) begin  
            counter_10 <= 4'd0;
            clk_10_out <= 1'd0;
        end
        else begin
            if (counter_10 == DIV_10) begin  
                counter_10 <= 4'd0;
                clk_10_out <= ~clk_10_out; 
            end
            else begin
                counter_10 <= counter_10 + 4'd1;
            end
        end
    end
endmodule