# Synthesize, implement, generate the bitstream, and export the hardware
# platform (.xsa) for Vitis. Run after 01_create_project.tcl.
#   vivado -mode batch -source 02_build_bitstream.tcl

set script_dir [file normalize [file dirname [info script]]]
set proj_dir   [file normalize "$script_dir/../build"]
set proj_name  zuboard_uart_led

open_project $proj_dir/$proj_name/$proj_name.xpr

launch_runs synth_1 -jobs 8
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} { error "synthesis failed" }

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} { error "implementation failed" }

open_run impl_1
set out_dir [file normalize "$script_dir/../prebuilt"]
file mkdir $out_dir
write_hw_platform -fixed -include_bit -force -file $out_dir/zuboard_uart_led.xsa

# Also copy the raw .bit next to it for direct JTAG programming without Vitis.
file copy -force \
    $proj_dir/$proj_name/$proj_name.runs/impl_1/system_wrapper.bit \
    $out_dir/system_wrapper.bit

puts "BUILD_DONE: $out_dir"
