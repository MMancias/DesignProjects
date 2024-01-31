`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/28/2023 12:15:27 PM
// Design Name: 
// Module Name: mod_m_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: mod-m counter, counts up to M value and resets (default M width is 32 bits)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mod_m_counter #(parameter WIDTH = 32) (
    input clk, // clock input
    input rst, // reset signal
    input [WIDTH-1:0] M2, // mod value (default WIDTH is 32)
    output reg [WIDTH-1:0] count, // counter signal
    output reg tick // tick (every mod M)
    );
    
    always @(posedge clk, negedge rst) begin
        if (!rst) begin // reset == 0
            count <= 0;
            tick <= 0;
        end
        else begin
            if (count == M2) begin // counter reaches M2
                tick <= 1'b1;
                count <= 0;
            end
            else begin// counter goes up if not M
                count <= count + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
