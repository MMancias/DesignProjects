`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/29/2023 03:01:03 PM
// Design Name: 
// Module Name: alu_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: top block for alu implementation on Zybo board
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_top(
    input clk, // input clock
    input [3:0] pb, // pushbuttons (used to load data into registers)
    input [3:0] sw, // switches (used for data input, function selection, and output mux)
    output [3:0] led // output result is shown in LEDs
    );
    
    // local wires
    wire w_clk_in; // to be used as input clock signal for top module
    
    // pushbutton synch
    wire w_pb1; // pb1 wire
    wire w_pb2; // pb2 wire
    wire w_pb3; // pb3 wire
    
    // input data wires
    wire [3:0] a_data; // used to store input a
    wire [3:0] b_data; // used to store input b
    // output data
    wire [4:0] led_data; // used to store ALU output
    wire [4:0] led_out; // used for output
    
    // clock divider
    clk_div #(.fout(25_000)) in_clk (.clk(clk), .rst(~pb[0]), .clk_out(w_clk_in)); // generating 25kHz clock
    
    // function select
    wire [2:0] w_func_sel;
    assign w_func_sel = sw[2:0]; // storing functon select
    wire w_rot_sel;
    assign w_rot_sel = sw[3]; // storing rotate selection
    
    // synch
    synch_edge pb1_dge_to_pulse (.clk(~w_clk_in), .rst(~pb[0]), .d(pb[1]), .rise(w_pb1), .fall(~w_pb1)); // synching PB1
    synch_edge pb2_dge_to_pulse (.clk(~w_clk_in), .rst(~pb[0]), .d(pb[2]), .rise(w_pb2), .fall(~w_pb2)); // synching PB2
    synch_edge pb3_dge_to_pulse (.clk(~w_clk_in), .rst(~pb[0]), .d(pb[3]), .rise(w_pb3), .fall(~w_pb3)); // synching PB3
    
    // registers storing inputs a, b, and output leds
    n_bit_reg #(.WIDTH(4)) a_reg (.d(sw), .clk(w_clk_in), .rst(~pb[0]), .en(w_pb1), .q(a_data)); // register to hold input a
    n_bit_reg #(.WIDTH(4)) b_reg (.d(sw), .clk(w_clk_in), .rst(~pb[0]), .en(w_pb2), .q(b_data)); // register to hold input b
    n_bit_reg #(.WIDTH(5)) out_reg (.d(led_data), .clk(w_clk_in), .rst(~pb[0]), .en(w_pb3), .q(led_out)); // register to hold output
    
    // ALU block instantiation
    alu #(.WIDTH(4)) alu_0 (.a(a_data), .b(b_data), .func_sel({w_rot_sel, w_func_sel}), .r(led_data[3:0]), .ov_sgn(led_data[4]));
    
    // led mux
    assign led = sw[3] ? led_out[4] : led_out[3:0]; // if sw3 is 1, output ov or sign, else output result value
    
    
    
endmodule
