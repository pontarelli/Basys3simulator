`timescale 1ns / 1ps

module top(
    input logic clk,              // from Basys 3
    input logic reset,            // btnR
    input logic KEYSIG_DATA,      // PS2
    input logic KEYSIG_CLK,       // PS2
    input logic [15:0] sw,        // SWITCH
    
    input logic up,down,left,right,  // push buttons
    
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


// example top level.
// this top level just blink some leds depending on a counter or on user inputs

    logic [31:0] counter;
    
    always_ff @(posedge clk) begin
        if (reset==1) counter=0;
        else counter = counter +1;
    end

    assign LED[15:8] = counter[27:20];
    assign LED[7:3] = sw[7:3];
    assign LED[2] = sw[0] & sw[1];
    assign LED[1] = sw[0] | sw[1];
    assign LED[0] = sw[0] ^ sw[1];

endmodule
