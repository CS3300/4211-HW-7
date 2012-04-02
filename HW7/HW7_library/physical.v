// from notes: assign lcdrs_in from transaction layer to lcdrs in the physical layer.
// put counter in here

module physical(
  input wire clk,
  input wire reset,
  input wire do_init,
  input wire do_send_data,
  input wire [7:0] data_to_send,
  input wire lcdrs_in,
  
  output reg init_done,
  output reg lcde,
  output reg lcdrs,
  output reg lcdrw,
  output reg lcddat,
  output reg send_data_done
  );


endmodule