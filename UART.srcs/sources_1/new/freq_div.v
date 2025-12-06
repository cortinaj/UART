`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 06:43:47 PM
// Design Name: 
// Module Name: freq_div
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


module freq_div #(parameter DIVISOR = 50_000_000) (
    input wire clk_in, rst,
    output reg clk_out
    );
    
    integer counter = 0;
    
    always @(posedge clk_in or posedge rst) begin
        if(rst) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if(counter == (DIVISOR/2 -1)) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin 
                counter <= counter + 1;
            end
        end
   end
endmodule
