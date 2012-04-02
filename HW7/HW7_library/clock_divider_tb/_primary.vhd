library verilog;
use verilog.vl_types.all;
entity clock_divider_tb is
    port(
        clk_in          : in     vl_logic;
        reset           : in     vl_logic;
        clk_out         : out    vl_logic
    );
end clock_divider_tb;
