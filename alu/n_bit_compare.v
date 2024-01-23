`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/21/2023 02:41:30 PM
// Design Name: 
// Module Name: n_bit_compare
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: n-bit comparator module using basic 1-bit comparison cell
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module n_bit_compare #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output eq,
    output lt,
    output gt
    );
    
    // wires to store comparison data
    wire [WIDTH-1:0] data_eq;
    wire [WIDTH-1:0] data_lt;
    wire [WIDTH-1:0] data_gt;
    
    // creating first bit comparator 
    comp_cell c0 (.a(a[0]), .b(b[0]), .eq0(1'b1), .lt0(1'b0), .gt0(1'b0), .eq1(data_eq[0]), .lt1(data_lt[0]), .gt1(data_gt[0]));
    
    // generating comparator from compare cell
    genvar i;
    generate
        for(i=1; i < WIDTH; i = i+1) // starting from second bit as first bit has set inputs for some ports
        begin: comp_cell_gen
        comp_cell cx (.a(a[i]), .b(b[i]), .eq0(data_eq[i-1]), .lt0(data_lt[i-1]), .gt0(data_gt[i-1]), .eq1(data_eq[i]), .lt1(data_lt[i]), .gt1(data_gt[i]));
        end
    endgenerate
     
    // assigning data to outputs
    assign eq = data_eq[WIDTH-1];
    assign lt = data_lt[WIDTH-1];
    assign gt = data_gt[WIDTH-1];
    
    
endmodule
