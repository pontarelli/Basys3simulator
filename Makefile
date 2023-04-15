



all:
	 verilator -Wno-WIDTH -Wno-PINMISSING --trace --top-module display --cc --exe simulator.cpp RGBpixmap.cpp *.v -CFLAGS -I/usr/include/freetype2 \
	 -LDFLAGS -lglut -LDFLAGS -lGLU -LDFLAGS -lpthread -LDFLAGS -lGL -LDFLAGS -lfreetype -LDFLAGS -lftgl
	 make -j -C obj_dir -f Vdisplay.mk Vdisplay
run:
	./obj_dir/Vdisplay
sim:
	./obj_dir/Vdisplay -vcd


clean:
	rm -rf obj_dir/
