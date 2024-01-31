`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias 
// 
// Create Date: 10/14/2023 01:00:28 AM
// Design Name: 
// Module Name: oled_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: OLED character write controller
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oled_fsm(
    input clk, // input clk
    input rst, // reset signal
    input pb3, // pushbutton 3 (from wrapper)
    input pb2, // pushbutton 2 (from wrapper)
    input d, // dispense signal from soda fsm
    input char_done, // character done writing (from OLED)
    
    output reg clr_reg, // clear registers at initial state
    output reg ld_price, // load/enable soda price register
    output reg ld_cents, // load/enable coins going in
    output reg ld_coins, // load/enable total coin value in
    output reg ld_disp //  load/enable *DISPENSE* 
    );
    
    
   // defining FSM states (one hot encoding)
   parameter init = 5'b00001; // initial state
   parameter wrt_price = 5'b00010; // wait for soda price input (pb3)
   parameter wrt_coins = 5'b00100; // wait for coin value input (pb2)
   parameter wrt_tot_coins = 5'b01000; // print out total value of coins in 
   parameter wrt_disp = 5'b10000; // display dispense message from soda fsm signal
   
   reg [4:0] state, next_state; // state registers
   
   // synchronous state transition
   always @(posedge  clk, negedge rst) begin: state_register
    if(!rst) // det == 0
    state <= init; // going back to initial state
    
    else
    state <= next_state; // go to next state
    end
   
   // state transitions
   always @(state, pb3, pb2, d, char_done) begin: next_state_logic
   next_state = state;
    case(state)
    init: begin // go to wrt_price if pb3 is pressed
        if (pb3)
        next_state = wrt_price;
        else
        next_state = init;                       
    end
    
    wrt_price: begin // go to wrt_coins if pb2
        if(!char_done)
        next_state = wrt_price;
        else if (pb2 && char_done)
        next_state = wrt_coins;
        else
        next_state = wrt_price;
    end
    
    wrt_coins: begin // show coin in value, go to next state once this is displayed
        if (!char_done)
        next_state = wrt_coins;
        else if (char_done)
        next_state = wrt_tot_coins;
        else
        next_state = wrt_coins;
    end
    
    wrt_tot_coins: begin // go to show total value once coin value is displayed
        if (!char_done)
        next_state = wrt_tot_coins;
        else if (char_done && d)
        next_state = wrt_disp;
        else if (char_done && !d)
        next_state = wrt_price;
        else
        next_state = wrt_tot_coins;
    end
    
    wrt_disp: begin // display DISPENSE message once coins in value >= soda price
        if (!char_done)
        next_state = wrt_disp;
        else if (char_done && !rst)
        next_state = init;
        else
        next_state = wrt_disp;
    end
    
    default : next_state = init;
    endcase 
    
   end
   
   // setting moore outputs
   always @(state) begin: moore_outputs
   // default values
   clr_reg <= 0;
   ld_price <= 0;
   ld_cents <= 0;
   ld_coins <= 0;
   ld_disp <= 1;
    case(state)
    init: begin 
        clr_reg <= 1;
    end
    
    wrt_price: begin
        ld_price <= 1;
    end
    
    wrt_coins: begin
        ld_cents <= 1;
    end
    
    wrt_tot_coins: begin
        ld_coins <= 1;
    end
    
    wrt_disp: begin
        ld_disp <= 1;
    end
    
    endcase
   end
endmodule
