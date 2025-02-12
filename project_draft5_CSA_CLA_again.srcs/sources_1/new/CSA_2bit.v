`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 20:22:22
// Design Name: 
// Module Name: CSA_2bit
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


module CSA_2bit(
    input [1:0] iA, iB,
    input iCin,
    output [1:0] oSum,
    output oCout
    );
    
    wire oCout_start;
    
    full_adder inst_start(
    .iA(iA[0]), .iB(iB[0]), .iCarry(iCin), .oSum(oSum[0]), .oCarry(oCout_start));
    
    CSelA CSelA_inst(
    .iA(iA[1]), .iB(iB[1]), .iCin(oCout_start), .oSum(oSum[1]), .oCout(oCout));
    
endmodule
