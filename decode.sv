`timescale 1ns / 1ps

module decode(
    input clk,
    input stall,
    input IDEXAfromWB,
    input IDEXBfromWB,
    input [31:0] IFIDIR,
    input [31:0] MEMWBValue,
    output reg [31:0] IDEXIR,
    output reg [31:0] IDEXA,
    output reg [31:0] IDEXB,
    output reg branchTaken,
    output reg [31:0] branchPCOffset
    );
    
     initial begin
        IDEXIR = no_op;
        IDEXA = no_op;
        IDEXB = no_op;
     end
     
     wire [5:0] IFIDop;
     assign IFIDop = IFIDIR[31:26];
    
    `include "parameters.sv"
    always @(posedge clk)begin
        if (stall) 
              begin// the first three pipeline stages stall if there is a load hazard or branch stall
                  //TODO inject NOPs
                 
                 
              end
         else begin
            //ID stage, with input from the WB stage
            IDEXIR <= IFIDIR;
            if (~IDEXAfromWB)
              IDEXA <= CPU.Regs[IFIDIR[25:21]]; // rs register value goes to IDEXA
            else
              IDEXA <= MEMWBValue;
            if (~IDEXBfromWB)
              IDEXB <= CPU.Regs[IFIDIR[20:16]]; // rt register value goes to IDEXB
            else
              IDEXB <= MEMWBValue;
              
            if (IFIDop == BEQINIT) begin
                 if (branchTaken)begin
                  //TODO set the value of R[rt] to 1
 		 end
            end
         end
    end      
    
    always @(*) begin //TODO set the branchTaken and branchPCOffset

    end

endmodule
