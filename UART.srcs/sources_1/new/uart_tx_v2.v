`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:28:33 AM
// Design Name: 
// Module Name: uart_tx_v2
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


module uart_tx_v2(
    input  [7:0] RxD_par,   // 8-bit parallel data to send
    input        RxD_start, // request to send
    input        sys_clk,   // FPGA clock
    input        BaudTick,  // baud rate tick
    output reg   TxD_ser = 1'b1 // UART TX line (idle = 1)
);

    // Internal registers
    reg  [3:0] state = 0;
    reg  [7:0] RxD_buff = 0;

    // State Machine
    always @(posedge sys_clk) begin

        // --- Latch data only when idle ---
        if (RxD_start && state < 2) begin
            RxD_buff <= RxD_par;
        end
        // --- Shift right while sending bits ---
        else if (state[3] && BaudTick) begin
            RxD_buff <= (RxD_buff >> 1);
        end

        case(state)
            4'b0000:     // Idle
                if (RxD_start)
                    state <= 4'b0010;

            4'b0010:     // Align to baud
                if (BaudTick)
                    state <= 4'b0011;

            4'b0011:     // Start bit
                if (BaudTick)
                    state <= 4'b1000;

            4'b1000: if (BaudTick) state <= 4'b1001; // Bit 0  
            4'b1001: if (BaudTick) state <= 4'b1010; // Bit 1
            4'b1010: if (BaudTick) state <= 4'b1011; // Bit 2
            4'b1011: if (BaudTick) state <= 4'b1100; // Bit 3
            4'b1100: if (BaudTick) state <= 4'b1101; // Bit 4
            4'b1101: if (BaudTick) state <= 4'b1110; // Bit 5
            4'b1110: if (BaudTick) state <= 4'b1111; // Bit 6
            4'b1111: if (BaudTick) state <= 4'b0001; // Bit 7

            4'b0001:     // Stop bit
                if (BaudTick) begin
                    if (RxD_start)      // new char waiting
                        state <= 4'b0011;
                    else
                        state <= 4'b0000; // back to idle
                end

            default:
                state <= 4'b0000;
        endcase
    end

    // UART Output
    always @(posedge sys_clk) begin
        // state < 3 = idle(1), align(1), start(0)
        // state >= 8 = data bits, send LSB
        TxD_ser <= (state < 3) | (state[3] & RxD_buff[0]);
    end
endmodule
