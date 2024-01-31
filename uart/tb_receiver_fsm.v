`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/01/2023 12:28:23 AM
// Design Name: 
// Module Name: tb_receiver_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test receiver module functionality
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
module tb_receiver_fsm(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_bd_tick;
    reg tb_in_rx;
    reg tb_in_rx_enable;
    reg tb_in_D_num;
    reg tb_in_S_num;
    reg [1:0] tb_in_Par;
    
    localparam WIDTH = 11; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be received
    
    wire [7:0] tb_out_d_out;
    wire tb_out_rx_done;
    wire tb_out_par_flag;
    wire tb_out_framing_flag;
    wire tb_out_is_active;
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    integer j;
    // defining unit under test
    receiver_fsm uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .bd_tick(tb_bd_tick),
    .rx(tb_in_rx),
    .rx_enable(tb_in_rx_enable),
    .D_num(tb_in_D_num),
    .S_num(tb_in_S_num),
    .Par(tb_in_Par),
    .d_out(tb_out_d_out),
    .rx_done(tb_out_rx_done),
    .is_active(tb_out_is_active),
    .par_flag(tb_out_par_flag),
    .framing_flag(tb_out_framing_flag)
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
    tb_in_rx = 1;
    tb_in_rx_enable = 0;
    data = {1'd0, 1'd1, 1'd1, 1'd0, 1'd1, 1'd0, 1'd1, 1'd1, 1'd1, 1'd1, 1'd1};
    # period;
    tb_in_D_num = 1;
    tb_in_S_num = 1;
    tb_in_Par = 2'b10;
    # period;
    // no-reset and start bit plus wait for count until 7
    tb_rst = 1;
    tb_bd_tick = 1;
    tb_in_rx = 1;
    tb_in_rx_enable = 1;
    # period;
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
    tb_in_rx_enable = 0;
    for (i = 0; i < 16*(WIDTH+1); i = i + 1) begin
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
