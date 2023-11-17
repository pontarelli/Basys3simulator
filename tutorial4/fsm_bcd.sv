`timescale 1ns / 1ps
module fsm_bcd (
    input logic clk,
    input logic reset,
    input logic up,
    input logic down,
    output logic [7:0] count
);

logic pressed;
always_ff @( posedge clk ) begin : blockName
    if (reset == 1'b1) begin
        count <= 8'b0;
        pressed <= 1'b0;
    end else begin
        if (up && !pressed) begin
		if (count[3:0]==9) begin
		    count[7:4] <= count[7:4] + 1'b1;
		    count[3:0] <= 0;
	    	end 
	     	else 
			count[3:0] <= count[3:0]+1;
            pressed <= 1'b1;
        end else if (down && !pressed) begin
		if (count[3:0]==0) begin
		    count[7:4] <= count[7:4] - 1'b1;
		    count[3:0] <= 9;
	    	end    
	        else
		    count[3:0] <= count[3:0]-1;
        end else if (!down && !up) begin
            pressed <= 1'b0;
        end
    end
end
endmodule
 
