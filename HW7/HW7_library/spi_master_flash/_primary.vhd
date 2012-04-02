library verilog;
use verilog.vl_types.all;
entity spi_master_flash is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        ASSERT_CHIPSEL  : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        SEND_INSTRUCTION: vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        GET_DATA        : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        DEASSERT_CHIPSEL: vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        RDID_CMD        : vl_logic_vector(7 downto 0) := (Hi1, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi1)
    );
    port(
        get_rdid        : in     vl_logic;
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        chipsel         : out    vl_logic;
        spiclk          : out    vl_logic;
        spimosi         : out    vl_logic;
        get_rdid_done   : out    vl_logic;
        manufacturer_id : out    vl_logic_vector(7 downto 0);
        memory_type     : out    vl_logic_vector(7 downto 0);
        memory_capacity : out    vl_logic_vector(7 downto 0);
        spimiso         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of ASSERT_CHIPSEL : constant is 1;
    attribute mti_svvh_generic_type of SEND_INSTRUCTION : constant is 1;
    attribute mti_svvh_generic_type of GET_DATA : constant is 1;
    attribute mti_svvh_generic_type of DEASSERT_CHIPSEL : constant is 1;
    attribute mti_svvh_generic_type of RDID_CMD : constant is 2;
end spi_master_flash;
