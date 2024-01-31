`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/06/2023 10:03:07 PM
// Design Name: 
// Module Name: tb_soda_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test soda dispenser top module functionality
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
module tb_soda_top(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_in_c;
    reg tb_in_init_done;
    reg tb_in_pb3;
    reg [7:0] tb_in_a;
    reg [7:0] tb_in_s;
    wire tb_out_d;
    
    // other local variables
    parameter period = 10; // constant period 10ns
    parameter nickel = 5; // nickel value ($0.05)
    parameter dime = 10; // dime value ($0.10)
    parameter quarter = 25; // quarter value ($0.25)
    
    // defining unit under test
    soda_top uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .c(tb_in_c),
    .init_done(tb_in_init_done),
    .a(tb_in_a),
    .s(tb_in_s),
    .pb3(tb_in_pb3),
    .d(tb_out_d)
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
    # period;
    // reset not-active
    tb_rst = 1;
    tb_in_init_done = 0;
    tb_in_pb3 = 0;
    tb_in_s = (6*quarter); // $1.50
    # period;
    
    // reset active
    tb_rst = 0;
    tb_in_c = 0;
    tb_in_a = 0;
    # period;
    
    // reset not-active fsm and setting default values
    tb_rst = 1;
    tb_in_c = 0;
    tb_in_a = 0;
    # (period*2);
    
    // transition to add (not happening because init_done is 0)
    tb_in_c = 1;
    # period;
    tb_in_a = (4*quarter) + (5*dime) + (3*nickel); // $1.65
    # (period*2);
    
    // transition back and based on condition (a >= s) dispense
    tb_in_c = 0;
    # (period*2);

    // resetting fsm and setting new soda price
    tb_rst = 0;
    # period;
    tb_in_s = 0; 
    # period;
    
    // reset not-active, default a value
    tb_rst = 1;
    tb_in_a = 0;
    tb_in_c = 0;
    # period;
    
    // stay in init, go to listen when soda price is ready (pb3 is pushed/high)
    tb_in_init_done = 1;
    # (period*2);
    
    // setting soda price
    tb_in_pb3 = 1;
    tb_in_s = (3*quarter) + (4*dime) + (5*nickel); // $1.40
    # period;
    
    // transition to add
    tb_in_pb3 = 0;
    tb_in_c = 1;
    tb_in_a = nickel; // $0.05
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = nickel; // $0.10
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = dime; // $0.20
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = dime; // $0.30
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = dime; // $0.40
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = quarter; // $0.65
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = quarter; // $0.90
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = quarter; // $1.15
    # (period*2);
    
    // transition to add
    tb_in_c = 1;
    tb_in_a = quarter; // $1.40
    # (period*2);
    
    // transition back and based on condition (a >= s) dispense
    tb_in_c = 0;
    # (period*30);
    
    # (period*30) $stop; // run 5 more periods and stop
    end

endmodule
