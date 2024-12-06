`timescale 1ns / 1ps

module wb(
    input clk,
    input [31:0] MEMWBValue,  
    input [31:0] MEMWBIR
    );
    
    wire [5:0] MEMWBop;
    wire [5:0] MEMWBrd;
    assign MEMWBop = MEMWBIR[31:26];
    assign MEMWBrd = MEMWBIR[15:11];    
     
   `include "parameters.sv"
   always @(posedge clk)
   begin
       if ((MEMWBop==ALUop) & (MEMWBrd != 0)) CPU.Regs[MEMWBrd] <= MEMWBValue; // ALU operation
          else if ((MEMWBop == LW) & (MEMWBIR[20:16] != 0))
                begin
                   //$display("The MEMWBValue is %d", MEMWBValue); 
                   CPU.Regs[MEMWBIR[20:16]] <= MEMWBValue; // Load operation
                end
          else if ( MEMWBop == CINDC ) CPU.Regs[MEMWBrd] <= MEMWBValue;
          else if ( MEMWBop == BEQINIT ) begin ; end // Do nothing
   end
endmodule
