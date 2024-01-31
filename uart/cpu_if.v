`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/24/2023 04:15:34 PM
// Design Name: 
// Module Name: cpu_if
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: CPU Interface for UART module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_if(
    // system signals
    input CLK50MHZ, // 50MHz clock
    input n_RST, // Active-low reset input driven from the CPU. It places the UART in an idle mode until it is programmed.
    input C_nD, //  indicates what kind of information is on the DATA bus, LOW: data bus is carrying data character, else status or control word
    input n_RD, // LOW: CPU is reading data or status words from the UART during a read cycle
    input n_WR, // LOW: CPU is writing data or control words to the UART during a write cycle
    input n_CS, // chip select signal which enables the UART. No read or write occur unless this signal is "low"
    input [7:0] DATA_IN, // DATA going into CPU interface (from CPU)
    input [7:0] DATA_Rx, // DATA coming from Rx_FIFO
    
    output reg [7:0] DATA_OUT, // DATA bus output (either received data, or status register)
    output reg [7:0] DATA_Tx, // DATA bus output (data to write to Tx_FIFO)
    output reg [7:0] DATA_CR, // DATA bus output (configuration register data output)
    
    // signals from other blocks (Tx, Rx)
    input Tx_RDY, // inform the CPU that the UART can accept a new character for transmission
    input Rx_RDY, // set to logic 1 when at least one character is in the RX_ FIFO
    input PE_Fg, // parity error flag (from Rx)
    input FE_Fg, // framing error flag (from Rx)
    input OE_Fg // overrun error flag (from Rx)
    );
    
    // reg for CPU IF function
    reg [3:0] control;
    // registers
    reg [7:0] CR; // configuration register
    reg [7:0] SR; // status register
    
    always @(posedge  CLK50MHZ, negedge n_RST) begin
        if (!n_RST || CR[7] == 1'd1) begin // reset is active (n_RST == 0) OR I_Rst == 1
            CR <= 0;
            SR <= 0;
            control <= 0;
            DATA_OUT <= 0;
            DATA_Tx <= 0;
            DATA_CR <= 0;
        end
        else begin
            control <= {C_nD, n_RD, n_WR, n_CS};
            SR <= {1'd0, 1'd0, 1'd0, OE_Fg, FE_Fg, PE_Fg, Tx_RDY, Rx_RDY}; // setting status register
        end
    end
    always @(posedge CLK50MHZ) begin // update values every clock cycle
    control = {C_nD, n_RD, n_WR, n_CS};
        case(control)
            4'b0010: begin
                     DATA_OUT <= DATA_Rx; // data in in this case is coming from Rx_FIFO
            end
            
            4'b0100: begin
                     DATA_Tx <= DATA_IN; // data from CPU goes to Tx_FIFO
            end
            
            4'b1010: begin
                     DATA_OUT <= SR; // data out is status register
            end
            
            4'b1100: begin
                     CR <= DATA_IN;
                     DATA_CR <= CR;
            end
            
            default: begin
                     DATA_OUT <= 0;
                     DATA_Tx <= 0;
                     DATA_CR <= CR;
            end
        endcase
    end
endmodule
