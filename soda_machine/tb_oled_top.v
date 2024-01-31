`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 03:07:41 AM
// Design Name: 
// Module Name: tb_oled_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test OLED controller (top) module functionality
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
module tb_oled_top(); // tb module has no ports
    parameter WIDTH = 12*8;
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_in_pb3;
    reg tb_in_pb2;
    reg tb_in_d;
    reg tb_in_char_done;
    
    reg [7:0] tb_in_soda_val; // soda cost value
    reg [7:0] tb_in_cents_in; // cent in value
    reg [7:0] tb_in_coins_val; // total input value
    
    wire [WIDTH-1:0] tb_out_soda_price; // soda price message for OLED
    wire [WIDTH-1:0] tb_out_coin_val; // cent value message for OLED
    wire [WIDTH-1:0] tb_out_coins_tot; // total coin value message for OLED
    wire [WIDTH-1:0] tb_out_disp; // // dispense message for OLED
    
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test
    oled_top uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .pb3(tb_in_pb3),
    .pb2(tb_in_pb2),
    .d(tb_in_d),
    .char_done(tb_in_char_done),
    .soda_val(tb_in_soda_val),
    .cents_in(tb_in_cents_in),
    .coins_val(tb_in_coins_val),
    .soda_price(tb_out_soda_price),
    .coin_val(tb_out_coin_val),
    .coins_tot(tb_out_coins_tot),
    .disp(tb_out_disp)
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
    tb_in_soda_val = 0;
    tb_in_cents_in = 0;
    tb_in_coins_val = 0;
    # (period*5);
    
    // no reset
    tb_rst = 1;
    // transition to write price
    tb_in_pb3 = 1;
    tb_in_soda_val = 200;
    tb_in_cents_in = 5;
    tb_in_coins_val = 75;
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
    tb_in_soda_val = 255;
    tb_in_cents_in = 10;
    tb_in_coins_val = 150;
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

