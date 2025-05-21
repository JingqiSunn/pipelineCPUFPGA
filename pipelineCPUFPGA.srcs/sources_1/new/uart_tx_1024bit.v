module uart_tx_1024bit (
    input wire clk_100,
    input wire rst_n,
    input wire [1023:0] data_block,
    output reg tx
);
    wire clk_50;

    // Instantiate the 50 Hz clock generator
    Clock_Creator_50hz Clock_Creator_50hz_1 (
        .clk_in(clk_100),
        .reset(rst_n),
        .standard_clock(clk_50)
    );

    // Baud rate parameters (unchanged)
    wire [27:0] counter_standard = 2604;
    wire [12:0] rest_counter_standard = 2;

    // State machine states
    localparam IDLE = 2'b00,
               SEND_START = 2'b01,
               SEND_DATA = 2'b10,
               SEND_END = 2'b11;

    // Marker bytes
    localparam [7:0] START_BYTE = 8'hAA;
    localparam [7:0] END_BYTE = 8'h55;

    // Registers
    reg tx_next;
    reg just_next;
    reg [27:0] counter, counter_next;
    reg whether_read_data_pack, whether_read_data_pack_next;
    reg [27:0] location_in_data_pack, location_in_data_pack_next;
    reg [12:0] rest_counter, rest_counter_next;
    reg [1:0] state, state_next;
    reg [6:0] byte_index, byte_index_next; // 0 to 127 for 128 bytes
    reg [9:0] data_pack; // 1 start bit, 8 data bits, 1 stop bit

    // Synchronous reset and state update logic
    always @(posedge clk_50, negedge rst_n)
        if (~rst_n) begin
            tx <= 1;
            counter <= 0;
            whether_read_data_pack <= 0;
            location_in_data_pack <= 0;
            rest_counter <= 0;
            state <= IDLE;
            byte_index <= 0;
        end else begin
            tx <= tx_next;
            counter <= counter_next;
            whether_read_data_pack <= whether_read_data_pack_next;
            location_in_data_pack <= location_in_data_pack_next;
            rest_counter <= rest_counter_next;
            state <= state_next;
            byte_index <= byte_index_next;
        end

    // Counter logic to create baud rate timing (unchanged)
    always @(posedge clk_100)
        begin
            if (counter != counter_next)
                begin
                    counter_next <= counter_next;
                    just_next <= just_next;
                end
            else 
                begin
                    if (counter == counter_standard)
                        begin
                            counter_next <= 0;
                            just_next <= 1;
                        end
                    else 
                        begin
                            counter_next <= counter + 1;
                            just_next <= 0;
                        end
                end
        end

    // State machine and data handling
    always @(just_next, state, byte_index, whether_read_data_pack, location_in_data_pack) begin
        // Default assignments
        state_next = state;
        byte_index_next = byte_index;
        whether_read_data_pack_next = whether_read_data_pack;
        location_in_data_pack_next = location_in_data_pack;
        rest_counter_next = rest_counter;
        data_pack = 10'b0;

        if (just_next == 1) begin
            case (state)
                IDLE: begin
                    whether_read_data_pack_next = 0;
                    location_in_data_pack_next = 0;
                    rest_counter_next = rest_counter + 1;
                    if (rest_counter == rest_counter_standard) begin
                        state_next = SEND_START;
                        rest_counter_next = 0;
                        whether_read_data_pack_next = 1;
                    end
                end
                SEND_START: begin
                    data_pack = {1'b1, START_BYTE, 1'b0}; // Start bit, start byte, stop bit
                    if (whether_read_data_pack == 1) begin
                        if (location_in_data_pack == 9) begin
                            location_in_data_pack_next = 0;
                            whether_read_data_pack_next = 0;
                            rest_counter_next = 1;
                            state_next = SEND_DATA;
                            byte_index_next = 0;
                        end else begin
                            location_in_data_pack_next = location_in_data_pack + 1;
                            whether_read_data_pack_next = 1;
                            rest_counter_next = 0;
                        end
                    end else if (rest_counter == rest_counter_standard) begin
                        location_in_data_pack_next = 0;
                        whether_read_data_pack_next = 1;
                        rest_counter_next = 0;
                    end else begin
                        rest_counter_next = rest_counter + 1;
                    end
                end
                SEND_DATA: begin
                    // Select 8-bit chunk from data_block
                    data_pack = {1'b1, data_block[(127 - byte_index)*8 +: 8], 1'b0};
                    if (whether_read_data_pack == 1) begin
                        if (location_in_data_pack == 9) begin
                            location_in_data_pack_next = 0;
                            whether_read_data_pack_next = 0;
                            rest_counter_next = 1;
                            if (byte_index == 127) begin
                                state_next = SEND_END;
                            end else begin
                                byte_index_next = byte_index + 1;
                            end
                        end else begin
                            location_in_data_pack_next = location_in_data_pack + 1;
                            whether_read_data_pack_next = 1;
                            rest_counter_next = 0;
                        end
                    end else if (rest_counter == rest_counter_standard) begin
                        location_in_data_pack_next = 0;
                        whether_read_data_pack_next = 1;
                        rest_counter_next = 0;
                    end else begin
                        rest_counter_next = rest_counter + 1;
                    end
                end
                SEND_END: begin
                    data_pack = {1'b1, END_BYTE, 1'b0}; // Start bit, end byte, stop bit
                    if (whether_read_data_pack == 1) begin
                        if (location_in_data_pack == 9) begin
                            location_in_data_pack_next = 0;
                            whether_read_data_pack_next = 0;
                            rest_counter_next = 1;
                            state_next = IDLE; // Loop back to IDLE for continuous transmission
                        end else begin
                            location_in_data_pack_next = location_in_data_pack + 1;
                            whether_read_data_pack_next = 1;
                            rest_counter_next = 0;
                        end
                    end else if (rest_counter == rest_counter_standard) begin
                        location_in_data_pack_next = 0;
                        whether_read_data_pack_next = 1;
                        rest_counter_next = 0;
                    end else begin
                        rest_counter_next = rest_counter + 1;
                    end
                end
            endcase
        end
    end

    // Drive tx signal
    always @(whether_read_data_pack, location_in_data_pack, data_pack)
        if (whether_read_data_pack == 1)
            tx_next = data_pack[location_in_data_pack];
        else
            tx_next = 1;

endmodule
