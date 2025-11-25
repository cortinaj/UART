`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 12:32:13 AM
// Design Name: 
// Module Name: simple_uart
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


module simple_uart #
(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)
(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg tx
);

    // Baud rate calculation
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // RX signals
    reg [7:0] rx_shift = 0;
    reg [12:0] rx_count = 0;
    reg rx_busy = 0;
    reg [7:0] rx_data = 0;
    reg rx_done = 0;
    reg rx_sample = 0;
    reg rx_prev = 1;

    // TX signals
    reg [7:0] tx_shift = 0;
    reg [12:0] tx_count = 0;
    reg tx_busy = 0;
    reg tx_start = 0;

    // ----------------------------------
    // RX logic (sample on falling edge start bit)
    always @(posedge clk) begin
        rx_prev <= rx;
        rx_done <= 0;

        if (!rx_busy && rx_prev && !rx) begin
            // Start bit detected
            rx_busy <= 1;
            rx_count <= CLKS_PER_BIT / 2;
            rx_shift <= 0;
        end else if (rx_busy) begin
            if (rx_count == CLKS_PER_BIT - 1) begin
                rx_count <= 0;
                rx_shift <= {rx, rx_shift[7:1]};
                if (&rx_shift[7:0]) begin
                    rx_busy <= 0;
                    rx_done <= 1;
                    rx_data <= rx_shift;
                    tx_shift <= rx_shift; // echo received
                    tx_start <= 1;
                end
            end else begin
                rx_count <= rx_count + 1;
            end
        end
    end

    // ----------------------------------
    // TX logic
    reg [3:0] tx_bit = 0;
    always @(posedge clk) begin
        if (rst) begin
            tx <= 1;
            tx_busy <= 0;
            tx_bit <= 0;
            tx_count <= 0;
            tx_start <= 0;
        end else if (tx_start) begin
            tx_busy <= 1;
            tx_bit <= 0;
            tx_count <= 0;
            tx_start <= 0;
        end else if (tx_busy) begin
            if (tx_count == CLKS_PER_BIT - 1) begin
                tx_count <= 0;
                tx_bit <= tx_bit + 1;
                case (tx_bit)
                    0: tx <= 0;           // start bit
                    1: tx <= tx_shift[0];
                    2: tx <= tx_shift[1];
                    3: tx <= tx_shift[2];
                    4: tx <= tx_shift[3];
                    5: tx <= tx_shift[4];
                    6: tx <= tx_shift[5];
                    7: tx <= tx_shift[6];
                    8: tx <= tx_shift[7];
                    9: tx <= 1;           // stop bit
                    default: tx_busy <= 0;
                endcase
            end else begin
                tx_count <= tx_count + 1;
            end
        end else begin
            tx <= 1;
        end
    end

endmodule
