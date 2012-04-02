library verilog;
use verilog.vl_types.all;
entity oneshot is
    port(
        reset           : in     vl_logic;
        clock           : in     vl_logic;
        get_debounce    : in     vl_logic;
        get_oneshot     : out    vl_logic
    );
end oneshot;
