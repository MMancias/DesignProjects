`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2023 06:44:23 PM
// Design Name: 
// Module Name: tb_Tx_top
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


// setting timescale
`timescale 1ns/1ps
module tb_Tx_top(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_Baud_tick;
    reg tb_in_D_num;
    reg tb_in_S_num;
    reg [1:0] tb_in_Par;
    reg tb_in_n_WR;
    reg [7:0] tb_in_DATA;
    reg tb_in_C_nD;
    
    localparam WIDTH = 8; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be sent
    
    wire tb_out_TxD;
    wire tb_out_Tx_RDY;
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    // defining unit under test
    Tx_top uut (
    .CLK50MHZ(tb_clk),
    .rst(tb_rst),
    .Baud_tick(tb_Baud_tick),
    .D_num(tb_in_D_num),
    .S_num(tb_in_S_num),
    .Par(tb_in_Par),
    .n_WR(tb_in_n_WR),
    .C_nD(tb_in_C_nD),
    .DATA(tb_in_DATA),
    
    .TxD(tb_out_TxD),
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
    // resetting fsm and setting default values
    tb_rst = 0;
    tb_Baud_tick = 0;
    data = {1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd1}; // data to be sent
    tb_in_n_WR = 1;
    tb_in_DATA = 0;
    tb_in_C_nD = 1;
    tb_in_D_num = 1;
    tb_in_S_num = 1;
    tb_in_Par = 2'b10;
    # (period * 20);
    
    // no-reset and start bit plus wait for count until 7
    tb_rst = 1;
    # (period * 10);
//    tb_in_n_WR = 0;
//    tb_in_DATA = data;
//    # period;
    tb_in_n_WR = 1;
    # (period*20); 
    
    
    //# period;
    // start data transmission
    // count until 7 then 15
    for (i = 0; i < 8; i = i+1) begin
        tb_Baud_tick = 0;
        # (period);
        if (i ==0 ) begin
        tb_in_n_WR = 0;
        tb_in_C_nD = 0;
        tb_in_DATA = data;
        end
        else begin
        tb_in_n_WR = 1;
        tb_in_C_nD = 1;
        end
        // Generate count sequences
        tb_Baud_tick = 1;
        # period;
    end
    // counting for rest of bits to be sent out
    for (i = 0; i < 16*(12); i = i + 1) begin
        tb_Baud_tick = 0;
        # (period);
        tb_Baud_tick = 1;
        # period;
    end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
