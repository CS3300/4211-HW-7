library verilog;
use verilog.vl_types.all;
entity d_ff is
    port(
        data            : in     vl_logic;
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        q               : out    vl_logic
    );
end d_ff;
