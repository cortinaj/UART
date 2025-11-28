`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 08:10:56 PM
// Design Name: 
// Module Name: UART
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


module UART(
   input  clk,        // 125 MHz
    input  RX,
    output TX,
    output reg led
);

    // RX wires
    wire [7:0] rx_byte;
    wire       rx_dv;

    // TX control
    reg        tx_valid = 0;
    reg [7:0]  tx_byte  = 0;
    wire       tx_done;

    //-------------------------
    // Instantiate RX
    //-------------------------
    uart_rx_v3 #(.CLKS_PER_BIT(1086)) RX_inst (
        .clk(clk),
        .RX_Serial(RX),
        .RX_Data_Valid(rx_dv),
        .RX_Byte(rx_byte)
    );

    //-------------------------
    // Instantiate TX
    //-------------------------
    uart_tx_v3 #(.CLKS_PER_BIT(1086)) TX_inst (
        .clk(clk),
        .TX_Data_Valid(tx_valid),
        .TX_Byte(tx_byte),
        .TX_Serial(TX),
        .TX_Done(tx_done)
    );

    //-------------------------
    // Echo: one-clock pulse
    //-------------------------
    always @(posedge clk) begin
        tx_valid <= 0;    // default

        if (rx_dv) begin
            tx_byte  <= rx_byte;
            tx_valid <= 1;  // ONE CLOCK ONLY
        end
    end

    // LED lights on RX
    always @(posedge clk) begin
        led <= rx_dv;
    end
endmodule
