NO_COLOR=\e[0m
OK_COLOR=\e[32;01m
ERROR_COLOR=\e[31;01m
WARN_COLOR=\e[33;01m
OK_STRING=$(OK_COLOR)[OK]$(NO_COLOR)

#define debug level for waveforms
LEVEL=1
VGA=0


help:
	@echo -e '$(OK_COLOR)'
	@echo -e 'Usage: $(NO_COLOR)'
	@echo -e 'make help: display this message'
	@echo -e 'make all: build the simulator with the specified verilog module'
	@echo -e 'make run [VGA=1]: simulate the verilog module on the BASYS3 simulator (VGA=1: enable VGA)'
	@echo -e 'make sim [LEVEL=n]: simulate the verilog module on the BASYS3 simulator dump the waveform down to the n-th level '
	@echo -e 'make project: Create vivado projet and open in gui mode'
	@echo -e 'make bitstream: Run Vivado in batch mode to build the bitstream'
	@echo -e 'make program: program the Basys 3 board'

all:
	@verilator -Wno-WIDTH -Wno-PINMISSING --trace --top-module top --cc --exe ./simulator/simulator.cpp ./simulator/RGBpixmap.cpp *.v -CFLAGS -I/usr/include/freetype2 \
	-CFLAGS -DVGA=${VGA} -LDFLAGS -lglut -LDFLAGS -lGLU -LDFLAGS -lpthread -LDFLAGS -lGL -LDFLAGS -lfreetype -LDFLAGS -lftgl
	@echo -e '$(OK_COLOR)[*] Compiled Verilog modules $(NO_COLOR)'
	@make  --silent -j -C obj_dir -f Vtop.mk Vtop
	@echo -e '$(OK_COLOR)[*] Created executable$(NO_COLOR)'

run: all
	@echo -e '$(OK_COLOR)[*] Run Simulator $(NO_COLOR)'
	@./obj_dir/Vtop 

sim: all
	@echo -e '$(OK_COLOR)[*] Run Simulator with log level=${LEVEL} $(NO_COLOR)'
	@./obj_dir/Vtop -vcd ${LEVEL}

project:
	@echo -e '$(OK_COLOR)[*] Create vivado projet and open in gui mode $(NO_COLOR)'
	@rm -rf basys3-1.* 
	@if vivado -source ./scripts/build.tcl ; then \
		echo 'Done'; \
	else \
		printf "%b" "$(WARN_COLOR)source settings64.sh in Vivado directory \n$(NO_COLOR)" ; \
	fi

bitstream:
	@echo -e '$(OK_COLOR)[*] Run Vivado in batch mode to build the bitstream $(NO_COLOR)'
	@rm -rf basys3-1.* 
	@if vivado -mode batch -source ./scripts/build.tcl ; then \
		echo 'Done'; \
	else \
		printf "%b" "$(WARN_COLOR)source settings64.sh in Vivado directory \n$(NO_COLOR)" ; \
	fi
	@cp basys3-1.runs/impl_1/top.bit .
	@echo -e '$(OK_COLOR)[*] Created bitstream top.bit $(NO_COLOR)'

program:
	@echo -e '$(OK_COLOR)[*] Program the basys 3 board $(NO_COLOR)'
	@echo -e '$(WARN_COLOR)[-->] It must be tested! $(NO_COLOR)'
	@vivado -mode tcl -source ./scripts/program_fpga.tcl 

clean:
	@rm -rf obj_dir/
	@rm -rf basys3-1.* 
	@echo -e '$(OK_COLOR)[*] Clean! $(NO_COLOR)'
