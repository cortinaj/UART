`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 07:57:15 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input rst,
    input btn_in,
    output reg pulse_out
    );
    
    // Synchronize button input
    reg [1:0] sync_reg = 2'b00;

    // Debounce logic
    reg [19:0] cnt = 20'd0;
    reg btn_state = 1'b0;
    wire cnt_max = (cnt == 20'hFFFFF);

    // One-pulse generation
    reg btn_state_d = 1'b0;

    // Synchronize input to clk
    always @(posedge clk) begin
        if (rst) begin
            sync_reg <= 2'b00;
        end else begin
            sync_reg <= {sync_reg[0], btn_in};
        end
    end

    wire btn_sync = sync_reg[1];

    // Debounce logic
    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
            btn_state <= 0;
        end else begin
            if (btn_sync != btn_state) begin
                cnt <= cnt + 1;
                if (cnt_max) begin
                    btn_state <= btn_sync;
                    cnt <= 0;
                end
            end else begin
                cnt <= 0;
            end
        end
    end

    // Register previous debounced state
    always @(posedge clk) begin
        if (rst) begin
            btn_state_d <= 0;
        end else begin
            btn_state_d <= btn_state;
        end
    end

    // Generate one pulse per valid button press
    always @(posedge clk) begin
        if (rst) begin
            pulse_out <= 0;
        end else begin
            pulse_out <= btn_state && ~btn_state_d;
        end
    end
        
endmodule
