`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 19:48:25
// Design Name: 
// Module Name: CSelA
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


module CSelA (
        input wire iA, iB,
        input wire iCin, 
        output wire oSum, 
        output wire oCout
    );
    
   // wire iCin_0, iCin_1;
    wire oCout_0, oCout_1;
    wire oSum_0, oSum_1;
    
    full_adder inst0(
    .iA(iA), .iB(iB), .iCarry(0), .oSum(oSum_0), .oCarry(oCout_0));
    
    full_adder inst1(
    .iA(iA), .iB(iB), .iCarry(1), .oSum(oSum_1), .oCarry(oCout_1));
    
    assign oSum = (iCin == 0) ? oSum_0 : oSum_1; 
    assign oCout = (iCin == 0) ? oCout_0 : oCout_1;
    
    
 
endmodule
