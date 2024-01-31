`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/11/2023 04:37:41 PM
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: clock divider module. Counter counts down from scale factor. Default frequency is 1Hz.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module clk_div(
    input clk, // clock signal in
    input rst, // reset signal
    output reg clk_out // clock signal out (divided clock)
    );
    
    // parameters
    parameter fout = 1; // desired frequency out
    parameter scale = (125_000_000)/fout; // scale factor needed to divide clock (fin is 125Mhz for Zybo board)
    parameter k_bit = $clog2(scale);
    
    // internal counter
    reg [k_bit-1:0] count = scale / 2; // used to count down to calculated scale factor
    
    always @(posedge clk, negedge rst)
        if (!rst) // reset == 0, reset pressed
        begin
        count <= scale / 2;
        clk_out <= 1'b0;
        end
    
        else 
        begin
            if (!count) // if counter is done, count = 0
            begin
            clk_out <= ~clk_out; // toggle clock out
            count <= scale / 2; // reset counter
            end
            
            else // counter is not done, keep counting
            begin
            count <= count - 1'b1; // keep counting down
            end
     end
      
endmodule
