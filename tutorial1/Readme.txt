# Primo tutorial con logica combinatoria


simulazione:

1. iverilog -g2005-sv -o tb adder_tb.sv adder.sv
2. ./tb
3. gtkwave test.vcd 

sintesi:
1. yosys synth.ys 
2. netlistsvg adder.js -o adder.svg
4. ristretto adder.svg 


demo:
1. top.v contiene il codice per la Basys3 on 16 switch e 16 led. 
2. seven_segment_sw.v contiene il codice per idecodificare i 4 bit degli swithhc nel codice 7seg. 
Gli switch sw[3:0] guidano il display 7seg e fanno anche AND/OR/XOR sui LED LED[2],LED[1] e LED[0]

Puo' essere simulato direttamente con i comandi:

cp top.v ../top.v ; cp seven_segment_sw.v ../seven_segment_sw.v ; cd .. ; make run

