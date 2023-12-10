`timescale 1ns / 1ps

module ioread(rst,ioRead,switchctrl,read_data,read_data_switch);
    input rst;			
    input ioRead;              //  ioRead from controller
    input switchctrl;		//  switchctrl from MemOrIO
    input[15:0] read_data_switch;  //data read from switch
    output[15:0] read_data;	// to MemOrIO
    
    reg[15:0] read_data;
    
    always @* begin
        if(rst == 1)
            read_data = 16'b0000000000000000;
        else if(ioRead == 1) begin
            if(switchctrl == 1)
                read_data = read_data_switch;
            else   read_data = read_data;
        end
    end
endmodule
