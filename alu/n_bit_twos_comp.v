`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/20/2023 06:35:50 PM
// Design Name: 
// Module Name: n_bit_twos_comp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: n bit 2's complement using XOR and OR gate structure
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_twos_comp #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] result
    );
    
    // local variables 
    wire [WIDTH-1:0] comp; // contains 2's complement data
    
    assign comp[0] = a[0]; // keep LSB value
    
    genvar i;
    generate
        for(i = 1; i < WIDTH; i = i+1) // starting from second bit and up
        begin: xor_or_structure
        if (i == 1'b1)
        assign comp[i] = a[i-1] ^ a[i]; // second bit value logic
        
        else
        assign comp[i] = (comp[i-1] | a[i-1]) ^ a[i]; // implementing cascaded OR and XOR gate structure for rest of bits
                                                      // if previous output or input bit is 1, xor with current bit
                                                      // effectively, copy first one, then invert the rest of bits
        end
    endgenerate
    
    assign result = comp; // assigning output to wire containing 2's complement data
    
    
endmodule
