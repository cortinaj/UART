`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:11:53 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input wire clk, rst,
    input wire baud_tick, //from baud_gen file
    input wire [7:0] tx_data, //byte of data to send
    input wire tx_start, //pulse to begin transmission
    output reg tx = 1'b1, //UART is idle
    output reg tx_busy = 0 //Sending data
    );
    
    //UART Frame: 10 bits = 1 Start and Stop, 8 data bits
    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg = 0;
    
    //FSM states
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    reg [1:0] state = IDLE;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            tx <= 1'b1; 
            tx_busy <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 0;
                    
                    if(tx_start) begin
                        shift_reg <= tx_data;
                        bit_index <= 0;
                        tx_busy <= 1;
                        state <= START;
                    end
                end
                
                START: begin
                    if (baud_tick) begin
                        tx <= 1'b0;
                        state <= DATA;
                    end
                end 
                
                DATA: begin
                    if(baud_tick) begin
                        tx <= shift_reg[bit_index];
                        bit_index <= bit_index + 1;
                        
                        if (bit_index == 7) begin
                            state <= STOP;
                            end
                    end 
                end
                
                STOP: begin
                    if(baud_tick) begin
                        tx <= 1'b1;
                        tx_busy <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
                    
                   
                
                
        
endmodule
