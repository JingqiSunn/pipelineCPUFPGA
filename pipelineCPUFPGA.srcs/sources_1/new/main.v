module main(
    input clk,
    input rst,
    // button
    input R15,
    // left switches
    input P5,
    input P4,
    input P3,
    input P2,
    input R2,
    input M4,
    input N4,
    input R1,
    // right switches
    input R3,
    input T3,
    input T5,
    //left LEDs
    output wire F6, 
    output wire G4,
    output wire G3,
    output wire J4,
    output wire H4,
    output wire J3,
    output wire J2,
    output wire K2,
    //output tube
    output wire B4,
    output wire A4,
    output wire A3,
    output wire B1,
    output wire A1,
    output wire B3,
    output wire B2,
    output wire D5,
    output wire D4,
    output wire E3,
    output wire D3,
    output wire F4,
    output wire F3,
    output wire E2,
    output wire D2,
    output wire H2,
    output wire G2,
    output wire C2,
    output wire C1,
    output wire H1,
    output wire G1,
    output wire F1,
    output wire E1,
    output wire G6,
    // examine LED
    output wire K1,
    output wire H6,
    output wire H5,
    output wire J5,
    output wire K6,
    output wire L1,
    output wire M1,
    output wire K3
    );
    // determine the cpu clock
    wire cpu_clk_40;
    wire cpu_clk_100;
    Tool_clock_divider clk_divider(
        .clk_in(clk),
        .reset(rst),
        .clk_10_out(cpu_clk_100),
        .clk_4_out(cpu_clk_40)
    ); 
    // debounce the button
    wire R15_debounced;
    debounce debounce_R15(
        .clk(clk),
        .rst(rst),
        .run_stop(1'b1),
        .key_in(R15),
        .key_out(R15_debounced)
    );

    // determine the confirm signal
    wire confirm;
    bonetime bonetime_R15(
        //.clk(cpu_clk_40),
        .clk(clk),
        .x_in(R15_debounced),
        .x_pos(confirm)
    );

    // instantiate the IM module
    wire ecall;
    wire [7:0] switch_left;
    wire [2:0] switch_right;
    wire [31:0] x10;
    wire [31:0] x17;
    wire done;
    wire [31:0] data;
    assign switch_left = {P5, P4, P3, P2, R2, M4, N4, R1};
    assign switch_right = {R3, T3, T5};
    IM im(
        //.clk(cpu_clk_40),
        .clk(clk),
        .clk_original(clk),
        .rst(rst),
        .ecall(ecall),
        .switch_left(switch_left),
        .switch_right(switch_right),
        .confirm(confirm),
        .x10(x10),
        .x17(x17),
        .done(done),
        .data(data),
        // output LED,
        .F6(F6),
        .G4(G4),
        .G3(G3),
        .J4(J4),
        .H4(H4),
        .J3(J3),
        .J2(J2),
        .K2(K2),
        //output tube
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
        .G6(G6)
    );

    // instantiate the TOP module
    TOP top(
        //.clk(cpu_clk_40),
        .clk(clk),
        .rst(rst),
        .done(done),
        .data(data),
        .ecall(ecall),
        .x10(x10),
        .x17(x17),
        .K1(K1),
        .H6(H6),
        .H5(H5),
        .J5(J5),
        .K6(K6),
        .L1(L1),
        .M1(M1),
        .K3(K3)
    );
endmodule