`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 06:38:53 PM
// Design Name: 
// Module Name: one_hot_counter
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


module one_hot_counter #(parameter N = 4) (
    input wire clk, rst, enable,
    output reg [N -1:0] count
    );
    
    always @(posedge clk) begin
        if(rst) begin
            count <= 4'b0001;
        end else if (enable) begin
            count <= {count[N-2:0],count[N-1]}; //rotate left
        end
    end
endmodule
