module transaction(
  input wire clk,
  input wire reset,
  input wire do_init,
  input wire do_write_data,
  input wire [7:0] data_to_write,
  input wire do_return_cursor_home,
  
  output wire LCDE_q,
  output wire LCDRS_q,
  output wire LCDRW_q,
  output wire [3:0] LCDDAT_q,
  output reg  reset_done,
  output reg  return_cursor_home_done,

  inout init_done,
  inout send_data_done
);


reg         do_send_data;
reg [7:0]   data_to_send;
reg         lcdrs_in;
reg [2:0]   current_state, next_state;

localparam  INIT = 3'b000;
localparam  FUNCTION_SET = 3'b001;
localparam  ENTRY_MODE_SET = 3'b010;
localparam  DISPLAY_ON_OFF = 3'b011;
localparam  CLEAR_DISPLAY = 3'b100;
localparam  IDLE = 3'b101;
localparam  DO_WRITE_RAM = 3'b110;

// handle state transitions & reset_done flag here
always@(negedge clk or posedge reset) begin
  if(reset) begin
    current_state <= INIT;
    reset_done <= 1'b0;
  end else begin 
    current_state <= next_state;
    if(current_state == CLEAR_DISPLAY) begin
       if(send_data_done) reset_done <= 1'b1;
      else reset_done <= 1'b0;
     end
  end
end

always@* begin
  case(current_state)
    INIT: begin
      do_send_data <= 1'b0;
      data_to_send <= 8'h00;
      lcdrs_in <= 0;
      return_cursor_home_done <= 1'b0;
      if(init_done) begin
        next_state <= FUNCTION_SET;
      end else begin
        next_state <= INIT;
      end
    end
      
    FUNCTION_SET: begin
      do_send_data <= 1'b1;
      data_to_send <= 8'h28;
      lcdrs_in <= 0;
      if(send_data_done) next_state <= ENTRY_MODE_SET;
      else next_state <= FUNCTION_SET;
    end
    
    ENTRY_MODE_SET: begin
      do_send_data <= 1'b1;
      data_to_send <= 8'h06;
      lcdrs_in <= 0;      
      if(send_data_done) next_state <= DISPLAY_ON_OFF;
      else next_state <= ENTRY_MODE_SET;
    end
    
    DISPLAY_ON_OFF: begin
      do_send_data <= 1'b1;
      data_to_send <= 8'h0F;
      lcdrs_in <= 0;      
      if(send_data_done) next_state <= CLEAR_DISPLAY;
      else next_state <= DISPLAY_ON_OFF;
    end
    
    CLEAR_DISPLAY: begin
      if(~send_data_done) begin
      do_send_data <= 1'b1;
      data_to_send <= 8'h01;
      lcdrs_in <= 0;      
      next_state <= CLEAR_DISPLAY;
      end else begin
        data_to_send <= 8'h0;
        lcdrs_in <= 0;
        do_send_data <= 1'b0;
        return_cursor_home_done <= 1;
        next_state <= IDLE;
      end
    end
    
    IDLE: begin
      do_send_data <= 1'b0;
      if(do_write_data) begin
        lcdrs_in <= 1;      
        next_state <= DO_WRITE_RAM;
        data_to_send <= data_to_write;
      end else if(do_return_cursor_home) begin
        next_state <= CLEAR_DISPLAY;
        return_cursor_home_done <= 0;
        lcdrs_in <= 0;      
      end else begin
        next_state <= IDLE;
        data_to_send <= 8'h0;
        lcdrs_in <= 0;
      end
    end
    
    DO_WRITE_RAM: begin
      if(~send_data_done) begin
      lcdrs_in <= 1;      
      do_send_data <= 1'b1;
      data_to_send <= data_to_write;
      next_state <= DO_WRITE_RAM;
      end else begin
        do_send_data <= 1'b0;
        next_state <= IDLE;
        data_to_send <= 8'h0;
        lcdrs_in <= 0;
      end
    end
    
  endcase
end


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