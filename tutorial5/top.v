`timescale 1ns / 1ps

module top(
    input logic clk,              // from Basys 3
    input logic reset,            // btnR
    input logic KEYSIG_DATA,      // PS2
    input logic KEYSIG_CLK,       // PS2
    input logic [15:0] sw,              // SWITCH
    
    input logic up,down,left,right,       // push buttons
    
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

    //enable the pixel only in a window [tick:tick+4][tick:tick+4]
    logic pixel_on;
    assign pixel_on = (h_count>=tick+HPW+HB) && (h_count<=tick+HPW+HB+15) &&
                   (v_count>=VPW+VB+tick) && (v_count<=VPW+VB+tick+15) ? 1'b1 :
	           1'b0;
    logic [3:0] pixel;
    logic [3:0] x,y;
    assign x=h_count-(tick+HPW+HB);
    assign y=v_count-(tick+VPW+VB);
    
    logic [15:0] ball_row;
    ball_rom rom_inst(y,ball_row);
    assign pixel = (pixel_on & ball_row[x]) ? 4'b1111:4'b0;   
    assign {R_VAL,G_VAL,B_VAL} = {pixel,4'b0,4'b0};

    
endmodule



module ball_rom(
    input [3:0] addr,   // 4-bit address
    output reg [15:0] data   // 16-bit data
    );
    
    always @*
        case(addr)
            4'b0000 :    data = 16'b00000011_11000000; //
            4'b0001 :    data = 16'b00000111_11100000; //
            4'b0010 :    data = 16'b00001111_11110000; //
            4'b0011 :    data = 16'b00011111_11111000; //
            4'b0100 :    data = 16'b00111111_11111100; //
            4'b0101 :    data = 16'b01111111_11111110; //
            4'b0110 :    data = 16'b11111111_11111111; //
            4'b0111 :    data = 16'b11111111_11111111; //
            4'b1000 :    data = 16'b11111111_11111111; //
            4'b1001 :    data = 16'b11111111_11111111; //
            4'b1010 :    data = 16'b11111111_11111111; //
            4'b1011 :    data = 16'b01111111_11111110; //
            4'b1100 :    data = 16'b00111111_11111100; // 
            4'b1101 :    data = 16'b00011111_11111000; //
            4'b1110 :    data = 16'b00001111_11110000; //
            4'b1111 :    data = 16'b00000111_11100000; // 
        endcase
    
endmodule

