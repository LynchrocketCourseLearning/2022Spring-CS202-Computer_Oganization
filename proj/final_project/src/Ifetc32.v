`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/08 22:17:33
// Design Name: 
// Module Name: Ifetc32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Ifetc32(
    Instruction_i, Instruction_o, branch_base_addr, Addr_result, Read_data_1, 
    Branch, nBranch, Jmp, Jal, Jr, Zero, clock, reset, link_addr, rom_adr_o
    );
    input[31:0] Instruction_i;
    output[31:0] Instruction_o;      // the instruction fetched from this module
    output[31:0] branch_base_addr;   // (pc+4) to ALU which is used by branch type instruction
    output reg [31:0] link_addr;    // (pc+4) to Decoder which is used by jal instruction
    output[13:0] rom_adr_o;
    
    input clock, reset;             // Clock and reset
    
    // from ALU
    input[31:0] Addr_result;        // the calculated address from ALU
    input Zero;                     // while Zero is 1, it means the ALUresult is zero
    
    // from Decoder
    input[31:0] Read_data_1;        // the address of instruction used by jr instruction
    
    // from Controller
    input Branch;                   // while Branch is 1,it means current instruction is beq
    input nBranch;                  // while nBranch is 1,it means current instruction is bnq
    input Jmp;                      // while Jmp 1, it means current instruction is jump
    input Jal;                      // while Jal is 1, it means current instruction is jal
    input Jr;                       // while Jr is 1, it means current instruction is jr
    
    reg[31:0] PC, Next_PC;
    
    assign Instruction_o = Instruction_i;
    assign rom_adr_o = PC[15:2];
    assign branch_base_addr = PC + 4;
    
    always @* begin
        if(((Branch == 1) && (Zero == 1)) || ((nBranch == 1) && (Zero == 0))) // beq, bne
            Next_PC = Addr_result; // the calculated new value for PC
        else if(Jr == 1) // jr
            Next_PC = Read_data_1; // the value of $31 register
        else // others
            Next_PC = PC + 4; // PC+4
    end
    
    always @(negedge clock) begin
        if(reset == 1)
            PC <= 32'h0000_0000;
        else if(Jmp == 1) begin // j
            PC <= {PC[31:28], Instruction_i[25:0], 2'b00}; // pseudo-direct addressing
            link_addr <= link_addr;
        end
        else if(Jal == 1) begin // jal
            PC <= {PC[31:28], Instruction_i[25:0], 2'b00}; // pseudo-direct addressing
            link_addr <= (PC + 4);
        end
        else 
            PC <= Next_PC;
    end
    
endmodule
