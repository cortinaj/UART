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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_16tick_gen(
    input clk,
    output reg tick
    );
    
    
    localparam integer DIV16 = 67; // ? 68
    reg [6:0] cnt;
    always @(posedge clk) begin
        if (cnt == DIV16-1) begin
            cnt <= 0;
            tick <= 1'b1;
        end else begin
            cnt <= cnt + 1;
            tick <= 1'b0;
        end
    end
//    reg [27:0] acc = 0;
//    localparam integer K = 3965801;
    
//    always @(posedge clk) begin
//        acc <= acc + K;
//    end
    
//    assign tick = acc[27];
endmodule
