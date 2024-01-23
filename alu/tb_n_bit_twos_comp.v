`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/20/2023 09:12:07 PM
// Design Name: 
// Module Name: tb_n_bit_twos_comp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test n-bit twos complement module
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
module tb_n_bit_twos_comp(); // tb module has no ports

    // defining uut local signals
    reg [4:0] tb_in_a;
    wire [4:0] tb_out_result;
        
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable
    
    // defining unit under test
    n_bit_twos_comp #(.WIDTH(5)) uut ( // testing 5-bit two's complement
    .a(tb_in_a),
    .result(tb_out_result)
    );
    
    // testing vectors
    initial
    begin
        // max value would be 5'b11111 due to max a (11111), 4'b1111
        for (i = 0; i <= 5'b11111; i = i+1)
        begin
        tb_in_a = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
