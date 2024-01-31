`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/31/2023 09:53:19 PM
// Design Name: 
// Module Name: receiver_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: receiver fsm design. Implementing oversampling scheme (sampling rate is 16)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module receiver_fsm (
    input clk, // clock signal
    input rst, // reset signal
    input bd_tick, // tick from baud rate generator
    input D_num, // select number of data bits (7 or 8)
    input S_num, // select number of stop bits (1 or 2)
    input [1:0] Par, // select parity scheme (No, Odd, Even, Invalid)
    input rx, // receive signal
    input rx_enable, // enable rx receive line
    
    output reg [7:0] d_out, // data bits in (width based on # of data bits) max amount is 8 bits
    output reg rx_done, // receiver is done receiving data
    output reg is_active, // indicates if receiver is active
    output reg par_flag, // flag is high if there's parity error
    output reg framing_flag // flag is high if there's framing error
    );
   
   // defining FSM states (one hot encoding)
   localparam idle = 5'd1; // idle state (wait for start bit and counter to reach 7)
   localparam data = 5'd2; // read data in state
   localparam parity = 5'd4; // parity check state
   localparam framing = 5'd8; // framing error check state
   localparam stop = 5'd16; // stop data acquisition
   
   // defining number of data to read
   wire [7:0] WIDTH; // total width of data to be received
   wire [3:0] w_N; // number of data bits
   wire [1:0] w_M; // number of stop bits
   wire w_P; // parity bit
   // Parity related regs
   reg Par_even; // even parity scheme
   reg Par_odd; // odd parity scheme
   reg par_check; // used to store result of XOR operation
   reg [3:0] bits; // store shift value (to only check data bits + parity bit)
   // framing related regs
   reg [1:0] stop_bits; // used to store amount of stop bits in data
   reg framing_check; // flag for data framing error

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
   reg [4:0] state, next_state; // state registers
   reg [3:0] counter; // counter holding tick amount (max is 15 for sampling rate = 16)
   reg [3:0] bit_count; // track amount of bits read (depending on # of data, parity, and stop bits)
   reg [10:0] received_data; // register to store data received (max amount is 11 bits)
   
   // synchronous state transition
   always @(posedge  clk, negedge rst) begin: state_register
    if(!rst) begin// rst == 0
        state <= idle; // going back to idle state
        bits <= 4'd0;
        stop_bits <= 2'd0;
        counter <= 4'd0;
        bit_count <= 4'd0;
        received_data <= 11'd0;
        par_check <= 1'd0;
        framing_check <= 1'd0;
    end
    else begin
        state <= next_state; // go to next state
        bits <= (w_N + w_P);
        stop_bits <= S_num ? 2'b11 : 2'b01;
    end
    end
   
   // state transitions logic
   always @(posedge bd_tick) begin: next_state_logic // no need to add anything else to sensitivity as bd_tick is the only signal we care for transitions

    case(state)
    idle: begin 
          if (rx_enable && !rx && counter == 4'd7) begin // bit goes to 0, start reading data
              counter = 4'd0;
              next_state <= data;
              bit_count <= 4'd0;
              received_data <= 11'd0;
              par_check <= 1'd0;
              framing_check <= 1'd0;
          end
          else
              next_state <= idle;
              counter <= counter + 1;
    end
    
    data: begin
            if( bit_count == (WIDTH - 1) && counter == 4'd15) begin // move to stop state if all data bits have been read (N + M + parity)
                // retrieve data (one last time)
                received_data[bit_count] <= rx; // setting last received bit
                
                next_state <= parity;
                bit_count <= 0;
                counter <= 0;
            end
            else if (counter == 4'd15) begin // count until 15 (sampling rate is 16), retrieve data, and restart count
                // retrieve data
                received_data[bit_count] <= rx; // data reception goes from LSB to MSB
                // update regs
                counter <= 0;
                bit_count <= bit_count + 1;
                next_state <= data;
            end
            else begin // keep counting if not 15 and still not done reading data
                counter <= counter + 1;
                next_state <= data;
            end
    end
    
    parity: begin 
            if (Par_even) begin // if even, XOR data and check result
                // mask to retrieve bits from MSB to WIDTH - bits, return 1 if XOR does not return 0 (it should in even parity)
                par_check <= ^(received_data & ((1'd1 << (bits)) - 1'd1)) != 1'd0; // add by offset to account for width
                next_state <= framing;
            end
            else if (Par_odd) begin // if odd, XOR data and check result
                // mask to retrieve bits from MSB to WIDTH - bits, return 0 if XOR does not return 1 (it should in odd parity)
                par_check <= ^(received_data & ((1'd1 << (bits)) - 1'd1)) != 1'd1; // add by offset to account for width   
                next_state <= framing;
            end
            else begin
                next_state <= framing;
                par_check <= 0; // if no parity, flag should stay down
            end
    end
    
    framing: begin            
             // condition for stop bits in data matching stop bits input
                               // mask to retrieve stop bits from data
             if ( stop_bits == ( received_data >> bits ) ) begin 
             framing_check <= 1'd0; // condition is met, flag is low
             next_state <= stop;
             end
             else begin
             framing_check <= 1'd1; // condition not met, flag is high
             next_state <= stop;
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
              received_data = 0;
              par_check = 0;
              framing_check = 0;
    end
    endcase 
    
   end
   
   // setting moore outputs
   always @(state) begin: moore_outputs
   // default values
   d_out <= 0;
   rx_done <= 0;
   par_flag <= 0;
   framing_flag <= 0;
   is_active <= 0;
    case(state)
    idle: begin
          d_out <= 0;
          rx_done <= 0;
          par_flag <= 0;
          framing_flag <= 0;
    end
    
    data: begin
          is_active <= 1;
    end
    
    parity: begin
            is_active <= 1;
    end
    
    framing: begin
             is_active <= 1;
    end
    
    stop: begin
        rx_done <= 1;
        // retrieving data bits from MSB to MSB- (bits-1), minus 1 to exclude parity bit
        d_out <= (received_data & ((1'd1 << (bits - 1'd1)) - 1'd1));
        par_flag <= par_check;
        framing_flag <= framing_check;
        is_active <= 0;
    end
    
    default: begin d_out <= 0; rx_done <= 0; par_flag <= 0; framing_flag <= 0; is_active <= 0; end
    endcase
   end
endmodule