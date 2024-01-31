`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/14/2023 02:06:38 AM
// Design Name: 
// Module Name: oled_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: OLED datapath design. Takes binary input and outputs its equivalent string representation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oled_datapath #(parameter WIDTH = 12*8)( // WIDTH is max size of str for OLED display
    // inputs from oled fsm
    input clk, // clock signal
    input clr_reg, // register clear
    input ld_price, // enable price register
    input ld_cents, // enable cents register
    input ld_coins, // enable coins register
    input ld_disp, // enable dispense register
    // inputs from wrapper or data in
    input [7:0] soda, // cost of soda input
    input [7:0] cents_in, // value of cent input
    input [7:0] coins, // value of coins input
    // outputs (to OLED)
    output [WIDTH-1:0] soda_price, // soda price message for OLED
    output [WIDTH-1:0] coin_val, // cent value message for OLED
    output [WIDTH-1:0] coins_tot, // total coin value message for OLED
    output [WIDTH-1:0] disp // // dispense message for OLED
    );
    // converting data in to its string equivalent
    wire [9:0] bcd_soda;
    wire [9:0] bcd_cents;
    wire [9:0] bcd_coins;
    // wires for storing string values
    wire [23:0] str_soda;
    wire [23:0] str_cents;
    wire [23:0] str_coins;
    // converting inputs to equivalent ASCII values
    // first convert to BCD representation
    bin_to_bcd soda_conv (.bin(soda), .bcd(bcd_soda));
    bin_to_bcd cents_conv (.bin(cents_in), .bcd(bcd_cents));
    bin_to_bcd coins_conv (.bin(coins), .bcd(bcd_coins));
    // converting BCD to text
    bcd_to_text_3 soda_text (.bcd_data(bcd_soda), .text_output(str_soda)); 
    bcd_to_text_3 cents_text (.bcd_data(bcd_cents), .text_output(str_cents)); 
    bcd_to_text_3 coins_text (.bcd_data(bcd_coins), .text_output(str_coins)); 
    // wire storing DISPENSE val
    wire [WIDTH-1:0] disp_val;
    assign disp_val = "*DISPENSED!*";
    
    // wires holding formatted output for OLED
    wire [WIDTH-1:0] w_soda_price;
    assign w_soda_price = {"COST: $", str_soda, "  "};
    
    wire [WIDTH-1:0] w_coin_val;
    assign w_coin_val = {"CENTS: $", str_cents, " "};
    
    wire [WIDTH-1:0] w_coins_tot;
    assign w_coins_tot = {"TOTAL: $", str_coins, " "};

    // registers to store values in
    n_bit_reg #(WIDTH-1) soda_reg (.clk(clk), .rst(clr_reg), .d(w_soda_price), .en(ld_price), .q(soda_price)); // register storing soda price
    n_bit_reg #(WIDTH-1) cents_reg (.clk(clk), .rst(clr_reg), .d(w_coin_val), .en(ld_cents), .q(coin_val)); // register storing cents val
    n_bit_reg #(WIDTH-1) coins_reg (.clk(clk), .rst(clr_reg), .d(w_coins_tot), .en(ld_coins), .q(coins_tot)); // register storing coins total
    n_bit_reg #(WIDTH-1) disp_reg (.clk(clk), .rst(clr_reg), .d(disp_val), .en(ld_disp), .q(disp)); // register storing dispense signal
    
    assign soda_price[WIDTH-1] = 0;
    assign coin_val[WIDTH-1] = 0;
    assign coins_tot[WIDTH-1] = 0;
    assign disp[WIDTH-1] = 0;
endmodule
