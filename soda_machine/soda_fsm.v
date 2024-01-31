`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias 
// 
// Create Date: 10/04/2023 02:17:25 PM
// Design Name: 
// Module Name: soda_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: soda machine finite state machine
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module soda_fsm (
    input clk, // clock signal
    input rst, // reset signal 
    input tot_lt_s, // comparator output (total is less than value of soda)
    input c, // coin deposited signal
    input [4:0] count, // output from counter (used to delay dispense signal)
    output reg d, // dispense signal
    output reg rst_counter, // signal used to reset counter
    output reg tot_clr, // clear total amount register
    output reg tot_ld, // load register with coin value signal
    // OLED-related control signals
    input init_done, // OLED is done initializing
    input pb3 // pushbutton 3 signal
    );
   
   // defining FSM states (one hot encoding)
   parameter init = 4'b0001; // initial state
   parameter listen = 4'b0010; // wait for input coin
   parameter add = 4'b0100; // add value of coin to total
   parameter disp = 4'b1000; // if total is greater than or equal to soda value, dispense 
   
   reg [3:0] state, next_state; // state registers
   
   // synchronous state transition
   always @(posedge  clk, negedge rst) begin: state_register
    if(!rst) // det == 0
    state <= init; // going back to initial state
    
    else
    state <= next_state; // go to next state
    end
   
   // state transitions
   always @(state, c, tot_lt_s, init_done, count, pb3) begin: next_state_logic
   next_state = state;
    case(state)
    init: begin // always go to listen state
        if (init_done && pb3)
        next_state = listen;
        else
        next_state = init;                       
    end
    
    listen: begin
        if (c)
        next_state = add;
        else if (!c && tot_lt_s)
        next_state = listen;
        else if (!c && !tot_lt_s)
        next_state = disp;
        else
        next_state = listen;
    end
    
    add: begin
        next_state = listen;
    end
    
    disp: begin
        if (count >= 5'd20)
        next_state = init;
        else
        next_state = disp;
    end
    
    default : next_state = init;
    endcase 
    
   end
   
   // setting moore outputs
   always @(state) begin: moore_outputs
   // default values
   d <= 0;
   tot_clr <= 0;
   tot_ld <= 0;
   rst_counter <= 0;
    case(state)
    init: begin 
        d <= 0;
        tot_clr <= 1;
    end
    
    listen: begin
        
    end
    
    add: begin
        tot_ld <= 1;
    end
    
    disp: begin
        d <= 1;
        rst_counter <= 1;
    end
    
    default: d <= 0;
    endcase
   end
endmodule
