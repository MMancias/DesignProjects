`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/10/2023 08:20:29 PM
// Design Name: 
// Module Name: Rx_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: top module for receiver (fsm and fifo)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Rx_top(
    input CLK50MHZ, // clock signal
    input rst, // reset signal
    input Baud_tick, // tick from baud rate generator
    input D_num, // select number of data bits (7 or 8)
    input S_num, // select number of stop bits (1 or 2)
    input [1:0] Par, // select parity scheme (No, Odd, Even, Invalid)
    input RxD, // receive signal
    input rx_enable, // enable receiver serial line
    input n_RD, // A LOW on this input informs that the CPU is reading data from the UART during a read cycle
    input C_nD, // used to determine if it's a data character or configuration word
    input Clr_EF, // if set (to HIGH), all error flags are cleared 
    
    output Rx_RDY, // set to logic 1 when at least one character is in the RX_ FIFO
    output [7:0] out_data, // outgoing data (data received)
    
    output PE_Fg, // parity error flag
    output FE_Fg, // framing error flag
    output OE_Fg, // overrun error flag
    output n_INT // active-low interrupt output
    );
    
    // local wires for connecting modules
    wire w_rx_done; // carrying the receive done signal
    wire [7:0] w_rx_data;  // carrying the data received to FIFO
    wire [7:0] w_d_out; // data out from FIFO (output data from Rx_top)
    wire w_par_flag; // parity flag signal
    wire w_framing_flag; // framing flag signal
    wire w_empty; // FIFO is empty
    wire w_full; // FIFO is full
    wire w_is_active; // shows if receiver is active (or NOT)
    
    // receiver fsm
    receiver_fsm controller (.clk(CLK50MHZ), .rst(rst), .bd_tick(Baud_tick), // inputs to fsm 
                             .D_num(D_num), .S_num(S_num), .Par(Par), // inputs from control register
                             .rx(RxD), .rx_enable(rx_enable), // input data
                             .d_out(w_rx_data), .rx_done(w_rx_done), .is_active(w_is_active), .par_flag(w_par_flag), .framing_flag(w_framing_flag)); // outputs
                             
    // FIFO
    uart_fifo rx_fifo (.clock(CLK50MHZ), .reset(rst), 
                    .write(w_rx_done), .data_in({2'b00, w_rx_data}),
                    .read(~n_RD && ~C_nD), .data_out(w_d_out), 
                    .empty(w_empty), .full(w_full));
                    
    // assigning Rx_RDY signal: LOW when NOT full, else HIGH 
    assign Rx_RDY = ~w_full ? 1'd0 : 1'd1;
    // assigning flags
    assign PE_Fg = Clr_EF ? 1'd0 : w_par_flag;
    assign FE_Fg = Clr_EF ? 1'd0 : w_framing_flag;
    assign OE_Fg = Clr_EF ? 1'd0 : (w_is_active & w_full) ? 1'd1 : 1'd0;
    // interrupt generation logic
    assign n_INT = (w_framing_flag | w_par_flag | (w_is_active & w_full)) ? 1'b0 : 1'b1;
    
    // assigning data out
    assign out_data = w_d_out;
    
endmodule
