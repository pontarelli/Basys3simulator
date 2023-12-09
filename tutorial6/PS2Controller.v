
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


module PS2Controller(
    PS2_CLK,
    PS2_DAT,
    dataOUT,
    asciiOUT,
    NEWDATA,
    KEYPRESS_S,
    KEYPRESS_P,
    KEYPRESS_R,
    KEYPRESS_ESC,
    KEYPRESS_UP,
    KEYPRESS_DOWN,
    KEYPRESS_LEFT,
    KEYPRESS_RIGHT
    );
   
    input PS2_CLK;
    input PS2_DAT;
    output[7:0] dataOUT;
    output reg [7:0] asciiOUT;
    output NEWDATA;
    output      KEYPRESS_ESC,
                KEYPRESS_UP,
                KEYPRESS_DOWN,
                KEYPRESS_LEFT,
                KEYPRESS_RIGHT,
                KEYPRESS_S,
                KEYPRESS_P,
                KEYPRESS_R;
    
    
    reg NEW_DATA_FLAG = 1'b0;
    
    reg[7:0] DAT_INT_CURRENT  = 8'd0; // internal data register, current data
    reg[7:0] DAT_INT_PREVIOUS = 8'd0; // Internal data register, previous data
    reg[3:0] INDEX_IT         = 4'd1;
    
    reg CLK_INT               = 1'd0; // New data clock
    //reg STROBE_INT            = 1'd1;
    
    assign NEWDATA = NEW_DATA_FLAG;
    reg  release_key=1'b0;
    //always @ (negedge PS2_CLK)
    //    if (NEWDATA==1'b1)
    //        $display("pressed %d (%x) --> %d %x %c", dataOUT,dataOUT,asciiOUT,asciiOUT,asciiOUT);
    
    always @ (negedge PS2_CLK)
    begin
        //$display("data %d", PS2_DAT);
        //dataOUT[8] <= ~dataOUT[8];
        case (INDEX_IT)
            2: DAT_INT_CURRENT[0] <= PS2_DAT;
            3: DAT_INT_CURRENT[1] <= PS2_DAT;
            4: DAT_INT_CURRENT[2] <= PS2_DAT;
            5: DAT_INT_CURRENT[3] <= PS2_DAT;
            6: DAT_INT_CURRENT[4] <= PS2_DAT;
            7: DAT_INT_CURRENT[5] <= PS2_DAT;
            8: DAT_INT_CURRENT[6] <= PS2_DAT;
            9: DAT_INT_CURRENT[7] <= PS2_DAT;
            10: CLK_INT <= 1'b1;
            11: 
               begin
                    CLK_INT        <= 1'b0;
                    NEW_DATA_FLAG  <= 1'b0;
               end
            1: NEW_DATA_FLAG <= 1'b1;
            default:;
        endcase
        
        if (INDEX_IT <= 4'd10)
        begin
            INDEX_IT <= INDEX_IT + 1'd1;
        end
        else
        begin
            INDEX_IT <= 4'd1;
        end
    end
    
    assign dataOUT = DAT_INT_PREVIOUS;
    
    assign KEYPRESS_ESC     = (DAT_INT_PREVIOUS == 8'h76);
    assign KEYPRESS_S       = (DAT_INT_PREVIOUS == 8'h1B);
    assign KEYPRESS_P       = (DAT_INT_PREVIOUS == 8'h4D);
    assign KEYPRESS_R       = (DAT_INT_PREVIOUS == 8'h2D);
    assign KEYPRESS_UP      = (DAT_INT_PREVIOUS == 8'h75);
    assign KEYPRESS_DOWN    = (DAT_INT_PREVIOUS == 8'h72);
    assign KEYPRESS_LEFT    = (DAT_INT_PREVIOUS == 8'h6B); 
    assign KEYPRESS_RIGHT   = (DAT_INT_PREVIOUS == 8'h74);

    

    always @ (posedge CLK_INT)
    begin
        if (DAT_INT_CURRENT == 8'd0)
        begin
            //dataOUT = DAT_INT_PREVIOUS;
            //dataOUT = 8'hFF;
        end
        else
        begin
            if (DAT_INT_CURRENT == 8'hF0)
            begin
                release_key <= 1'b1;
                DAT_INT_PREVIOUS <= 8'h00;
            end
            else
                begin 
                if (release_key==1'b0)
                    DAT_INT_PREVIOUS <= DAT_INT_CURRENT;
                release_key <= 1'b0;
                end
        end
    end

always @(*)
    case (dataOUT)
        8'h45: asciiOUT = "0";
        8'h16: asciiOUT = "1";
        8'h1E: asciiOUT = "2";
        8'h26: asciiOUT = "3";
        8'h25: asciiOUT = "4";
        8'h2E: asciiOUT = "5";
        8'h36: asciiOUT = "6";
        8'h3D: asciiOUT = "7";
        8'h3E: asciiOUT = "8";
        8'h46: asciiOUT = "9";
        8'h1C: asciiOUT = "A";
        8'h32: asciiOUT = "B";
        8'h21: asciiOUT = "C";
        8'h23: asciiOUT = "D";
        8'h24: asciiOUT = "E";
        8'h2B: asciiOUT = "F";
        8'h1B: asciiOUT = "S";
        8'h4D: asciiOUT = "P";
        8'h31: asciiOUT = "n";
        8'h4E: asciiOUT = "-";
        8'h2D: asciiOUT = "r";
        8'h3C: asciiOUT = "U";
        8'h4B: asciiOUT = "L";
        8'h44: asciiOUT = "o";
        default: asciiOUT = " ";
        
    endcase
    
endmodule

