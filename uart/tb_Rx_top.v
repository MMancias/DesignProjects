`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/14/2023 05:50:11 PM
// Design Name: 
// Module Name: tb_Rx_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test top level block of uart receiver
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
module tb_Rx_top(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_bd_tick;
    reg tb_in_rx;
    reg tb_in_rx_enable;
    reg tb_in_D_num;
    reg tb_in_S_num;
    reg [1:0] tb_in_Par;
    reg tb_in_n_RD;
    reg tb_in_C_nD;
    reg tb_in_Clr_EF;
    
    localparam WIDTH = 11; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be received
    
    wire tb_out_Rx_RDY;
    wire [7:0] tb_out_d_out;
    wire tb_out_PE_Fg;
    wire tb_out_FE_Fg;
    wire tb_out_OE_Fg;
    wire tb_out_n_INT;
    
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    integer j;
    // defining unit under test
    Rx_top uut (
    .CLK50MHZ(tb_clk),
    .rst(tb_rst),
    .Baud_tick(tb_bd_tick),
    .RxD(tb_in_rx),
    .rx_enable(tb_in_rx_enable),
    .D_num(tb_in_D_num),
    .S_num(tb_in_S_num),
    .Par(tb_in_Par),
    .n_RD(tb_in_n_RD),
    .C_nD(tb_in_C_nD),
    .Clr_EF(tb_in_Clr_EF),
    
    .out_data(tb_out_d_out),
    .Rx_RDY(tb_out_Rx_RDY),
    .PE_Fg(tb_out_PE_Fg),
    .FE_Fg(tb_out_FE_Fg),
    .OE_Fg(tb_out_OE_Fg),
    .n_INT(tb_out_n_INT)
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
    tb_bd_tick = 0;
    tb_in_rx_enable = 0;
    tb_in_rx = 1;
    tb_in_n_RD = 1;
    data = {1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd0, 1'd0, 1'd1, 1'd1};
    tb_in_D_num = 1;
    tb_in_S_num = 1;
    tb_in_Par = 2'b10;
    tb_in_C_nD = 1; // change this to test read
    tb_in_Clr_EF = 0;
    # (period * 20);
    // no-reset and start bit plus wait for count until 7
    tb_rst = 1;
    tb_bd_tick = 1;
    tb_in_rx = 1;
    tb_in_rx_enable = 1;
    # (period * 10);
    //# period;
    // start data transmission
    // count until 7 then 15
    for (i = 0; i < 8; i = i+1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        tb_in_rx = 0;
        tb_bd_tick = 1;
        # period;
    end
    j = 0;
    tb_in_rx_enable = 1;
    for (i = 0; i < 16*(WIDTH)*2; i = i + 1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        if (i % 16 == 0 && j < WIDTH) begin
            tb_in_rx = data[j]; // grab data for tb_in_rx when tb_bd_tick goes low
            j = j+1;
        end
        tb_bd_tick = 1;
        # period;
    end
    // reading data from FIFO
    tb_in_n_RD = 0;
    tb_in_C_nD = 0;
    tb_in_Clr_EF = 0; // change this to see flag behavior
    # period;
    
    /** adding 3 more receive cycles to test OE flag **/
    tb_in_n_RD = 1;
    # period;
    // start data transmission
    // count until 7 then 15
    for (i = 0; i < 8; i = i+1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        tb_in_rx = 0;
        tb_bd_tick = 1;
        # period;
    end
    j = 0;
    for (i = 0; i < 16*(WIDTH)*2; i = i + 1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        if (i % 16 == 0 && j < WIDTH) begin
            tb_in_rx = data[j]; // grab data for tb_in_rx when tb_bd_tick goes low
            j = j+1;
        end
        tb_bd_tick = 1;
        # period;
    end
    
    // start data transmission
    // count until 7 then 15
    for (i = 0; i < 8; i = i+1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        tb_in_rx = 0;
        tb_bd_tick = 1;
        # period;
    end
    j = 0;
    for (i = 0; i < 16*(WIDTH)*2; i = i + 1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        if (i % 16 == 0 && j < WIDTH) begin
            tb_in_rx = data[j]; // grab data for tb_in_rx when tb_bd_tick goes low
            j = j+1;
        end
        tb_bd_tick = 1;
        # period;
    end
    
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule