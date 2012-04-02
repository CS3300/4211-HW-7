module command(
  input wire CCLK,
  input wire BTN0,  // Btn north
  input wire BTN1,  // Btn east
  input wire SPIMISO,

  output wire SPISCK,
  output wire SPIMOSI,
  output wire SFCE,    // parallel flash prom
  output wire SPISF,
  output wire FPGAIB,  // platform flash prom
  output wire AMPCS,   // pre-amp
  output wire DACCS,   // dac converter
  output wire ADCON,   // adc converter
  output wire LCDE,
  output wire LCDRS,
  output wire LCDRW,
  output wire [3:0] LCDDAT
  );

localparam IDLE = 2'b00;
localparam WAIT_GET_RDID_DONE = 2'b01;
localparam SEND_BYTE = 2'b10;
localparam WAIT_DONE = 2'b11;

wire          CLKDV_OUT;      // divided clock, output of DCM
wire          CLK0_OUT;
wire          BTN1_debounced;
reg           do_init;
wire          init_done;
wire          reset_done;
reg           do_write_data;
reg  [7:0]    data_to_write;
wire          send_data_done;
wire          get_rdid_oneshot;
wire          get_rdid_done;
reg  [127:0]  string_to_display;
reg  [4:0]    display_counter;
reg  [1:0]    current_state, next_state;
reg  [15:0]   man_ID_out, mem_TP_out, mem_CP_out;  // 2-digit displayed on LCD panel
wire [7:0]    man_ID;
wire [7:0]    mem_TP;
wire [7:0]    mem_CP;
wire [35:0]   CONTROL;

 // icon icon (
     // .CONTROL0(CONTROL) // INOUT BUS [35:0]
 // );

 // ila ila (
     // .CONTROL(CONTROL), // INOUT BUS [35:0]
     // .CLK(CLK0_OUT), // IN
     // .TRIG0({do_write_data,BTN0,CLKDV_OUT,SPIMOSI,SPIMISO,BTN1_debounced,get_rdid_oneshot,get_rdid_done, mem_CP_out}) // IN BUS [23:0]
 // );



always@* begin
  man_ID_out = (hex_to_ASCII(man_ID));
  mem_TP_out = (hex_to_ASCII(mem_TP));
  mem_CP_out = (hex_to_ASCII(mem_CP));
end



wire          w;                // for use to sim m25p16 memory
wire          hold;             // for use to sim m25p16 memory
assign w = 1;                   // for use to sim m25p16 memory
assign hold = 1;                // for use to sim m25p16 memory

always @(negedge CLKDV_OUT or posedge BTN0) begin
  if(BTN0)  current_state <= IDLE;
  else      current_state <= next_state;
end


always @(posedge CLKDV_OUT or posedge BTN0) begin
  if(BTN0) begin
  display_counter <= 5'h0; // tracks the current cell to write to
  do_init <= 1;
  string_to_display <= 0;
  do_write_data <= 1'b0;
  data_to_write <= 0;
  next_state <= 0;
  man_ID_out <= 0;
  mem_TP_out <= 0;
  mem_CP_out <= 0;
  end else begin
  case(current_state)
    IDLE: begin
      do_write_data <= 1'b0;
      if(~init_done)begin
        do_init <= 1;
      end else if (~reset_done) begin
        do_init <= 0;
        next_state <= IDLE;
      end else if(get_rdid_oneshot) begin
        next_state <= WAIT_GET_RDID_DONE;
        display_counter <= 5'h10;  // write to upper left cell
      end else begin
        do_init <= 0;
        next_state <= IDLE;
        end
      end

    WAIT_GET_RDID_DONE: begin
      if(get_rdid_done) begin
      next_state <= SEND_BYTE;
      string_to_display[127:104] <= "CP=";
      string_to_display[103:88]  <= mem_CP_out;
      string_to_display[87:64] <= " I=";
      string_to_display[63:48] <= man_ID_out;
      string_to_display[47:16] <= " TP=";
      string_to_display[15:0] <= mem_TP_out;
      end
      else next_state <= WAIT_GET_RDID_DONE;
      end

    SEND_BYTE: begin
      if(get_rdid_oneshot) begin
        next_state <= WAIT_GET_RDID_DONE;
      end else if(display_counter!=0) begin
        next_state <= WAIT_DONE;
        do_write_data <= 1'b1;
      end else begin
        next_state <= SEND_BYTE;
        do_write_data <= 1'b0;
      end
      end

    WAIT_DONE: begin
      if(get_rdid_oneshot) begin
        next_state <= WAIT_GET_RDID_DONE;
      end else if(send_data_done) begin
        next_state <= SEND_BYTE;
        do_write_data <= 1'b0;
        display_counter <= display_counter -1;
      end else begin
        next_state <= WAIT_DONE;
        do_write_data <= 1'b1;
        end
      end
  endcase
  end
