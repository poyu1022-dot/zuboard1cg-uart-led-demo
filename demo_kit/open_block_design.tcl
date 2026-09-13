open_project [file normalize "[file dirname [info script]]/../build/zuboard_uart_led/zuboard_uart_led.xpr"]
open_bd_design [get_files system.bd]
regenerate_bd_layout
start_gui
