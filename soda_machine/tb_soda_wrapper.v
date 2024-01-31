`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/09/2023 08:20:23 PM
// Design Name: 
// Module Name: tb_soda_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test soda fsm wrapper functionality
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
module tb_soda_wrapper(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg [3:0] tb_in_pb;
    reg [3:0] tb_in_sw;
    wire [3:0] tb_out_led;
    
    
    // other local variables
    parameter period = 100; // constant period 100ns
    
    // defining unit under test
    soda_wrapper uut (
    .clk(tb_clk),
    .pb(tb_in_pb),
    .sw(tb_in_sw),
    .led(tb_out_led)
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
    # (period*10);
    // reset not-active, price mode, set switches to zero
    tb_in_pb[0] = 0;
    tb_in_sw = 0;
    tb_in_pb[3:1] = 0;
    # (period*10);
    // reset active, price mode, set switches to zero
    tb_in_pb[0] = 1;
    # (period*10);
    tb_in_sw[3] = 1;
    tb_in_sw[2:0] = 0;
    tb_in_pb[1] = 1;
    tb_in_pb[3] = 1;
    # (period*10);
    // set coin value to zero
    tb_in_sw[3] = 0;
    tb_in_sw[2:0] = 0;
    tb_in_pb[2] = 1;
    # (period*10);
    // reset and set soda value
    tb_in_pb[0] = 1;
    tb_in_pb[3:0] = 0;
    tb_in_sw = 0;
    # (period*10);
    // setting soda value
    tb_in_sw[3] = 1;
    tb_in_sw[1] = 1;
    tb_in_pb[1] = 1;
    tb_in_pb[3] = 1;
    # (period*10);
    // set coin value
    tb_in_sw = 0;
    tb_in_pb = 0;
    # (period*10);
    tb_in_sw[3] = 0;
    tb_in_sw[2] = 1;
    tb_in_pb[2] = 1;
    
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
