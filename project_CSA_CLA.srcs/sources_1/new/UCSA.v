`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 22:58:20
// Design Name: 
// Module Name: UCSA
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


module UCSA #(
        //N = OPERAND_WIDTH
        //M = ADDER_WIDTH
        //don't get angry Nadia
        parameter N = 16,
        parameter M = 8
)(
    input wire [N-1:0] iA, iB,
    input wire iCin,
    output wire [N-1:0] oSum,
    output wire oCout
    );
    
    wire [(N/M)-1:0] oCout_i;
    
    
    genvar i; 
    generate
        for(i=0; i<N/M; i=i+1)
        begin
        if (i==0) begin
            ripple_carry_adder_Nb #(.ADDER_WIDTH(M)) 
            inst_start(
            .iA(iA[(i*(M)+(M-1)) : i*(M)]), .iB(iB[(i*(M)+(M-1)) : i*(M)]), .iCarry(iCin), .oSum(oSum[(i*(M)+(M-1)) : i*(M)]), .oCarry(oCout_i[i]));
        end
        else begin
           UCSelA #(.M(M))
           UCSelA_inst(
            .iA(iA[(i*(M)+(M-1)) : i*(M)]), .iB(iB[(i*(M)+(M-1)) : i*(M)]), .iCin(oCout_i[i-1]), .oSum(oSum[(i*(M)+(M-1)) : i*(M)]), .oCout(oCout_i[i]));
        end
        end
    endgenerate
    
   assign oCout = oCout_i[(N/M)-1];
  
endmodule
