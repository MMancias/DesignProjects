`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/16/2023 07:29:05 PM
// Design Name: 
// Module Name: synch_edge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: module for synchronizer with edge detection. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module synch_edge(
    input clk,
    input rst,
    input d,
    output rise,
    output fall
    );
    
    // local signals
    // output from first d-type flip flop
    wire w_sync;
    // output from second flip flop
    wire w_out_c1;
    // output from third flip flop
    wire w_out_c2;
   
    // module instantiations
    // synchronizing flip flop
    d_ff sync (.d(d), .clk(clk), .rst(rst), .q(w_sync));
    // compare reg 1
    d_ff c1 (.d(w_sync), .clk(clk), .rst(rst), .q(w_out_c1));
    // compare reg 2
    d_ff c2 (.d(w_out_c1), .clk(clk), .rst(rst), .q(w_out_c2));
    
    // comparison signal
    assign rise = w_out_c1 & ~w_out_c2; 
    assign fall = ~w_out_c1 & w_out_c2; 
endmodule
