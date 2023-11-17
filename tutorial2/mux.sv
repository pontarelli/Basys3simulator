/* 
 * mux a quattro ingressi
 */



// mux a quattro ingressi con tristate
module mux4z #(parameter N=8)
 (
    input logic [N-1:0] a,b,c,d,
    input logic [1:0] s,
    output tri [N-1:0] y
 );

assign y= (s==0)?a:'z;
assign y= (s==1)?b:'z;
assign y= (s==2)?c:'z;
assign y= (s==3)?d:'z;

 
 endmodule

// mux a quattro ingressi con always_comb
module mux4a #(parameter N=8)
 (
    input logic [N-1:0] a,b,c,d,
    input logic [1:0] s,
    output logic [N-1:0] y
 );

 always_comb begin : blockName
    case(s)
        2'b00 : y=a;
        2'b01 : y=b;
        2'b10 : y=c;
        2'b11 : y=d;
    endcase
 end

endmodule


// mux a quattro ingressi con conditional assignment
module mux4c #(parameter N=8)
 (
    input logic [N-1:0] a,b,c,d,
    input logic [1:0] s,
    output tri [N-1:0] y
 );

	assign y= (s==0)? a :
		  (s==1)? b :
		  (s==2)? c :
		  (s==3)? d : 4'bx;
 
 endmodule


// mux a quattro ingressi con mux2
module mux2 #(parameter N = 8)
	(
	 input logic [N-1:0] a, b,
	 input logic s,
	 output logic [N-1:0] y
        );

	assign y = s ? a : b; 

endmodule

module mux4comp #(parameter N = 8)
	(
	 input logic [N-1:0] a, b,c,d,
	 input logic[1:0] s,
	 output logic [N-1:0] y
        );
	logic[N-1:0] n1,n2;
	mux2 #(N) m1 (a,b,s[0],n1);
	mux2 #(N) m2 (c,d,s[0],n2);
	mux2 #(N) m3 (n2,n1,s[1],y);


endmodule

module testbench ();

    logic [9:0] d3,d2,d1,d0;
    tri [9:0] out;
    logic [1:0] s;

    //mux4z #(10) dut(.a(d0),.b(d1),.c(d2),.d(d3),.s(s),.y(out));
    //mux4a #(10) dut(.a(d0),.b(d1),.c(d2),.d(d3),.s(s),.y(out));
    //mux4c #(10) dut(.a(d0),.b(d1),.c(d2),.d(d3),.s(s),.y(out));
    mux4comp #(10) dut(.a(d0),.b(d1),.c(d2),.d(d3),.s(s),.y(out));

    initial begin
        $monitor("d3=0x%h, d2=0x%h, d1=0x%h, d0=0x%h, y=0x%h, s=%d",d3,d2,d1,d0,out,s);
        s =0;
        d1=10'd37;
        d0=10'h37;
        #10;
        s =1;
        #10;
        d2=-1;
        #10;
        s=3;
        #10;
        s=2;
        #10;
        $finish;
    end

endmodule
