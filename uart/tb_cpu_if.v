`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/24/2023 06:11:03 PM
// Design Name: 
// Module Name: tb_cpu_if
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench testing for UART CPU Interface functionality
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
module tb_cpu_if(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg [7:0] tb_in_DATA;
    reg [9:0] tb_in_DATA_Rx;
    reg tb_in_C_nD;
    reg tb_in_n_RD;
    reg tb_in_n_WR;
    reg tb_in_n_CS;
    
    reg tb_in_Rx_RDY;
    reg tb_in_Tx_RDY;
    reg tb_in_PE_Fg;
    reg tb_in_FE_Fg;
    reg tb_in_OE_Fg;
    
    localparam WIDTH = 8; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be sent
    
    wire [7:0] tb_out_DATA_OUT;
    wire [7:0] tb_out_DATA_Tx;
    wire [7:0] tb_out_DATA_CR;
    
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    // defining unit under test
    cpu_if uut (
    .CLK50MHZ(tb_clk),
    .n_RST(tb_rst),
    .C_nD(tb_in_C_nD),
    .n_RD(tb_in_n_RD),
    .n_WR(tb_in_n_WR),
    .n_CS(tb_in_n_CS),
    .DATA_IN(tb_in_DATA),
    .DATA_Rx(tb_in_DATA_Rx),
    
    .DATA_OUT(tb_out_DATA_OUT),
    .DATA_Tx(tb_out_DATA_Tx),
    .DATA_CR(tb_out_DATA_CR),
    
    .Rx_RDY(tb_in_Rx_RDY),
    .Tx_RDY(tb_in_Tx_RDY),
    .PE_Fg(tb_in_PE_Fg),
    .FE_Fg(tb_in_FE_Fg),
    .OE_Fg(tb_in_OE_Fg)
    );

    // clock signal  
    initial
    begin
    tb_clk = 1'b0;
    forever #(period/4) tb_clk = ~tb_clk;
    end
    
    // testing input combinations
    initial
    begin
    // resetting fsm and setting default values
    tb_rst = 0;
    tb_in_DATA = 0;
    tb_in_C_nD = 0;
    tb_in_n_RD = 0;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    tb_in_DATA_Rx = 0;
    
    data = 0;
    // setting status register values 
    tb_in_Rx_RDY = 1;
    tb_in_Tx_RDY = 1;
    tb_in_PE_Fg = 0;
    tb_in_FE_Fg = 0;
    tb_in_OE_Fg = 0;
    # (period * 5);
    
    // different cases 
    tb_rst = 1;
    # period;
    // ( Read Rx_FIFO Data)
    data = {1'd1, 1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd0, 1'd1};
    tb_in_DATA_Rx = data;
    tb_in_C_nD = 0;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period * 5);
    
    // ( Write Data to Tx_FIFO)
    data = {1'd1, 1'd1, 1'd0, 1'd1, 1'd1, 1'd0, 1'd1, 1'd0};
    tb_in_DATA = data;
    tb_in_C_nD = 0;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * 5);
    
    // ( See Status Register)
//    data = {1'd1, 1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd0, 1'd1};
//    tb_in_DATA = data;
    tb_in_C_nD = 1;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period * 5);
    
    // ( Write Configuration register)
    data = {1'd0, 1'd0, 1'd1, 1'd0, 1'd1, 1'd1, 1'd1, 1'd1};
    tb_in_DATA = data;
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * 5);
    
    // ( Write Configuration register) with I_Rst == 1
    data = {1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd1, 1'd1, 1'd1};
    tb_in_DATA = data;
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * 5);
    
    // try X combination
    tb_in_C_nD = 0;
    tb_in_n_RD = 0;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * 5);
    
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule

