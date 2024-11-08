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

    
    logic [63:0] counter,counter2;
    logic [3:0] cifra;
    logic [1:0] sel;

    always_ff @(posedge clk) begin
        if (reset==1) counter=0;
        else counter = counter +1;
    end

    assign sel= counter[20:19];
    assign {cifra,an}= (sel==2'b00) ? {counter2[3:0], 4'b0111 }:
                       (sel==2'b01) ? {counter2[7:4], 4'b1011}:
                       (sel==2'b10) ? {4'b0, 4'b1101}:
                                      {4'b0, 4'b1110};


    //fsm fsm_inst(clk,reset,up,down,counter2[7:0]);
    fsm_bcd fsm_inst(clk,reset,up,down,counter2[7:0]);
    seven_segment_sw ss(.sw(cifra), .an(), .ca(seg[0]), .cb(seg[1]), .cc(seg[2]), .cd(seg[3]), .ce(seg[4]), .cf(seg[5]), .cg(seg[6]));

endmodule
