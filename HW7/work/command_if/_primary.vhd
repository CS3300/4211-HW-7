library verilog;
use verilog.vl_types.all;
entity command_if is
    generic(
        STOP_ON_ERROR   : integer := 1
    );
    port(
        data_in         : in     vl_logic_vector(7 downto 0);
        inst_valid      : in     vl_logic;
        data_valid      : in     vl_logic;
        char_out        : out    vl_logic_vector(7 downto 0);
        row             : out    vl_logic;
        col             : out    vl_logic_vector(3 downto 0);
        char_valid      : out    vl_logic;
        display_on      : out    vl_logic;
        clear_display   : out    vl_logic;
        test_reset      : in     vl_logic;
        invalid_cmd     : out    vl_logic;
        busy_cmd        : out    vl_logic;
        init_done       : out    vl_logic;
        init_error      : out    vl_logic;
        cmd_cd          : out    vl_logic;
        cmd_rch         : out    vl_logic;
        cmd_ems         : out    vl_logic;
        cmd_doo         : out    vl_logic;
        cmd_cds         : out    vl_logic;
        cmd_fs          : out    vl_logic;
        cmd_cgra        : out    vl_logic;
        cmd_ddra        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STOP_ON_ERROR : constant is 1;
end command_if;
