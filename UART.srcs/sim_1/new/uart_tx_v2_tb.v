`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 11:17:20 AM
// Design Name: 
// Module Name: uart_tx_v2_tb
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


module uart_tx_v2_tb();
 reg        sys_clk = 0;
    reg        BaudTick = 0;
    reg  [7:0] RxD_par;
    reg        RxD_start;
    wire       TxD_ser;

    // Instantiate DUT
    uart_tx_v2 dut (
        .RxD_par(RxD_par),
        .RxD_start(RxD_start),
        .sys_clk(sys_clk),
        .BaudTick(BaudTick),
        .TxD_ser(TxD_ser)
    );

    //--------------------------------------
    // Clock: 10ns period (100 MHz)
    //--------------------------------------
    always #5 sys_clk = ~sys_clk;

    //--------------------------------------
    // BaudTick generator (slow for waves)
    // Here: 1 tick every 16 cycles
    //--------------------------------------
    integer baud_count = 0;

    always @(posedge sys_clk) begin
        if (baud_count == 15) begin
            baud_count <= 0;
            BaudTick <= 1;
        end else begin
            baud_count <= baud_count + 1;
            BaudTick <= 0;
        end
    end

    //--------------------------------------
    // Stimulus
    //--------------------------------------
    initial begin
        // Initialize
        RxD_par   = 8'h00;
        RxD_start = 0;

        // Wait a bit
        #50;

        // Send first byte
        RxD_par = 8'hA5;     // 0b10100101
        RxD_start = 1;       // one cycle pulse
        #10;
        RxD_start = 0;

        // Wait for full frame to finish (start + 8 bits + stop)
        #2000;

        // Send second byte
        RxD_par = 8'h3C;
        RxD_start = 1;
        #10;
        RxD_start = 0;

        #2000;

        $finish;
    end
endmodule
