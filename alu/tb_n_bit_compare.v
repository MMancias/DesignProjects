`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/21/2023 03:01:04 PM
// Design Name: 
// Module Name: tb_n_bit_compare
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test n-bit comparator functionality
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// setting timescale
`timescale 1ns/1ps
module tb_n_bit_compare(); // tb module has no ports

    // defining uut local signals
    reg [3:0] tb_in_a;
    reg [3:0] tb_in_b;
    wire tb_out_eq;
    wire tb_out_lt;
    wire tb_out_gt;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable
    
    // defining unit under test
    n_bit_compare #(.WIDTH(4)) uut ( // creating a 4-bit comparator
    .a(tb_in_a),
    .b(tb_in_b),
    .eq(tb_out_eq),
    .lt(tb_out_lt),
    .gt(tb_out_gt)
    );
    
    // testing vectors
    initial
    begin
        // max value would be 8'b11111111 due to max a and b values (4+4)
        for (i = 0; i <= 8'b11111111; i = i+1)
        begin
         {tb_in_b, tb_in_a} = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
