library verilog;
use verilog.vl_types.all;
entity lcd_control is
    port(
        lcddat          : in     vl_logic_vector(3 downto 0);
        lcdrs           : in     vl_logic;
        lcdrw           : in     vl_logic;
        lcde            : in     vl_logic;
        char_out        : out    vl_logic_vector(7 downto 0);
        row_out         : out    vl_logic;
        column_out      : out    vl_logic_vector(3 downto 0);
        char_valid      : out    vl_logic
    );
end lcd_control;
