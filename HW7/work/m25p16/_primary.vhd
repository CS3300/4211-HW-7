library verilog;
use verilog.vl_types.all;
entity m25p16 is
    port(
        c               : in     vl_logic;
        data_in         : in     vl_logic;
        s               : in     vl_logic;
        w               : in     vl_logic;
        hold            : in     vl_logic;
        data_out        : out    vl_logic
    );
end m25p16;
