create_project -force basys3-1 -part xc7a35tcpg236-1
set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "/opt/Xilinx/Vivado/2022.1/data/xhub/boards/XilinxBoardStore/boards/Xilinx/basys3/1.2"]" -objects $obj
set_property -name "board_part" -value "digilentinc.com:basys3:part0:1.2" -objects $obj
add_files top.v
add_files vga_controller.v
add_files pixel_gen.v
add_files PS2Controller.v
add_files seven_segment.v
add_files seven_segment_sw.v
add_files ball_rom.v
set_property file_type SystemVerilog [get_files top.v]
set_property file_type SystemVerilog [get_files seven_segment_sw.v]
set_property top top [current_fileset]
update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse[get_files constraints.xdc]
launch_runs synth_1 -jobs 8
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
	   error "ERROR: synthesis failed"
   }

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
	   error "ERROR: implementation failed"
   }
