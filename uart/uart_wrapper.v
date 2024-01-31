`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2023 10:54:30 PM
// Design Name: 
// Module Name: uart_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_wrapper(
    input clk,
    input [7:0] sw,
    input [3:0] btn,
    output [3:0] led
    );
    
    wire ground; wire [7:0] ground2;
    assign ground = 1'd0;
    assign ground2 = 8'd0;
    
    wire w_CLK50MHZ;
    // Clock IP
    clk_50MHz clk_50MHz
   (
    // Clock out ports
    .clk_out1(w_CLK50MHZ),     // output clk_out1
    // Status and control signals
    .reset(ground), // input reset
    // Clock in ports
    .clk_in1(clk)      // input clk_in1
    );
    // wires for setting inputs
    wire w_pb0;
    wire w_pb1;
    wire w_pb2;
    wire w_pb3;
    
    
    // pulse edge generators
    synch_edge btn0 (.clk(w_CLK50MHZ), .rst(1'd1), .d(btn[0]), .rise(w_pb0), .fall(ground));
    synch_edge btn1 (.clk(w_CLK50MHZ), .rst(1'd1), .d(btn[1]), .rise(w_pb1), .fall(ground));
    synch_edge btn2 (.clk(w_CLK50MHZ), .rst(1'd1), .d(btn[2]), .rise(w_pb2), .fall(ground));
    synch_edge btn3 (.clk(w_CLK50MHZ), .rst(1'd1), .d(btn[3]), .rise(w_pb3), .fall(ground));
    
    // wire for looping data
    wire w_loop;
    
    // uart 
    UART uart0 (.clk(w_CLK50MHZ), .n_RST(~w_pb0),
                .C_nD(~w_pb1), .n_RD(~w_pb2), .n_WR(~w_pb3), .n_CS(ground), .DATA_IN(sw), 
                .n_INT(ground), .DATA_OUT(ground2), .Rx_RDY(led[0]), .Tx_RDY(led[1]),
                .RxD(w_loop), .TxD(w_loop),
                .PE_Fg(led[2]), .FE_Fg(led[3]));
    
endmodule
