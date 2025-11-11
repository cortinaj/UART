`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 09:53:27 PM
// Design Name: 
// Module Name: baud_gen_tb
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


module baud_gen_tb();
     // Testbench signals
    reg clk = 0;
    reg rst = 0;
    wire baud_tick;

    // Instantiate DUT (Device Under Test)
    baud_gen uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Clock generation: 125 MHz ? period = 8 ns
    always begin
        #4 clk = ~clk;   // 4 ns high + 4 ns low = 8 ns period
    end

    initial begin
        // Monitor signals
        $display("Starting baud_gen testbench...");
        $monitor("Time=%0t | reset=%b | tick=%b", $time, rst, baud_tick);

        // Apply reset
        rst = 1;
        #20;             // keep reset high for 20 ns
        rst = 0;

        // Let simulation run long enough to observe multiple ticks
        #20000;          // 20 us total sim time (enough for ~2 ticks)

        $display("Simulation Finished.");
        $stop;
    end
endmodule
