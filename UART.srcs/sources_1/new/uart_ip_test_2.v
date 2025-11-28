`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 09:07:57 PM
// Design Name: 
// Module Name: uart_ip_test_2
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


module uart_ip_test_2(
    input  clk,          // 125 MHz Clock
    input  RX,           // UART RX from PC
    output TX,           // UART TX to PC
    output reg [3:0] led // LEDs for mode output
);

//--------------------------------------
// UART interfacing wires
//--------------------------------------
wire [7:0] rx_data;
wire       rx_ready;

reg  [7:0] tx_data = 0;
reg        tx_start = 0;

UART_IP uart_core (
    .sys_clk(clk),
    .TX(TX),
    .RX(RX),

    .TxD_par(rx_data),
    .TxD_ready(rx_ready),

    .RxD_par(tx_data),
    .RxD_start(tx_start)
);

//--------------------------------------
// UART transmit helper task (1-cycle pulse)
//--------------------------------------
task uart_send_byte(input [7:0] b);
begin
    tx_data  <= b;
    tx_start <= 1'b1;
end
endtask

//--------------------------------------
// Reset pulse clear
//--------------------------------------
always @(posedge clk)
    tx_start <= 1'b0;


//--------------------------------------
// MENU STATE MACHINE
//--------------------------------------
localparam M_IDLE     = 0,
           M_MENU     = 1,
           M_WAIT_CMD = 2,
           M_COUNTER  = 3;

reg [2:0] state = M_IDLE;

reg [31:0] counter;

always @(posedge clk) begin
    case(state)

        //-----------------------------------------------------
        // Print menu once when the FPGA starts
        //-----------------------------------------------------
        M_IDLE: begin
            uart_send_byte("\n");  // newline
            state <= M_MENU;
        end

        //-----------------------------------------------------
        // Send out the menu characters
        //-----------------------------------------------------
        M_MENU: begin
            // You can turn this into a full string, here's a short fixed version
            uart_send_byte("1");
            state <= M_WAIT_CMD;
        end

        //-----------------------------------------------------
        // Wait for input key from user
        //-----------------------------------------------------
        M_WAIT_CMD: begin
            if(rx_ready) begin

                case(rx_data)

                    //------------------------------------------
                    // OPTION 1 ? start binary counter on LEDs
                    //------------------------------------------
                    "1": begin
                        uart_send_byte("C"); // "Counter mode\n"
                        state <= M_COUNTER;
                    end

                    //------------------------------------------
                    // OPTION 2 ? turn LEDs off
                    //------------------------------------------
                    "2": begin
                        uart_send_byte("O"); // "LEDs Off\n"
                        led <= 4'b0000;
                    end

                    //------------------------------------------
                    // Invalid key
                    //------------------------------------------
                    default: begin
                        uart_send_byte("E"); // "Error\n"
                    end
                endcase

            end // rx_ready
        end

        //-----------------------------------------------------
        // Binary Counter Mode
        //-----------------------------------------------------
        M_COUNTER: begin
            counter <= counter + 1;

            // Slow down LED update
            if(counter[20])
                led <= led + 1;

            if(rx_ready && rx_data == "0") begin
                // Exit mode
                uart_send_byte("X"); // "Exit counter\n"
                state <= M_WAIT_CMD;
            end
        end

    endcase
end
endmodule
