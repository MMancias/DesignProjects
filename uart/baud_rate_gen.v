`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/29/2023 01:22:58 PM
// Design Name: 
// Module Name: baud_rate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: baud rate generator using mod-m counter, this baud tick is the sampling rate signal
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_rate_gen (
    input clk, // clock signal
    input rst, // reset signal
    input [1:0] BD_Rate, // select Baud Rate 
    output tick // output signal (every mod M)
    );
    // baud rate related wires
    localparam WIDTH = $clog2(814); // max width needed for baud rates
    wire [WIDTH-1:0] bd_rate_mod;
    // wires containing mod value
    wire [WIDTH-1:0] mod_115_200;
    wire [WIDTH-1:0] mod_57_600;
    wire [WIDTH-1:0] mod_19_200;
    wire [WIDTH-1:0] mod_9_600;
    
    // mod values based on baud rate
    // these values are calculated based on the formula
    // counter_val = CLK_FREQ / (baud_rate * 16), where CLK_FREQ is 125MHz
    assign mod_115_200 = 10'd68;
    assign mod_57_600 = 10'd136;
    assign mod_19_200 = 10'd407;
    assign mod_9_600 = 10'd814;
    // mux to select baud rate mod value
    assign bd_rate_mod = BD_Rate[1] ? (BD_Rate[0] ? mod_115_200 : mod_57_600) : (BD_Rate[0] ? mod_19_200 : mod_9_600);
    
    // local wires
    wire w_tick;
    wire [WIDTH-1:0] ignore;
    assign ignore = 9'd0;
    
    // instantiating mod-M counter
    mod_m_counter #(WIDTH) counter (.clk(clk), .rst(rst), .M2(bd_rate_mod),
                                    .count(ignore), .tick(w_tick));
    // assigning output tick                 
    assign tick = w_tick;
    
endmodule
