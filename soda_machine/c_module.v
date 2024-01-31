`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/05/2023 08:23:35 PM
// Design Name: 
// Module Name: c_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: "basic" block for double-dabble hardware implementation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module c_module(
    input [3:0] a,
    output reg [3:0] s
    );
    
    // ROM used for c module truth table
    always @(a)
    case(a)
    4'b0000 : s = 4'b0000;
    4'b0001 : s = 4'b0001;
    4'b0010 : s = 4'b0010;
    4'b0011 : s = 4'b0011;
    4'b0100 : s = 4'b0100;
    4'b0101 : s = 4'b1000;
    4'b0110 : s = 4'b1001;
    4'b0111 : s = 4'b1010;
    4'b1000 : s = 4'b1011;
    4'b1001 : s = 4'b1100;
    4'b1010 : s = 4'b1111;
    4'b1011 : s = 4'b1111;
    4'b1100 : s = 4'b1111;
    4'b1101 : s = 4'b1111;
    4'b1110 : s = 4'b1111;
    4'b1111 : s = 4'b1111;
    
    endcase
endmodule
