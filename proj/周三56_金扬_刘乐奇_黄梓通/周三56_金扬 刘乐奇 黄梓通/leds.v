`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds(clk, rst, write, enable, addr,write_data, led);
    input clk;    		    
    input rst; 		        
    input write;		       // ioWrite from controller
    input enable;		     //ledctrl from MemOrIO
    input[1:0] addr;	        // last 2 bit of address
    input[15:0] write_data;	  //  data written to the led
    output reg[23:0] led;	//  24 bit signal sent to board
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            led <= 24'h000000;
        end
		else if(enable && write) begin
			if(addr == 2'b00)
				led[23:0] <= { led[23:16], write_data[15:0] };
			else if(addr == 2'b10 )
				led[23:0] <= { write_data[7:0], led[15:0] };
			else
				led <= led;
        end
		else begin
            led <= led;
        end
    end
endmodule
