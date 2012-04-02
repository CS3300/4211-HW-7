library verilog;
use verilog.vl_types.all;
entity physical is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        do_init         : in     vl_logic;
        do_send_data    : in     vl_logic;
        data_to_send    : in     vl_logic_vector(7 downto 0);
        lcdrs_in        : in     vl_logic;
        init_done       : out    vl_logic;
        lcde            : out    vl_logic;
        lcdrs           : out    vl_logic;
        lcdrw           : out    vl_logic;
        lcddat          : out    vl_logic_vector(3 downto 0);
        send_data_done  : out    vl_logic
    );
end physical;
