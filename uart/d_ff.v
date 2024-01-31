`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/10/2023 11:21:45 PM
// Design Name: 
// Module Name: d_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: d-type flip flop
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module d_ff(
    input d,
    input clk,
    input rst,
    output reg q
    );
    always @ (posedge clk, negedge rst)
    begin
        if (!rst) // reset == 0, reset has been pressed
        begin
        q <= 1'b0;
        end
        
        else // reset not pressed (reset == 0)
        begin
        q <= d;
        end
    end
    
    
endmodule
