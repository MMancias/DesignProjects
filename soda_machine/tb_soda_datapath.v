`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/04/2023 09:12:50 PM
// Design Name: 
// Module Name: tb_soda_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test soda machine dataflow functionality
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
module tb_soda_datapath(); // tb module has no ports

    // defining uut local signals
    reg tb_clk;
    reg [3:0] tb_in_a;
    reg [3:0] tb_in_s;
    reg tb_in_tot_ld;
    reg tb_in_tot_clr;
    reg tb_in_rst_counter;
    wire tb_out_lt_s;
    wire [3:0] tb_out_count;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // index variable in for loop
    
    // defining unit under test
    soda_datapath #(4) uut (
    .clk(tb_clk),
    .a(tb_in_a),
    .s(tb_in_s),
    .tot_ld(tb_in_tot_ld),
    .tot_clr(tb_in_tot_clr),
    .rst_counter(tb_in_rst_counter),
    .tot_lt_s(tb_out_lt_s),
    .count(tb_out_count)
    );

    // clock signal  
    initial
    begin
    tb_clk = 1'b0;
    forever #(period/2) tb_clk = ~tb_clk;
    end
      
    // testing input combinations
    initial
    begin
    // resetting register, counter and setting value of soda
    tb_in_tot_clr = 0;
    tb_in_tot_ld = 0;
    tb_in_rst_counter = 0;
    tb_in_s = 4'd15;
    # (period*5);
    // enabling register and setting input a default value
    tb_in_tot_clr = 1;
    tb_in_tot_ld = 1;
    tb_in_a = 4'd0;
    tb_in_rst_counter = 1;
    # period;
    
    // testing output functionality
    // WARNING: infinite for loop
    for (i = 0; i <= 4'b1111; i = i+1) begin
        tb_in_a = i;
       
        # (period*4);
        // i matches value of soda, reset
        if (i == 4'b1111)
            i = 0;
    end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
