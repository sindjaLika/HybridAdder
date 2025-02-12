`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 22:16:23
// Design Name: 
// Module Name: CSelA_w_CLA
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


module CSelA_w_CLA #(
    //Again don't get mand
    //M = ADDER_WIDTH = amount of PFA involved
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
    
     CLA #(.ADDER_WIDTH(M))
     inst0(.iA(iA), .iB(iB), .iCin(0), .oSum(oSum_0), .oCout(oCout_0));
    
     CLA #(.ADDER_WIDTH(M))
     inst1(.iA(iA), .iB(iB), .iCin(1), .oSum(oSum_1), .oCout(oCout_1));
    
    genvar i;
    for(i=0; i<M; i=i+1)
        begin
            assign oSum[i] = (iCin == 0) ? oSum_0[i] : oSum_1[i]; 
        end
    
    assign oCout = (iCin == 0) ? oCout_0 : oCout_1;
    
endmodule
