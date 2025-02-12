`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 15:39:31
// Design Name: 
// Module Name: PFA
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


module PFA(
    input   wire    iA, iB, iCin,
    output  wire    oSum, oG, oP
    );
    
    wire o1;
    
    assign o1 = iA ^ iB;
    assign oSum = o1 ^ iCin;
    assign oG = iA & iB;
    assign oP = iA | iB;
    
endmodule
