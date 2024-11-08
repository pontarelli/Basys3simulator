# Secondo tutorial 

1. il file mux.sv  contiene 4 tipi di mux a 4 ingressi:
 - usando always_comb
 - usando conditional assignment
 - usando dei tristate
 - usando dei mux a 2 ingressi

Per la simulazione con Icarus Verilog eseguire:

1. iverilog -g2005-sv -o tb mux.sv
2. ./tb


2. il file seven_segment_sw.v contiene il codice per pilotare il display a 7 segmenti 
per la board di sviluppo basys 3 usando come input 4 switch 

3. il file top.v contiene il codice per il top level da usare per simulare/sintetizzare 
un contatore che guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simulato direttamente con i comandi:

cp top.v ../top.v ; cp seven_segment_sw.v ../seven_segment_sw.v ; cd .. ; make run
