`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/05/2023 03:45:40 PM
// Design Name: 
// Module Name: tb_soda_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test soda dispenser finite state machine functionality
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
module tb_soda_fsm(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_in_tot_lt_s;
    reg tb_in_c;
    reg [3:0] tb_in_count;
    reg tb_in_init_done;
    reg tb_in_pb3;
    wire tb_out_d;
    wire tb_out_tot_clr;
    wire tb_out_tot_ld;
    wire tb_out_rst_counter;
    
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test
    soda_fsm uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .tot_lt_s(tb_in_tot_lt_s),
    .c(tb_in_c),
    .count(tb_in_count),
    .pb3(tb_in_pb3),
    .d(tb_out_d),
    .rst_counter(tb_out_rst_counter),
    .init_done(tb_in_init_done),
    .tot_clr(tb_out_tot_clr),
    .tot_ld(tb_out_tot_ld)
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
    // resetting fsm and setting default values
    tb_rst = 0;
    tb_in_c = 0;
    tb_in_pb3 = 0;
    tb_in_init_done = 0;
    tb_in_tot_lt_s = 1;
    tb_in_count = 4'd15;
    # (period*5);
    
    // no reset
    tb_rst = 1;
    // transition to listen
    tb_in_init_done = 1;
    # (period*2);
    tb_in_pb3 = 1;
    # (period*2);
    // transition to add
    tb_in_c = 1;
    # (period*2);
    
    // stay in wait
    tb_in_c = 0;
    tb_in_tot_lt_s = 1;
    # (period*2);

    // go to disp
    tb_in_c = 0;
    tb_in_tot_lt_s = 0;
    # (period*2);
    tb_in_count = 0;
    # (period*5);
    
    // go back to init (after count is greater than 10)
    tb_in_count = 4'd15;
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
