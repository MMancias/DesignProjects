`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2023 05:35:40 PM
// Design Name: 
// Module Name: tb_comp_cell_2bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
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
module tb_comp_cell_2bit(); // tb module has no ports

    // defining uut local signals
    reg [1:0] tb_in_a;
    reg [1:0] tb_in_b;
    wire tb_out_eq;
    wire tb_out_lt;
    wire tb_out_gt;
        
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable
    
    // defining unit under test
    comp_cell_2bit uut ( 
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
        for (i = 0; i <= 4'b1111; i = i+1)
        begin
        {tb_in_b, tb_in_a} = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
