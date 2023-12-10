`timescale 1ns/1ps

module scan_seg(
    input clk,
    input rst,
    input write,
    input enable,
    input[1:0] addr,	        // last 2 bit of address
    input[15:0] write_data,	  //  data written to the led
    output [7:0] bit_sel,
    output [7:0] seg_out
);

reg error = 0;
reg [1:0] errorType = 0;
reg [15:0] state = 16'b10_10_10_10_10_10_10_10; // 00 for lights out, 01 for lights flickering, 10 for lights on
reg [31:0] data = 32'h0;
reg clkout;
reg l_clkout;
reg [31:0] cnt;
reg [31:0] l_cnt;
reg [2:0] scan_cnt;
reg [6:0] Y_reg;
reg [7:0] bit_sel_reg;

parameter  period = 50000;
parameter  l_period = 50_000_000;

assign seg_out = {Y_reg, 1'b1};
assign bit_sel = bit_sel_reg;

always@(posedge clk or posedge rst) begin
    if(rst) begin
        data <= 32'h0000_0000;
    end
	else if(enable && write) begin
		if(addr == 2'b00)
			data[31:0] <= { data[31:16], write_data[15:0] };
		else if(addr == 2'b10 )
			data[31:0] <= { write_data[15:0], data[15:0] };
		else
			data <= data;
    end
	else begin
		data <= data;
    end
end

always @(posedge clk)
begin
    if(rst == 1) begin 
        cnt <= 0;
        clkout = 0;
    end
    else begin 
        if(cnt == (period >> 1) - 1) begin
            clkout <= ~clkout;
            cnt <= 0;
        end
        else
            cnt <= cnt + 1;
    end
end

always @(posedge clk)
begin
    if(rst == 1) begin 
        l_cnt <= 0;
        l_clkout <= 0;
    end
    else begin 
        if(l_cnt == (l_period >> 1) - 1) begin
            l_clkout <= ~l_clkout;
            l_cnt <= 0;
        end
        else
            l_cnt <= l_cnt + 1;
    end
end

always @(posedge clkout)
begin
    if(rst == 1)
        scan_cnt <= 0;
    else begin
        if(scan_cnt == 3'b111)
            scan_cnt <= 0;
        else
        scan_cnt <= scan_cnt + 1;
    end
end

always @(scan_cnt)
begin
    if(rst == 1)
        bit_sel_reg = 8'b00000000;
    else
    case(scan_cnt)
        3'b000: bit_sel_reg = ~8'b00000001;
        3'b001: bit_sel_reg = ~8'b00000010;
        3'b010: bit_sel_reg = ~8'b00000100;
        3'b011: bit_sel_reg = ~8'b00001000;
        3'b100: bit_sel_reg = ~8'b00010000;
        3'b101: bit_sel_reg = ~8'b00100000;
        3'b110: bit_sel_reg = ~8'b01000000;
        3'b111: bit_sel_reg = ~8'b10000000;
    endcase
end

always @(scan_cnt)
begin
    if(error == 0)
    begin
        case(scan_cnt)
                3'b000: 
                if(state[1:0] == 0 || ((state[1:0] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[3:0])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase    
                3'b001:
                if(state[3:2] == 0 || ((state[3:2] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[7:4])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                3'b010:
                if(state[5:4] == 0 || ((state[5:4] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[11:8])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                3'b011:
                if(state[7:6] == 0 || ((state[7:6] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[15:12])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                3'b100:
                if(state[9:8] == 0 || ((state[9:8] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[19:16])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                3'b101:
                if(state[11:10] == 0 || ((state[11:10] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[23:20])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase  
                3'b110:
                if(state[13:12] == 0 || ((state[13:12] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[27:24])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                3'b111:
                if(state[15:14] == 0 || ((state[15:14] == 1) && l_clkout == 0))
                    Y_reg = ~7'b0000_000;
                else
                case (data[31:28])
                    0:Y_reg = ~7'b1111_110;   //0
                    1:Y_reg = ~7'b0110_000;   //1
                    2:Y_reg = ~7'b1101_101;   //2
                    3:Y_reg = ~7'b1111_001;   //3
                    4:Y_reg = ~7'b0110_011;   //4
                    5:Y_reg = ~7'b1011_011;   //5
                    6:Y_reg = ~7'b1011_111;   //6
                    7:Y_reg = ~7'b1110_000;   //7
                    8:Y_reg = ~7'b1111_111;   //8
                    9:Y_reg = ~7'b1110_011;   //9
                    10:Y_reg = ~7'b1110_111; //A
                    11:Y_reg = ~7'b0011_111; // b
                    12:Y_reg = ~7'b0001_101; // c
                    13:Y_reg = ~7'b0111_101; // d
                    14:Y_reg = ~7'b1001_111; // E
                    15:Y_reg = ~7'b1000_111; // F
                endcase
                default: Y_reg = ~7'b0000_000;   //all disabled
        endcase  
        end
        else
        begin
            case(scan_cnt)
                3'b000:
                case (errorType)
                    2'b00:Y_reg = ~7'b0000_000;   //off
                    2'b01:Y_reg = ~7'b0110_000;   //1
                    2'b10:Y_reg = ~7'b1101_101;   //2
                    2'b11:Y_reg = ~7'b1111_001;   //3
                endcase
                3'b001: 
                Y_reg = ~7'b0000101;   //r
                3'b010:
                Y_reg = ~7'b0011101;  //o
                3'b011:
                Y_reg = ~7'b0000101;   //r
                3'b100:
                Y_reg = ~7'b0000101;   //r
                3'b101:
                Y_reg = ~7'b1001111;    //E
                default: Y_reg = ~7'b0000_000;   //all disabled
        endcase     
        end  
    end
endmodule