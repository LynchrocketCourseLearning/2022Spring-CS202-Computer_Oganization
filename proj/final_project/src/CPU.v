`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/11 08:10:04
// Design Name: 
// Module Name: CPU
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


module CPU(
    input fpga_rst,                 // rst signal from board
    input fpga_clk,                 // from Y18 on board
    input[23:0] switch2N4,          // 24 switchs from board
    output[23:0] led2N4,            // 24 leds from board
    output [7:0] bit_sel,           // 0 for selecting the segment display in the corresponding position
    output [7:0] seg_out,
    // UART
    input start_pg,                 // Active High
    input rx,                       // recieve data by UART
    output tx                       // send data by UART
    );
    
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o;                   // Uart write out enable
    wire upg_done_o;                  // Uart rx data have done
    // data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    // data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
    
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
    // Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge fpga_clk) begin
        if (spg_bufg) upg_rst = 0;
        if (fpga_rst) upg_rst = 1;
    end
    // used for other modules which don't relate to UART
    wire rst;
    assign rst = fpga_rst | !upg_rst;
    
    uart_bmpg_0 uart(
        .upg_clk_i(upg_clk),
        .upg_rst_i(upg_rst),
        .upg_rx_i(rx),
        .upg_clk_o(upg_clk_o),
        .upg_wen_o(upg_wen_o),
        .upg_adr_o(upg_adr_o),
        .upg_dat_o(upg_dat_o),
        .upg_done_o(upg_done_o),
        .upg_tx_o(tx)
    );
    
    // clock
    wire cpu_clk;                        // cpu_clk: 23Mhz from cpuclk
    cpuclk cpuclk(
        .clk_in1(fpga_clk),               // 100MHz
        .clk_out1(cpu_clk),
        .clk_out2(upg_clk)
    );
    
    // from ifetch
    wire[31:0] instruction_o;             // to controller
    wire[31:0] opcplus4_decode;           // to decoder (pc+4)
    wire[31:0] opcplus4_alu;              // to ALU (pc+4)
    wire[13:0] rom_adr_o;                 // to programrom 
    
   // from decoder
    wire[31:0] read_data_1;               // to ifetch, ALU
    wire[31:0] read_data_2;               // to ALU, MemIO
    wire[31:0] sign_extend;               // to ALU 
    
    // from controller
    wire iowrite,ioread;                  // to MemIO
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire memwrite;
    wire memread;
    wire memoriotoreg;
    wire memreg;
    wire sftmd;
    wire[1:0] aluop;                       // to ALU
    
    // from ALU   
    wire zero;    
    wire[31:0] addr_result;  
    wire[31:0] alu_result;   

    // from dmemory
    wire[31:0] read_data;                // data read from memory
    
    // from MemOrIO
    wire[31:0] write_data;               // data written into memory or I/O
    wire[31:0] address;                  // address sent to IO device and memory
    wire ledctrl,switchctrl, segctrl;    // control with IO device is enabled
    wire[31:0] rdata;                    // data read from mem/IO, written into register
     
    // from programrom
    wire[31:0] instruction_i;             // to ifetch
    
    // from IOread
    wire[15:0] ioread_data;              // data read from IO
    
    // from switch 
    wire[15:0] ioread_data_switch;       // data read from switch
    
    // from ifetc32
    // wire[31:0] instruction;
    // wire[31:0] opcplus4_decode;           // to decoder (pc+4)
    // wire[31:0] opcplus4_alu;              // to ALU (pc+4)
    // wire[13:0] rom_adr_o;                 // to programrom 
    Ifetc32 ifetch(
        .Instruction_i(instruction_i),
        .Instruction_o(instruction_o),
        .branch_base_addr(opcplus4_alu),
        .link_addr(opcplus4_decode),
        .Addr_result(addr_result),
        .Read_data_1(read_data_1),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .Jr(jrn),
        .Zero(zero),
        .clock(cpu_clk),
        .reset(rst),
        .rom_adr_o(rom_adr_o) 
    );
     
     // from decoder
     // wire[31:0] read_data_1;  
     // wire[31:0] read_data_2;  
     // wire[31:0] sign_extend; 
    decode32 decoder(
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .Sign_extend(sign_extend),
        .Instruction(instruction_o),
        .mem_data(rdata),
        .ALU_result(alu_result),
        .Jal(jal),
        .RegWrite(regwrite),
        .MemOrIOtoReg(memoriotoreg),
        .RegDst(regdst),
        .clock(cpu_clk),
        .reset(rst),
        .opcplus4(opcplus4_decode)
    );
    
    // from controller
    // wire iowrite,ioread;
    // wire alusrc;
    // wire branch;
    // wire nbranch,jmp,jal,jrn,i_format;
    // wire regdst;
    // wire regwrite;
    // wire memwrite;
    // wire memread;
    // wire memoriotoreg;
    // wire memreg;
    // wire sftmd;
    // wire[1:0] aluop;
    control32 control(
        .Opcode(instruction_o[31:26]),
        .Function_opcode(instruction_o[5:0]),
        .Alu_resultHigh(alu_result[31:10]),
        .Jr(jrn),
        .RegDST(regdst),
        .ALUSrc(alusrc),
        .MemOrIOtoReg(memoriotoreg),
        .RegWrite(regwrite),
        .MemRead(memread),
        .MemWrite(memwrite),
        .IORead(ioread),
        .IOWrite(iowrite),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .I_format(i_format),
        .Sftmd(sftmd),
        .ALUOp(aluop)
    );
    
    // from ALU   
    // wire zero;    
    // wire[31:0] addr_result;  
    // wire[31:0] alu_result;
    executs32 ALU(
       .Read_data_1(read_data_1),
       .Read_data_2(read_data_2),
       .Sign_extend(sign_extend),
       .Function_opcode(instruction_o[5:0]),
       .Exe_opcode(instruction_o[31:26]),
       .ALUOp(aluop),
       .Shamt(instruction_o[10:6]),
       .ALUSrc(alusrc),
       .I_format(i_format),
       .Zero(zero),
       .Jr(jrn),
       .Sftmd(sftmd),
       .ALU_Result(alu_result),
       .Addr_Result(addr_result),
       .PC_plus_4(opcplus4_alu)
     );
    
    // from dmemory
    // wire[31:0] read_data;                // data read from memory
    dmemory32 memory(
      .ram_dat_o(read_data),
      .ram_adr_i(address[15:2]),
      .ram_dat_i(write_data),
      .ram_wen_i(memwrite),
      .ram_clk_i(cpu_clk),
      .upg_rst_i(upg_rst), 
      .upg_clk_i(upg_clk_o), 
      .upg_wen_i(upg_wen_o & upg_adr_o[14]), 
      .upg_adr_i(upg_adr_o[13:0]),  
      .upg_dat_i(upg_dat_o), 
      .upg_done_i(upg_done_o)
    );
    
    // from MemOrIO
    // wire[31:0] write_data;               // data written into memory or I/O
    // wire[31:0] address;                  // address sent to IO device and memory
    // wire ledctrl,switchctrl, segctrl;    // control with IO device is enabled
    // wire[31:0] rdata;                    // data read from mem/IO, written into register
    MemOrIO memio(
       .addr_in(alu_result),
       .addr_out(address),
       .mRead(memread),
       .mWrite(memwrite),
       .ioRead(ioread),
       .ioWrite(iowrite),
       .m_rdata(read_data),
       .io_rdata(ioread_data),
       .r_rdata(read_data_2),
       .r_wdata(rdata),
       .write_data(write_data),
       .LEDCtrl(ledctrl),
       .SwitchCtrl(switchctrl),
       .SegCtrl(segctrl)
    );
    
    programrom prom(
        .rom_clk_i(cpu_clk),                       // ROM clock
        .rom_adr_i(rom_adr_o),                     // From IFetch
        .Instruction_o(instruction_i),             // To IFetch
        // UART Programmer Pinouts
        .upg_rst_i(upg_rst),                       // UPG reset (Active High)
        .upg_clk_i(upg_clk_o),                     // UPG clock (10MHz)
        .upg_wen_i(upg_wen_o & (!upg_adr_o[14])),     // UPG write enable
        .upg_adr_i(upg_adr_o[13:0]),               // UPG write address
        .upg_dat_i(upg_dat_o),                     // UPG write data
        .upg_done_i(upg_done_o)                    // 1 if program finished
    );
    
    // from IOread
    // wire[15:0] ioread_data;              // data read from IO
    ioread ir(
        .rst(rst),
        .ioRead(ioread),
        .switchctrl(switchctrl),
        .read_data(ioread_data),
        .read_data_switch(ioread_data_switch)
    );

    //from led: none :)
    leds led16(
        .clk(cpu_clk),
        .rst(rst),
        .write(iowrite),
        .enable(ledctrl), 
        .addr(address[1:0]),
        .write_data(write_data[15:0]), 
        .led(led2N4)  
     );

    // from switch 
    // wire[15:0] ioread_data_switch; // data read from switch
    switchs switch16(
        .clk(cpu_clk),
        .rst(rst),
        .read(ioread),
        .enable(switchctrl),
        .addr(address[1:0]), 
        .read_data(ioread_data_switch), 
        .sw(switch2N4)
     );

     // from Segment Display
     // wire [7:0] bit_sel;    // 0 for selecting the segment display in the corresponding position
     // wire [7:0] seg_out;    // data to be displayed in the specific segment display
     scan_seg ss(
        .clk(cpu_clk),
        .rst(rst),
        .write(iowrite),
        .enable(segctrl),
        .addr(address[1:0]),
        .write_data(write_data[15:0]),
        .bit_sel(bit_sel),
        .seg_out(seg_out)
     );

endmodule
