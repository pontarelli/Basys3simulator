
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
            an <= 4'b1111;
            {cg,cf,ce,cd,cc,cb,ca} <= 7'h3F;
        end
        else begin
            an <= 4'b1110;
            case (key)
                "0": {cg,cf,ce,cd,cc,cb,ca} <= 7'h3F;
                "1": {cg,cf,ce,cd,cc,cb,ca} <= 7'h06;
                "2": {cg,cf,ce,cd,cc,cb,ca} <= 7'h5B;
                "3": {cg,cf,ce,cd,cc,cb,ca} <= 7'h4F;
                "4": {cg,cf,ce,cd,cc,cb,ca} <= 7'h66;
                "5": {cg,cf,ce,cd,cc,cb,ca} <= 7'h6D;
                "6": {cg,cf,ce,cd,cc,cb,ca} <= 7'h7D;
                "7": {cg,cf,ce,cd,cc,cb,ca} <= 7'h07;
                "8": {cg,cf,ce,cd,cc,cb,ca} <= 7'h7F;
                "9": {cg,cf,ce,cd,cc,cb,ca} <= 7'h6F;
                "A": {cg,cf,ce,cd,cc,cb,ca} <= 7'h77;
                "B": {cg,cf,ce,cd,cc,cb,ca} <= 7'h7C;
                "C": {cg,cf,ce,cd,cc,cb,ca} <= 7'h39;
                "D": {cg,cf,ce,cd,cc,cb,ca} <= 7'h5E;
                "E": {cg,cf,ce,cd,cc,cb,ca} <= 7'h79;
                "F": {cg,cf,ce,cd,cc,cb,ca} <= 7'h71;
                " ": {cg,cf,ce,cd,cc,cb,ca} <= 7'h00;
                "-": {cg,cf,ce,cd,cc,cb,ca} <= 7'h40;
                "r": {cg,cf,ce,cd,cc,cb,ca} <= 7'h63;
                "U": {cg,cf,ce,cd,cc,cb,ca} <= 7'h76;
                "L": {cg,cf,ce,cd,cc,cb,ca} <= 7'h38;
                "d": {cg,cf,ce,cd,cc,cb,ca} <= 7'h54;
                "o": {cg,cf,ce,cd,cc,cb,ca} <= 7'h73;
                "n": {cg,cf,ce,cd,cc,cb,ca} <= 7'h5C;
                default: {cg,cf,ce,cd,cc,cb,ca} <= 7'b1111111;
            endcase
        end
    end
    
endmodule

