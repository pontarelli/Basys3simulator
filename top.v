`timescale 1ns / 1ps

module display(
    input clk,              // from Basys 3
    input reset,            // btnR
    input KEYSIG_DATA,      // PS2
    input KEYSIG_CLK,       // PS2
    input [15:0] sw,              // SWITCH
    /*input up,               
    input down,             
    input left,             
    input right,             
    input space,            
    input enter,            
    */
    //seven segment display
    output [3:0] an,           //select digit 
    output ca,cb,cc,cd,ce,cf,cg,  // select segment    
    
    output h_sync,           // to VGA port
    output v_sync,           // to VGA port
    output [3:0] R_VAL,       // to DAC, to VGA port
    output [3:0] G_VAL,       // to DAC, to VGA port
    output [3:0] B_VAL       // to DAC, to VGA port
    );
    
    wire w_reset, w_up, w_down, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [7:0] LED_DATA,asciiOUT;
    wire HZ5_CLK, NewData, KEYPRESS_S, KEYPRESS_P, KEYPRESS_R, KEYPRESS_ESC,KEYPRESS_UP, KEYPRESS_DOWN, KEYPRESS_LEFT, KEYPRESS_RIGHT;
    
    vga_controller vga(.clk_100MHz(clk), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(h_sync), .vsync(v_sync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixel_gen pg(.clk(clk), .reset(w_reset), .up(KEYPRESS_UP), .down(KEYPRESS_DOWN), 
                 .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next));
    
    PS2Controller KeyboardDriver(KEYSIG_CLK, KEYSIG_DATA, LED_DATA, asciiOUT, NewData, KEYPRESS_S,
    KEYPRESS_P, KEYPRESS_R, KEYPRESS_ESC,KEYPRESS_UP, KEYPRESS_DOWN, KEYPRESS_LEFT, KEYPRESS_RIGHT);
    

    seven_segment ss(.clk(clk), .reset(w_reset), .key(asciiOUT), .an(an), .ca(ca), .cb(cb), .cc(cc), .cd(cd), .ce(ce), .cf(cf), .cg(cg));
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign {R_VAL,G_VAL,B_VAL} = rgb_reg;
    
endmodule
