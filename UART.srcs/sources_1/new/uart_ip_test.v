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
module uart_ip_test(
    input  clk,          // 125 MHz clock
    input  RX,           // UART receive
    output TX,           // UART transmit
    output reg [3:0]led      // LED indicator for TX activity
);

   //--------------------------------------
    // Wires for UART_IP RX
    //--------------------------------------
    wire [7:0] rx_data;   // Received byte
    wire       rx_ready;  // Pulse when byte received
    
   reg  [7:0] tx_data = 8'd0;
   reg        tx_start = 1'b0;
   wire       tx_busy;
    //--------------------------------------
    // Instantiate UART IP (RX only)
    //--------------------------------------
    UART_IP uart_core (
        .sys_clk(clk),
        .TX(TX),             // TX not used
        .RX(RX),

        .TxD_par(rx_data),
        .TxD_ready(rx_ready),

        .RxD_par(tx_data),    // TX input not used
        .RxD_start(tx_start)   // TX input not used
    );

    always @(posedge clk) begin
        tx_start <= 1'b0;      // default

        if (rx_ready) begin
            tx_data  <= rx_data;   // ASCII 'A' (0x41)
            tx_start <= 1'b1;  // trigger one-cycle pulse
        end
    end
    
    //--------------------------------------
    // LED logic: lights up when RX_ready pulsesss
    //--------------------------------------
    reg [23:0] led_timer;

    always @(posedge clk) begin
        if (rx_ready) begin
            led_timer <= 24'hFFFFFF; // Load timer on RX
        end
        else if (led_timer != 0) begin
            led_timer <= led_timer - 1; // Decrement timer
        end

        led[0] <= (led_timer != 0);
    end
    
   
endmodule