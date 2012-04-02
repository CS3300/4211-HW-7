//module for LCD controller initialization sequence detector
`default_nettype none
`timescale 1ns/1ns

module init_detector(
  input wire [3:0] lcddat,  //Is SF_D on data sheet
  input wire lcde, lcdrw, lcdrs, test_reset,
  output reg init_error, init_done
  );
  
  reg clk;
  reg [31:0] counter;
     
   parameter  STOP_ON_ERROR = 1;        // If 0, continue running on error
   localparam INITIAL_DELAY = 1499999; // Power-on wait
   localparam C1_WAIT       = 409999;  // Wait after first cycle
   localparam C2_WAIT       = 9999;  // Wait after second cycle
   localparam C3_WAIT       = 3999;  // Wait after third cycle
   localparam C4_WAIT       = 3999;  // Wait after fourth cycle


   // Correct lcddat sequence, per Xilinx UG230
   localparam INIT_DATA_1   = 4'h3;
   localparam INIT_DATA_2   = 4'h3;
   localparam INIT_DATA_3   = 4'h3;
   localparam INIT_DATA_4   = 4'h2;
   

   // Bus timing constraints
   localparam LCD_EN_WIDTH  = 23;
   localparam LCD_A_SETUP   = 4;
   localparam LCD_A_HOLD    = 2;


   // Misc. constants
   localparam LCDRW_WRITE   = 0;
   localparam LCDRW_READ    = 1;
   localparam LCDRS_INST    = 0;
   localparam LCDRS_DATA    = 1;
   
   localparam INITIALIZATION = 4'h0;
   localparam WRITE_CYCLE_1 = 4'h1;
   localparam WAIT_CYCLE_1 = 4'h2;
   localparam WRITE_CYCLE_2 = 4'h3;
   localparam WAIT_CYCLE_2 = 4'h4;
   localparam WRITE_CYCLE_3 = 4'h5;
   localparam WAIT_CYCLE_3 = 4'h6;
   localparam WRITE_CYCLE_4 = 4'h7;
   localparam WAIT_CYCLE_4 = 4'h8;
   localparam DONE = 4'h9;
   
   
   reg [3:0]  current_state;
   reg [3:0]  next_state;
   reg error;
   reg counter_reset;
   integer cycle_number;
   
   initial begin
     clk=1'b0;
     forever 
     #5 clk=~clk;
   end 
     
   
initial begin
  init_state();
  $timeformat(-9, 0, "ns", 0);  //It prints time in nano seconds
end
   
//Creates reset
always @(test_reset)
  if (test_reset)
    init_state();
    
always @(posedge clk) begin
  if (counter_reset)
    counter <= 0;
  else
    counter <= counter + 1;
end
   
  always @(posedge clk) begin
	current_state <= next_state;
	end 
  
