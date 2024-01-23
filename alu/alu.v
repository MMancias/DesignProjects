`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/27/2023 02:42:13 PM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: arithmetic logic unit (alu) module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu #(parameter WIDTH = 32) (
    input [WIDTH-1:0] a, // input a
    input [WIDTH-1:0] b, // input b
    input [3:0] func_sel, // function select input
    output [WIDTH-1:0] r, // output from selected function 
    output ov_sgn // overflow/sign output (from adder or sign from subtractor)
    );
    
    // wires to carry local signals
    // adder wires
    wire [WIDTH-1:0] w_sum;
    wire w_cout;
    // subtractor wires
    wire [WIDTH-1:0] w_sub;
    wire w_sgn;
    
    // 2's comp wire
    wire [WIDTH-1:0] w_twos_comp;
    // comparator wire
    wire [WIDTH-1:0] w_comp;
    // AND wire
    wire [WIDTH-1:0] w_and;
    // OR wire
    wire [WIDTH-1:0] w_or;
    // XOR wire
    wire [WIDTH-1:0] w_xor;
    // rotate function and wires
    wire [WIDTH-1:0] w_rot_out;
    wire [WIDTH-1:0] w_rot_r;
    wire [WIDTH-1:0] w_rot_l;
    
    // module instantiations
    n_bit_adder #(.WIDTH(WIDTH)) add (.a(a), .b(b), .cin(1'b0), .sum(w_sum), .ov_sgn(w_cout)); // adder block
    
    n_bit_sub #(.WIDTH(WIDTH)) sub (.a(a), .b(b), .sub(w_sub), .sgn(w_sgn)); // subtractor block
    
    n_bit_twos_comp #(.WIDTH(WIDTH)) twos_comp (.a(a), .result(w_twos_comp)); // 2's complement block
    
    n_bit_compare #(.WIDTH(WIDTH)) comp (.a(a), .b(b), .eq(w_comp[0]), .lt(w_comp[1]), .gt(w_comp[2])); // comparator block
    assign w_comp[WIDTH-1:3] = 0; // setting the rest of the bits to 0
    
    assign w_and = a & b; // AND block
    assign w_or = a | b; // OR block
    assign w_xor = a ^ b; // XOR block
    
    // rotate right
    assign w_rot_r = {a[0], a[WIDTH-1:1]};
    // rotate left
    assign w_rot_l = {a[WIDTH-2:0], a[WIDTH-1]};
    
    // rotate mux design 
    assign w_rot_out = func_sel[3] ? w_rot_r : w_rot_l;
    
    // func select mux design
    assign r = (func_sel[2]) ? 
              (func_sel[1] ? // MSB is 1
                  (func_sel[0] ? w_rot_out : w_xor) 
                  : (func_sel[0] ? w_or : w_and)) // second 4 functions
           : (func_sel[1] ? // MSB is 0
                  (func_sel[0] ? w_twos_comp : w_comp) // first 4 functions
                  : (func_sel[0] ? w_sub : w_sum));
    
    // overflow and sign bit mux
    assign ov_sgn = func_sel[0] ? w_sgn : w_cout;
    
endmodule
