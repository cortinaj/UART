`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:19:07 AM
// Design Name: 
// Module Name: baud_tick_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// zybo z7-10 clk is 125 MHz
//target baud rate is 115200
//DIV = 125/115200
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_tick_gen(
    input clk,
    output reg tick
    );
    
    localparam integer DIV = 1085; 
    reg [10:0] cnt;
    
    always @(posedge clk) begin
        if(cnt == DIV -1) begin
            cnt <= 0;
            tick <= 1'b1;
        end else begin
            cnt <= cnt + 1;
            tick <= 1'b0;
        end
    end

endmodule
