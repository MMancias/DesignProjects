`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/21/2023 02:25:52 PM
// Design Name: 
// Module Name: comp_cell
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: comparator cell module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module comp_cell(
    input a, // input a
    input b, // input b
    input eq0, // previous equal comparison
    input lt0, // previous less than comparisom
    input gt0, // previous greater than comparison
    output eq1, // result of current equal comparison
    output lt1, // result of current less than comparison
    output gt1 // result of current greater than comparison
    );
    
    // assigning value of current comparison based on previous comparison
    assign eq1 = ( (~a&~b) | (a&b) ) & eq0; 
    assign lt1 = (~a&b) | ( ((~a&~b) | (a&b)) & lt0);
    assign gt1 = (a&~b) | ( ((~a&~b) | (a&b)) & gt0);
    
endmodule
