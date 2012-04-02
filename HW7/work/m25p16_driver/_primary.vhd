library verilog;
use verilog.vl_types.all;
entity m25p16_driver is
    port(
        clk             : out    vl_logic;
        din             : out    vl_logic;
        cs_valid        : out    vl_logic;
        hard_protect    : out    vl_logic;
        hold            : out    vl_logic
    );
end m25p16_driver;
