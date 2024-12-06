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
                case(IDEXIR[5:0]) // func field of the instruction
                    6'b100000: EXMEMALUOut = IDEXA + IDEXB; // ADD
                    6'b110010: EXMEMALUOut = IDEXA ^ IDEXB; // XOR
                    6'b110011: EXMEMALUOut = ~(IDEXA & IDEXB); // NAND
                    6'b110100: EXMEMALUOut = (IDEXA > IDEXB) ? 32'd1 : 32'd0; // SGT
                    6'b110101: EXMEMALUOut = IDEXA >> IDEXB; // SRL
                    default: EXMEMALUOut = 32'b0; // Default case
                endcase



                case (IDEXIR[5:0]) //case for the various R-type instructions
                      32: begin
                          EXMEMALUOut <= Ain + Bin;  //add operation
                      end
                      50: begin
                          EXMEMALUOut <= Ain ^ Bin;  //XOR
                      end
                      51: begin
                          EXMEMALUOut <= ~(Ain & Bin); //NAND
                      end
                      52: begin
                          EXMEMALUOut <= (Ain > Bin) ? 32'd1 : 32'd0; //SGT
                      end
                      53: begin
                          EXMEMALUOut <= Ain >> Bin; //SRL
                      end
                      default: ; //other R-type operations: subtract, SLT, etc.
                  endcase

                     EXMEMIR <= IDEXIR; //pass along the IR & B register
              end
              if(IDEXIR[31:26] == 6'b101111) begin // opcode for CINDC
                    if (IDEXA > 0)
                        EXMEMALUOut = IDEXA - IDEXB; // Conditional decrement
                    else
                        EXMEMALUOut = IDEXA + IDEXB; // Conditional increment
                end

//------------------------------------------------------
              else if (IDEXop==CINDC) begin
                  if (Ain > 0) begin
                      //TODO Assign Ain - Bin to EXMEMALUOut
                      EXMEMALUOut <= Ain - Bin;
                  end else begin
                      //TODO Assign Ain + Bin to EXMEMALUOut
                      EXMEMALUOut <= Ain + Bin;
                  end
                  EXMEMIR <= IDEXIR; //pass along the IR & B register
              end
              else if (IDEXop==BEQINIT) begin
                  // For BEQINIT, no ALU computation here, just pass IR
                  EXMEMIR <= IDEXIR;
              end
              
       end
endmodule
