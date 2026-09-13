# ZUBoard 1CG - UART0 "Hello" + alternating User RGB LED (D4/D5) blink demo
# Creates the Vivado project + IP Integrator block design from scratch.
#
# Usage (from a Vivado Tcl console, or `vivado -mode batch -source 01_create_project.tcl`):
#   the project is created under ../build/zuboard_uart_led

set script_dir [file normalize [file dirname [info script]]]
set proj_dir   [file normalize "$script_dir/../build"]
set proj_name  zuboard_uart_led
set part_name  xczu1cg-sbva484-1-e

create_project $proj_name $proj_dir/$proj_name -part $part_name -force
create_bd_design "system"

# Zynq UltraScale+ MPSoC Processing System
set zu_vlnv [lindex [get_ipdefs -filter {NAME == zynq_ultra_ps_e} -all] end]
set ps [create_bd_cell -type ip -vlnv $zu_vlnv zynq_ultra_ps_e_0]

# - UART0 on MIO 10/11 (Bank 500, 1.8V) -> on-board FTDI FT2232H -> J16 micro-USB
#   (see ZUBoard 1CG HW User's Guide, Table 1 / Table 15)
# - DDR controller disabled: the demo app runs entirely from on-chip memory (OCM),
#   so no DDR part/timing configuration is required.
# - M_AXI_GP2 (HPM0_LPD) disabled: no PL AXI peripherals are used in this design.
set_property -dict [list \
    CONFIG.PSU__DDRC__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 10 .. 11} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
] $ps

# LED blink logic (PL) - see led_blink.v. Runs off the PS's own PL fabric clock
# (pl_clk0, enabled by default at 100MHz) and fabric reset (pl_resetn0).
add_files -norecurse "$script_dir/led_blink.v"
update_compile_order -fileset sources_1
create_bd_cell -type module -reference led_blink led_blink_0
connect_bd_net [get_bd_pins $ps/pl_clk0]     [get_bd_pins led_blink_0/clk]
connect_bd_net [get_bd_pins $ps/pl_resetn0]  [get_bd_pins led_blink_0/resetn]

# Bring the 6 LED channel outputs (D4 = RGB1, D5 = RGB2) out to top-level ports.
foreach sig {led_d4_r led_d4_g led_d4_b led_d5_r led_d5_g led_d5_b} {
    create_bd_port -dir O $sig
    connect_bd_net [get_bd_pins led_blink_0/$sig] [get_bd_ports $sig]
}

regenerate_bd_layout
validate_bd_design
save_bd_design

# Top-level HDL wrapper + pin/IO constraints for D4 (Bank 44) and D5 (Bank 65/66).
set wrapper_path [make_wrapper -files [get_files system.bd] -top]
add_files -norecurse $wrapper_path
update_compile_order -fileset sources_1
set_property top system_wrapper [current_fileset]

add_files -fileset constrs_1 -norecurse "$script_dir/led_constraints.xdc"
update_compile_order -fileset sources_1

puts "PROJECT_CREATED: $proj_dir/$proj_name/$proj_name.xpr"
