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
    input rst,
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
        .TX(TX),             
        .RX(RX),

        .TxD_par(rx_data),
        .TxD_ready(rx_ready),

        .RxD_par(tx_data),   
        .RxD_start(tx_start)   
    );

   always @(posedge clk) begin
       if (rst) begin
           led       <= 4'b0000;
           tx_start  <= 1'b0;
           tx_data   <= 8'd0;
       end
       else begin
           tx_start <= 1'b0; // default

           if (rx_ready) begin
               tx_data  <= rx_data;   
               tx_start <= 1'b1; // echo received byte

               // Check for '1' key
               if (rx_data == "1") begin
                   led[3:1] <= 3'b111; // turn all LEDs on
               end
           end
       end
   end
    
   //--------------------------------------
   // Optional LED pulse logic
   //--------------------------------------
   reg [23:0] led_timer;

   always @(posedge clk) begin
       if (rst) begin
           led_timer <= 24'd0;
           led[0] <= 1'b0;
       end
       else begin
           if (rx_ready && rx_data != "1") begin
               led_timer <= 24'hFFFFFF; // load timer on RX
           end
           else if (led_timer != 0) begin
               led_timer <= led_timer - 1; // decrement timer
           end

           // Only use bit 0 for pulse effect
           if (rx_data != "1")
               led[0] <= (led_timer != 0);
       end
   end
    
   
endmodule