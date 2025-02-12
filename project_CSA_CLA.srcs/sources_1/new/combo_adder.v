`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2024 22:30:14
// Design Name: 
// Module Name: combo_adder
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


module combo_adder#(
        //N = OPERAND_WIDTH
        //M = ADDER_WIDTH
        //don't get angry Nadia
        parameter N = 16,
        parameter M = 4
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
            CLA #(.ADDER_WIDTH(M)) 
            inst_start(
            .iA(iA[(i*(M)+(M-1)) : i*(M)]), .iB(iB[(i*(M)+(M-1)) : i*(M)]), .iCin(iCin), .oSum(oSum[(i*(M)+(M-1)) : i*(M)]), .oCout(oCout_i[i]));
        end
        else begin
           CSelA_w_CLA #(.M(M))
           inst(
            .iA(iA[(i*(M)+(M-1)) : i*(M)]), .iB(iB[(i*(M)+(M-1)) : i*(M)]), .iCin(oCout_i[i-1]), .oSum(oSum[(i*(M)+(M-1)) : i*(M)]), .oCout(oCout_i[i]));
        end
        end
    endgenerate
    
   assign oCout = oCout_i[(N/M)-1];
   
endmodule
