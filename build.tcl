create_project -force basys3-1 -part xc7a35tcpg236-1
set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "/opt/Xilinx/Vivado/2022.1/data/xhub/boards/XilinxBoardStore/boards/Xilinx/basys3/1.2"]" -objects $obj
set_property -name "board_part" -value "digilentinc.com:basys3:part0:1.2" -objects $obj
add_files top.v
add_files vga_controller.v
add_files pixel_gen.v
add_files PS2Controller.v
add_files seven_segment.v
add_files ball_rom.v
add_files -fileset constrs_1 -norecurse /home/sal/vpong/constraints.xdc
launch_runs synth_1 -jobs 8
launch_runs impl_1 -to_step write_bitstream -jobs 8

