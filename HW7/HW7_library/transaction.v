// from notes: assign lcdrs_in in the transaction layer state machine

module transaction(
  input wire clk,
  input wire reset,
  input wire do_write_data,
  input wire [7:0] data_to_write,
  input wire do_set_dd_ram_addr,
  input wire [6:0] dd_ram_addr,
  
  output wire LCDE_q,
  output wire LCDRS_q,
  output wire LCDRW_q,
  output wire LCDDAT_q,
  output reg set_dd_ram_addr_done,
  output wire send_data_done
);

wire        do_init;
wire        do_send_data;
wire [7:0]  data_to_send;
wire        lcdrs_in;
wire        init_done;


physical PHYSICAL(
  .clk(clk),
  .reset(reset),
  .do_init(do_init),
  .do_send_data(do_send_data),
  .data_to_send(data_to_send),
  .lcdrs_in(lcdrs_in),
  .init_done(init_done),
  .lcde(LCDE_q),
  .lcdrs(LCDRS_q),
  .lcdrw(LCDRW_q),
  .lcddat(LCDDAT_q),
  .send_data_done(send_data_done)
);

endmodule