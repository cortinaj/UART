`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 06:58:04 PM
// Design Name: 
// Module Name: uart_rx_v3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Parameter CLKS_PER_BIT = frequency of clk/ freq of uart
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx_v3 #(parameter CLKS_PER_BIT = 1086)(
    input clk,
    input RX_Serial,
    output RX_Data_Valid,
    output [7:0] RX_Byte
    );
    
    //States for FSM
    localparam s_IDLE = 3'b000;
    localparam s_RX_START_BIT = 3'b001;
    localparam s_RX_DATA_BITS = 3'b010;
    localparam s_RX_STOP_BIT = 3'b011; 
    localparam s_CLEANUP = 3'b100;
    
    reg RX_Data_R = 1'b1; //data recieved
    reg RX_Data = 1'b1;
    
    reg [7:0] Clk_Count = 0;
    reg [2:0] Bit_Index = 0; //Working with 8 bits
    reg [7:0] Byte = 0; //Values of the recieved byte
    reg RX_DV = 0;
    reg [2:0] SM_Main = 0;
    
    //Use a two stage synchronizer for incoming data. Allows it to be used in the RX clock domain -> Reduce metastability
    always @(posedge clk) begin
        RX_Data_R <= RX_Serial;
        RX_Data <= RX_Data_R;
    end
    
    //Control RX state machine
    always @(posedge clk) begin
        case(SM_Main)
            s_IDLE: 
            begin
                RX_DV <= 1'b0;
                Clk_Count <= 0;
                Bit_Index <= 0;
                if (RX_Data == 1'b0) //start bit detected
                    SM_Main <= s_RX_START_BIT;
                else
                    SM_Main <= s_IDLE;
            end
            
            //Check middle of the start bit to make sure it's still low
            s_RX_START_BIT:
            begin
                if(Clk_Count == (CLKS_PER_BIT - 1) / 2)
                    begin
                        if(RX_Data == 1'b0) begin
                            Clk_Count <= 0; //reset counter, found the middle
                            SM_Main <= s_RX_DATA_BITS;
                        end else begin
                            SM_Main <= s_IDLE;
                        end              
                end else begin
                    Clk_Count <= Clk_Count + 1;
                    SM_Main <= s_RX_START_BIT;
                end
            end
            
            // Wait CLKS_PER_BIT -1 clk cycle to sample serial data
            s_RX_DATA_BITS:
            begin
                if(Clk_Count < CLKS_PER_BIT - 1) begin
                    Clk_Count <= Clk_Count + 1;
                    SM_Main <= s_RX_DATA_BITS;
                end else begin
                    Clk_Count <= 0;
                    Byte[Bit_Index] <= RX_Data;
                    
                    // Check if all bits have been receieved
                    if(Bit_Index < 7) begin
                        Bit_Index <= Bit_Index + 1;
                        SM_Main <= s_RX_DATA_BITS;
                    end else begin
                        Bit_Index <= 0;
                        SM_Main <= s_RX_STOP_BIT;
                    end
                end
           end 
           
           s_RX_STOP_BIT:
           begin
                //Wait CLKS_PER_BIT -1 clock cycles for Stop bit to finish
                if (Clk_Count < CLKS_PER_BIT -1) begin
                    Clk_Count <= Clk_Count + 1;
                    SM_Main <= s_RX_STOP_BIT;
                end else begin
                    RX_DV <= 1'b1;
                    Clk_Count <= 0;
                    SM_Main <= s_CLEANUP;
                end
           end
           
           //Stay here for 1 clock
           
           s_CLEANUP:
           begin
                SM_Main <= s_IDLE;
                RX_DV <= 1'b0;
           end
           
           default:
                SM_Main <= s_IDLE;
                
        endcase
     end
     
    assign RX_Data_Valid = RX_DV;
    assign RX_Byte = Byte;   
                    
                                
  
endmodule
