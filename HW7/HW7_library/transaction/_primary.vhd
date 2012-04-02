library verilog;
use verilog.vl_types.all;
entity transaction is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        do_init         : in     vl_logic;
        do_write_data   : in     vl_logic;
        data_to_write   : in     vl_logic_vector(7 downto 0);
        LCDE_q          : out    vl_logic;
        LCDRS_q         : out    vl_logic;
        LCDRW_q         : out    vl_logic;
        LCDDAT_q        : out    vl_logic_vector(3 downto 0);
        reset_done      : out    vl_logic;
        init_done       : inout  vl_logic;
        send_data_done  : inout  vl_logic
    );
end transaction;
