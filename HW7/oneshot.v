module oneshot(
  input wire reset,
  input wire clock,
  input wire get_debounce,
  output wire get_oneshot
    );

wire get_debounce_q;

d_ff D1(
  .data(get_debounce),
  .clock(clock),
  .reset(reset),
  .q(get_debounce_q)
);


assign get_oneshot = get_debounce & ~get_debounce_q;

endmodule