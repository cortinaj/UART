`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 08:38:07 PM
// Design Name: 
// Module Name: top_uart
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


module top_uart(
    input  wire clk,        // 125 MHz ZYBO system clock
    input  wire rst_btn,        // active high reset

    // PMOD USB-UART pins
    input  wire pmod_rxd,   // PMOD TXD -> FPGA RX
    output wire pmod_txd,   // FPGA TX -> PMOD RXD

    // For demo: send a byte
    input  wire send_btn
);

    wire baud_tick;
    wire tx_busy;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'h00;

    wire [7:0] rx_data;
    wire rx_ready;

    //------------------------------------------------------------
    //  Baud Generator
    //------------------------------------------------------------
    baud_gen BAUD(
        .clk(clk),
        .rst(rst_btn),
        .baud_tick(baud_tick)
    );

    //------------------------------------------------------------
    // UART Transmitter
    //------------------------------------------------------------
    uart_tx TX(
        .clk(clk),
        .rst(rst_btn),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(pmod_txd),
        .tx_busy(tx_busy)
    );

    //------------------------------------------------------------
    // UART Receiver (16x oversample version)
    //------------------------------------------------------------
    uart_rx RX(
        .clk(clk),
        .rst(rst_btn),
        .rx(pmod_rxd),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .frame_error()
    );

    //------------------------------------------------------------
    // Simple TX logic (send ASCII 'A' when button pressed)
    //------------------------------------------------------------
    reg btn_sync1, btn_sync2, btn_prev;

    always @(posedge clk) begin
        // Button synchronizer
        btn_sync1 <= send_btn;
        btn_sync2 <= btn_sync1;

        btn_prev <= btn_sync2;

        // Rising edge: send a byte
        if (!tx_busy && (btn_sync2 == 1'b1) && (btn_prev == 1'b0)) begin
            tx_data  <= 8'h41;   // ASCII 'A'
            tx_start <= 1'b1;
        end else begin
            tx_start <= 1'b0;
        end
    end
endmodule
