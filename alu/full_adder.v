`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/05/2023 03:07:31 PM
// Design Name: 
// Module Name: full_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Two 1bit input full adder module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module full_adder(
    input a,        // 1bit inpiut a    
    input b,        // 1bit input b
    input cin,      // carry-in signal
    output cout,    // carry_out signal
    output sum      // result of sum
    );
    
    assign sum = cin ^ (a^b);   // equation derived from full adder truth table
    assign cout = a&&b || b&&cin || a&&cin;  // equation derived from full adder truth table
endmodule
