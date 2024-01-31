`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 10/15/2023 01:07:32 AM
// Design Name: 
// Module Name: bcd_to_text_3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: module to convert 10-bit wide BCD input to equivalent text
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bcd_to_text_3 (
  input [9:0] bcd_data,        // 10-bit BCD data (three digits) to convert
  output [23:0] text_output    // Output text (ASCII) string (three digits)
);

  reg [23:0] text_string;
  
  always @ (bcd_data) begin
    // Convert the first digit
    case (bcd_data[9:8])
      2'b00: text_string[23:16] = "0";
      2'b01: text_string[23:16] = "1";
      2'b10: text_string[23:16] = "2";
      2'b11: text_string[23:16] = "3";
      
      default: text_string[23:16] = " ";
    endcase
    
    // Convert the second digit
    case (bcd_data[7:4])
      4'b0000: text_string[15:8] = "0";
      4'b0001: text_string[15:8] = "1";
      4'b0010: text_string[15:8] = "2";
      4'b0011: text_string[15:8] = "3";
      4'b0100: text_string[15:8] = "4";
      4'b0101: text_string[15:8] = "5";
      4'b0110: text_string[15:8] = "6";
      4'b0111: text_string[15:8] = "7";
      4'b1000: text_string[15:8] = "8";
      4'b1001: text_string[15:8] = "9";
      
      default: text_string[15:8] = " ";
    endcase

    // Convert the third digit
    case (bcd_data[3:0])
      4'b0000: text_string[7:0] = "0";
      4'b0001: text_string[7:0] = "1";
      4'b0010: text_string[7:0] = "2";
      4'b0011: text_string[7:0] = "3";
      4'b0100: text_string[7:0] = "4";
      4'b0101: text_string[7:0] = "5";
      4'b0110: text_string[7:0] = "6";
      4'b0111: text_string[7:0] = "7";
      4'b1000: text_string[7:0] = "8";
      4'b1001: text_string[7:0] = "9";
      
      default: text_string[7:0] = " ";
    endcase
  end

  assign text_output = text_string;

endmodule

