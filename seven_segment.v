
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2015 05:57:38 PM
// Design Name: 
// Module Name: PS2Controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_segment(
    
    input clk,reset,
    input [7:0] key,
    output reg [3:0] an,           //select digit 
    output reg cg,cf,ce,cd,cc,cb,ca  // select segment    
    );
   
    always @ (posedge clk)
    begin
        if (reset) begin
            an <= 4'b1101;
            {cg,cf,ce,cd,cc,cb,ca} <= 7'h3F;
        end
        else begin
            an <= 4'b1110;
            case (key)
                "0": {cg,cf,ce,cd,cc,cb,ca} <= 7'h40;
                "1": {cg,cf,ce,cd,cc,cb,ca} <= 7'h79;
                "2": {cg,cf,ce,cd,cc,cb,ca} <= 7'h24;
                "3": {cg,cf,ce,cd,cc,cb,ca} <= 7'h30;
                "4": {cg,cf,ce,cd,cc,cb,ca} <= 7'h19;
                "5": {cg,cf,ce,cd,cc,cb,ca} <= 7'h12;
                "6": {cg,cf,ce,cd,cc,cb,ca} <= 7'h02;
                "7": {cg,cf,ce,cd,cc,cb,ca} <= 7'h78;
                "8": {cg,cf,ce,cd,cc,cb,ca} <= 7'h00;
                "9": {cg,cf,ce,cd,cc,cb,ca} <= 7'h10;
                "A": {cg,cf,ce,cd,cc,cb,ca} <= 7'h08;
                "B": {cg,cf,ce,cd,cc,cb,ca} <= 7'h03;
                "C": {cg,cf,ce,cd,cc,cb,ca} <= 7'h46;
                "D": {cg,cf,ce,cd,cc,cb,ca} <= 7'h21;
                "E": {cg,cf,ce,cd,cc,cb,ca} <= 7'h06;
                "F": {cg,cf,ce,cd,cc,cb,ca} <= 7'h0E;
                " ": {cg,cf,ce,cd,cc,cb,ca} <= 7'h7F;
                "-": {cg,cf,ce,cd,cc,cb,ca} <= 7'h3F;
                "r": {cg,cf,ce,cd,cc,cb,ca} <= 7'h1C;
                "U": {cg,cf,ce,cd,cc,cb,ca} <= 7'h09;
                "L": {cg,cf,ce,cd,cc,cb,ca} <= 7'h47;
                "o": {cg,cf,ce,cd,cc,cb,ca} <= 7'h7C;
                "n": {cg,cf,ce,cd,cc,cb,ca} <= 7'h2B;
                "S": {cg,cf,ce,cd,cc,cb,ca} <= 7'h12;
                "P": {cg,cf,ce,cd,cc,cb,ca} <= 7'h0C;
                default: {cg,cf,ce,cd,cc,cb,ca} <= 7'b1111111;
            endcase
        end
    end
    
endmodule

