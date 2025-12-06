`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 06:33:01 PM
// Design Name: 
// Module Name: binary_up_counter
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


module binary_up_counter #(parameter N = 4)(
    input wire clk, rst, enable,
    output reg [N-1:0] count
    );
    
    always @(posedge clk) begin
        if(rst) begin
            count <= 0;
        end else if(enable) begin
            count <= count + 1;
        end
    end
endmodule
