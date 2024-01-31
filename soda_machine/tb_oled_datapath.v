`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/14/2023 02:37:08 AM
// Design Name: 
// Module Name: tb_oled_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test OLED datapath functionality
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
module tb_oled_datapath(); // tb module has no ports
    parameter WIDTH = 12*8;
    // defining uut local signals
    reg tb_clk;
    reg tb_in_clr_reg;
    reg tb_in_ld_price;
    reg tb_in_ld_cents;
    reg tb_in_ld_coins;
    reg tb_in_ld_disp;
    // more inputs
    reg [7:0] tb_in_soda;
    reg [7:0] tb_in_cents_in;
    reg [7:0] tb_in_coins;
    // outputs
    wire [WIDTH-1:0] tb_out_soda_price;
    wire [WIDTH-1:0] tb_out_coin_val;
    wire [WIDTH-1:0] tb_out_coins_tot;
    wire [WIDTH-1:0] tb_out_disp;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test
    oled_datapath uut (
    .clk(tb_clk),
    .clr_reg(tb_in_clr_reg),
    
    .ld_price(tb_in_ld_price),
    .ld_cents(tb_in_ld_cents),
    .ld_coins(tb_in_ld_coins),
    .ld_disp(tb_in_ld_disp),
    
    .soda(tb_in_soda),
    .cents_in(tb_in_cents_in),
    .coins(tb_in_coins),
    
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
    tb_in_clr_reg = 0;
    
    tb_in_ld_price = 0;
    tb_in_ld_cents = 0;
    tb_in_ld_coins = 0;
    tb_in_ld_disp = 0;
    
    tb_in_soda = 0;
    tb_in_cents_in = 0;
    tb_in_coins = 0;
    # (period*5);
    
    // no reset
    tb_in_clr_reg = 1;
    tb_in_soda = 250;
    tb_in_cents_in = 25;
    tb_in_coins = 50;
    # period;
    // transition to write price
    tb_in_ld_price = 1;
    # (period*2);
    // transition to write coins
    tb_in_ld_cents = 1;
    # (period*2);
    
    // should go to write coins total
    tb_in_ld_coins = 1;
    # (period*2);

    // go to disp
    tb_in_ld_disp = 1;
    # (period*2);
    // should go to init 
    # (period*2);
    // reset
    tb_in_clr_reg = 0;
    # period;
    // no reset
    tb_in_clr_reg = 1;
    tb_in_soda = 150;
    tb_in_cents_in = 10;
    tb_in_coins = 100;
    # period;
    // transition to write price
    tb_in_ld_price = 1;
    # (period*2);
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
