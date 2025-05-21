module TOP_tb(

    );
    
    
    
     // Inputs
           reg clkin;
           reg rst;
           reg R15;
           
           
           
 main top1_inst (
    .clk(clkin),  // Clock input
    .rst(rst),      // Reset input
    .R15(R15),
    .P5(P5),
    .P4(P4),
    .P3(P3),
    .P2(P2),
    .R2(R2),
    .M4(M4),
    .N4(N4),
    .R1(R1),
    // Left LEDs
    .F6(F6),
    .G4(G4),
    .G3(G3),
    .J4(J4),
    .H4(H4),
    .J3(J3),
    .J2(J2),
    .K2(K2),
    // Tube outputs
    .B4(B4),
    .A4(A4),
    .A3(A3),
    .B1(B1),
    .A1(A1),
    .B3(B3),
    .B2(B2),
    .D5(D5),
    .D4(D4),
    .E3(E3),
    .D3(D3),
    .F4(F4),
    .F3(F3),
    .E2(E2),
    .D2(D2),
    .H2(H2),
    .G2(G2),
    .C2(C2),
    .C1(C1),
    .H1(H1),
    .G1(G1),
    .F1(F1),
    .E1(E1),
    .G6(G6),
    // Examine LED
    .K1(K1)
);
    
    
         initial begin
                    clkin = 0;
                    forever #6 clkin = ~clkin;
                end
          initial begin
                    R15 = 0;
                    forever #40000 R15 = ~R15;
                end
        initial begin
            // Initialize inputs
            rst = 1;
           
            
            // Apply reset
            #10;
            rst = 0;
            #10;
            rst = 1;
            
            
            ////////////////////
        
        
        
       
       
        end
endmodule 