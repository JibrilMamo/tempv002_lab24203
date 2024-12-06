`timescale 1ns / 1ps

module execute(
    input bypassAfromMEM,
    input bypassAfromALUinWB,
    input bypassAfromLWinWB,
    input bypassBfromMEM,
    input bypassBfromALUinWB,
    input bypassBfromLWinWB,
    input clk,
    input  [31:0] IDEXIR,
    input [31:0] IDEXA,
    input [31:0] IDEXB,
    input [31:0] MEMWBValue,
    output reg [31:0] EXMEMB,
    output reg [31:0] EXMEMIR,
    output reg [31:0] EXMEMALUOut
    );
    
 `include "parameters.sv"
    
 wire [31:0] Ain;
 wire [31:0] Bin;   
 wire [5:0] IDEXop;
 
 assign IDEXop = IDEXIR[31:26];
    
 forward FWDTOEX(
     .bypassAfromMEM(bypassAfromMEM),
     .bypassAfromALUinWB(bypassAfromALUinWB),
     .bypassAfromLWinWB(bypassAfromLWinWB),
     .bypassBfromMEM(bypassBfromMEM),
     .bypassBfromALUinWB(bypassBfromALUinWB),
     .bypassBfromLWinWB(bypassBfromLWinWB),
     .IDEXA(IDEXA),
     .IDEXB(IDEXB),
     .MEMWBValue(MEMWBValue),
     .EXMEMALUOut(EXMEMALUOut),
     .Ain(Ain),
     .Bin(Bin)
    );
    
   initial begin
     EXMEMB = 0;
     EXMEMIR = 0;
     EXMEMALUOut = 0;
   end
    
     always @(posedge clk)begin
              if ((IDEXop==LW) |(IDEXop==SW)) begin // address calculation & copy B
                   //$display("Received a load/store instruction");
                   EXMEMALUOut <= Ain +{{16{IDEXIR[15]}}, IDEXIR[15:0]};
                   EXMEMIR <= IDEXIR; EXMEMB <= Bin; //pass along the IR & B register
              end
              else if (IDEXop==ALUop) begin
                case (IDEXIR[5:0]) //case for the various R-type instructions
                       32: begin
                              EXMEMALUOut <= Ain + Bin;  //add operation
                           end
                                                                         //TODO ... add cases for XOR, NAND, SGT, SRL 
                       default: ; //other R-type operations: subtract, SLT, etc.
                     endcase
                     EXMEMIR <= IDEXIR; //pass along the IR & B register
              end
              else if (IDEXop==CINDC) begin
                         if (Ain > 0) begin 
                             //TODO Assign Ain - Bin to EXMEMALUOut
                         end
                         else begin
                             //TODO Assign Ain + Bin to EXMEMALUOut
                         end  
                         EXMEMIR <= IDEXIR; //pass along the IR & B register
              end           
              else if (IDEXop==BEQINIT) begin
                        // Do n
                        EXMEMIR <= IDEXIR;
              end
       end
endmodule
