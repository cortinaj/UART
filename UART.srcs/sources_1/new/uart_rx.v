`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 07:19:19 PM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// A 125 MHz clk with a baud rate of 115200. It will be oversampled 16x
// DIVIDER = 125e6/ (16 * baud rate)) = 68
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx#(
    parameter CLK_FREQ = 125_000_000,   // 125 MHz
    parameter BAUD_RATE = 115200,       // UART baud
    parameter OVERSAMPLE = 16           // 16x oversampling
)(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg [7:0] rx_data = 0,
    output reg rx_ready = 0,
    output reg frame_error = 0
);

    // ------------------------------------------------------------
    // Derived clock divider for oversampling
    // sample rate = baud * 16 = 115200 * 16 = 1.8432 MHz
    // divider = 125e6 / 1.8432e6 = 67.8 ? 68
    // ------------------------------------------------------------
    localparam integer OVERSAMPLE_DIV =
        CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

    // UART states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;

    // oversample counter
    reg [7:0] sample_cnt = 0;      // 0..15
    reg [15:0] os_div_cnt = 0;     // divides 125 MHz down to oversample clock

    // data bit index
    reg [2:0] bit_idx = 0;

    // shift register
    reg [7:0] shift_reg = 0;

    // sync RX to clk domain
    reg rx1, rx2;
    always @(posedge clk) begin
        rx1 <= rx;
        rx2 <= rx1;
    end

    // generate oversample enable (tick)
    wire os_tick = (os_div_cnt == OVERSAMPLE_DIV);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            os_div_cnt <= 0;
        end else begin
            if (os_div_cnt == OVERSAMPLE_DIV)
                os_div_cnt <= 0;
            else
                os_div_cnt <= os_div_cnt + 1;
        end
    end

    // main UART RX logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_idx <= 0;
            sample_cnt <= 0;
            rx_ready <= 0;
            frame_error <= 0;
        end else begin

            rx_ready <= 0;  // default

            if (os_tick) begin
                case (state)

                // ------------------------------------------------------------
                // Wait for start bit (falling edge)
                // ------------------------------------------------------------
                IDLE: begin
                    if (rx2 == 0) begin
                        state <= START;
                        sample_cnt <= 0;
                    end
                end

                // ------------------------------------------------------------
                // Validate start bit at sample 8 (middle of bit)
                // ------------------------------------------------------------
                START: begin
                    if (sample_cnt == 7) begin
                        if (rx2 == 0) begin
                            state <= DATA;
                            sample_cnt <= 0;
                            bit_idx <= 0;
                        end else begin
                            state <= IDLE;  // false start detect
                        end
                    end else begin
                        sample_cnt <= sample_cnt + 1;
                    end
                end

                // ------------------------------------------------------------
                // Sample data bits at sample 8
                // ------------------------------------------------------------
                DATA: begin
                    if (sample_cnt == 7) begin
                        shift_reg[bit_idx] <= rx2;  // sample bit

                        if (bit_idx == 7) begin
                            state <= STOP;
                        end

                        bit_idx <= bit_idx + 1;
                    end

                    if (sample_cnt == 15)
                        sample_cnt <= 0;
                    else
                        sample_cnt <= sample_cnt + 1;
                end

                // ------------------------------------------------------------
                // Sample stop bit at middle (sample 8)
                // ------------------------------------------------------------
                STOP: begin
                    if (sample_cnt == 7) begin
                        if (rx2 == 1) begin
                            rx_data <= shift_reg;
                            rx_ready <= 1;
                        end else begin
                            frame_error <= 1;
                        end
                        state <= IDLE;
                    end

                    if (sample_cnt == 15)
                        sample_cnt <= 0;
                    else
                        sample_cnt <= sample_cnt + 1;
                end

                endcase
            end
        end
    end
endmodule
