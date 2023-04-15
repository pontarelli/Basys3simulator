NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32;01m
ERROR_COLOR=\x1b[31;01m
WARN_COLOR=\x1b[33;01m
OK_STRING=$(OK_COLOR)[OK]$(NO_COLOR)

#define debug level for waveforms
LEVEL=1


help:
	@echo -e '$(OK_COLOR)'
	@echo -e 'Usage: $(NO_COLOR)'
	@echo -e 'make help: display this message'
	@echo -e 'make all: build the simulator with the specified verilog module'
	@echo -e 'make run: simulate the verilog module on the BASYS3 simulator'
	@echo -e 'make sim [LEVEL=n]: simulate the verilog module on the BASYS3 simulator dump the waveform down to ithe n-th level '

all:
	@verilator -Wno-WIDTH -Wno-PINMISSING --trace --top-module top --cc --exe simulator.cpp RGBpixmap.cpp *.v -CFLAGS -I/usr/include/freetype2 \
	-LDFLAGS -lglut -LDFLAGS -lGLU -LDFLAGS -lpthread -LDFLAGS -lGL -LDFLAGS -lfreetype -LDFLAGS -lftgl
	@echo -e '$(OK_COLOR)[*] Compiled Verilog modules $(NO_COLOR)'
	@make  --silent -j -C obj_dir -f Vtop.mk Vtop
	@echo -e '$(OK_COLOR)[*] Created executable$(NO_COLOR)'

run: all
	@echo -e '$(OK_COLOR)[*] Run Simulator $(NO_COLOR)'
	@./obj_dir/Vtop

sim: all
	@echo -e '$(OK_COLOR)[*] Run Simulator with log level=${LEVEL} $(NO_COLOR)'
	@./obj_dir/Vtop -vcd ${LEVEL}

clean:
	@rm -rf obj_dir/
	@echo -e '$(OK_COLOR)[*] Clean! $(NO_COLOR)'
