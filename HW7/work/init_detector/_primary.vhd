library verilog;
use verilog.vl_types.all;
entity init_detector is
    generic(
        STOP_ON_ERROR   : integer := 1
    );
    port(
        lcddat          : in     vl_logic_vector(3 downto 0);
        lcde            : in     vl_logic;
        lcdrw           : in     vl_logic;
        lcdrs           : in     vl_logic;
        test_reset      : in     vl_logic;
        init_error      : out    vl_logic;
        init_done       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STOP_ON_ERROR : constant is 1;
end init_detector;
