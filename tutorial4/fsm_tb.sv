module test;

logic u,d,clk,reset;
logic [7:0] count;
// generate clock
	always     // no sensitivity list, so it always executes
	begin
		clk = 1; #5; clk = 0; #5;
	end


initial begin
	$dumpfile("test.vcd");
	$dumpvars(0,test);
	reset = 1; #27; reset = 0;
	u = 0; d = 0; #10;
	u = 1; d = 0; #10;
	u = 0; d = 0; #10;
	u = 1; d = 0; #10;
	u = 0; d = 0; #10;
	u = 0; d = 1; #10;
	u = 0; d = 0; #10;

	# 10000 ;
	$finish;
end


      fsm fsm_inst(clk,reset,u,d,count);

      initial
	      $monitor("At time %t, u=%d  d= %d, count =%d" ,$time, u, d,count);
	   
endmodule // test
