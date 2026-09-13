# Program the ZUBoard 1CG over JTAG and launch hello_avnet.elf.
# Run with:  xsdb program_and_run.tcl   (or: xsct, on older Vitis releases)
#
# Prerequisites:
#   - ZUBoard 1CG BOOT MODE switch (SW2) set to JTAG: ON-ON-ON-ON
#   - Board connected via micro-USB (J16) and powered on
#
# This uses the prebuilt bitstream/ELF shipped in ../prebuilt/. It does not
# touch the board's QSPI flash / factory image.

set script_dir [file normalize [file dirname [info script]]]
set repo_dir   [file normalize "$script_dir/.."]

set bit_file  "$repo_dir/prebuilt/system_wrapper.bit"
set elf_file  "$repo_dir/prebuilt/hello_avnet.elf"
set psu_init  "$repo_dir/prebuilt/psu_init.tcl"

connect
after 1000

targets -set -filter {name =~ "*PSU*"}
fpga -file $bit_file
puts "BITSTREAM_PROGRAMMED"

targets -set -filter {name =~ "*PSU*"}
source $psu_init
psu_init
psu_ps_pl_isolation_removal
psu_ps_pl_reset_config
puts "PSU_INIT_DONE"

targets -set -filter {name =~ "*Cortex-A53 #0*"}
rst -processor
dow $elf_file
puts "ELF_DOWNLOADED"

con
puts "APP_RUNNING"
