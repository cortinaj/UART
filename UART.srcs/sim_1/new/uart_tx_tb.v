`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:28:58 PM
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb();
reg clk = 0;
    reg rst = 0;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'h41;     // ASCII 'A'

    wire tx;
    wire tx_busy;

    // 125 MHz clock: 8 ns period (4 ns high, 4 ns low)
    always #4 clk = ~clk;

    // Baud tick generator (same 1085 cycles as your real one)
    reg baud_tick = 0;
    integer counter = 0;
    localparam DIVIDER = 1085;

    // Generate baud_tick pulses
    always @(posedge clk) begin
        if (counter == DIVIDER-1) begin
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end

    // Instantiate DUT
    uart_tx uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    initial begin
        $display("UART TX Testbench Starting...");
        $monitor("T=%0t ns | tx=%b | busy=%b", $time, tx, tx_busy);

        // Reset the design
        rst = 1;
        #20;
        rst = 0;

        // Wait a little, then start transmission
        #50;
        tx_start = 1;
        #8;
        tx_start = 0;

        // Run long enough to see full UART frame (approx 10 bits * 8680 ns)
        #100000;    // 100 us

        $display("Simulation Finished.");
        $stop;
    end
endmodule
