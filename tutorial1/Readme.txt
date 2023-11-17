# Primo tutorial con logica combinatoria


Mostra una simulazione con Icarus Verilog:

1. iverilog -g2005-sv -o tb adder_tb.sv adder.sv
2. ./tb
3. gtkwave test.vcd 

Mostra i risultati della sintesi con Yosys:
1. yosys synth.ys 
2. netlistsvg adder.js -o adder.svg
4. ristretto adder.svg 
