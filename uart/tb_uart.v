`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/28/2023 12:54:11 AM
// Design Name: 
// Module Name: tb_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test uart functionality
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
module tb_uart(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_in_C_nD;
    reg tb_in_n_RD;
    reg tb_in_n_WR;
    reg tb_in_n_CS;
    reg [7:0] tb_in_DATA_IN;
    localparam WIDTH = 8; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be received
    
    wire tb_out_n_INT;
    wire [7:0] tb_out_DATA_OUT;
    wire tb_out_Rx_RDY;
    wire tb_out_Tx_RDY;
    
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    // defining unit under test
    uart_verif uut (
    .clk(tb_clk),
    .n_RST(tb_rst),
    .C_nD(tb_in_C_nD),
    .n_RD(tb_in_n_RD),
    .n_WR(tb_in_n_WR),
    .n_CS(tb_in_n_CS),
    .DATA_IN(tb_in_DATA_IN),
    
    .n_INT(tb_out_n_INT),
    .DATA_OUT(tb_out_DATA_OUT),
    .Rx_RDY(tb_out_Rx_RDY),
    .Tx_RDY(tb_out_Tx_RDY)
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
    // resetting uart and setting configuration register values
    tb_rst = 0;
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    tb_in_DATA_IN = 0;
    // Configuration is: Baud rate 9600 (I'll replace it with 115200 for sim purposes), 8 data bits, 1 stop bit and odd parity - 
    // Data Character for transmission will be D = 0x68
    data = {1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd0};
    # (period * 20);
    // no-reset (wait for FIFO)
    tb_rst = 1;
    # (period * 10);
    // setting configuration register
    tb_in_DATA_IN = data;
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # period;
    // reset inputs
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period*40);
    
    // writing data to Tx_FIFO to start transmitting
    data = {1'd0, 1'd1, 1'd1, 1'd0, 1'd1, 1'd0, 1'd0, 1'd0};
    tb_in_DATA_IN = data;
    tb_in_C_nD = 0;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * (15*20));
    // reset inputs (wait for transmission to be done)
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period * (15*2000));
    
    // read status register
    tb_in_C_nD = 1;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period * 2);
    // reset inputs 
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period);
    
    // read Rx_data
    tb_in_C_nD = 0;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period * 2);
    // reset inputs 
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period);
    
    /** SECOND TEST **/
    
        // Configuration is: Baud rate 115,200, 7 data bits, 2 stop bits, and even parity - 
    // Data Character is G = 0x71
    data = {1'd0, 1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd1};
    # (period * 20);
    // no-reset (wait for FIFO)
    tb_rst = 1;
    # (period * 10);
    // setting configuration register
    tb_in_DATA_IN = data;
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # period;
    // reset inputs
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period*40);
    
    // writing data to Tx_FIFO to start transmitting
    data = {1'd1, 1'd1, 1'd1, 1'd0, 1'd0, 1'd0, 1'd1};
    tb_in_DATA_IN = data;
    tb_in_C_nD = 0;
    tb_in_n_RD = 1;
    tb_in_n_WR = 0;
    tb_in_n_CS = 0;
    # (period * (15*15));
    // reset inputs (wait for transmission to be done)
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period * (15*200));
    
    // read status register
    tb_in_C_nD = 1;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period * 5);
    // reset inputs 
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period * 5);
    
    // read Rx_data
    tb_in_C_nD = 0;
    tb_in_n_RD = 0;
    tb_in_n_WR = 1;
    tb_in_n_CS = 0;
    # (period);
    // reset inputs 
    tb_in_C_nD = 1;
    tb_in_n_RD = 1;
    tb_in_n_WR = 1;
    tb_in_n_CS = 1;
    # (period);
    
    # (period*100) $stop; // run 5 more periods and stop
    end
endmodule