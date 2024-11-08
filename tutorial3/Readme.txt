# Terzo tutorial 

1. il file seven_segment_sw.v  contiene la decodifica da binario a 7 segmenti

2. il file top.v contiene il codice per il top level da usare per simulare/sintetizzare 
la fsm che legge dalla PS2, converte in binario e guida il display a 7 segmenti della board di sviluppo basys 3
Puo' essere simulato direttamente con i comandi:

cp top.v ../top.v ; cp seven_segment_sw.v ../seven_segment_sw.v ; cd ..; make run

