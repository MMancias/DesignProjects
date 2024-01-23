`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/21/2023 02:35:38 PM
// Design Name: 
// Module Name: tb_comp_cell
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test compare cell functionality
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
module tb_comp_cell(); // tb module has no ports

    // defining uut local signals
    reg tb_in_a;
    reg tb_in_b;
    wire tb_out_eq;
    wire tb_out_lt;
    wire tb_out_gt;
        
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable
    
    // defining unit under test
    comp_cell uut ( 
    .a(tb_in_a),
    .b(tb_in_b),
    .eq(tb_out_eq),
    .lt(tb_out_lt),
    .gt(tb_out_gt)
    );
    
    // testing vectors
    initial
    begin
        // max value would be 2'b11 due to max a (11)
        for (i = 0; i <= 2'b11; i = i+1)
        begin
        {tb_in_b, tb_in_a} = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule