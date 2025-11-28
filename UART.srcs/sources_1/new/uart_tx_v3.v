`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 07:41:19 PM
// Design Name: 
// Module Name: uart_tx_v3
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


module uart_tx_v3 #(parameter CLKS_PER_BIT = 1086)(
    input clk,
    input TX_Data_Valid,
    input [7:0] TX_Byte,
    output TX_Active,
    output reg TX_Serial,
    output TX_Done
    );
    
    localparam s_IDLE = 3'b000;
    localparam s_TX_START_BIT = 3'b001;
    localparam s_TX_DATA_BITS = 3'b010;
    localparam s_TX_STOP_BIT = 3'b011;
    localparam s_CLEANUP = 3'b100;
    
    reg [2:0] SM_Main = 0;
    reg [7:0] Clk_Count = 0;
    reg [2:0] Bit_Index = 0;
    reg [7:0] Data = 0;
    reg Done = 0;
    reg Active = 0;
    
    always @(posedge clk) begin
        case (SM_Main)
            s_IDLE: 
            begin
                TX_Serial <= 1'b1;
                Done <= 1'b0;
                Clk_Count <= 0;
                Bit_Index <= 0;
                
                if(TX_Data_Valid == 1'b1)
                    begin
                        Active <= 1'b1; //drive signal for idle
                        Data <= TX_Byte;
                        SM_Main <= s_TX_START_BIT;
                    end
                 else
                    SM_Main <= s_IDLE;
            end
            
            //Send outStart Bit: Start bit = 0
            s_TX_START_BIT:
            begin
                TX_Serial <= 1'b0;
                
                //Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
                if(Clk_Count < CLKS_PER_BIT -1)
                    begin
                        Clk_Count <= Clk_Count + 1;
                        SM_Main <= s_TX_START_BIT;
                    end  
                else
                    begin
                        Clk_Count <= 0;
                        SM_Main <= s_TX_DATA_BITS;
                    end
            end
            
            //Wait CLKS_PER_BIT -1 clock cycles for data bits to finish
            s_TX_DATA_BITS:
            begin
                TX_Serial <= Data[Bit_Index];
                
                if(Clk_Count < CLKS_PER_BIT - 1)
                    begin
                        Clk_Count <= Clk_Count + 1;
                        SM_Main <= s_TX_DATA_BITS;
                    end
                 else
                    begin
                        Clk_Count <= 0;
                        
                        //Check if all bits were sent out
                        if(Bit_Index < 7)
                            begin
                                Bit_Index <= Bit_Index + 1;
                                SM_Main <= s_TX_DATA_BITS;
                            end
                        else
                            begin
                                Bit_Index <= 0;
                                SM_Main <= s_TX_STOP_BIT;
                            end 
                    end
            end
            s_TX_STOP_BIT:
            begin
                TX_Serial <= 1'b1;
                
                //Wait CLKS_PER_BIT -1 clock cycles for Stop bit to finish
                if(Clk_Count < CLKS_PER_BIT -1)
                    begin
                        Clk_Count <= Clk_Count + 1;
                        SM_Main <= s_TX_STOP_BIT;
                    end
                else
                    begin
                        Done <= 1'b1;
                        Clk_Count <= 0;
                        SM_Main <= s_CLEANUP;
                        Active <= 1'b0;
                    end
            end
            
            //Stay here for 1 clock
            s_CLEANUP:
            begin
                Done <= 1'b1;
                SM_Main <= s_IDLE;
            end
            
            default:
                SM_Main <= s_IDLE;
                      
        endcase
    end
    
   assign TX_Active = Active;
   assign TX_Done = Done;
                                                            
                        
endmodule
