`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2024 11:30:21
// Design Name: 
// Module Name: full_adder
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


module full_adder(
    input   wire    iA, iB, iCarry,
    output  wire    oSum, oCarry
    );
    
    wire o1, o2, o3;
    
    assign o1 = iA ^ iB; 
    assign o2 = o1 & iCarry;
    assign o3 = iA & iB;
    assign oSum = o1 ^ iCarry;
    assign oCarry = o2 | o3; 
    
endmodule
