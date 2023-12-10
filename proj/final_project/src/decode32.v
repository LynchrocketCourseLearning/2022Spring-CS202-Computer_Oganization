`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/07 15:25:32
// Design Name: 
// Module Name: decode32
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


module decode32(
    read_data_1, read_data_2, Instruction, mem_data, ALU_result,
    Jal, RegWrite, MemtoReg, RegDst, Sign_extend, clock, reset, opcplus4,
    MemOrIOtoReg
    );
    output[31:0] read_data_1;               // 输出的第一操作数
    output[31:0] read_data_2;               // 输出的第二操作数
    
    input[31:0]  Instruction;               // 取指单元来的指令
    input[31:0]  mem_data;                  // 从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;                // 从执行单元来的运算的结果
    input        Jal;                       // 来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元
    input        MemtoReg;                  // 来自控制单元
    
    input        RegDst;             
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    
    input        clock, reset;              // 时钟和复位
    
    input[31:0]  opcplus4;                  // 来自取指单元，JAL中用
    
    input        MemOrIOtoReg;
    
    
    wire[5:0] opcode; 
    wire[4:0] rs;
    wire[4:0] rt;
    wire[4:0] rd;
    wire[15:0] immediate;
    
    assign opcode = Instruction[31:26];
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
    assign immediate = Instruction[15:0];
    
    // for sign extension
    // addi(001000)(sign), addiu(001001)(sign), 
    // slti(001010)(sign), sltiu(001011)(zero), 
    // andi(001100)(zero), ori(001101)(zero), xori(001110)(zero), 
    // lui(001111){imm, 16'b0} solve in ALU
    assign Sign_extend = ( (opcode == 6'b001100) || (opcode == 6'b001101) || (opcode == 6'b001110) || (opcode == 6'b001011) ) ?     
                    { {16{1'b0}}, immediate } :               // zero extend
                    { {16{Instruction[15]}}, immediate };     // sign extend
   
    wire[4:0] write_register;    // register address to be written
    wire[31:0] write_data;       // data to be written to register
    
    assign write_register = (RegWrite && Jal) ? 5'b11111 : ((RegDst) ? rd : rt);
//    assign write_data = (Jal) ? opcplus4 : ((MemtoReg) ? mem_data : ALU_result);
    assign write_data = (Jal) ? opcplus4 : ((MemOrIOtoReg) ? mem_data : ALU_result);
    
    // 5 bits -> [0, 31], totally 32 registers
    reg[31:0] register_group[0:31];
    integer i;
    always@(posedge clock) begin
        if (reset) for (i=0; i<=31; i=i+1) register_group[i] <= 32'h0000_0000;
        else if (RegWrite) 
            register_group[write_register] <= write_data;
    end
    
    assign read_data_1 = register_group[rs];
    assign read_data_2 = register_group[rt];
    
endmodule
