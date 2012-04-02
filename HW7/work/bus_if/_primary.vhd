library verilog;
use verilog.vl_types.all;
entity bus_if is
    generic(
        STOP_ON_ERROR   : integer := 1
    );
    port(
        lcde            : in     vl_logic;
        lcdrs           : in     vl_logic;
        lcdrw           : in     vl_logic;
        lcddat          : in     vl_logic_vector(3 downto 0);
        init_done       : in     vl_logic;
        test_reset      : in     vl_logic;
        data_out        : out    vl_logic_vector(7 downto 0);
        inst_valid      : out    vl_logic;
        data_valid      : out    vl_logic;
        t_setup_error   : out    vl_logic;
        t_hold_error    : out    vl_logic;
        t_pw_error      : out    vl_logic;
        t_4bit_error    : out    vl_logic;
        t_c_error       : out    vl_logic;
        glitch_error    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STOP_ON_ERROR : constant is 1;
end bus_if;
