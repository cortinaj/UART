`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:38:45 AM
// Design Name: 
// Module Name: UART_IP
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


module UART_IP(
// UART pins
    input  sys_clk,      // 125 MHz on Zybo Z7-10
    output TX,           // UART transmit
    input  RX,           // UART receive

    // RX output to FPGA
    output [7:0] TxD_par,   // received byte
    output       TxD_ready, // pulse = byte received

    // TX input from FPGA
    input  [7:0] RxD_par,   // byte to transmit
    input        RxD_start  // pulse = send byte
);

    // Baud Generators
    wire BaudTick;
    wire Baud16Tick;

    baud_tick_gen baudgen (
        .clk(sys_clk),
        .tick(BaudTick)
    );

    baud_16tick_gen baud16gen (
        .clk(sys_clk),
        .tick(Baud16Tick)
    );

    // UART Transmitter
    uart_tx_v2 uart_tx (
        .RxD_par(RxD_par),       // byte to send
        .RxD_start(RxD_start),   // pulse to start sending
        .sys_clk(sys_clk),       // FPGA clock
        .BaudTick(BaudTick),     // baud tick
        .TxD_ser(TX)             // serial output
    );

    // UART Receiver
    uart_rx_v2 uart_rx (
        .clk(sys_clk),
        .Baud16Tick(Baud16Tick),
        .rxd(RX),
        .data(TxD_par),     // received byte sent to FPGA
        .ready(TxD_ready)   // pulse = new byte ready
    );

endmodule
