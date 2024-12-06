`timescale 1ns / 1ps

module mem(
    input clk,
    input [31:0] EXMEMALUOut,
    input [31:0] EXMEMB, 
    input [31:0] EXMEMIR,
    output reg [31:0] MEMWBValue,
    output reg [31:0] MEMWBIR
    );

    wire [5:0] EXMEMop;    
    assign EXMEMop = EXMEMIR[31:26];

    initial begin
        MEMWBIR = no_op;
        MEMWBValue = 0;
    end 
     
    `include "parameters.sv"
    always @ (posedge clk)
    begin
        if (EXMEMop==ALUop) MEMWBValue <= EXMEMALUOut; //Pass along ALU result
              else if (EXMEMop == LW) MEMWBValue <= CPU.DMemory[EXMEMALUOut>>2]; //Load
              else if (EXMEMop == SW) CPU.DMemory[EXMEMALUOut>>2] <= EXMEMB; //Store
              else if (EXMEMop == CINDC) begin
                        MEMWBValue <= EXMEMALUOut;    
                   end
              else if (EXMEMop == BEQINIT) begin ; end // Do nothing
              MEMWBIR <= EXMEMIR; //pass along IR
    end
endmodule
