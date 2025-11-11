`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 09:29:29 PM
// Design Name: 
// Module Name: baud_gen
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


module baud_gen(
    input wire clk, rst,
    output reg baud_tick
    );
    
    // Divider for 115200 baud rate @ 125 MHz
    localparam  integer DIVIDER = 1085;
    
    reg [10:0] counter = 0;
    
    //f_clk = 125 MHz
    // Tclk = 1/fclk = 1/125Mhz = 8ns
    //T_baud = 1/ baud_rate = 8.68us = 8680ns
    //Divider = 8680/8 = 1085
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 0;
            baud_tick <= 0;
        end else begin
            if(counter == DIVIDER - 1) begin
                counter <= 0;
                baud_tick <= 1;
            end else begin
                counter <= counter + 1;
                baud_tick <= 0;
            end
        end
   end
endmodule
