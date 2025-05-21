module Clock_Creator_50hz(
    input clk_in,
    input reset,
    output reg standard_clock
    );
    reg [25:0] accumulator;
    initial 
        begin
            standard_clock = 1;
        end
    always @(posedge clk_in, negedge reset)
        begin
            if (~reset)
                begin
                    standard_clock <= 1;
                    accumulator <= 26'b00000000000000000000000000;
                end
            else 
                begin
                    accumulator <= accumulator + 1;
                    if (accumulator == 1)
                        begin
                            accumulator <= 26'b00000000000000000000000000;
                            standard_clock <= ~standard_clock;
                        end     
                end
        end
endmodule