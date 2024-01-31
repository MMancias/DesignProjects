`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 11/14/2023 07:09:48 PM
// Design Name: 
// Module Name: transmitter_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: transmitter fsm design. Sampling every 16 baud rate ticks
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transmitter_fsm (
    input clk, // clock signal
    input rst, // reset signal
    input bd_tick, // tick from baud rate generator
    input D_num, // select number of data bits (7 or 8)
    input S_num, // select number of stop bits (1 or 2)
    input [1:0] Par, // select parity scheme (No, Odd, Even, Invalid)
    input ready, // FIFO is full and ready to start data transmission
    input [7:0] d_in, // received data bits from Tx_FIFO
    input tx_start, // input to indicate transmitter to start
    
    output reg tx, // data bit out
    output reg tx_done, // transmitter is done sending data
    output reg is_active // transmitter is actively transmitting data
    );
   
   // defining FSM states (one hot encoding)
   localparam idle = 4'd1; // idle state (wait for FIFO to be full?)
   localparam start = 4'd2; // start state (count until 7, send start bit)
   localparam data = 4'd4; // send data every 15 count
   localparam stop = 4'd8; // transmitter is done sending data
   
   // defining number of data to read
   wire [7:0] WIDTH; // total width of data to be received
   wire [3:0] w_N; // number of data bits
   wire [1:0] w_M; // number of stop bits
   wire w_P; // parity bit
   // Parity related regs
   reg Par_even; // even parity scheme
   reg Par_odd; // odd parity scheme
   reg par_check; // used to store result of XOR operation
   reg par_bit; // value for parity bit based on par_check value
   // stop bits related regs
   reg stop_check;
   reg [1:0] stop_bits; // 2 stop bits
   reg stop_bit; // one stop bit
   
   assign w_N = D_num ? 4'd8 : 4'd7; // assign number of data bits
   assign w_M = S_num ? 2'd2 : 2'd1; // assign number of stop bits
   assign w_P = Par[1] ? (Par[0] ? 1'd0 : 1'd1) : (Par[0] ? 1'd1 : 1'd0); // assign parity bit number
   
   assign WIDTH = w_N + w_M + w_P; // calculate number of bits
   
   // always block for determining parity scheme
   always @(Par) begin: Parity_Scheme
    if (Par == 2'b01) begin
        Par_odd = 1'd1;
        Par_even = 1'd0;
    end
    else if (Par == 2'b10) begin
        Par_even = 1'd1;
        Par_odd = 1'd0;
    end
    else begin
        Par_even = 1'd0;
        Par_odd = 1'd0;      
    end
   end
   reg [3:0] state, next_state; // state registers
   reg [3:0] counter; // counter holding tick amount (max is 15 for sampling rate = 16)
   reg [3:0] bit_count; // track amount of bits read (depending on # of data, parity, and stop bits)
   reg [11:0] tx_data; // register to store data to be transmitted (max amount is 12 bits)
   reg tx_send; // bit to be sent out
   
   // synchronous state transition
   always @(posedge  clk, negedge rst) begin: state_register
    if(!rst) begin // rst == 0
        state <= idle; // going back to idle state
        counter <= 4'd0;
        bit_count <= 4'd0;
        tx_data <= 12'd0;
        par_check <= 1'd0;
        par_bit <= 1'd0;
        stop_check <= 1'd0;
        stop_bits <= 2'd0;
        tx_send <= 1'd0;
        stop_bit <= 1'd0;
    end
    else begin
        state <= next_state; // go to next state
        par_check <= ^(d_in); // assigning value to par_check
        stop_bit <= 1'd1;
        stop_bits <= S_num ? 2'b11 : 2'b01; 
        par_bit <= (Par_even && par_check) ? 1 :
           (Par_odd && !par_check) ? 1 :
           (Par_even || Par_odd) ? 0 :
           1'd0; // Default case (no parity or invalid parity)
    end
    end
   
   // state transitions logic
   always @(posedge bd_tick) begin: next_state_logic // bd_tick is the only signal we care for transitions

    case(state)
    idle: begin
          if (ready && tx_start) begin // FIFO is ready and signal to start transmission is HIGH
              next_state <= start;
              counter <= 4'd0;
              bit_count <= 4'd0; // count down from # of bits (from MSB to LSB)
              tx_data <= {stop_bits, par_bit, d_in, 1'd0}; // setting data to send out (send LSB to MSB)
              
          end
          else
              next_state <= idle;
    end
    
    start: begin // wait for 16 sampling ticks 
           if (counter == 4'd15) begin
               next_state <= data;
               bit_count <= bit_count + 1;
               counter <= 0;
           end
           else begin
                tx_send <= tx_data[bit_count];
                next_state <= start;
                counter <= counter + 1;
           end
    end
    data: begin
            if( bit_count == (WIDTH) && counter == 4'd15) begin // if bit_count is zero, send last bit before going to stop state
                next_state <= stop;
                bit_count <= 0;
                counter <= 0;
            end
            else if (counter == 4'd15) begin // count until 15 (sampling rate is 16), send data bit, and restart count
                // update regs
                counter <= 4'd0;
                bit_count <= bit_count + 1;
                next_state <= data;
            end
            else begin // keep counting if not 15 ( still not done counting to next bit )
                tx_send <= tx_data[bit_count]; // assign bit to be sent out to current bit
                counter <= counter + 1;
                next_state <= data;
            end 
    end
    
    stop: begin
          next_state <= idle;
    end
    
    default : begin
              next_state = idle;
              // default register values
              counter = 0;
              bit_count = 0;
              tx_data = 0;
              par_check = 0;
              par_bit = 0;
    end
    endcase 
    
   end
   
   // setting moore outputs
   always @(state, tx_send) begin: moore_outputs
   // default values
   tx <= 0;
   tx_done <= 0;
   is_active <= 0;
    case(state)
    idle: begin
          tx_done <= 0;
    end
    
    start: begin
           tx <= tx_send;
           is_active <= 1;
    end
    
    data: begin
          tx <= tx_send;
          is_active <= 1;
    end
    
    stop: begin
          tx_done <= 1;
          is_active <= 0;
    end
    
    default: begin tx <= 0; tx_done <= 0; is_active <= 0; end
    endcase
   end
endmodule
