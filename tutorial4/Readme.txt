# Quarto tutorial 

1. il file fsm.sv  contiene una macchina a stati con contatore

2. il file fsm_bcd.sv  contiene una macchina a stati con contatore BCD

3. il file fsm_tb.v contiene il testbench per fsm.sv

4. il file top.v contiene il codice per il top level da usare per simulare/sintetizzare 
la fsm che guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simualto direttamente con i comandi:

cp top.v ../vpong/top.v ; cp fsm.sv ../vpong/fsm.sv ; make run

5. il file top_bcd.v contiene il codice per il top level da usare per simulare/sintetizzare 
la fsm BCD che guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simualto direttamente con i comandi:

cp top_bcd.v ../vpong/top.v ; cp fsm_bcd.sv ../vpong/fsm_bcd.sv ; make run
