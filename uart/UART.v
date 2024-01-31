`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/24/2023 04:14:32 PM
// Design Name: 
// Module Name: UART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART top module 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART(
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
    output Tx_RDY, // inform the CPU that the UART can accept a new character for transmission
    
    // signals for Rx and Tx
    input RxD, // serial receive line
    output TxD, // serial transmit line
    
    // output signals for board implementation
    output PE_Fg,
    output FE_Fg
    );
    
    // clock wires
    wire w_CLK50MHZ;
    // wires for connecting blocks CPU CR to transmitter and receiver blocks
    wire [7:0] w_CR; // control register data
    wire [1:0] bd_rate; // baud rate
    wire d_num; // # of data bits
    wire s_num; // # of stop bits
    wire [1:0] par; // parity data
    wire clr_ef; // 7th bit (index 6) of control register
    
    assign bd_rate = w_CR[1:0];
    assign d_num = w_CR[2];
    assign s_num = w_CR[3];
    assign par = w_CR[5:4];
    assign clr_ef = w_CR[6];
    
    // wires from Tx to CPU IF
    wire [7:0] w_Tx_data;
    wire w_Tx_RDY;
    // wires from Rx to CPU IF
    wire [7:0] w_Rx_data;
    wire w_Rx_RDY;
    wire w_PE_Fg;
    wire w_FE_Fg;
    wire w_OE_Fg;
    // baud generator wire
    wire w_baud_tick;
    // modules
    assign w_CLK50MHZ = clk;
    // Clock IP (clock IP may be used for wrapper instead)
//    clk_50MHz clk_50MHz
//   (
//    // Clock out ports
//    .clk_out1(w_CLK50MHZ),     // output clk_out1
//    // Status and control signals
//    .reset(n_RST), // input reset
//   // Clock in ports
//    .clk_in1(clk)      // input clk_in1
//    );
    // CPU Interface block
    cpu_if CPU_IF_BLOCK (.CLK50MHZ(w_CLK50MHZ), .n_RST(n_RST), .C_nD(C_nD), .n_RD(n_RD), .n_WR(n_WR), .n_CS(n_CS),
                         .DATA_IN(DATA_IN), .DATA_Rx(w_Rx_data),
                         .Rx_RDY(w_Rx_RDY), .Tx_RDY(w_Tx_RDY), .PE_Fg(w_PE_Fg), .FE_Fg(w_FE_Fg), .OE_Fg(w_OE_Fg),
                         .DATA_OUT(DATA_OUT), .DATA_Tx(w_Tx_data), .DATA_CR(w_CR));
                         
    // Baud Rate Generator
    baud_rate_gen Baud_Rate_Generator (.clk(w_CLK50MHZ), .rst(n_RST), 
                                       .BD_Rate(bd_rate),
                                       .tick(w_baud_tick));
                                       
    // Transmitter Block
    Tx_top Tx_Block (.CLK50MHZ(w_CLK50MHZ), .rst(n_RST), .Baud_tick(w_baud_tick), .n_WR(n_WR), .C_nD(C_nD),
                     .D_num(d_num), .S_num(s_num), .Par(par), .DATA(w_Tx_data),
                     .TxD(TxD), .Tx_RDY(w_Tx_RDY));
    // maybe rx_enable could be ~TxD? (since TxD is high until it starts transmitting)
    // Receiver Block
    Rx_top Rx_Block (.CLK50MHZ(w_CLK50MHZ), .rst(n_RST), .Baud_tick(w_baud_tick), .n_RD(n_RD), .C_nD(C_nD), .Clr_EF(clr_ef),
                     .D_num(d_num), .S_num(s_num), .Par(par),
                     .RxD(RxD), .rx_enable(1'd1),
                     .Rx_RDY(w_Rx_RDY), .out_data(w_Rx_data), .PE_Fg(w_PE_Fg), .FE_Fg(w_FE_Fg), .OE_Fg(w_OE_Fg), .n_INT(n_INT));
      
      
    assign Rx_RDY = w_Rx_RDY;
    assign Tx_RDY = w_Tx_RDY;
    assign PE_Fg = w_PE_Fg;
    assign FE_Fg = w_FE_Fg;
    
endmodule
