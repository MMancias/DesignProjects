`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/06/2023 09:19:10 PM
// Design Name: 
// Module Name: soda_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: top module to integrate soda machine fsm and dataflow modules
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module soda_top #(parameter WIDTH = 8)(
    input clk, // input clock
    input rst, // global reset
    input c, // coin in signal
    input init_done, // OLED signal
    input [WIDTH-1:0] a, // value of coin input
    input [WIDTH-1:0] s, // value of soda input
    input pb3, // pushbutton 3 input signal
    output d // dispense soda signal
    );
    
    // local wires
    wire w_tot_clr; // wire carrying reset signal from fsm to dataflow
    wire w_tot_ld; // wire carrying load (enable) signal from fsm to dataflow
    wire w_tot_lt_s; // wire carrying comparator signal from dataflow to fsm
    wire w_out_d; // dispense signal wire
    wire [4:0] w_count; // count signal from datapath
    wire w_rst_counter; // reset counter signal
    
    // module instantiations
    soda_fsm controller (.clk(clk), .rst(rst), .tot_lt_s(w_tot_lt_s), .c(c), .init_done(init_done), .count(w_count), .pb3(pb3),
                         .tot_ld(w_tot_ld), .d(w_out_d), .rst_counter(w_rst_counter), .tot_clr(w_tot_clr)); // fsm module
                         
    soda_datapath datapath (.clk(clk), .a(a), .s(s), .tot_ld(w_tot_ld), .tot_clr(~w_tot_clr), .rst_counter(w_rst_counter), 
                            .tot_lt_s(w_tot_lt_s), .count(w_count)); // datapath module
    
    assign d = w_out_d;
    
endmodule
