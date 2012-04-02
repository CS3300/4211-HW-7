library verilog;
use verilog.vl_types.all;
entity internal_logic is
    port(
        c               : in     vl_logic;
        d               : in     vl_logic;
        w               : in     vl_logic;
        s               : in     vl_logic;
        hold            : in     vl_logic;
        data_to_read    : in     vl_logic_vector(7 downto 0);
        q               : out    vl_logic;
        data_to_write   : out    vl_logic_vector(7 downto 0);
        page_add_index  : out    vl_logic_vector(7 downto 0);
        add_mem         : out    vl_logic_vector(23 downto 0);
        write_op        : out    vl_logic;
        read_op         : out    vl_logic;
        be_enable       : out    vl_logic;
        se_enable       : out    vl_logic;
        add_pp_enable   : out    vl_logic;
        pp_enable       : out    vl_logic;
        read_enable     : out    vl_logic;
        data_request    : out    vl_logic;
        srwd_wrsr       : out    vl_logic;
        write_protect   : out    vl_logic;
        wrsr            : out    vl_logic
    );
end internal_logic;
