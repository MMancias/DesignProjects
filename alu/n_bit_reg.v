`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/27/2023 01:41:51 PM
// Design Name: 
// Module Name: n_bit_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: generic n-bit register with active-low asynchronous reset and clock enable inputs
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_reg #(parameter WIDTH = 32) (
    input [WIDTH-1:0] d, // input data
    input clk, // input clock
    input rst, // input reset
    input en, // input enable
    output reg [WIDTH-1:0] q // output data
    );
    
    always @(posedge clk, negedge rst)
    begin
        if (!rst) begin // if reset is pressed, rst == 0
        q <= 0;
        end
        
        else if (en) begin // if enable, en == 1
        q <= d;
        end
    end
endmodule
