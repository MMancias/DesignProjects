`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/17/2023 12:42:46 PM
// Design Name: 
// Module Name: tb_transmitter_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test transmitter fsm functionality
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
module tb_transmitter_fsm(); // tb module has no ports
    
    // defining uut local signals
    reg tb_clk;
    reg tb_rst;
    reg tb_bd_tick;
    reg tb_in_D_num;
    reg tb_in_S_num;
    reg [1:0] tb_in_Par;
    reg tb_in_ready;
    reg [7:0] tb_in_d_in;
    reg tb_in_tx_start;
    
    localparam WIDTH = 8; // number of bits - 1 being transmitted
    reg [WIDTH-1:0] data; // used to store data to be sent
    
    wire tb_out_tx;
    wire tb_out_tx_done;
    wire tb_out_is_active;
    // other local variables
    parameter period = 20; // constant period 20ns
    integer i;
    // defining unit under test
    transmitter_fsm uut (
    .clk(tb_clk),
    .rst(tb_rst),
    .bd_tick(tb_bd_tick),
    .D_num(tb_in_D_num),
    .S_num(tb_in_S_num),
    .Par(tb_in_Par),
    .ready(tb_in_ready),
    .d_in(tb_in_d_in),
    .tx_start(tb_in_tx_start),
    
    .tx(tb_out_tx),
    .tx_done(tb_out_tx_done),
    .is_active(tb_out_is_active)
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
    data = {1'd1, 1'd1, 1'd0, 1'd1, 1'd1, 1'd1, 1'd0, 1'd0}; // data to be sent
    tb_in_ready = 0;
    tb_in_tx_start = 0;
    tb_in_d_in = 0;
    # period;
    tb_in_D_num = 1;
    tb_in_S_num = 1;
    tb_in_Par = 2'b10;
    # period;
    // no-reset and start bit plus wait for count until 7
    tb_rst = 1;
    tb_in_d_in = data;
    tb_bd_tick = 1;
    # period; 
    tb_in_ready = 1;
    tb_in_tx_start = 1;
    # period;
    //# period;
    // start data transmission
    // count until 7 then 15
    for (i = 0; i < 8; i = i+1) begin
        tb_bd_tick = 0;
        # (period);
        // Generate count sequences
        tb_bd_tick = 1;
        # period;
    end
    // counting for rest of bits to be sent out
    for (i = 0; i < 16*(12); i = i + 1) begin
        tb_bd_tick = 0;
        # (period);
        tb_bd_tick = 1;
        # period;
    end
        
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule
