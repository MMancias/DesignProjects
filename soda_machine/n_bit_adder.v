`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/18/2023 04:41:42 PM
// Design Name: 
// Module Name: n_bit_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: parametrized full-adder to allow adder of any width to be created. Default width is 32 bits.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_adder #(parameter WIDTH = 32)
    (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin,
    output [WIDTH-1:0] sum,
    output ov_sgn // final carry-out, also know as overflow signal
    );
    
    // wire for carry, used to connect adders
    // full width because we have initial carry in
    wire [WIDTH:0] w_carry;
    
    // generating n modules
    genvar i;
    
    generate 
        for(i = 0; i < WIDTH; i = i+1)
        begin: adder_gen_block
        full_adder fa (.a(a[i]), .b(b[i]), .cin(w_carry[i]), .cout(w_carry[i+1]), .sum(sum[i]));
        end
    endgenerate 
    
    // assigning overflow and carry in signal
    assign w_carry[0] = cin;
    assign ov_sgn = w_carry[WIDTH];
    
endmodule
