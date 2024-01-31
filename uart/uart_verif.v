`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/28/2023 12:36:44 AM
// Design Name: 
// Module Name: uart_verif
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: uart verification design (serial loop connection)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_verif(
    input clk, // input clock
    input n_RST, // Active-low reset input driven from the CPU. It places the UART in an idle mode until it is programmed.
    input C_nD, //  indicates what kind of information is on the DATA bus, LOW: data bus is carrying data character, else status or control word
    input n_RD, // LOW: CPU is reading data or status words from the UART during a read cycle
    input n_WR, // LOW: CPU is writing data or control words to the UART during a write cycle
    input n_CS, // chip select signal which enables the UART. No read or write occur unless this signal is "low"
    input [7:0] DATA_IN, // DATA going into CPU interface (from CPU)
    
    output n_INT, // Active-low interrupt output driven by the UART in case of errors
    output [7:0] DATA_OUT, // DATA coming out from UART (Status reg, or received data)
    
    // signals from other blocks (Rx, Tx)
    output Rx_RDY, // set to logic 1 when at least one character is in the RX_ FIFO
    output Tx_RDY // inform the CPU that the UART can accept a new character for transmission
    );
    // wire for looping data
    wire w_loop;
    
    wire ignore;
    assign ignore = 1'd0;
    
    UART test_design (.clk(clk), .n_RST(n_RST),
                      .C_nD(C_nD), .n_RD(n_RD), .n_WR(n_WR), .n_CS(n_CS), .DATA_IN(DATA_IN), 
                      .n_INT(n_INT), .DATA_OUT(DATA_OUT), .Rx_RDY(Rx_RDY), .Tx_RDY(Tx_RDY),
                      .RxD(w_loop), .TxD(w_loop),
                      .PE_Fg(ignore), .FE_Fg(ignore));
endmodule
