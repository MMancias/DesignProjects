`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/18/2023 06:35:17 PM
// Design Name: 
// Module Name: Tx_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: uart transmitter top level design
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Tx_top(
    input CLK50MHZ, // clock signal
    input rst, // reset signal
    input Baud_tick, // tick from baud rate generator
    input D_num, // select number of data bits (7 or 8)
    input S_num, // select number of stop bits (1 or 2)
    input [1:0] Par, // select parity scheme (No, Odd, Even, Invalid)
    input [7:0] DATA, // data coming from CPU to Tx_FIFO
    input n_WR, // A LOW on this input informs that the CPU is writing data to the UART during a write cycle
    input C_nD, // used to determine if it's a data character or configuration word
    output TxD, // serial transmission line
    output Tx_RDY // inform the CPU that the UART can accept a new character for transmission
    );
    
    // local wires
    wire w_full; // FIFO is full
    wire w_empty; // FIFO is empty
    wire [9:0] tx_data; // data to be transmitted from FIFO
    wire read_enable; // HIGH if Tx_FIFO has data (not empty), then alert tx_fsm to transmit data
    assign read_enable = (~w_empty) ? 1'd1 : 1'd0; // If FIFO is not empty, enable transmission
    
    wire w_tx_done; // transmission is done
    wire w_tx; // bit being transmitted
    wire w_is_active; // wire carrying active signal
    
    // module instantiation
    
    transmitter_fsm controller (.clk(CLK50MHZ), .rst(rst), .bd_tick(Baud_tick), // inputs to FSM
                                .D_num(D_num), .S_num(S_num), .Par(Par), // inputs from control register
                                .ready(read_enable), .d_in(tx_data[7:0]), .tx_start(1'd1), // input data
                                .tx(w_tx), .tx_done(w_tx_done), .is_active(w_is_active)); // outputs
    
    // FIFO
    uart_fifo tx_fifo (.clock(CLK50MHZ), .reset(rst), 
                    .write(~n_WR && ~C_nD), .data_in({2'b00, DATA}),
                    .read(read_enable), .data_out(tx_data), 
                    .empty(w_empty), .full(w_full));
                    
    // Tx_RDY signal is HIGH when UART can accept a new character, i.e., NOT full
    assign Tx_RDY = ~(w_is_active & ~w_full);
    // assigning transmission line, when FIFO is NOT empty, enable transmission line
    assign TxD = w_is_active ? w_tx : 1'd1;
endmodule
