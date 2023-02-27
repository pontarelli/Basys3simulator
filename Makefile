



all:
	 verilator -Wno-WIDTH -Wno-PINMISSING --trace --top-module display --cc --exe simulator.cpp *.v -LDFLAGS -lglut -LDFLAGS -lGLU -LDFLAGS -lpthread -LDFLAGS -lGL
	 make -j -C obj_dir -f Vdisplay.mk Vdisplay
run:
	./obj_dir/Vdisplay
sim:
	./obj_dir/Vdisplay -vcd


clean:
	rm -rf obj_dir/
