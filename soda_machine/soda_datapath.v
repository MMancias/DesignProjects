`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/04/2023 03:08:42 PM
// Design Name: 
// Module Name: soda_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: soda dispenser dataflow to determine if input coins is greater than or equal to soda price
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module soda_datapath #(parameter WIDTH = 8) (
    input clk,
    input [WIDTH-1:0] a, // value of input coin
    input [WIDTH-1:0] s, // value of soda
    input tot_ld, // input to total register
    input tot_clr, // input to clear register
    input rst_counter, // reset counter signal
    output tot_lt_s, // comparison output (if lt is 1, it means it's not greater than or equal)
    output [4:0] count // output from counter
    );
    
    // wires for local signals
    wire [WIDTH-1:0] w_tot_out;
    wire [WIDTH-1:0] w_tot_in; // output wire from adder (into register)
    wire w_comp; // output wire from comparator
    wire [2:0] w_ignore; // wire to ground unnecessary ports
    
    wire [4:0] w_count;
    
    assign w_ignore = 3'b000; // grounding unnecessary ports

    // module instantiations
    n_bit_reg #(WIDTH) reg_tot (.d(w_tot_in), .clk(clk), .rst(tot_clr), .en(tot_ld), .q(w_tot_out)); // register used to store sum total

    n_bit_adder #(WIDTH) add (.a(w_tot_out), .b(a), .cin(1'b0), .sum(w_tot_in), .ov_sgn(w_ignore[0])); // adder used to get coin value total
       
    n_bit_compare #(WIDTH) comp (.a(w_tot_out), .b(s), .eq(w_ignore[1]), .lt(w_comp), .gt(w_ignore[2])); // compare used to compare value of soda to total value in
    
    n_bit_counter #(5) counter (.clk(clk), .rst(tot_clr), .en(rst_counter), .count(w_count));

    assign tot_lt_s = w_comp;
    assign count = w_count;
    
endmodule
