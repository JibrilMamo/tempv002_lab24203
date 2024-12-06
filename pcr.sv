`timescale 1ns / 1ps

module prc(
     input clk,
     input branchTaken,
     input stall,
     input [31:0] branchPCOffset,
     output reg [31:0] PC
    );
    
    initial
    begin
        PC = 0;
    end
    
    always @(posedge clk)
    begin

      if (branchTaken) begin 
         PC <= PC + branchPCOffset;
         end
         else if (stall) begin
            PC <= PC; 
         end
         else begin
            PC <= PC + 4; 
         end

      
     end
endmodule
