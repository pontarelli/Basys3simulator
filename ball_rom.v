`timescale 1ns / 1ps

module ball_rom(
    input [2:0] addr,   // 3-bit address
    output reg [7:0] data   // 8-bit data
    );
    
    always @*
        case(addr)
            3'b000 :    data = 8'b00100100; //   ****  
            3'b001 :    data = 8'b01100110; //  ******
            3'b010 :    data = 8'b11100111; // ********
            3'b011 :    data = 8'b00000000; // ********
            3'b100 :    data = 8'b00000000; // ********
            3'b101 :    data = 8'b11100111; // ********
            3'b110 :    data = 8'b01100110; //  ******
            3'b111 :    data = 8'b00100100; //   ****
        endcase
    
endmodule
