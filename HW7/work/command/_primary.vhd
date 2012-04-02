library verilog;
use verilog.vl_types.all;
entity command is
    port(
        CCLK            : in     vl_logic;
        BTN0            : in     vl_logic;
        BTN1            : in     vl_logic;
        SPIMISO         : in     vl_logic;
        SPISCK          : out    vl_logic;
        SPIMOSI         : out    vl_logic;
        SFCE            : out    vl_logic;
        SPISF           : out    vl_logic;
        FPGAIB          : out    vl_logic;
        AMPCS           : out    vl_logic;
        DACCS           : out    vl_logic;
        ADCON           : out    vl_logic;
        LCDE            : out    vl_logic;
        LCDRS           : out    vl_logic;
        LCDRW           : out    vl_logic;
        LCDDAT          : out    vl_logic_vector(3 downto 0)
    );
end command;
