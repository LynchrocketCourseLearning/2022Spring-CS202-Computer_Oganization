`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/07 14:46:20
// Design Name: 
// Module Name: control32
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


module control32(
    Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, 
    Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp,
    Alu_resultHigh, MemRead, IORead, IOWrite, MemOrIOtoReg
    );
    input[5:0] Opcode;              // instruction[31..26], Opcodecode
    input[5:0] Function_opcode;     // instructions[5..0], Function_opcode
    
    output Jr;                 // 1 indicates the instruction is "jr", otherwise it's not "jr" 
    output Jmp;                 // 1 indicate the instruction is "j", otherwise it's not
    output Jal;                 // 1 indicate the instruction is "jal", otherwise it's not
    output Branch;              // 1 indicate the instruction is "beq" , otherwise it's not
    output nBranch;             // 1 indicate the instruction is "bne", otherwise it's not
    output RegDST;              // 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output MemtoReg;            // 1 indicate read data from memory and write it into register
    output RegWrite;            // 1 indicate write register(R,I(lw)), otherwise it's not
    output MemWrite;            // 1 indicate write data memory, otherwise it's not
    output ALUSrc;              // 1 indicate the 2nd data is immidiate (except "beq","bne")
    output Sftmd;               // 1 indicate the instruction is shift instruction
    output I_format;            // 1 indicate the instruction is I-type but isn't "beq","bne","LW" or "SW" 
    output[1:0] ALUOp;          // if the instruction is R-type or I_format, ALUOpcode is 2'b10;
                                // if the instruction is"beq" or "bne", ALUOpcode is 2'b01£»
                                // if the instruction is"lw" or "sw", ALUOpcode is 2'b00£»
    
    // The real address of LW and SW is Alu_Result, the signal comes from the execution unit
    // From the execution unit Alu_Result[31..10], used to help determine whether to process Mem or I
    input[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output MemOrIOtoReg;        // 1 indicates that data needs to be read from memory or I/O to the register
    output MemRead;             // 1 indicates that the instruction needs to read from the memory
    output IORead;              // 1 indicates I/O read
    output IOWrite;             // 1 indicates I/O write
    
    
    wire R_format, Lw, Sw;
    assign R_format = (Opcode == 6'b000000) ? 1'b1 : 1'b0;
    assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;
    assign Lw = (Opcode == 6'b100011) ? 1'b1 : 1'b0;
    assign Sw = (Opcode == 6'b101011) ? 1'b1 : 1'b0;
                         
    assign RegDST = R_format;
    
    assign Jr = ((Opcode == 6'b000000) && (Function_opcode == 6'b001000)) ? 1'b1 : 1'b0;
    assign Jmp = (Opcode==6'b000010) ? 1'b1 : 1'b0;
    assign Jal = (Opcode==6'b000011) ? 1'b1 : 1'b0;
    assign Branch = (Opcode==6'b000100) ? 1'b1 : 1'b0;
    assign nBranch = (Opcode==6'b000101) ? 1'b1 : 1'b0;
    assign ALUSrc = (I_format || Lw || Sw) ? 1'b1 : 1'b0;
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
    
    assign Sftmd = (((Function_opcode == 6'b000000) || (Function_opcode == 6'b000010) 
                ||(Function_opcode == 6'b000011) || (Function_opcode == 6'b000100) 
                ||(Function_opcode == 6'b000110) || (Function_opcode == 6'b000111)) 
                && R_format)? 1'b1:1'b0;

    
    assign MemtoReg = Lw;
//    assign MemWrite = Sw;
    assign RegWrite = ((R_format || Lw || Jal || I_format) && !(Jr));
    
    assign MemWrite = (Sw && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1 : 1'b0;   // Write memory
    assign MemRead = (Lw && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1 : 1'b0;    // Read memory
    assign IORead = (Lw && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1'b1 : 1'b0;     // Read input port
    assign IOWrite = (Sw && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1'b1: 1'b0;     // Write output port
    
    // Read Opcodeerations require reading data from memory or I/O to write to the register
    assign MemOrIOtoReg = (IORead || MemRead);
endmodule
