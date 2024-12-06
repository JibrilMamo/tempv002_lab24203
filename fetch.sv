`timescale 1ns / 1ps

module fetch(
      input clk,
      input branchTaken,
      input stall,
      input [31:0] PC,
      output reg [31:0] IFIDIR
    );
     `include "parameters.sv"
     
     initial begin
        IFIDIR = no_op;
     end 
     
    always @(posedge clk) begin
        if (branchTaken) begin // the indirect jump has been resolved
             IFIDIR <= no_op;
          end
          else if (stall) begin
             IFIDIR <= IFIDIR;
          end
          else begin
             IFIDIR <= CPU.IMemory[PC>>2];
          end
    end
endmodule