end


// always @(posedge CLKDV_OUT or posedge BTN0) begin
  // if(BTN0)        data_to_write <= 0;
  // else begin
  // data_to_write <= string_to_display[((display_counter+1)*8)-1:((display_counter+1)*8)-8];
  // end
// end


always @(posedge CLKDV_OUT or posedge BTN0) begin
  if(BTN0)        data_to_write <= 0;
  else begin
    case(display_counter)
      5'h10: data_to_write <= string_to_display[127:120];
      5'h0f: data_to_write <= string_to_display[119:112];
      5'h0e: data_to_write <= string_to_display[111:104];
      5'h0d: data_to_write <= string_to_display[103:96];
      5'h0c: data_to_write <= string_to_display[95:88];
      5'h0b: data_to_write <= string_to_display[87:80];
      5'h0a: data_to_write <= string_to_display[79:72];
      5'h09: data_to_write <= string_to_display[71:64];
      5'h08: data_to_write <= string_to_display[63:56];
      5'h07: data_to_write <= string_to_display[55:48];
      5'h06: data_to_write <= string_to_display[47:40];
      5'h05: data_to_write <= string_to_display[39:32];
      5'h04: data_to_write <= string_to_display[31:24];
      5'h03: data_to_write <= string_to_display[23:16];
      5'h02: data_to_write <= string_to_display[15:8];
      5'h01: data_to_write <= string_to_display[7:0];
      endcase
  end
end




 // clock_divider CLK_DIV(
     // .CLKIN_IN(CCLK), 
     // .RST_IN(BTN0), 
     // .CLKDV_OUT(CLKDV_OUT),
//     //.CLKIN_IBUFG_OUT(CLKIN_IBUFG_OUT), 
     // .CLK0_OUT(CLK0_OUT)
     // );


clock_divider_tb CLK_DIV_TB(
.clk_in(CCLK),
.reset(BTN0),
.clk_out(CLKDV_OUT)
);

transaction TXN(
  .clk(CLKDV_OUT),
  .reset(BTN0),
  .do_init(do_init),
  .reset_done(reset_done),
  .do_write_data(do_write_data),
  .data_to_write(data_to_write),
  .LCDE_q(LCDE),
  .LCDRS_q(LCDRS),
  .LCDRW_q(LCDRW),
  .LCDDAT_q(LCDDAT),
  .init_done(init_done),
  .send_data_done(send_data_done)
);

spi_master_flash SPI_FLASH(
  .get_rdid(get_rdid_oneshot),
  .get_rdid_done(get_rdid_done),
  .reset(BTN0),
  .clk(CLKDV_OUT),
  .chipsel(SPISF),
  .spiclk(SPISCK),
  .spimosi(SPIMOSI),
  .spimiso(SPIMISO),
  .manufacturer_id(man_ID),
  .memory_type(mem_TP),
  .memory_capacity(mem_CP)
);


// for use in testbench.
m25p16 memory (
 .c(SPISCK),
 .data_in(SPIMOSI),
 .s(SPISF),
 .w(w),                // write protect; active low. assign to 1.
 .hold(hold),          // hold communication; active low. assign to 1.
 .data_out(SPIMISO)
);




debounce_sync BTN1_debouncer(
  .clock(CLKDV_OUT),
  .reset(BTN0),
  .async_in(BTN1),
  .sync_out(BTN1_debounced)
);
oneshot BTN1_oneshotter(
  .reset(BTN0),                           // button north
  .clock(CLKDV_OUT),                      // comes from the clock divider
  .get_debounce(BTN1_debounced),          // comes from the BTN1_debouncer
  .get_oneshot(get_rdid_oneshot)          // output is used in command layer
);


function [15:0] hex_to_ASCII;
  input [7:0] hex;
  reg   [4:0] temp;
  reg   [7:0] upper_byte, lower_byte;
  begin
    temp = hex[7:4];
    upper_byte = convert(temp);
    temp = hex[3:0];
    lower_byte = convert(temp);
    hex_to_ASCII = {upper_byte, lower_byte};
  end
endfunction

function [7:0] convert;
  input [3:0] nibble;
  reg [7:0] return_value;
  begin
    return_value = 8'h00;
    return_value[2:0] = nibble[2:0];
    if(nibble == 4'h9) return_value[3] = 1;
    else if(nibble > 4'h9) return_value[7:4] = 4'h4; // if character, add 0x40
    else return_value[7:4] = 4'h3;                   // if number, add 0x30
    convert = return_value;
  end
  
endfunction



assign ADCON  = 1'b0;
assign DACCS  = 1'b1;
assign FPGAIB = 1'b0;
assign AMPCS  = 1'b1;
assign SFCE   = 1'b1;

endmodule
