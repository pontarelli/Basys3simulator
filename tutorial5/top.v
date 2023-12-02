`timescale 1ns / 1ps

module top(
    input logic clk,              // from Basys 3
    input logic reset,            // btnR
    input logic KEYSIG_DATA,      // PS2
    input logic KEYSIG_CLK,       // PS2
    input logic [15:0] sw,              // SWITCH
    
    input logic up,down,       // push buttons
    
    //LEDs
    output logic [15:0] LED, 
    
    //seven segment display
    output logic[3:0] an,           //select digit 
    output logic [7:0] seg,  // select segment    
    
    output logic h_sync,           // to VGA port
    output logic v_sync,           // to VGA port
    output logic [3:0] R_VAL,       // to DAC, to VGA port
    output logic [3:0] G_VAL,       // to DAC, to VGA port
    output logic [3:0] B_VAL       // to DAC, to VGA port
    );

    // Based on VGA standards found at vesa.org for 640x480 resolution
    // Total horizontal width of screen = 800 pixels, partitioned  into sections
    parameter HPW = 96;              // horizontal Pulse Width in pixels
    parameter HB  = 48;              // horizontal back porch width in pixels
    parameter HD  = 640;             // horizontal display area width in pixels
    parameter HF  = 16;              // horizontal front porch width in pixels
    parameter HMAX = HD+HF+HB+HPW-1; // max value of horizontal counter = 799
    // Total vertical length of screen = 521 pixels, partitioned into sections
    parameter VD = 480;             // vertical display area length in lines 
    parameter VF = 10;              // vertical front porch length in lines  
    parameter VB = 29;              // vertical back porch length in lines   
    parameter VPW = 2;              // vertical Pulse width in lines  
    parameter VMAX = VD+VF+VB+VPW-1; // max value of vertical counter = 521   
    
    logic [9:0] pos_x,pos_y;
    logic [9:0] ray_x,ray_y;
    assign pos_x=10'd100;
    assign pos_y=10'd150;


    assign R_VAL= ((ray_x >= pos_x) & (ray_x <= 16+pos_x))?4'b1111:4'b0000;
    assign G_VAL=0;
    assign B_VAL=0;
    assign h_sync=(counter_x>=HPW);
    assign v_sync=(counter_y>=VPW);
    assign ray_x= counter_x-(HPW+HB);
    assign ray_y= counter_y-(VPW+VB);

    logic [9:0] counter_x,counter_y;
    always @(posedge (clk)) begin
        if (reset) begin
            counter_x=0;
            counter_y=0;
        end
        else begin
            if (counter_x==HMAX) begin
                counter_y=counter_y+1;
                counter_x=0;
            end
            else counter_x=counter_x+1;
            if (counter_y==VMAX+1) counter_y=0;
        end
    end        

endmodule
/*


    logic [31:0] counter; 
    logic [8:0] tick; 
    always_ff @(posedge clk) begin
        if (reset==1) begin 
		counter=0;
		tick=0;
	end
	else if (counter=='d416800*4) begin
		counter =0;
		tick=tick+1;
	     end
	     else
		counter = counter +1;	
    end
    
    // *** Generate 25MHz from 100MHz *********************************************************
	logic  w_25MHz;
	assign w_25MHz = (counter[1] == 0) ? 1 : 0; // assert tick 1/2 of the time
    // ****************************************************************************************

    logic [9:0] h_count, v_count;

    //Logic for horizontal counter
    always @(posedge w_25MHz or posedge reset)      // pixel tick
        if(reset)
            h_count = 0;
        else
            if(h_count == HMAX)                 // end of horizontal scan
                h_count = 0;
            else
                h_count = h_count + 1;         
  
    // Logic for vertical counter
    always @(posedge w_25MHz or posedge reset)
        if(reset)
            v_count = 0;
        else
            if(h_count == HMAX)                 // end of horizontal scan
                if((v_count == VMAX))           // end of vertical scan
                    v_count = 0;
                else
                    v_count = v_count + 1;
        
    // h_sync deasserted during the pulse period
    //assign h_sync = (h_count >= (HD+HB) && h_count <= (HD+HB+HR-1));
    assign h_sync = (h_count >= HPW); 
    
    // v_sync deasserted during the pulse period
    assign v_sync = (v_count >= VPW);

    logic [3:0] pixel;
    assign pixel = (h_count==tick+HPW+HB+1)  || (h_count==tick+HPW+HB+2) ? 4'hf :
                   (h_count>HPW+HB+638) ? 4'hf :
                   (v_count==VPW+VB+1) || (v_count==VPW+VB+2) ? 4'hf :
	           4'h0;
    assign {R_VAL,G_VAL,B_VAL} = {pixel,4'b0,4'b0};

    
endmodule
*/
