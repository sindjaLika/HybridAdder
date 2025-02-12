`timescale 1ns / 1ps

module uart_rx #(
  parameter   CLK_FREQ      = 125_000_000,
  parameter   BAUD_RATE     = 115_200,
  // Example: 125 MHz Clock / 115200 baud UART -> CLKS_PER_BIT = 1085 
  parameter   CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE
)
(
  input wire        iClk, iRst,
  input wire        iRxSerial,
  output wire [7:0] oRxByte, 
  output wire       oRxDone
);
    // Double-register the input wire to prevent metastability issues
    reg rRx1, rRx2;

    always @(posedge iClk)
    begin
        rRx1 <= iRxSerial;
        rRx2 <= rRx1;
    end
    
  // State definition  
  localparam sIDLE         = 3'b000;
  localparam sRX_START     = 3'b001;
  localparam sRX_DATA      = 3'b010;
  localparam sRX_STOP      = 3'b011;
  localparam sDONE         = 3'b100;
  
  // Register variables required to drive the FSM
  //---------------------------------------------
  // Remember:  -> 'current' is the register output
  //            -> 'next' is the register input
  
  // -> FSM state
  reg [2:0] rFSM_Current, wFSM_Next; 
  
  // -> counter to keep track of the clock cycles
  reg [$clog2(CLKS_PER_BIT*3):0]   rCnt_Current, wCnt_Next;
    
  // -> counter to keep track of sent bits
  // (between 0 and 7)
  reg [2:0] rBit_Current, wBit_Next;
  
  // -> the byte we want to send (we store an internal copy)
  reg [7:0] rRxData_Current, wRxData_Next;
  
      
    
  // Describe all previous registers
  //------------------------------------------ 
  // Needs to be done with a clocked always block 
  // Don't forget the synchronous reset (default state)
  
  always @(posedge iClk)
  begin
    if (iRst==1)
      begin
        rFSM_Current <= sIDLE;
        rCnt_Current <= 0;
        rBit_Current <= 0;
        rRxData_Current <= 0;
        // REMOVED: rRx1 <= 1;
        // REMOVED: rRx2 <= 1;
      end
    else
      begin
        rFSM_Current <= wFSM_Next;
        rCnt_Current <= wCnt_Next;
        rBit_Current <= wBit_Next;
        rRxData_Current <= wRxData_Next;
      end
  end
  
  // Next state logic
  //------------------------------------------ 
  // -> this is a COMBINATIONAL module, which specifies the next state 
  //    of the FSM and also the next value of the previous registers
  // -> to AVOID LATCHES, you need to make sure all the next register values
  //    ( rFSM_Next, rCnt_Next, rBit_Next, rTxData_Next)
  //    are defined for every possible condition
     
  always @(*)
    begin
      
      case (rFSM_Current)
      
        // IDLE STATE:
        // -> we simply wait here until iTxStart is asserted
        // -> when iTxStart is asserted, we copy the byte to send
        //    (iRxByte) into our local register (rRxData_Current)  
        //    and we are ready to start the frame transmission    
        sIDLE :
          begin
            wCnt_Next = 0;
            wBit_Next = 0;
             
            //instead of checking a wire iTxStart, check for start bit
            //so signal should be 1 everywhere then suddenly low 
            // BUG WAS HERE : rRx2 goes low on start bit...
            if (rRx2 == 0)
              begin
                wFSM_Next = sRX_START;
                wRxData_Next = 0; // CHANGED from rRx2;   // copy the byte to send into rTxData_Current
              end
            else
             begin    
                wFSM_Next = sIDLE;
                wRxData_Next = rRxData_Current;
             end
          end 
           
        // TX_START STATE:
        // -> we stay here for the duration of the start bit,
        //    which takes CLKS_PER_BIT clock cycles
        // -> we use rCnt_Current to keep track of clock cycles 

//        sRX_START :
//            begin
//              wRxData_Next = rRxData_Current;
//              wBit_Next = 0;
               
//              if (rCnt_Current < (CLKS_PER_BIT - 1) )
//                begin
//                  wFSM_Next = sRX_START;
//                  wCnt_Next = rCnt_Current + 1;
//                end
//              else
//                begin
//                  wFSM_Next = sRX_DATA;
//                  wCnt_Next = 0;
//                end
//            end

        sRX_START :
            begin
              //wRxData_Next = rRxData_Current;
              wBit_Next = 0; 
               
              if (rCnt_Current < ((CLKS_PER_BIT*3)/2- 1) )
                begin
                  wFSM_Next = sRX_START;
                  wCnt_Next = rCnt_Current + 1;
                  wRxData_Next = rRxData_Current;
                end
              else
                begin
                  wFSM_Next = sRX_DATA;
                  wCnt_Next = 0;
                  // ADDED: READ BIT
                  wRxData_Next = { rRx2, rRxData_Current[7:1] }; // shift rTxData_Current one bit to the right
                end
            end 
           
           
          // TX_DATA STATE:
          // -> we stay here for the duration of the byte sending,
          //    which takes 8 * CLKS_PER_BIT clock cycles     
          // -> we use rCnt_Current to keep track of clock cycles 
          // -> we use rBit_Current to keep track of number of bits
        
          // -> when rBit_Current increases, we shift the contents of the
          //    rTxData_Current register
          // -> why? by doing so, the LSB of rTxData_Current contains the
          //    bit we need to send
          // -> see below, where oTxSerial is assigned the value of rTxData_Current[0]
          
          
//          sRX_DATA :
//            begin
//              if (rCnt_Current == (CLKS_PER_BIT/2 - 1) )
//                begin
//                  wFSM_Next = sRX_DATA;
//                  wCnt_Next = rCnt_Current + 1;
//                  wRxData_Next = {rRx2, rRxData_Current[7:1] };
//                  wBit_Next = rBit_Current;
//                end
//              else if (rCnt_Current < (CLKS_PER_BIT - 1) )
//                begin
//                  wFSM_Next = sRX_DATA;
//                  wCnt_Next = rCnt_Current + 1;
//                  wRxData_Next = rRxData_Current;
//                  wBit_Next = rBit_Current;
//                end
//              else
//                begin
//                  wRxData_Next = rRxData_Current;
//                  wCnt_Next = 0;
                  
//                  if (rBit_Current != 7)
//                    begin
//                      wFSM_Next = sRX_DATA;
//                      wBit_Next = rBit_Current + 1;
//                    end
//                  else
//                    begin
//                      wFSM_Next = sRX_STOP;
//                      wBit_Next = 0;
//                    end
//                end
//            end  
          sRX_DATA :
            begin
              
              if (rCnt_Current < (CLKS_PER_BIT - 1) )
                begin
                  wFSM_Next = sRX_DATA;
                  wCnt_Next = rCnt_Current + 1;
                  wRxData_Next = rRxData_Current;
                  wBit_Next = rBit_Current;
                end
              else
                begin
                  wCnt_Next = 0;
                  
                  if (rBit_Current != 7)
                    begin
                      wFSM_Next = sRX_DATA;
                      wBit_Next = rBit_Current + 1;
                      wRxData_Next = { rRx2, rRxData_Current[7:1] }; // shift rTxData_Current one bit to the right
                    end
                  else
                    begin
                      wFSM_Next = sRX_STOP;
                      wBit_Next = 0;
                      wCnt_Next = 0;
                      wRxData_Next = rRxData_Current;
                    end
                end
            end  
            
           
          // TX_STOP STATE:
          // -> we stay here for the duration of the stop bit,
          //    which takes CLKS_PER_BIT clock cycles
          // -> we use rCnt_Current to keep track of clock cycles 
          sRX_STOP :
            begin
              wBit_Next = 0;
              wRxData_Next = rRxData_Current;
                  
              // ADDED: Wait until out of stop bit
              if (rCnt_Current < (CLKS_PER_BIT - 1) )
                begin
                  wFSM_Next = sRX_STOP;
                  wCnt_Next = rCnt_Current + 1;
                end
              else
                begin
                  wFSM_Next = sDONE;
                  wCnt_Next = 0;
                end
            end 
           
           
          // DONE STATE:
          // -> we stay here 1 clock cycle, we will use this state
          //    to assert the output oDone 
          sDONE :
            begin
              wRxData_Next = rRxData_Current;
              wBit_Next = 0;
              wCnt_Next = 0;
              wFSM_Next = sIDLE;
            end
           
           
          default :
            begin
              wFSM_Next = sIDLE;
              wCnt_Next = 0;
              wBit_Next = 0;
              wRxData_Next = 0;
            end 
        endcase
    end
    

 
  // 3. Output logic
  //------------------------------------------ 
  // -> these are COMBINATIONAL circuits, which specify the value of
  //    the outputs, based on the current state of the registers used
  //    in the FSM
  
  
  // Output oTxSerial : easiest is to define it with a combinational
  //  always block
  //  -> it is '1' by default
  //  -> it is '0' during the start bit
  //  -> it is rTxData_Current[0] during the sending of bits
  //  -> it is '1' during the stop bit
  
  
  assign oRxByte = rRxData_Current;
  
  // Output oTxBusy : easiest is to define it with a simple
  // continuous assignment
  //  -> it is '0' when FSM in sIDLE or sDONE
  //  -> it is '1' otherwise

  assign oRxDone = (rFSM_Current == sDONE) ? 1 : 0;
   
endmodule
