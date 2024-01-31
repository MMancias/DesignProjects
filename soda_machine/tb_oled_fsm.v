`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias 
// 
// Create Date: 10/14/2023 01:40:23 AM
// Design Name: 
// Module Name: tb_oled_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test OLED fsm functionality
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
module tb_oled_fsm(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_in_pb3;
    reg tb_in_pb2;
    reg tb_in_d;
    reg tb_in_char_done;
    wire tb_out_clr_reg;
    wire tb_out_ld_price;
    wire tb_out_ld_cents;
    wire tb_out_ld_coins;
    wire tb_out_ld_disp;
    
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test
    oled_fsm uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .pb3(tb_in_pb3),
    .pb2(tb_in_pb2),
    .d(tb_in_d),
    .char_done(tb_in_char_done),
    .clr_reg(tb_out_clr_reg),
    .ld_price(tb_out_ld_price),
    .ld_cents(tb_out_ld_cents),
    .ld_coins(tb_out_ld_coins),
    .ld_disp(tb_out_ld_disp)
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
    tb_in_pb3 = 0;
    tb_in_pb2 = 0;
    tb_in_d = 0;
    tb_in_char_done = 0;
    # (period*5);
    
    // no reset
    tb_rst = 1;
    // transition to write price
    tb_in_pb3 = 1;
    # (period*2);
    // transition to write coins
    tb_in_char_done = 1;
    # (period*2);
    tb_in_pb3 = 0;
    tb_in_pb2 = 1;
    tb_in_char_done = 0;
    # (period*2);
    
    // should go to write coins total
    tb_in_char_done = 1;
    # (period*2);
    tb_in_pb2 = 0;
    tb_in_char_done = 0;
    # (period*2);

    // go to disp
    tb_in_char_done = 1;
    # (period/2);
    tb_in_char_done = 1;
    tb_in_d = 1;
    # (period*2);
    // should go to init
    tb_in_char_done =  1;
    tb_rst = 0;
    # (period*2);
    
    // second run this time NOT going to disp
    tb_rst = 1;
    # period;
    // transition to write price
    tb_in_pb3 = 1;
    # (period*2);
    // transition to write coins
    tb_in_char_done = 1;
    # (period*2);
    tb_in_pb3 = 0;
    tb_in_pb2 = 1;
    tb_in_char_done = 0;
    # (period*2);
    
    // should go to write coins total
    tb_in_char_done = 1;
    # (period*2);
    tb_in_pb2 = 0;
    tb_in_char_done = 0;
    # (period*2);

    // go to write_price
    tb_in_char_done = 1;
    tb_in_d = 0;
    # (period/2);
    tb_in_char_done = 1;
    # (period*2);
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule

