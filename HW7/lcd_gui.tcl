if [info exists tk_patchLevel] {
    source lcd_gui_internal.tcl
} else {
    echo "Tk unavailable; GUI disabled."
}