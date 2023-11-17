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

    
    logic [31:0] counter;
    
    always_ff @(posedge clk) begin
        if (reset==1) counter=0;
        else counter = counter +1;
    end

    assign LED[15:3] = sw[15:3];
    assign LED[2] = sw[0] & sw[1];
    assign LED[1] = sw[0] | sw[1];
    assign LED[0] = sw[0] ^ sw[1];


    seven_segment_sw ss(.sw(counter[28:25]), .an(an), .ca(seg[0]), .cb(seg[1]), .cc(seg[2]), .cd(seg[3]), .ce(seg[4]), .cf(seg[5]), .cg(seg[6]));



endmodule
