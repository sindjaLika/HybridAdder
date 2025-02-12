`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 16:14:31
// Design Name: 
// Module Name: CLA
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


module CLA #(
     parameter   ADDER_WIDTH = 8
    )
    (
    input   wire [ADDER_WIDTH-1:0]  iA, iB, 
    input   wire                    iCin,
    output  wire [ADDER_WIDTH-1:0]  oSum, 
    output  wire                    oCout
    );
    
    wire [ADDER_WIDTH:0] oC;
    wire [ADDER_WIDTH-1:0] oG;
    wire [ADDER_WIDTH-1:0] oP;
    
    genvar i;
    
    generate
        for(i=1; i<ADDER_WIDTH+1; i=i+1)
        begin
        if (i==1) begin
            PFA  inst0(
            .iA(iA[i-1]), .iB(iB[i-1]), 
            .iCin(iCin), .oSum(oSum[i-1]), 
            .oG(oG[i-1]), .oP(oP[i-1]));
        end
        else if (i==ADDER_WIDTH) begin
            PFA  inst_last(
            .iA(iA[ADDER_WIDTH-1]), .iB(iB[ADDER_WIDTH-1]), 
            .iCin(oC[ADDER_WIDTH-1]), .oSum(oSum[ADDER_WIDTH-1]), 
            .oG(oG[ADDER_WIDTH-1]), .oP(oP[ADDER_WIDTH-1]));
        end
        else begin
            PFA  inst0(
            .iA(iA[i-1]), .iB(iB[i-1]), 
            .iCin(oC[i-1]), .oSum(oSum[i-1]), 
            .oG(oG[i-1]), .oP(oP[i-1]));
        end
        end
    endgenerate
    
    assign oC[0] = iCin;
    assign oC[1] = oG[0] | (oP[0]&oC[0]);
    assign oC[2] = oG[1] | (oP[1]&oG[0]) | (oP[1]&oP[0]&oC[0]);
    assign oC[3] = oG[2] | (oP[2]&oG[1]) | (oP[2]&oP[1]&oG[0]) | (oP[2]&oP[1]&oP[0]&oC[0]);
    assign oC[4] = oG[3] | (oP[3]&oG[2]) | (oP[3]&oP[2]&oG[1]) | (oP[3]&oP[2]&oP[1]&oG[0]) | (oP[3]&oP[2]&oP[1]&oP[0]&oC[0]);
    assign oC[5] = oG[4] | (oP[4]&oG[3]) | (oP[4]&oP[3]&oG[2]) | (oP[4]&oP[3]&oP[2]&oG[1]) | (oP[4]&oP[3]&oP[2]&oP[1]&oG[0]) | (oP[4]&oP[3]&oP[2]&oP[1]&oP[0]&oC[0]);
    assign oC[6] = oG[5]| (oP[5]&oG[4]) | (oP[5]&oP[4]&oG[3]) | (oP[5]&oP[4]&oP[3]&oG[2]) | (oP[5]&oP[4]&oP[3]&oP[2]&oG[1]) | (oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oG[0]) | (oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oP[0]&oC[0]);
    assign oC[7] = oG[6] | (oP[6]&oG[5])| (oP[6]&oP[5]&oG[4]) | (oP[6]&oP[5]&oP[4]&oG[3]) | (oP[6]&oP[5]&oP[4]&oP[3]&oG[2]) | (oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oG[1]) | (oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oG[0]) | (oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oP[0]&oC[0]);
    assign oC[8] = oG[7]| (oP[7]&oG[6]) | (oP[7]&oP[6]&oG[5])| (oP[7]&oP[6]&oP[5]&oG[4]) | (oP[7]&oP[6]&oP[5]&oP[4]&oG[3]) | (oP[7]&oP[6]&oP[5]&oP[4]&oP[3]&oG[2]) | (oP[7]&oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oG[1]) | (oP[7]&oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oG[0]) | (oP[7]&oP[6]&oP[5]&oP[4]&oP[3]&oP[2]&oP[1]&oP[0]&oC[0]);
    assign oCout = oC[8];
    
endmodule
