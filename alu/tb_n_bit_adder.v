`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/20/2023 06:13:54 PM
// Design Name: 
// Module Name: tb_n_bit_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test n bit adder functionality
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
module tb_n_bit_adder(); // tb module has no ports

    // defining uut local signals
    reg [3:0] tb_in_a;
    reg [3:0] tb_in_b;
    reg tb_in_cin;
    wire [3:0] tb_out_sum;
    wire tb_out_ov_sgn;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable
    
    // defining unit under test
    n_bit_adder #(.WIDTH(4)) uut ( // creating a 4-bit adder
    .a(tb_in_a),
    .b(tb_in_b),
    .cin(tb_in_cin),
    .sum(tb_out_sum),
    .ov_sgn(tb_out_ov_sgn)
    );
    
    // testing vectors
    initial
    begin
        // max value would be 9'b111111111 due to max a, b, and cin values (4+4+1)
        for (i = 0; i <= 9'b111111111; i = i+1)
        begin
        {tb_in_cin, tb_in_b, tb_in_a} = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
