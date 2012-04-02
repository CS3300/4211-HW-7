module command(
  input wire CCLK,
  input wire BTN0,  // Btn north
  input wire BTN1,  // Btn east
  input wire SPIMISO,
  input wire SW0,
  
  output reg [7:0] LED,
  output wire SPISCK,
  output wire SPIMOSI,
  output wire SFCE,
  output wire SPISF,
  output wire FPGAIB,
  output wire AMPCS,
  output wire DACCS,
  output wire ADCON,
  output wire LCDE,
  output wire LCDRS,
  output wire LCDRW,
  output wire LCDDAT
  );

wire          CLKDV_OUT;      // divided clock, output of DCM
wire          do_write_data;
wire [7:0]    data_to_write;
wire          do_set_dd_ram_addr;
wire [6:0]    dd_ram_addr;
wire          set_dd_ram_addr_done;
wire          send_data_done;
  
transaction TXN(
  .clk(CLKDV_OUT),
  .reset(BTN0),
  .do_write_data(do_write_data),
  .data_to_write(data_to_write),
  .do_set_dd_ram_addr(do_set_dd_ram_addr),
  .dd_ram_addr(dd_ram_addr),
  .LCDE_q(LCDE),
  .LCDRS_q(LCDRS),
  .LCDRW_q(LCDRW),
  .LCDDAT_q(LCDDAT),
  .set_dd_ram_addr_done(set_dd_ram_addr_done),
  .send_data_done(send_data_done)  
);



endmodule