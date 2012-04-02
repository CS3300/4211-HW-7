library verilog;
use verilog.vl_types.all;
entity memory_access is
    generic(
        initfile        : string  := "initM25P16.txt"
    );
    port(
        add_mem         : in     vl_logic_vector(23 downto 0);
        be_enable       : in     vl_logic;
        se_enable       : in     vl_logic;
        add_pp_enable   : in     vl_logic;
        pp_enable       : in     vl_logic;
        read_enable     : in     vl_logic;
        data_request    : in     vl_logic;
        data_to_write   : in     vl_logic_vector(7 downto 0);
        page_add_index  : in     vl_logic_vector(7 downto 0);
        data_to_read    : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of initfile : constant is 1;
end memory_access;
