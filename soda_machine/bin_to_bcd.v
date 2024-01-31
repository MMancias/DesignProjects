`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/05/2023 08:59:10 PM
// Design Name: 
// Module Name: bin_to_bcd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: binary to binary-coded-decimal (BCD) module using flattened double-dabble algorithm
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bin_to_bcd(
    input [7:0] bin, // input binary number
    output [9:0] bcd // bcd output
    );
    
    //wire [9:0] bcd; // used in case of not enough output ports
    // wires needed to connect (and cascade) several c-modules
    wire [3:0] w_c1_out;
    wire [3:0] w_c2_out;
    wire [3:0] w_c3_out;
    wire [3:0] w_c4_out;
    wire [3:0] w_c5_out;
    wire [3:0] w_c6_out;
    wire [3:0] w_c7_out;
    
    // c_module block connection and instantiation
    c_module c1 (.a({1'b0, bin[7:5]}), .s(w_c1_out));
    c_module c2 (.a({w_c1_out[2:0], bin[4]}), .s(w_c2_out));
    c_module c3 (.a({w_c2_out[2:0], bin[3]}), .s(w_c3_out));
    c_module c4 (.a({w_c3_out[2:0], bin[2]}), .s(w_c4_out));
    c_module c5 (.a({w_c4_out[2:0], bin[1]}), .s(w_c5_out));
    c_module c6 (.a({1'b0, w_c1_out[3], w_c2_out[3], w_c3_out[3]}), .s(w_c6_out));
    c_module c7 (.a({w_c6_out[2:0], w_c4_out[3]}), .s(w_c7_out));
    
    // assigning bcd output
    assign bcd = {w_c6_out[3], w_c7_out, w_c5_out, bin[0]};
    
endmodule
