`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 07:51:58 PM
// Design Name: 
// Module Name: uart_rx_tb
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


module uart_rx_tb();
   // DUT I/O
    reg clk;
    reg rst;
    reg rx;

    wire [7:0] rx_data;
    wire rx_ready;
    wire frame_error;

    // Instantiate DUT
    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .frame_error(frame_error)
    );

    // 125 MHz clock -> 8 ns period
    always #4 clk = ~clk;

    // Baud rate timing (bit period)
    // 1 / 115200 = 8.6806us = 8680.6ns
    real BIT_PERIOD = 8680.6;

    // Task to send 1 UART frame (start + 8 data bits + stop)
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (LOW)
            rx = 1'b0;
            #(BIT_PERIOD);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit (HIGH)
            rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // Test sequence
    initial begin
        // Init signals
        clk = 1'b0;
        rst = 1'b1;
        rx  = 1'b1;   // idle line is HIGH

        // Release reset
        #100;
        rst = 1'b0;

        // Wait a little
        #20000;

        // Send 'A' = 0x41 = 0100_0001
        $display("Sending byte 0x41 ('A')");
        send_uart_byte(8'h41);

        // Wait for reception
        wait (rx_ready == 1'b1);

        #1; // allow signal settle

        $display("Received byte: 0x%02h (char %c)", rx_data, rx_data);
        if (frame_error)
            $display("FRAME ERROR detected!");
        else
            $display("Frame OK");

        // Finish
        #20000;
        $stop;
    end
endmodule
