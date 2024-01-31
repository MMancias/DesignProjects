`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/28/2023 01:23:58 PM
// Design Name: 
// Module Name: tb_mod_m_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test mod-m counter functionality
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
module tb_mod_m_counter(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    wire [3:0] tb_out_count;
    wire tb_out_tick;
    
    
    // other local variables
    parameter period = 50; // constant period 50ns
    
    // defining unit under test 
    mod_m_counter uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .count(tb_out_count),
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
    # (period*2)
    
    // reset not active, enable
    tb_rst = 1;
    # (period*20);
    
    // reset active, then not active
    tb_rst = 0;
    # (period*2);
    
    tb_rst = 1;
    # (period*20);
    
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
