module spi_master_flash(
  input wire get_rdid,
  input wire reset,
  input wire clk,

  output reg chipsel,
  output reg spiclk,
  output reg spimosi,
  output reg get_rdid_done,
  output reg [7:0] manufacturer_id,
  output reg [7:0] memory_type,
  output reg [7:0] memory_capacity,
  input wire spimiso 
);


reg [2:0] current_state;
reg [2:0] next_state;
reg [6:0] counter;
reg       spiclk_enable;

parameter IDLE = 3'b000;
parameter ASSERT_CHIPSEL = 3'b001;
parameter SEND_INSTRUCTION = 3'b010;
parameter GET_DATA = 3'b011;
parameter DEASSERT_CHIPSEL = 3'b100;
parameter [7:0] RDID_CMD = 8'h9F;


always @(negedge clk or posedge reset) begin
  if(reset)  current_state <= IDLE;
  else       current_state <= next_state;
end


always @(posedge spiclk or posedge reset) begin

  if     (reset)                             counter <= 0;
  else if(current_state == IDLE)             counter <= 0;
  else if(current_state == ASSERT_CHIPSEL)   counter <= 0;
  else if(current_state == SEND_INSTRUCTION) counter <= counter+1;
  else if(current_state == GET_DATA)         counter <= counter+1;
  else counter <= 0;  // then current_state is DEASSERT_CHIPSEL
end


always @(posedge clk or posedge reset) begin
  if (reset) spiclk <= 0;
  else if(spiclk_enable) spiclk <= !spiclk;
end


always @(posedge clk) begin
  case(current_state)
    IDLE: begin
            if(!get_rdid) begin
              next_state <= IDLE;                    // wait here til something happens.
              chipsel <=1;                           // chipsel is active low.
              spiclk_enable <= 0;
              spimosi <= 0;
              get_rdid_done <= 0;
            end else begin                           //if here, then get_rdid is asserted and reset isn't.
              next_state <= ASSERT_CHIPSEL;
            end
          end

    ASSERT_CHIPSEL: begin
            spiclk_enable <= 1;
            chipsel <= 0;                            // chipsel is active low.
            next_state <= SEND_INSTRUCTION;          //  machine can keep going
          end

    SEND_INSTRUCTION: begin
            spimosi <= RDID_CMD[7-counter];           // output 0x9F with the first 8 bits.
            if(counter < 8) next_state <= SEND_INSTRUCTION;
            else begin
              spimosi <= 0;
              next_state <= GET_DATA;
            end
          end
    
    GET_DATA: begin
            if(counter < 16)       manufacturer_id[7-(counter  -8)] <= spimiso;
            else if(counter < 24)      memory_type[7-(counter -16)] <= spimiso;
            else if(counter < 32)  memory_capacity[7-(counter -24)] <= spimiso;
            else                                next_state <= DEASSERT_CHIPSEL;
          end
   
    DEASSERT_CHIPSEL: begin
            chipsel <= 1;                            // chipsel is active low.
            spiclk_enable <= 0;
            get_rdid_done <= 1;
            next_state <= IDLE;
          end
  endcase
end


endmodule