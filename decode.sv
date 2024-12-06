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
        branchTaken = 1'b0;
        branchPCOffset = 32'd0;
    end
     
    wire [5:0] IFIDop;
    assign IFIDop = IFIDIR[31:26];

    `include "parameters.sv"

    // Sequential Logic for Decode Stage
    always @(posedge clk) begin
        if (stall) begin
            IDEXIR <= no_op;
            IDEXA  <= no_op;
            IDEXB  <= no_op;
            branchTaken <= 1'b0;
            branchPCOffset <= 32'd0;
        end else begin
            IDEXIR <= IFIDIR;

            if (~IDEXAfromWB)
                IDEXA <= CPU.Regs[IFIDIR[25:21]]; // rs register value goes to IDEXA
            else
                IDEXA <= MEMWBValue;

            if (~IDEXBfromWB)
                IDEXB <= CPU.Regs[IFIDIR[20:16]]; // rt register value goes to IDEXB
            else
                IDEXB <= MEMWBValue;
        end
    end      

    reg [31:0] signExtImm;

    // Combinational Logic for Branch Signals
    always @(*) begin
        branchTaken = 1'b0;
        branchPCOffset = 32'd0;

        signExtImm = {{16{IFIDIR[15]}}, IFIDIR[15:0]};

        if (IFIDop == BEQINIT) begin
            branchTaken = (CPU.Regs[IFIDIR[25:21]] == CPU.Regs[IFIDIR[20:16]]) ? 1'b1 : 1'b0;
            branchPCOffset = signExtImm << 2;
        end
    end

endmodule
