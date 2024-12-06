`timescale 1ns / 1ps

module control(
     input [31:0] IFIDIR,
     input [31:0] IDEXIR,
     input [31:0] EXMEMIR,
     input [31:0] MEMWBIR,
     output bypassAfromMEM,
     output bypassBfromMEM,
     output bypassAfromALUinWB,
     output bypassBfromALUinWB,
     output bypassAfromLWinWB,
     output bypassBfromLWinWB,
     output IDEXAfromWB,
     output IDEXBfromWB,
     output stall
    );
    `include "parameters.sv"



   wire IDEXAfromMEM, IDEXBfromMEM, IDEXAfromEX, IDEXBfromEX, branchStall;
   wire [4:0] IDEXrs, IDEXrt, EXMEMrd, MEMWBrd, EXMEMrt, IFIDrs, IFIDrt; //hold register fields
   wire [5:0] EXMEMop, MEMWBop, IDEXop, IFIDop, IDEXrd ; //Hold opcodes

   assign IDEXrs = IDEXIR[25:21];  assign IDEXrt = IDEXIR[20:16];  assign EXMEMrd = EXMEMIR[15:11]; assign EXMEMrt = EXMEMIR[20:16];
   assign MEMWBrd = MEMWBIR[15:11]; assign EXMEMop = EXMEMIR[31:26];
   assign MEMWBop = MEMWBIR[31:26];  assign IDEXop = IDEXIR[31:26];
   assign IDEXrd = IDEXIR[15:11];
   assign IFIDop = IFIDIR[31:26]; assign IFIDrs = IFIDIR[25:21]; assign IFIDrt = IFIDIR[20:16];
   // The bypass to input A from the MEM stage for an ALU operation
   assign bypassAfromMEM = (IDEXrs == EXMEMrd) & (IDEXrs!=0) & (EXMEMop==ALUop | ((EXMEMop==CINDC))); // yes, bypass
   // The bypass to input B from the MEM stage for an ALU operation
   assign bypassBfromMEM = (IDEXrt == EXMEMrd)&(IDEXrt!=0) & (EXMEMop==ALUop | ((EXMEMop==CINDC))); // yes, bypass
   // The bypass to input A from the WB stage for an ALU operation
   assign bypassAfromALUinWB =( IDEXrs == MEMWBrd) & (IDEXrs!=0) & (MEMWBop==ALUop | ((MEMWBop==CINDC) ));
   // The bypass to input B from the WB stage for an ALU operation
   assign bypassBfromALUinWB = (IDEXrt == MEMWBrd) & (IDEXrt!=0) & (MEMWBop==ALUop |((MEMWBop==CINDC)));
   // The bypass to input A from the WB stage for an LW operation
   assign bypassAfromLWinWB =( IDEXrs == MEMWBIR[20:16]) & (IDEXrs!=0) & (MEMWBop==LW);
   // The bypass to input B from the WB stage for an LW operation
   assign bypassBfromLWinWB = (IDEXrt == MEMWBIR[20:16]) & (IDEXrt!=0) & (MEMWBop==LW);
 
   
   //Forwarding from the WB stage to the decode stage
   assign IDEXAfromWB = (MEMWBIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[25:21] == MEMWBIR[20:16]) & (MEMWBop == LW) | EXMEMop == BEQINIT) | ( (MEMWBop == ALUop) & (MEMWBrd == IFIDIR[25:21]))
     | ((MEMWBop == CINDC) & (MEMWBrd == IFIDIR[25:21])) );
   assign IDEXBfromWB = (MEMWBIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[20:16] == MEMWBIR[20:16]) & (MEMWBop == LW | EXMEMop == BEQINIT)) | ( (MEMWBop == ALUop) & (MEMWBrd == IFIDIR[20:16]))
     | ((MEMWBop == CINDC) & (MEMWBrd == IFIDIR[20:16])));   
    // Stalling from MEM stage to decode stage
       assign IDEXAfromMEM = (EXMEMIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[25:21] == EXMEMIR[20:16]) & (EXMEMop == LW | EXMEMop == BEQINIT)) | ( (EXMEMop == ALUop) & (EXMEMrd == IFIDIR[25:21]))
     | ((EXMEMop == CINDC) & (EXMEMrd == IFIDIR[25:21])) );
   assign IDEXBfromMEM = (EXMEMIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[20:16] == EXMEMIR[20:16]) & (EXMEMop == LW | EXMEMop == BEQINIT)) | ( (EXMEMop == ALUop) & (EXMEMrd == IFIDIR[20:16]))
     | ((EXMEMop == CINDC) & (EXMEMrd == IFIDIR[20:16])));
    // Stalling from EX stage to decode stage    
       assign IDEXAfromEX= (IDEXIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[25:21] == IDEXIR[20:16]) & (IDEXop == LW) | IDEXop == BEQINIT) | ( (IDEXop == ALUop) & (IDEXrd == IFIDIR[25:21]))
     | ((IDEXop == CINDC) & (IDEXrd == IFIDIR[25:21])) );
   assign IDEXBfromEX = (IDEXIR != no_op) & (IFIDIR != no_op) &
   (((IFIDIR[20:16] == IDEXIR[20:16]) & (IDEXop == LW | IDEXop == BEQINIT)) | ( (IDEXop == ALUop) & (IDEXrd == IFIDIR[20:16]))
     | ((IDEXop == CINDC) & (IDEXrd == IFIDIR[20:16])));
     
   assign branchStall = (IDEXIR[31:26]==BEQINIT) && (IDEXAfromMEM | IDEXBfromMEM | IDEXAfromEX | IDEXBfromEX | IDEXAfromWB | IDEXBfromWB);
    
   // The signal for detecting a stall based on the use of a result from LW
   assign stall = (IDEXIR[31:26]==LW) && // source instruction is a load
         ((((IFIDop==LW)) && (IFIDrs==IDEXrt)) | // stall for LW address calc
         ((IFIDop==ALUop) && ((IFIDrs==IDEXrt) | (IFIDrt==IDEXrt))) |  //ALU use
         ((IFIDop==SW) && ((IFIDrs==IDEXrt) | (IFIDrt==IDEXrt))) |  //stall for SW 
         ((IFIDop==CINDC) && ((IFIDrs==IDEXrt) | (IFIDrt==IDEXrt))) | // stall for CINDC
         branchStall);  //BEQINIT Hazard
endmodule
