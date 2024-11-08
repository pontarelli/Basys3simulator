# Quarto tutorial 

1. il file fsm.sv  contiene una macchina a stati con contatore UP/DOWN

2. il file fsm_tb.v contiene il testbench per fsm.sv

Per la simulazione con Icarus Verilog eseguire:

1. iverilog -g2005-sv -o tb fsm.sv fsm_tb.sv
2. ./tb
3. gtkwave test.vcd 


3. il file fsm_bcd.sv contiene una macchina a stati con contatore BCD

4. il file top.v contiene il codice per il top level da usare per simulare/sintetizzare 
la fsm che guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simulato direttamente con i comandi:

cp top.v ../top.v ; cp fsm.sv ../fsm.sv ; cd ..; make run

5. il file top_bcd.v contiene il codice per il top level da usare per simulare/sintetizzare 
la fsm BCD che guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simulato direttamente con i comandi:

cp top_bcd.v ../top.v ; cp fsm_bcd.sv ../fsm_bcd.sv ; cd .. ; make run
