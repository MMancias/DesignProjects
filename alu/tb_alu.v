`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Miguel Mancias
// 
// Create Date: 09/29/2023 01:30:07 PM
// Design Name: 
// Module Name: tb_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench to test ALU functionality
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// setting timescale
`timescale 1ns/1ps
module tb_alu(); // tb module has no ports

    // defining uut local signals
    reg [3:0] tb_in_a; // input a for alu
    reg [3:0] tb_in_b; // input b for alu
    reg [3:0] tb_in_func_sel; // function select input
    wire [3:0] tb_out_r; // result 
    wire tb_out_ov_sgn; // adder overflow (or subtraction sign) signal
    
    // other local variables
    parameter period = 50; // constant period 50ns
    integer i; // first index variable
    integer j; // second index variable
    
    // defining unit under test
    alu #(.WIDTH(4)) uut ( // creating a 4-bit alu
    .a(tb_in_a),
    .b(tb_in_b),
    .func_sel(tb_in_func_sel),
    .r(tb_out_r),
    .ov_sgn(tb_out_ov_sgn)
    );
    
    // testing vectors
    initial
    begin
        // max value would be 3'b111 due to max function select values
        for (i = 0; i <= 3'b111; i = i+1) // iterating through function select
        begin
        tb_in_func_sel = i;
        # period;
            case(tb_in_func_sel)
            3'b000: begin // adder
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b001: begin // subtraction
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b010: begin // compare
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b011: begin // 2's complement (one input only)
                    for(j = 0; j <= 4'b1111; j = j+1) begin
                    {tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b100: begin // AND
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b101: begin // OR
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b110: begin // XOR
                    for(j = 0; j <= 8'b11111111; j = j+1) begin
                    {tb_in_b, tb_in_a} = j;
                    # period;
                    end
            end
            
            3'b111: begin // rotate 
                    for(j = 0; j <= 4'b1111; j = j+1) begin // Rotate right (one input only)
                    tb_in_func_sel[3] = 1'b1; // testing rotate right
                    {tb_in_a} = j;
                    # period;
                    end
                    
                    for(j = 0; j <= 4'b1111; j = j+1) begin // Rotate left (one input only)
                    tb_in_func_sel[3] = 1'b0; // testing rotate left
                    {tb_in_a} = j;
                    # period;
                    end
            end
            endcase 
            
        end
    # (period*5) $stop; // run 5 more periods and stop
    end

endmodule

