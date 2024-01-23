`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2023 05:28:48 PM
// Design Name: 
// Module Name: comp_cell_2bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module comp_cell_2bit(
    input [1:0] a,
    input [1:0] b,
    output eq,
    output lt,
    output gt
    );
    
    // local wire
    wire [1:0] data_eq;
    wire [1:0] data_lt;
    wire [1:0] data_gt;
    
    comp_cell c1 (.a(a[0]), .b(b[0]), .eq0(1'b1), .lt0(1'b0), .gt0(1'b0), .eq1(data_eq[0]), .lt1(data_lt[0]), .gt1(data_gt[0]));
    comp_cell c2 (.a(a[1]), .b(b[1]), .eq0(data_eq[0]), .lt0(data_lt[0]), .gt0(data_gt[0]), .eq1(data_eq[1]), .lt1(data_lt[1]), .gt1(data_gt[1]));
    
    assign eq = data_eq[1];
    assign lt = data_lt[1];
    assign gt = data_gt[1];
    
endmodule
