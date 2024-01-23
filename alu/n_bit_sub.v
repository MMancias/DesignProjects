`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/27/2023 12:54:04 PM
// Design Name: 
// Module Name: n_bit_sub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: n-bit subtractor module using full adder, 2's complement, inverter and mux modules
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_sub #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] sub,
    output sgn
    );
    
    // local wires to connect blocks
    wire [WIDTH-1:0] w_sum;
    wire [WIDTH-1:0] w_twos_comp;
    wire w_sgn;
    
    // creating necessary modules
    n_bit_adder #(.WIDTH(WIDTH)) add (.a(a), .b(~b), .cin(1'b1), .sum(w_sum), .ov_sgn(w_sgn)); // adding a and ~b, wire w_sgn carries sign signal
    n_bit_twos_comp #(.WIDTH(WIDTH)) twos (.a(w_sum), .result(w_twos_comp)); // twos complement calculation of sum operation
    
    // assigning sign for subtraction
    assign sgn = ~w_sgn;
    
    // mux design 
    assign sub = sgn ? w_twos_comp : w_sum;
    
    
    
endmodule
