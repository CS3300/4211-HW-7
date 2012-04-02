library verilog;
use verilog.vl_types.all;
entity clock_divider is
    port(
        CLKIN_IN        : in     vl_logic;
        RST_IN          : in     vl_logic;
        CLKDV_OUT       : out    vl_logic;
        CLKIN_IBUFG_OUT : out    vl_logic;
        CLK0_OUT        : out    vl_logic
    );
end clock_divider;
