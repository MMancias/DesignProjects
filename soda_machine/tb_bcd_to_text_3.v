`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 01:25:46 AM
// Design Name: 
// Module Name: tb_bcd_to_text_3
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
module tb_bcd_to_text_3(); // tb module has no ports

    // defining uut local signals
    reg [9:0] tb_in_bcd_data;
    wire [23:0] tb_out_text_output;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable in for loop
    
    // defining unit under test
    bcd_to_text_3 uut (
    .bcd_data(tb_in_bcd_data),
    .text_output(tb_out_text_output)
    );
    // testing input combinations
    initial
    begin
        for (i = 0; i <= 10'b1111111111; i = i+1) begin
        tb_in_bcd_data = i;
        # period;
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
