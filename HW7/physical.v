module physical(
  input wire clk,
  input wire reset,
  input wire do_init,
  input wire do_send_data,
  input wire [7:0] data_to_send,
  input wire lcdrs_in,

  output reg  init_done,
  output reg  lcde,
  output wire lcdrs,
  output wire lcdrw,
  output reg  [3:0] lcddat,
  output reg  send_data_done
  );


localparam  IDLE = 5'b0000;
localparam  WAIT_40uS_0 = 5'b1111;
localparam  ASSERT_LCDE_1 = 5'b0001;
localparam  WAIT_4_1MS = 5'b0010;
localparam  ASSERT_LCDE_2 = 5'b0011;
localparam  WAIT_100US = 5'b0100;
localparam  ASSERT_LCDE_3 = 5'b0101;
localparam  WAIT_40US_1 = 5'b0110;
localparam  SET_LCDDAT_2 = 5'b10000;
localparam  ASSERT_LCDE_4 = 5'b0111;
localparam  WAIT_40US_2 = 5'b1000;
localparam  SEND_NIBBLE1 = 5'b1001;
localparam  ASSERT_LCDE_NIBBLE1 = 5'b1010;
localparam  BETWEEN_NIBBLES = 5'b1011;
localparam  SEND_NIBBLE2 = 5'b1100;
localparam  ASSERT_LCDE_NIBBLE2 = 5'b1101;
localparam  WAIT_40US_AFTER_CMD = 5'b1110;

reg [4:0] current_state, next_state;
reg [19:0] counter, count_up_to_value;

assign lcdrs = lcdrs_in;
assign lcdrw = 0;  // will only ever be writing, never reading.

always@(negedge clk or posedge reset) begin
  if(reset) current_state <= IDLE;
  else current_state <= next_state;
end

// handle counter here
always@(negedge clk or posedge reset) begin
  if(reset) begin
    counter <= 0;
  end else if(next_state != current_state) begin  // about to transition states
    counter <= 0;                                 // reset the counter
  end else counter <= counter +1;                 // if here, not transitioning states.
end


// handle next state logic and state data here
always@(posedge clk or posedge reset)begin
  if(reset) begin
    init_done <= 0;
    lcde <= 0;
    lcddat <= 0;
    send_data_done <= 0;
    next_state <= 0;
    count_up_to_value <= 20'hffff;
  end else begin
  case(current_state)
   IDLE: begin
    lcde <= 0;
    lcddat <= 0;
    send_data_done <= 0;
    count_up_to_value <= 20'hffff;
    if(do_init && ~init_done) begin
      next_state <= WAIT_40uS_0;
      lcddat <= 3;
    end else if(do_send_data && ~send_data_done) begin
      next_state <= SEND_NIBBLE1;
      lcde <= 0;
      lcddat <= data_to_send[7:4];
    end else next_state <= IDLE;
    end

   WAIT_40uS_0: begin
      lcde <= 0;
      lcddat <= 3;
      count_up_to_value <= 20'h3;
      if(counter == count_up_to_value) next_state <= ASSERT_LCDE_1;
      else next_state <= WAIT_40uS_0;
   end
    
   ASSERT_LCDE_1: begin
     lcde <= 1;
     lcddat <= 3;
     count_up_to_value <= 20'h3;
     if(counter == count_up_to_value) next_state <= WAIT_4_1MS;
     else next_state <= ASSERT_LCDE_1;
    end

   WAIT_4_1MS: begin
    lcde <= 0;
    lcddat <= 3;
    count_up_to_value <= 20'hA028;
    if(counter == count_up_to_value) next_state <= ASSERT_LCDE_2;
    else next_state <= WAIT_4_1MS;
    end

   ASSERT_LCDE_2: begin
      lcde <= 1;
      lcddat <= 3;
      count_up_to_value <= 20'h3;
      if(counter == count_up_to_value) next_state <= WAIT_100US;
      else next_state <= ASSERT_LCDE_2;
    end

   WAIT_100US: begin
    lcde <= 0;
    lcddat <= 3;
    count_up_to_value <= 20'h3E8;
    if(counter == count_up_to_value) next_state <= ASSERT_LCDE_3;
    else next_state <= WAIT_100US;
    end

   ASSERT_LCDE_3: begin
    lcde <= 1;
    lcddat <= 3;
    count_up_to_value <= 20'h3;
    if(counter == count_up_to_value) next_state <= WAIT_40US_1;
    else next_state <= ASSERT_LCDE_3;
    end

   WAIT_40US_1: begin
    lcde <= 0;
    lcddat <= 3;
    count_up_to_value <= 20'h190;
    if(counter == count_up_to_value) next_state <= SET_LCDDAT_2;
    else next_state <= WAIT_40US_1;
    end
    
   SET_LCDDAT_2: begin
    lcde <= 0;
    lcddat <= 2;
    count_up_to_value <= 20'h3;
    if(counter == count_up_to_value) next_state <= ASSERT_LCDE_4;
    else next_state <= SET_LCDDAT_2;
    end   
    
   ASSERT_LCDE_4: begin
    lcde <= 1;
    lcddat <= 2;
    count_up_to_value <= 20'h3;
    if(counter == count_up_to_value) next_state <= WAIT_40US_2;
    else next_state <= ASSERT_LCDE_4;
    end
   
   WAIT_40US_2: begin
    lcde <= 0;
    lcddat <= 2;
    count_up_to_value <= 20'h190;
    if(counter == count_up_to_value) begin
    next_state <= IDLE;
    init_done <= 1;
    end else next_state <= WAIT_40US_2;
    end

   SEND_NIBBLE1: begin
    lcde <= 0;
    lcddat <= data_to_send[7:4];
    count_up_to_value <= 20'h6;
    if(counter == count_up_to_value) begin
      next_state <= ASSERT_LCDE_NIBBLE1;
    end else next_state <= SEND_NIBBLE1;
    end

   ASSERT_LCDE_NIBBLE1: begin
    lcde <= 1;
    lcddat <= data_to_send[7:4];
    count_up_to_value <= 20'h3;
    if(counter == count_up_to_value) next_state <= BETWEEN_NIBBLES;
    else next_state <= ASSERT_LCDE_NIBBLE1;
    end

   BETWEEN_NIBBLES: begin
    lcde <= 0;
    lcddat <= data_to_send[7:4];
    count_up_to_value <= 20'hA;
    if(counter == count_up_to_value) next_state <= SEND_NIBBLE2;
    else next_state <= BETWEEN_NIBBLES;
    end

   SEND_NIBBLE2: begin
    lcde <= 0;
    lcddat <= data_to_send[3:0];
    next_state <= ASSERT_LCDE_NIBBLE2;
    end

   ASSERT_LCDE_NIBBLE2: begin
    lcde <= 1;
    lcddat <= data_to_send[3:0];
    count_up_to_value <= 20'h3;
    if(counter == count_up_to_value) next_state <= WAIT_40US_AFTER_CMD;
    else next_state <= ASSERT_LCDE_NIBBLE2;
    end

   WAIT_40US_AFTER_CMD: begin
    lcde <= 0;
    lcddat <= data_to_send[3:0];
    send_data_done <= 0;
    //count_up_to_value <= 20'h190;
    count_up_to_value <= 20'h3D68;  // good for 1.64ms
    if(counter == count_up_to_value) begin
      next_state <= IDLE;
      send_data_done <= 1;
    end
    else next_state <= WAIT_40US_AFTER_CMD;
    end

  endcase
  end
end

endmodule