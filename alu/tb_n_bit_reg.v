`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/27/2023 01:56:52 PM
// Design Name: 
// Module Name: tb_n_bit_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test n-bit register functionality
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
module tb_n_bit_reg(); // tb module has no ports

    // defining uut local signals
    reg [3:0] tb_in_d;
    reg tb_clk;
    reg tb_rst;
    reg tb_en;
    wire [3:0] tb_out_q;
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // for loop index variable
    
    // defining unit under test
    n_bit_reg #(.WIDTH(4)) uut (
    .d(tb_in_d),
    .clk(tb_clk),
    .rst(tb_rst),
    .en(tb_en),
    .q(tb_out_q)
    );
    
    
    // resetting unit
    initial begin
    tb_rst = 0;
    tb_en = 0;
    end

    // clock signal  
    initial
    begin
    tb_clk = 1'b0;
    forever #(period/2) tb_clk = ~tb_clk;
    end
    
    // testing input combinations
    initial
    begin
    # (period/2) tb_rst = 1; tb_en = 1;
    for (i = 0; i <= 4'b1111; i = i+1) begin // max input is 4'b1111
        tb_in_d = i;
        # (period/2) ;
        tb_en = ~tb_en;
        # (period/2);
    end
    # (period*5) $stop; 
    end

endmodule
