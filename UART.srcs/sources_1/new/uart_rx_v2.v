`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:28:33 AM
// Design Name: 
// Module Name: uart_tx_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx_v2(
    input        clk,
    input        Baud16Tick,
    input        rxd,
    output reg [7:0] data = 0,
    output reg       ready = 0
);

    //----------------------------------------
    // 1. Synchronize RXD into clock domain
    //----------------------------------------
    reg [1:0] rxd_sync;
    always @(posedge clk)
        if (Baud16Tick)
            rxd_sync <= {rxd_sync[0], rxd};

    //----------------------------------------
    // 2. Simple noise filter (3-bit majority)
    //----------------------------------------
    reg [2:0] filter = 3'b111;
    reg       rxd_filt = 1;

    always @(posedge clk)
        if (Baud16Tick) begin
            if (rxd_sync[1] && filter != 3'b111)
                filter <= filter + 1;
            else if (!rxd_sync[1] && filter != 3'b000)
                filter <= filter - 1;

            if (filter == 3'b000) rxd_filt <= 0;
            else if (filter == 3'b111) rxd_filt <= 1;
        end

    //----------------------------------------
    // 3. Oversampling bit counter (0..15)
    //----------------------------------------
    reg [3:0] os_count = 0;
    wire sample = (os_count == 8);

    always @(posedge clk)
        if (Baud16Tick) begin
            if (state == IDLE)
                os_count <= 0;
            else
                os_count <= os_count + 1;
        end

    //----------------------------------------
    // 4. State machine
    //----------------------------------------
    localparam IDLE = 4'b0000,
               START = 4'b0001,
               BIT0 = 4'b0010,
               BIT1 = 4'b0011,
               BIT2 = 4'b0100,
               BIT3 = 4'b0101,
               BIT4 = 4'b0110,
               BIT5 = 4'b0111,
               BIT6 = 4'b1000,
               BIT7 = 4'b1001,
               STOP = 4'b1010;

    reg [3:0] state = IDLE;

    always @(posedge clk) begin
        ready <= 0;  // default

        if (Baud16Tick) begin
            case (state)

                IDLE:  begin
                    if (rxd_filt == 0)  // falling edge: start bit begin
                        state <= START;
                end

                START: if (sample) begin
                    if (rxd_filt == 0)
                        state <= BIT0; // valid start bit
                    else
                        state <= IDLE; // noise / glitch
                end

                BIT0: if (sample) begin data[0] <= rxd_filt; state <= BIT1; end
                BIT1: if (sample) begin data[1] <= rxd_filt; state <= BIT2; end
                BIT2: if (sample) begin data[2] <= rxd_filt; state <= BIT3; end
                BIT3: if (sample) begin data[3] <= rxd_filt; state <= BIT4; end
                BIT4: if (sample) begin data[4] <= rxd_filt; state <= BIT5; end
                BIT5: if (sample) begin data[5] <= rxd_filt; state <= BIT6; end
                BIT6: if (sample) begin data[6] <= rxd_filt; state <= BIT7; end
                BIT7: if (sample) begin data[7] <= rxd_filt; state <= STOP; end

                STOP: if (sample) begin
                    if (rxd_filt == 1) begin
                        ready <= 1;   // COMPLETE BYTE RECEIVED
                    end
                    state <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end
endmodule