`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 21:38:02
// Design Name: 
// Module Name: CSA_4bit
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


module CSA_4bit(

    input wire [3:0] iA, iB,
    input wire iCin,
    output wire[3:0] oSum,
    output wire oCout
    );
    
    wire [3:0] oCout_i;
    
    
    genvar i; 
    generate
        for(i=0; i<4; i=i+1)
        begin
        if (i==0) begin
            full_adder inst_start(
            .iA(iA[0]), .iB(iB[0]), .iCarry(iCin), .oSum(oSum[0]), .oCarry(oCout_i[0]));
        end
        else begin
           CSelA CSelA_inst(
            .iA(iA[i]), .iB(iB[i]), .iCin(oCout_i[i-1]), .oSum(oSum[i]), .oCout(oCout_i[i]));
        end
        end
    endgenerate
    
   assign oCout = oCout_i[3];
   
endmodule