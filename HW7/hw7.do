#vlog d_ff.v
vlog debounce.v
vlog oneshot.v
vlog clock_divider_tb.v
vlog spi_master_flash.v
vlog physical.v
vlog transaction.v
vlog command.v
vlog bus_if.v
vlog command_if.v
vlog init_detector.v
vlog lcd_control.v
vlog testbench.v
vsim -novpt testbench.v
source lcd_gui.tcl

do wave.do
run 50 ms