`timescale 1ns / 1ps

module switchs(clk, rst, read, enable,addr, read_data, sw);
    input clk;			       
    input rst;			       
    input enable;			      //SwitchCtrl from MemOrIO
    input[1:0] addr;		    //  last 2 bit of address
    input read;			    //  ioRead from controller
    output reg [15:0] read_data;	     //  data read from switch, sent to ioRead
    input [23:0] sw;		    //  from the 24 switches on board

    always@(negedge clk or posedge rst) begin
        if(rst) begin
            read_data <= 0;
        end
		else if(enable && read) begin
			if(addr==2'b00)
				read_data[15:0] <= sw[15:0];   // data output,lower 16 bits non-extended
			else if(addr==2'b10)
				read_data[15:0] <= { 8'h00, sw[23:16] }; //data output, upper 8 bits extended with zero
			else 
				read_data <= read_data;
        end
		else begin
            read_data <= read_data;
        end
    end
endmodule
