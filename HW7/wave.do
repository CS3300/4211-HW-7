onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /testbench/CCLK
add wave -noupdate /testbench/BTN0
add wave -noupdate /testbench/BTN1
add wave -noupdate /testbench/SPIMISO
add wave -noupdate /testbench/SPISCK
add wave -noupdate /testbench/SPIMOSI
add wave -noupdate /testbench/LCDDAT
add wave -noupdate -divider Command
add wave -noupdate /testbench/CMD/BTN1_debounced
add wave -noupdate /testbench/CMD/do_init
add wave -noupdate /testbench/CMD/init_done
add wave -noupdate /testbench/CMD/reset_done
add wave -noupdate /testbench/CMD/do_write_data
add wave -noupdate /testbench/CMD/data_to_write
add wave -noupdate /testbench/CMD/send_data_done
add wave -noupdate /testbench/CMD/get_rdid_oneshot
add wave -noupdate /testbench/CMD/get_rdid_done
add wave -noupdate /testbench/CMD/string_to_display
add wave -noupdate /testbench/CMD/display_counter
add wave -noupdate /testbench/CMD/current_state
add wave -noupdate /testbench/CMD/next_state
add wave -noupdate /testbench/CMD/man_ID_out
add wave -noupdate /testbench/CMD/mem_TP_out
add wave -noupdate /testbench/CMD/mem_CP_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59987272 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5150 us} {68150 us}
