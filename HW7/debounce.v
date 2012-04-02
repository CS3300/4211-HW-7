`default_nettype none

module debounce_sync(
  input wire clock,
  input wire reset,
  input wire async_in,
  
  output wire sync_out
);

wire q1;

d_ff D1(
  .clock( clock ),
  .reset( reset ),
  .data( async_in ),
  
  .q( q1 )
);
  
d_ff D2(
  .clock( clock ),
  .reset( reset ),
  .data( q1 ),
  
  .q( sync_out )
);
endmodule