always @(*) begin
  counter_reset = 0;
        
    //Case statement for all the delay and wait time cycles
    case (current_state)
      INITIALIZATION: begin
        if (lcde) begin
		/*
		// Power on timing is a error
          if (counter < INITIAL_DELAY && !init_error) begin
            $display("%0t:ERROR: Power On timing delay not meet.  User needs to wait 15ms.", $time);
            error_instruction;
          end
		  else if (lcddat != INIT_DATA_1 && !init_error) begin
		  */
         if (lcddat != INIT_DATA_1 && !init_error) begin
            $display("%0t:ERROR: Initialization Cycle: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_1, lcddat);
            error_instruction;
          end
          else begin
            next_state = WRITE_CYCLE_1;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = INITIALIZATION;
        end
      WRITE_CYCLE_1: begin
        if (!lcde) begin
          if (counter < LCD_EN_WIDTH && !init_error) begin
            $display("%0t:ERROR: First LCD Enable Width timing delay not meet. User needs to wait 240ns", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_1 && !init_error) begin
            $display("%0t:ERROR: Write Cycle 1: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_1, lcddat);
            error_instruction;
          end
          else begin
          next_state = WAIT_CYCLE_1;
          counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WRITE_CYCLE_1;
        end
      WAIT_CYCLE_1: begin
        if (lcde) begin
          if (counter < C1_WAIT && !init_error) begin
            $display("%0t:ERROR: First wait timing delay not meet. User needs to wait 4.1ms for first wait cycle", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_2 && !init_error) begin
            $display("%0t:ERROR: Wait Cycle 1: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_2, lcddat);
            error_instruction;
          end
          else begin
            cycle_number = 1;
            next_state = WRITE_CYCLE_2;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WAIT_CYCLE_1;
        end
      WRITE_CYCLE_2: begin
        if (!lcde) begin
          if (counter < LCD_EN_WIDTH && !init_error) begin
            $display("%0t:ERROR: Second LCD Enable Width timing delay not meet. User needs to wait 240ns", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_2 && !init_error) begin
            $display("%0t:ERROR: Write Cycle 2: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_2, lcddat);
            error_instruction;
          end
          else begin
            next_state = WAIT_CYCLE_2;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WRITE_CYCLE_2;
        end
      WAIT_CYCLE_2: begin
        if (lcde) begin
          if (counter < C2_WAIT && !init_error) begin
            $display("%0t:ERROR: Second wait timing delay not meet. User needs to wait 100us for second wait cycle", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_3 && !init_error) begin
            $display("%0t:ERROR: Wait Cycle 2: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_3, lcddat);
            error_instruction;
          end
          else begin
            cycle_number = 2;
            next_state = WRITE_CYCLE_3;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WAIT_CYCLE_2;
        end
      WRITE_CYCLE_3: begin
        if (!lcde) begin
          if (counter < LCD_EN_WIDTH && !init_error) begin
            $display("%0t:ERROR: Third LCD Enable Width timing delay not meet. User needs to wait 240ns", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_3 && !init_error) begin
            $display("%0t:ERROR: Write Cycle 3: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_3, lcddat);
            error_instruction;
          end
          else begin
            next_state = WAIT_CYCLE_3;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WRITE_CYCLE_3;
        end
      WAIT_CYCLE_3: begin
        if (lcde) begin
          if (counter < C3_WAIT && !init_error) begin
            $display("%0t:ERROR: Third wait timing delay not meet. User needs to wait 40us for third wait cycle", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_4 && !init_error) begin
            $display("%0t:ERROR: Wait Cycle 3: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_4, lcddat);
            error_instruction;
          end
          else begin
            cycle_number = 3;
            next_state = WRITE_CYCLE_4;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WAIT_CYCLE_3;
        end
      WRITE_CYCLE_4: begin
        if (!lcde) begin
          if (counter < LCD_EN_WIDTH && !init_error) begin
            $display("%0t:ERROR: Fourth LCD Enable Width timing delay not meet. User needs to wait 240ns", $time);
            error_instruction;
          end
          else if (lcddat != INIT_DATA_4 && !init_error) begin
            $display("%0t:ERROR: Write Cycle 4: Expecting lcddat to = %0h, but lcddat = %0h", $time, INIT_DATA_4, lcddat);
            error_instruction;
          end
          else begin
            next_state = WAIT_CYCLE_4;
            counter_reset = 1;  //reset the clock counter to zero for the next cycle
          end
        end
        else 
          next_state = WRITE_CYCLE_4;
        end
      WAIT_CYCLE_4: begin
        if (lcde) begin
          if (counter < C4_WAIT && !init_error) begin
            $display("%0t:ERROR: Fourth wait timing delay not meet. User needs to wait 40us for fourth wait cycle", $time);
            error_instruction;
          end
        end
          if (counter >= C4_WAIT && !init_error) begin
             next_state = DONE;
             counter_reset = 1;  //reset the clock counter to zero for the next cycle
             init_done=1;
             $display("%0t: Bus initialization Successful", $time);
          end
        else 
          next_state = WAIT_CYCLE_4;
        end
       DONE: begin
          next_state = DONE;
         end
    endcase
end


//Error counter 
task error_instruction ();
  begin
    error = error+1;
    init_error = 1;
   if (STOP_ON_ERROR) begin
      $display("ERROR = %0d", error);
      $stop;
    end
  end
endtask

//Intilizes everything to zero at beginning of program 
task init_state();
  begin
   cycle_number = 0;
   counter_reset=0;
   counter=0;
   current_state = 0;
   error=0;
   init_done=0;
   init_error=0;
  end
endtask

endmodule  
