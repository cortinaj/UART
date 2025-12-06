`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 10:38:45 AM
// Design Name: 
// Module Name: UART_IP
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
module uart_ip_test(
    input  clk,          // 125 MHz clock
    input rst,
    input btn,
    input  RX,           // UART receive
    output TX,           // UART transmit
    output reg [3:0]led      // LED indicator for TX activity
);

    // Wires for UART_IP
    wire [7:0] rx_data;   // Received byte
    wire       rx_ready;  // Pulse when byte received

    //Wires for Debouncer Module
    wire btn_debounce;
    
    //Wires for baud tick gen
    wire baud_tick;
    
    reg [13:0] pace_cnt = 0;
    wire pace_ready = (pace_cnt == 0);
    
   reg  [7:0] tx_data = 8'd0;
   reg        tx_start = 1'b0;
   
   wire slow_clk;
   
   wire [3:0] bin_count;
   wire [3:0] onehot_count;
   
   reg[1:0] mode = 0;
   reg[3:0] counter_led = 0;
   


    // Instantiate UART IP 
    UART_IP uart_core (
        .sys_clk(clk),
        .TX(TX),             
        .RX(RX),

        .TxD_par(rx_data),
        .TxD_ready(rx_ready),

        .RxD_par(tx_data),   
        .RxD_start(tx_start)   
    );
    
    debouncer db(.clk(clk),
                 .rst(rst),
                 .btn_in(btn),
                 .pulse_out(btn_debounce)
                 );
    freq_div #(.DIVISOR(50_000_000)) div(.clk_in(clk),
                                         .rst(rst),
                                         .clk_out(slow_clk)
                                         );
    binary_up_counter #(.N(4)) bin (.clk(slow_clk),
                          .rst(rst),
                          .enable(mode==1),
                          .count(bin_count)
                          );
    one_hot_counter #(.N(4)) one(.clk(slow_clk),
                       .rst(rst),
                       .enable(mode==2),
                       .count(onehot_count)
                       );
   
    
    // STRING TO SEND ON BUTTON PRESS
    localparam MSG_LEN = 15;
    localparam [8*MSG_LEN-1:0] MESSAGE = 
        {"Button Press!"};

    reg send_msg = 0;
    reg [7:0] msg_index = 0;

    // Extract the next character
    wire [7:0] msg_char = MESSAGE[8*(MSG_LEN-1 - msg_index) +: 8];
    
    always @(posedge slow_clk or posedge rst) begin
        if (rst)
            counter_led <= 4'b0000;
        else begin
            case (mode)
                1: counter_led <= bin_count;      // binary counter
                2: counter_led <= onehot_count;   // one-hot counter
                default: counter_led <= 4'b0000;
            endcase
        end
    end
    
   always @(posedge clk) begin
        tx_start <= 1'b0;     // default off (1-cycle pulse)

        if (rst) begin
            led       <= 4'b0000;
            msg_index <= 0;
            send_msg  <= 0;
        end 
        else begin
            // BUTTON PRESSED ? Start sending message
            if (btn_debounce)
                send_msg <= 1;
            // ACTIVE MESSAGE MODE (send one byte per tx_done)
           if (send_msg) begin
                if (pace_ready) begin
                    if (msg_index < MSG_LEN) begin
                        tx_data  <= msg_char;
                        tx_start <= 1'b1;
                        msg_index <= msg_index + 1;
                        pace_cnt <= 14'd12000; // Wait full char time
                    end 
                    else begin
                        send_msg  <= 0;
                        msg_index <= 0;
                    end
                end else begin
                    pace_cnt <= pace_cnt - 1;
                end
            end
            // NORMAL UART ECHO + LED CONTROL
            if (!send_msg) begin
                if (rx_ready) begin
                    tx_data <= rx_data;
                    tx_start <= 1'b1;
                    if (rx_data == "b")
                        mode <= 1;
                    if (rx_data == "o")
                        mode <= 2;
                    if (rx_data == "0")
                        mode <= 0;
                    if (rx_data == "1")
                        led <= 4'b1111;
                end
                if (mode == 0)
                    led <= led;           // keep manual LED state
                else
                    led <= counter_led;   // show counter animation
            end
        end
    end
  
endmodule