`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/05/2023 03:12:30 PM
// Design Name: 
// Module Name: tb_full_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test full adder functionality
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// setting sim time unit 1ns
// and sim timestep 10ps
`timescale 1 ns/10 ps
// testbench module has no ports
module tb_full_adder;
    // index of for loop
    integer i;
    //signal declarations
    reg tb_in_a;
    reg tb_in_b;
    reg tb_in_cin;
    wire tb_out_cout;
    wire tb_out_sum;
    // other declaration
    parameter period=10; // a constant value of 10ns
    // instantiate the unit under test
    full_adder uut (
    // assigning tb signals to full_adder ports
    .a(tb_in_a),    
    .b(tb_in_b),
    .cin(tb_in_cin),
    .cout(tb_out_cout),
    .sum(tb_out_sum)
    );
    //in-line stimulus
    initial
    begin
    // testing all possible combinations
    for (i = 0; i <= 3'b111; i = i+1)
        begin
        {tb_in_a, tb_in_b, tb_in_cin} = i;
        # period;
        end
    # (period*5) $stop;
    end // of initial block
endmodule
