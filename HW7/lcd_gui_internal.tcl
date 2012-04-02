# Close window if it's already open
if {[winfo exists .lcdgui]} {
    destroy .lcdgui
}

toplevel .lcdgui
for { set i 0 } { $i < 32 } { incr i } {
    if { $i < 16 } {
	set row 0
    } else {
	set row 1
    }
    set col [expr $i - $row*16]
    label .lcdgui.char_$i
    .lcdgui.char_$i configure -text " " -font {-family courier -size 18} -bd 3 -relief groove
    grid configure .lcdgui.char_$i -row $row -column $col
}

#set row [examine -value -radix decimal /command_if/row]
#set col [examine -value -radix decimal /command_if/col]
#set charn [expr $row*16 + col]
#.lcdgui.char_$charn configure -text [examine -value -radix ascii /command_if/char_out]

when {/char_valid} {
    if {[examine -value -radix unsigned  /char_valid]} {
	set row [examine -value -radix unsigned /row_out]
	set col [examine -value -radix unsigned /column_out]
	set chnum [expr $col + $row*16]
	set charlist [examine -value -radix ascii /char_out]
	set char [lindex $charlist 0]
	.lcdgui.char_$chnum configure -text $char
    }
}