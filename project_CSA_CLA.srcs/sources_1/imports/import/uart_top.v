`timescale 1ns / 1ps

module uart_top #(
    parameter   OPERAND_WIDTH = 512,
    parameter   ADDER_WIDTH   = 16,
    parameter   NBYTES        = OPERAND_WIDTH / 8,    
    // values for the UART (in case we want to change them)
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
)  
(
    input   wire   iClk, iRst,
    input   wire   iRx,
    output  wire   oTx,
    //output to debug state
    output wire    oLED_RX_A,
    output wire    oLED_RX_B,
    output wire    oLED_ADDER,
    output wire    oLED_TX
);
  
  // Buffer to exchange data between Pynq-Z2 and laptop
  //reg [NBYTES*8-1:0] rBuffer;
  
  // State definition  
  localparam s_IDLE         = 3'b000;
  localparam s_RX_A         = 3'b001;
  //localparam s_WAIT_RX      = 4'b0010;
  localparam s_RX_B         = 3'b010;
  localparam s_ADDER_START  = 3'b011;
  localparam s_TX           = 3'b100;
  localparam s_WAIT_TX      = 3'b101;
  localparam s_DONE         = 3'b110;
  //localparam s_ADDER_STOP   = 4'b1000;
   
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [2:0]   rFSM;  
  
  // Connection to UART TX (inputs = registers, outputs = wires)
  reg         rTxStart;
  reg [7:0]   rTxByte;
  
  //Connection to mp_adder
  reg [NBYTES*8-1:0]      rOpA, rOpB;
  reg         rAddStart;
  reg [(NBYTES+1)*8-1:0]         rRes; //NYBYTES + 1 or NYBTES only?
  
  wire        wAddDone;
  wire [NBYTES*8:0]       wRes;
  
  wire        wTxBusy;
  wire        wTxDone;
  wire [7:0]  wRxByte;
  wire        wRxDone;
      
  //transmitter that will actually print the value in jupyter
  uart_tx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(oTx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
     
  //receiver that captures that value written by ser.write()
  uart_rx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) ) 
  UART_RX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iRxSerial(iRx),
     .oRxByte(wRxByte),
     .oRxDone(wRxDone)
     );
     
  mp_adder #( .OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(ADDER_WIDTH) )
  mp_adder_INST
  ( .iClk(iClk), .iRst(iRst), .iStart(rAddStart), .iOpA(rOpA), .iOpB(rOpB), 
  .oRes(wRes), .oDone(wAddDone));
     
  reg [$clog2(NBYTES):0] rCnt;
 // reg  rRcv; //ADDED: keeps track of how many NBYTESeen read, should only be 2
  
  always @(posedge iClk)
  begin
  
  // reset all registers upon reset
  if (iRst == 1 ) 
    begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
     // rRcv <= 0;
      rTxByte <= 0;
      rAddStart <= 0;
      //rRes <= 0;
      // rBuffer <= {8'b0, rBuffer[NBYTES*8-9:8]}; CHANGED
      //rBuffer <= 0
     rOpA<= 0;
     rOpB<= 0;
    end 
  else 
    begin
      case (rFSM)
   
        s_IDLE :
          begin
            rFSM <= s_RX_A;
            rOpA <= 0;
            rOpB <= 0;
            rRes <= 0;
          end
          
        //NEW PLAN: Make 2 seperate RX, in which for each state, store immediately
       //to OpA and OpB  
       
       s_RX_A:
          begin
            if ( rCnt < NBYTES )
              begin
              rFSM <= s_RX_A;  
                if ( wRxDone )
                  begin
                    rCnt <= rCnt + 1;
                    rOpA <= {rOpA[NBYTES*8-9:0] , wRxByte};
                  end       
              end
            else
              begin
                rFSM <= s_RX_B; 
               //rBuffer <= 0;
                rCnt <= 0;
              end     
          end
          
          s_RX_B:
          begin
            //rBuffer <= "Hello World!";       
            if ( rCnt < NBYTES )
              begin
              rFSM <= s_RX_B;     
                if ( wRxDone )
                  begin
                    rCnt <= rCnt + 1;
                    rOpB <= {rOpB[NBYTES*8-9:0],wRxByte};
                  end   
              end
            else
              begin
                rFSM <= s_ADDER_START; 
                rCnt <= 0;
                //rBuffer <= 0;
                rAddStart = 1;
              end     
          end
          
//        s_RX:
//          begin
//            //rBuffer <= "Hello World!";       
//            if ( rCnt < 2* NBYTES )
//              begin
//                if ( wRxDone )
//                  begin
//                    rCnt <= rCnt + 1;
//                    rBuffer <= {rBuffer[NBYTES*8-9:0] , wRxByte};
//                  end
//                rFSM <= s_RX;              
//              end
//            else
//              begin
//                rFSM <= s_STORE_OPS; // CHANGED: Here replace with move to s_STORE_OPS states 
//                rCnt <= 0;
//              end     
//          end
          
          //ADDED: define new state to transfer read value to iOpA and iOpB
//          s_STORE_OPS:
//            begin
//                if (rRcv < 2)
//                    begin
//                        if (rRcv == 0)
//                            begin
//                                rOpA <= rBuffer;
//                            end
                            
//                        else
//                            begin
//                                rOpB <= rBuffer;
//                            end
                            
//                        rBuffer <= 0;
//                        rRcv <= rRcv + 1;
//                        rFSM <= s_RX;
//                    end
//                else
//                    begin 
//                        rFSM <= s_ADDER;
//                        rAddStart <= 1;
//                    end
//            end
          
          //ADDED: keep adding till done signal 
          s_ADDER_START: 
            begin
                rAddStart = 0;
                if (wAddDone)
                    begin
                        rRes <= {7'b00000000,wRes}; // Note: if this doesn't work add 7'b0 in front (left)
                        rFSM <= s_TX;
                    end
                else
                    begin
                        rRes <= rRes;
                        rFSM <= s_ADDER_START;
                    end
            end
            
//          s_ADDER_STOP:
//            begin
//                rAddStart <= 0;
//                rFSM <= s_TX;
//            end
          
                  
//        s_RX :
//          begin
//            if ( (rCnt < NBYTES) ) 
//              begin
//                rFSM <= s_WAIT_RX;
//                // MOVED: rBuffer <= {wRxByte, rBuffer[NBYTES*8-9:0]};    // Shift in the buffer from right to left
//                rCnt <= rCnt + 1;            //continue shifting in as long as NBYTES hasnt reached
//              end 
//            else 
//              begin
//                rFSM <= s_TX;
//                //rTxByte <= 0; // first byte to send is carry prepended with 0000000 ?
//                rCnt <= 0;
//              end
//            end 
            
//            s_WAIT_RX :
//              begin
//                if (wRxDone) begin
//                  // MOVED TO HERE and put wRxByte on the LSB side:
//                  rBuffer <= {rBuffer[NBYTES*8-9:0],wRxByte};    // Shift in the buffer from right to left  
//                  rFSM <= s_RX;
//                end else begin
//                  rFSM <= s_WAIT_RX;                 
//                end
//              end 
             
        s_TX :
          begin
            if ( (rCnt < NBYTES+1) && (wTxBusy ==0) ) 
              begin
                rFSM <= s_WAIT_TX;
                rTxStart <= 1; 
                rTxByte <= rRes[(NBYTES+1)*8-1:(NBYTES+1)*8-8];            // we send the uppermost byte
                rRes <= {rRes[(NBYTES+1)*8-9:0] , 8'b00000000};    // we shift from right to left
                rCnt <= rCnt + 1;
              end 
            else 
              begin
                rFSM <= s_DONE;
                rTxStart <= 0;
                rTxByte <= 0;
                rCnt <= 0;
              end
            end 
            
            s_WAIT_TX :
              begin
                if (wTxDone) begin
                  rFSM <= s_TX;
                end else begin
                  rFSM <= s_WAIT_TX;
                  rTxStart <= 0;                   
                end
              end 
              
            s_DONE :
              begin
                rFSM <= s_IDLE;
              end 

            default :
              rFSM <= s_IDLE;
             
          endcase
      end
    end       
    
  assign oLED_RX_A = (rFSM == s_RX_A) ? 1:0;
  assign oLED_RX_B = (rFSM == s_RX_B) ? 1:0;
  assign oLED_ADDER = (rFSM == s_ADDER_START) ? 1:0;
  assign oLED_TX = (rFSM == s_TX)? 1:0;
endmodule