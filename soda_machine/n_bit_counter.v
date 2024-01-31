`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/21/2023 12:04:56 AM
// Design Name: 
// Module Name: n_bit_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: n-bit counter design with default size 32-bits with enable signal (start counter)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_counter #(parameter WIDTH = 32) (
    input clk, // input clock
    input rst, // reset signal
    input en, // enable signal to start counter
    output reg [WIDTH-1:0] count // counter register
    );
    
    // behavior modeling
    always @(posedge clk, negedge rst) begin
        if (!rst) // reset == 0
        count <= 0;
        else if (en)
        count <= count + 1;
    end
        
endmodule
