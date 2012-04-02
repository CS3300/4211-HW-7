library verilog;
use verilog.vl_types.all;
entity debounce_sync is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        async_in        : in     vl_logic;
        sync_out        : out    vl_logic
    );
end debounce_sync;
