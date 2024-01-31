`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/07/2023 03:30:52 PM
// Design Name: 
// Module Name: soda_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: soda fsm wrapper for implementation in Zybo Board
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module soda_wrapper(
    input clk, // input clock
    input [3:0] pb, // pushbuttons
    input [3:0] sw, // switches
    output [3:0] led, // leds (used for debugging)
    output [3:0] ja_p, // PMOD Pins 1-4.
    output [3:0] ja_n // PMOD Pins 7-10.
    );
    
    // clock and synchronizer wires
    wire w_10kHz; // wire needed for 10kHz clock signal
    wire w_pb0; // synched pushbutton 0
    wire w_pb1; // synched pushbutton 1
    wire w_pb2; // synched pushbutton 2
    wire w_pb3; // synched pushbutton 3
    
    wire w_pb3_fall; // falling edge of pb3
    wire w_pb2_fall; // falling edge of pb2
    
    // ignore wire for unnecessary ports
    wire w_ignore;
    assign w_ignore = 1'b0;
    // synchronizing pushbuttons
    
    synch_edge synch_pb1 (.clk(~w_10kHz), .rst(~pb[0]), .d(pb[1]), .rise(w_pb1), .fall(w_ignore)); // synchronizing pushbutton1
    synch_edge synch_pb2 (.clk(~w_10kHz), .rst(~pb[0]), .d(pb[2]), .rise(w_pb2), .fall(w_pb2_fall)); // synchronizing pushbutton2
    synch_edge synch_pb3 (.clk(~w_10kHz), .rst(~pb[0]), .d(pb[3]), .rise(w_pb3), .fall(w_pb3_fall)); // synchronizing pushbutton3
    
    // generating 10kHz clock
    clk_div #(.fout(10_000)) fsm_clk (.clk(clk), .rst(1'b1), .clk_out(w_10kHz));
    
    // register wires
    wire [7:0] w_cents; // wire to store cents values 
    wire w_sel; // select between enable for coin or soda price reg 
    
    // mux to select cents from switches
    assign w_cents = (sw[2]) ? 8'd25 : (sw[1]) ? 8'd10 : (sw[0]) ? 8'd5 : 8'd0;
    
    // data input register output wires
    wire [7:0] w_coins; // wire carrying coin values
    wire [7:0] w_soda; // wire carrying total soda price
    wire [7:0] w_price_temp; // wire carrying temporary soda price values (from inputs sw[2:0])
    wire [7:0] w_soda_sum; // output from adder for setting soda price 
    
    // registers to store coin and soda values
    n_bit_reg #(8) coin_vals (.d(w_cents), .clk(w_10kHz), .rst(~pb[0]), .en(w_pb2), .q(w_coins)); // register holding coin values for fsm
    
    // registers and adder needed for setting total soda value
    n_bit_adder #(8) add_vals (.a(w_cents), .b(w_price_temp), .cin(1'b0), .sum(w_soda_sum), .ov_sgn(w_ignore)); // adder for totaling soda price
    n_bit_reg #(8) soda_vals (.d(w_soda_sum), .clk(w_10kHz), .rst(~pb[0]), .en(w_pb1), .q(w_price_temp)); // register holding values in for soda price
    n_bit_reg #(8) soda_tot (.d(w_price_temp), .clk(w_10kHz), .rst(~pb[0]), .en(w_pb3), .q(w_soda)); // register holding total soda price for fsm
    // fsm wires
    wire d_out;
    wire w_init_done;
    // fsm module
    soda_top soda_machine (.clk(w_10kHz), .rst(~pb[0]), .c(w_pb2), .a(w_coins), .s(w_soda), .init_done(w_init_done), .pb3(w_pb3),
                           .d(d_out));
    
    // leds used for debugging
    assign led[0] = d_out;
    assign led[3] = w_coins[0];
    /** OLED implementation **/
    
    // wires
    wire w_char_done;
    wire [7:0] w_coins_tot_temp;
    wire [7:0] w_coins_tot;
    
    wire [(12*8)-1:0] price_soda;
    wire [(12*8)-1:0] val_cents;
    wire [(12*8)-1:0] val_coins;
    wire [(12*8)-1:0] str_dispense;
    
    // registers and adder needed for setting total soda value
    n_bit_adder #(8) add_coins (.a(w_cents), .b(w_coins_tot), .cin(1'b0), .sum(w_coins_tot_temp), .ov_sgn(w_ignore)); // adder for totaling coins in
    n_bit_reg #(8) coins_tot (.d(w_coins_tot_temp), .clk(w_10kHz), .rst(~pb[0]), .en(w_pb2), .q(w_coins_tot)); // register holding values in for total coins
    // oled controller
    oled_top oled_control (.clk(w_10kHz), .rst(~pb[0]), .pb3(w_pb3), .pb2(w_pb2), .d(d_out), .char_done(w_char_done),
                           .soda_val(w_soda), .cents_in(w_cents), .coins_val(w_coins_tot), 
                           .soda_price(price_soda), .coin_val(w_ignore), .coins_tot(val_coins), .disp(str_dispense));
    
    // wire for characters
    wire [(12 * 8) - 1:0] characters;
    wire [(12 * 8) - 1:0] characters_soda_coins;
    
    // wire for writing characters
    wire char_valid; // wire for selecting writing characters to OLED
    assign char_valid = sw[3] ? w_pb3_fall : w_pb2_fall;
    
    // dispense signal wires
    wire d_signal;
    n_bit_reg #(1) disp_signal (.d(d_out), .clk(w_10kHz), .rst(~pb[0]), .en(d_out), .q(d_signal)); // register holding dispense signal (keep high until reset)
    
    oled_driver #(
    .CLOCK_FREQUENCY (5_000_000)) // Must be slower than 12 MHz.
    oled (

    // System Signals:
    .clock     (w_10kHz),
    .reset_n   (~pb[0]),

    // SPI:
    .cs  (ja_p[0]), // PMOD Pin 1.
    .mosi(ja_p[1]), // PMOD Pin 2.
    .sck (ja_p[3]), // PMOD Pin 4.

    // OLED Signals:
    .dc       (ja_n[0]), // PMOD Pin 7.
    .res      (ja_n[1]), // PMOD Pin 8.
    .vccen    (ja_n[2]), // PMOD Pin 9.
    .pmoden   (ja_n[3]), // PMOD Pin 10.

    // Done Signals:
    .init_done      (w_init_done),
    .characters_done(w_char_done),
    
    .characters      (characters),
    .characters_valid(char_valid)

  );

    // Assign the character array to some test values.
    assign characters_soda_coins = (sw[3]) ? price_soda : val_coins;
    
    assign characters = d_signal ? str_dispense : characters_soda_coins;
    
    // more debugging
    assign led[1] = ~w_init_done;
    assign led[2] = w_char_done;
    
endmodule
