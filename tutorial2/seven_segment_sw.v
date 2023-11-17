
`timescale 1ns / 1ps


module seven_segment_sw(
    
    input logic  [3:0] sw,
    output logic [3:0] an,           //select digit 
    output logic cg,cf,ce,cd,cc,cb,ca  // select segment    
    );
   
    always_comb 
    begin
        an = 4'b1110;
	case (sw)
            4'b0: {cg,cf,ce,cd,cc,cb,ca} = 7'h40; 
            4'h1: {cg,cf,ce,cd,cc,cb,ca} = 7'h79;
            4'h2: {cg,cf,ce,cd,cc,cb,ca} = 7'h24;
            4'h3: {cg,cf,ce,cd,cc,cb,ca} = 7'h30;
            4'h4: {cg,cf,ce,cd,cc,cb,ca} = 7'h19;
            4'h5: {cg,cf,ce,cd,cc,cb,ca} = 7'h12;
            4'h6: {cg,cf,ce,cd,cc,cb,ca} = 7'h02;
            4'h7: {cg,cf,ce,cd,cc,cb,ca} = 7'h78;
            4'h8: {cg,cf,ce,cd,cc,cb,ca} = 7'h00;
            4'h9: {cg,cf,ce,cd,cc,cb,ca} = 7'h10;
            4'hA: {cg,cf,ce,cd,cc,cb,ca} = 7'h08;
            4'hB: {cg,cf,ce,cd,cc,cb,ca} = 7'h03;
            4'hC: {cg,cf,ce,cd,cc,cb,ca} = 7'h46;
            4'hD: {cg,cf,ce,cd,cc,cb,ca} = 7'h21;
            4'hE: {cg,cf,ce,cd,cc,cb,ca} = 7'h06;
            4'hF: {cg,cf,ce,cd,cc,cb,ca} = 7'h0E;
        endcase
    end
endmodule

