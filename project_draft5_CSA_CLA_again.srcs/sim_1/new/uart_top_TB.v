`timescale 1ns / 1ps

module uart_top_TB ();
 
  // We downscale the values in the simulation
  // this will give CLKS_PER_BIT = 100 / 10 = 10
  localparam CLK_FREQ_inst  = 125_000_000;
  localparam BAUD_RATE_inst = 10;
  localparam NBYTES_inst = OPERAND_WIDTH_inst /8;
  localparam OPERAND_WIDTH_inst = 128;
  localparam ADDER_WIDTH_inst = 16;
  localparam BAUD_RATE     = 115_200;
 
 //inputs
  reg  rClk = 0;
  reg rRst = 0;
  reg rRx = 0;
  reg [OPERAND_WIDTH_inst: 0]   rExpectedResult = 0;
  wire   wTx;
  
  // instantiate module under test
  uart_top #(.OPERAND_WIDTH(OPERAND_WIDTH_inst), .ADDER_WIDTH(ADDER_WIDTH_inst), .NBYTES(NBYTES_inst), 
  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst))
  uart_top_inst
    (.iClk(rClk),
     .iRst(rRst),
     .iRx(rRx),
     .oTx(wTx)
     );
     
localparam T  = 4;
 always 
  begin
    rClk = 1;
    #(T/2);
    rClk = 0;
    #(T/2);
  end

  initial
    begin
      rRst = 1;
      #(5*T);
      rRst = 0;
      #(5*T);
      
      rRx <= 256'h12121212_34343434_56565656_78787878_efefefef_cdcdcdcd_abababab_90909090;
      #T;
      //rExpectedResult = rRx[255:128] + rRx[127:0];
      
            
      // display the results in the terminal
      $display(wTx);
      
      
      #(5*T);
        
      $stop;
    end

endmodule