library verilog;
use verilog.vl_types.all;
entity acdc_check is
    port(
        c               : in     vl_logic;
        d               : in     vl_logic;
        s               : in     vl_logic;
        hold            : in     vl_logic;
        write_op        : in     vl_logic;
        read_op         : in     vl_logic;
        srwd_wrsr       : in     vl_logic;
        write_protect   : in     vl_logic;
        wrsr            : in     vl_logic
    );
end acdc_check;
