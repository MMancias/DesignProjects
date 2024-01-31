`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/15/2023 02:16:47 AM
// Design Name: 
// Module Name: oled_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: top levevl design for OLED fsm and datapath
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oled_top #(parameter WIDTH = 12*8) (
    input clk, // input clk
    input rst, // reset signal
    input pb3, // pushbutton 3 (from wrapper)
    input pb2, // pushbutton 2 (from wrapper)
    input d, // dispense signal from soda fsm
    input char_done, // character done writing (from OLED)
    
    input [7:0] soda_val, // soda cost value
    input [7:0] cents_in, // cent in value
    input [7:0] coins_val, // total input value
    
    output [WIDTH-1:0] soda_price, // soda price message for OLED
    output [WIDTH-1:0] coin_val, // cent value message for OLED
    output [WIDTH-1:0] coins_tot, // total coin value message for OLED
    output [WIDTH-1:0] disp // // dispense message for OLED
    );
    
    // wires for connecting fsm to datapath
    wire w_clr_reg;
    wire w_ld_price;
    wire w_ld_cents;
    wire w_ld_coins;
    wire w_ld_disp;
    
    // module instantiation
    oled_fsm controller (.clk(clk), .rst(rst), .pb3(pb3), .pb2(pb2), .d(d), .char_done(char_done), 
                         .clr_reg(w_clr_reg), .ld_price(w_ld_price), .ld_cents(w_ld_cents), .ld_coins(w_ld_coins), .ld_disp(w_ld_disp));
                         
    oled_datapath data (.clk(clk), .clr_reg(~w_clr_reg), .ld_price(w_ld_price), .ld_cents(w_ld_cents), .ld_coins(w_ld_coins), .ld_disp(w_ld_disp),
                        .soda(soda_val), .cents_in(cents_in), .coins(coins_val),
                        .soda_price(soda_price), .coin_val(coin_val), .coins_tot(coins_tot), .disp(disp));
endmodule
