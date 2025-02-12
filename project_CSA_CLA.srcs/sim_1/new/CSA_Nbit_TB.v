`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2024 22:23:44
// Design Name: 
// Module Name: CSA_Nbit_TB
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


module CSA_Nbit_TB;
    localparam N = 16;
    reg [N-1:0]  r_iA, r_iB;
    reg r_iCin;
    wire [N-1:0]  w_Sum;
    wire w_Cout;
    
    CSA_Nbit  #(.N(N))
    inst(.iA(r_iA), .iB(r_iB), .iCin(r_iCin), .oSum(w_Sum), .oCout(w_Cout));
        
    integer i;
    
    initial 
    /*begin

       //test vector 1
    r_iA = 4'b0011; r_iB = 3'b0100; r_iCarry = 0; 
    #50
    if(w_oSum != 4'b0111 || w_oCarry != 4'b0000)    $display("test vector 1 failed"); 
    else                                $display("test vector 1 passed");
 
    
    $stop;*/
    begin

    $monitor ("(%d + %d + %d) = %d", r_iA, r_iB, r_iCin, {w_Cout, w_Sum});  

    // Use a for loop to apply random values to the input  
    for (i = 0; i < 8; i = i+1) 
    begin  
        #10 
        r_iA <= $random;  
        r_iB <= $random;  
        r_iCin <= $random;  
    end  
        
    end
endmodule
