`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/29/2023 01:58:07 PM
// Design Name: 
// Module Name: tb_baud_rate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test baud rate generator
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
module tb_baud_rate_gen(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg [1:0] tb_BD_Rate;
    wire tb_out_tick;
    
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test 
    baud_rate_gen uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .BD_Rate(tb_BD_Rate),
    .tick(tb_out_tick)
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
    // resetting counter
    tb_rst = 0;
    tb_BD_Rate = 2'b01;
    # (period*2)
    
    // reset not active, enable
    tb_rst = 1;
    # (period*400);
    
    // reset active, then not active
    tb_rst = 0;
    # (period*2);
    
    tb_rst = 1;
    # (period*800);
    
    tb_BD_Rate = 2'b11;
    # (period*1600);
    
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule

