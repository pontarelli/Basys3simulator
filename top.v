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

    
    logic [63:0] counter,counter2;
    logic [3:0] cifra;
    logic [1:0] sel;

    always_ff @(posedge clk) begin
        if (reset==1) counter=0;
        else counter = counter +1;
    end

    logic [3:0] tasto [3:0];
    logic [10:0] temp ;
    integer tick;
    logic [1:0] tick2;
    assign sel= counter[20:19];
    assign {cifra,an}= (sel==2'b00) ? {tasto[3], 4'b0111 }:
                       (sel==2'b01) ? {tasto[2], 4'b1011}:
                       (sel==2'b10) ? {tasto[1], 4'b1101}:
                                      {tasto[0], 4'b1110};
    
    seven_segment_sw ss(.sw(cifra), .an(), .ca(seg[0]), .cb(seg[1]), .cc(seg[2]), .cd(seg[3]), .ce(seg[4]), .cf(seg[5]), .cg(seg[6]));

    
    always_ff @(negedge KEYSIG_CLK or posedge reset) begin
        if (reset==1) 
        begin
            temp=11'b0;
            tick=0;
            tasto={-1,-1,-1,-1};
            tick2=0;
        end    
        else 
            begin
                temp[10:0]= {KEYSIG_DATA, temp[10:1] };
                tick=tick+1;
                if (tick==11)
                    begin
                        tick=0;
                        $display("tasto: %h (%b)",temp[8:1],temp[8:1]);
                        if (temp[8:1]=='h16) tasto[tick2]=1;
                        if (temp[8:1]=='h1E) tasto[tick2]=2;
                        if (temp[8:1]=='h26) tasto[tick2]=3;
                        if (temp[8:1]=='h25) tasto[tick2]=4;
                        tick2=tick2+1;
                    end
            end    
    end     
/*

    logic w_vid_on, w_p_tick;
    logic [9:0] w_x, w_y;
    logic [11:0] rgb_reg;
    logic [11:0] rgb_next;
    logic [7:0] DATA,asciiOUT;
    logic HZ5_CLK, NewData, KEYPRESS_S, KEYPRESS_P, KEYPRESS_R, KEYPRESS_ESC,KEYPRESS_UP, KEYPRESS_DOWN, KEYPRESS_LEFT, KEYPRESS_RIGHT;
    
    assign LED[15:3] = sw[15:3];
    assign LED[2] = sw[0] & sw[1];
    assign LED[1] = sw[0] | sw[1];
    assign LED[0] = sw[0] ^ sw[1];
    
    seven_segment ss(.clk(clk), .reset(reset), .key(asciiOUT), .an(an), .ca(seg[0]), .cb(seg[1]), .cc(seg[2]), .cd(seg[3]), .ce(seg[4]), .cf(seg[5]), .cg(seg[6]));
    
    /*vga_controller vga(.clk_100MHz(clk), .reset(reset), .video_on(w_vid_on),
                       .hsync(h_sync), .vsync(v_sync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixel_gen pg(.clk(clk), .reset(reset), .up(KEYPRESS_UP), .down(KEYPRESS_DOWN), 
                 .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next));
    
    
    */
/*    PS2Controller KeyboardDriver(KEYSIG_CLK, KEYSIG_DATA, DATA, asciiOUT, NewData, KEYPRESS_S,
    KEYPRESS_P, KEYPRESS_R, KEYPRESS_ESC,KEYPRESS_UP, KEYPRESS_DOWN, KEYPRESS_LEFT, KEYPRESS_RIGHT);
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign {R_VAL,G_VAL,B_VAL} = rgb_reg;
    
*/
endmodule
