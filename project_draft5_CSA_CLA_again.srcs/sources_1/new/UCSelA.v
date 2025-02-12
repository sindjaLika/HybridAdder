`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 23:05:03
// Design Name: 
// Module Name: UCSelA
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


module UCSelA #(
    //Again don't get mand
    //M = ADDER_WIDTH = ripplecarryadder_Mbit
    parameter M = 4
)(
   input wire [M-1:0] iA, iB,
   input wire iCin, 
   output wire [M-1:0] oSum,
   output wire oCout
    );
    
   // wire iCin_0, iCin_1;
    wire oCout_0, oCout_1;
    wire [M-1:0]oSum_0, oSum_1;
    
     ripple_carry_adder_Nb #(.ADDER_WIDTH(M))
     inst0(.iA(iA), .iB(iB), .iCarry(0), .oSum(oSum_0), .oCarry(oCout_0));
    
     ripple_carry_adder_Nb #(.ADDER_WIDTH(M))
     inst1(.iA(iA), .iB(iB), .iCarry(1), .oSum(oSum_1), .oCarry(oCout_1));
    
    genvar i;
    for(i=0; i<M; i=i+1)
        begin
            assign oSum[i] = (iCin == 0) ? oSum_0[i] : oSum_1[i]; 
        end
    
    assign oCout = (iCin == 0) ? oCout_0 : oCout_1;
    
endmodule
