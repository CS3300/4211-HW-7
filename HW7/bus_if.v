`default_nettype none
`timescale 1ns/1ns
// LCD controller bus interface module

module bus_if(input wire lcde,
    input wire       lcdrs,
    input wire 	     lcdrw,
    input wire [3:0] lcddat,
    input wire 	     init_done,
    input wire 	     test_reset,

    output reg [7:0] data_out,
    output reg 	     inst_valid,
    output reg 	     data_valid, 	     

	      // Timing constraint error state (NOT notifiers; 1 = error)
    output reg 	     t_setup_error,  // Setup time violation
    output reg 	     t_hold_error,   // Hold time violation
    output reg 	     t_pw_error,     // Pulse width violation
    output reg       t_4bit_error,   // Delay after 1st 4-bit error
    output reg 	     t_c_error,      // Delay after 2nd 4-bit error
    output reg 	     glitch_error    // Address/data changed while LCDE high
	      );

   // Stop on errors by default
   parameter  STOP_ON_ERROR = 1;   

   // LCDRS/LCDRW signal values
   localparam LCDRS_DATA = 1;
   localparam LCDRS_INST = 0;
   localparam LCDRW_READ = 1;
   localparam LCDRW_WRITE = 0;
   
  // Bus timing constraints (in nanoseconds)
   localparam T_SETUP = 40;     // Setup time: LCDRS/LCDRW to LCDE rising
   localparam T_HOLD = 10;      // Hold time: LCDE falling to LCDRS/LCDRW
   localparam T_PW = 230;       // minimum LCDE pulse width
   localparam T_4BIT = 1000;    // minimum delay between 4-bit halves
   localparam T_C = 40000;      // minimum delay after full cycle

   // Times of relevant events
   reg [63:0] 	     lcdrw_changed, lcdrs_changed, lcde_rising_edge,
		     lcde_falling_edge, lcddat_changed;


   // notifier signals for specify blocks
   reg 		     t_setup_rs_note, t_setup_rw_note, t_setup_data_note,
		     t_hold_rs_note, t_hold_rw_note, t_hold_data_note,
		     t_pw_note, t_4bit_note, t_c_note, rs_glitch_note,
		     rw_glitch_note, data_glitch_note;
   

   // Simulation state
   reg 	     lcdrs_reg;
   reg 	     lcdrw_reg;
   reg       inst_half;
   reg       data_half;
   reg [3:0] lcddat_reg;
   reg       inst_valid_r;
   reg       data_valid_r;

   // Asserted to indicate an error with the current cycle
   wire       bad_cycle;
   assign bad_cycle = t_setup_error || t_hold_error || t_pw_error
		       || t_4bit_error || t_c_error || glitch_error;

   always @(bad_cycle)
     if(STOP_ON_ERROR) begin
	#50;
	if (bad_cycle)
	  $stop;
     end

   // Workaround for specify condition syntax problems
   wire       fc_id;
   wire       nfc_id;
   assign fc_id = !(inst_half || data_half) && init_done;
   assign nfc_id = (inst_half || data_half) && init_done;
   
   
   // Set output for a bad cycle
   always @(*)
     if(bad_cycle && init_done)
       begin
	  data_out = 8'hxx;
	  data_valid_r = 0;
	  inst_valid_r = 0;
       end

   // Delay and suppress inst_valid / data_valid on hold error
   always @(inst_valid_r or data_valid_r) begin
      #(T_HOLD+1);
      if (bad_cycle) begin
	 inst_valid = 0;
	 data_valid = 0;
      end
      else begin
	 inst_valid = inst_valid_r;
	 data_valid = data_valid_r;
      end
   end
	 
   // Notifier handlers
   always @(t_setup_rs_note) begin
      $display("%0t: ERROR: Setup time violation. LCDRS changed at %0t and LCDE was asserted at %0t, should have waited until at least %0t",
	       $time,
	       lcdrs_changed,
	       $time,
	       lcdrs_changed + T_SETUP);
      t_setup_error = 1;
   end

   always @(t_setup_rw_note) begin
      $display("%0t: ERROR: Setup time violation. LCDRW changed at %0t and LCDE was asserted at %0t, should have waited until at least %0t",
	       $time,
	       lcdrw_changed,
	       $time,
	       lcdrw_changed + T_SETUP);
      t_setup_error = 1;
   end

   always @(t_setup_data_note) begin
      $display("%0t: ERROR Setup time violation. LCDDAT changed at %0t and LCDE was asserted at %0t, should have waited until at least %0t",
	       $time,
	       lcddat_changed,
	       $time,
	       lcddat_changed + T_SETUP);
      t_setup_error = 1;
   end

   always @(t_hold_rs_note) begin
      $display("%0t: ERROR: Hold time violation. LCDE was deasserted at %0t and LCDRS changed at %0t, should have waited until at least %0t",
	       $time,
	       lcde_falling_edge,
	       $time,
	       lcde_falling_edge + T_HOLD);
      t_hold_error = 1;
   end

   always @(t_hold_rw_note) begin
      $display("%0t: ERROR: Hold time violation. LCDE was deasserted at %0t and LCDRW changed at %0t, should have waited until at least %0t",
	       $time,
	       lcde_falling_edge,
	       $time,
	       lcde_falling_edge + T_HOLD);
      t_hold_error = 1;
   end
   
   always @(t_hold_data_note) begin
      $display("%0t: ERROR: Hold time violation. LCDE was deasserted at %0t and LCDDAT changed at %0t, should have waited until at least %0t",
	       $time,
	       lcde_falling_edge,
	       $time,
	       lcde_falling_edge + T_HOLD);
      t_hold_error = 1;
   end
   
   always @(t_pw_note) begin
      $display("%0t: ERROR: Insufficient LCDE pulse width. LCDE rising edge was at %0t, falling edge was at %0t, should have waited until at least %0t",
	       $time,
	       lcde_rising_edge,
	       $time,
	       lcde_rising_edge + T_PW);
      t_pw_error = 1;
   end

   always @(t_4bit_note) begin
      $display("%0t: ERROR:  Insufficient delay between 4-bit cycles. Previous cycle ended at %0t, new cycle started at %0t, should have waited until at least %0t",
	       $time,
	       lcde_falling_edge,
	       $time,
	       lcde_falling_edge + T_4BIT);
      t_4bit_error = 1;
   end

   always @(t_c_note) begin
      $display("%0t: ERROR: Insufficient delay after full cycle. Previous cycle ended at %0t, new cycle started at %0t, should have waited until at least %0t",
	       $time,
	       lcde_falling_edge,
	       $time,
	       lcde_falling_edge + T_C);
      t_c_error = 1;
   end

   always @(rs_glitch_note) begin
      $display("%0t: ERROR: LCDRS changed while LCDE asserted.", $time);
      glitch_error = 1;
   end

   always @(rw_glitch_note) begin
      $display("%0t: ERROR: LCDRW changed while LCDE asserted.", $time);
      glitch_error = 1;
   end

   always @(data_glitch_note) begin
      $display("%0t: ERROR: LCDDAT changed while LCDE asserted.", $time);
      glitch_error = 1;
   end

   
   // Specify block for bus timing constraints
   specify
      $setuphold(posedge lcde &&& init_done, lcdrs, T_SETUP, 1, t_setup_rs_note);
      $setuphold(posedge lcde &&& init_done, lcdrw, T_SETUP, 1, t_setup_rw_note);      
      $setuphold(posedge lcde &&& init_done, lcddat, T_SETUP, 1, t_setup_data_note);
      $setuphold(negedge lcde &&& init_done, lcdrs, 1, T_HOLD, t_hold_rs_note);
      $setuphold(negedge lcde &&& init_done, lcdrw, 1, T_HOLD, t_hold_rw_note);
      $setuphold(negedge lcde &&& init_done, lcddat, 1, T_HOLD, t_hold_data_note);
      $width(posedge lcde &&& init_done, T_PW, 0, t_pw_note);
      $width(negedge lcde &&& nfc_id, T_4BIT,
	     0, t_4bit_note);
      $width(negedge lcde &&& fc_id, T_C, 0, t_c_note);
      $nochange(posedge lcde, lcdrs &&& init_done, 0, 0, rs_glitch_note);
      $nochange(posedge lcde, lcdrw &&& init_done, 0, 0, rw_glitch_note);
      $nochange(posedge lcde, lcddat &&& init_done, 0, 0, data_glitch_note);
   endspecify

   // Record signal change times
   always @(lcdrs)
     lcdrs_changed = $time;
   
   always @(lcdrw)
     lcdrw_changed = $time;
   
   always @(lcddat)
     lcddat_changed = $time;

   // Simulate power-on reset and set up timeformat
   initial begin
      init_state();
      $timeformat(-9, 0, "ns", 0);
   end

   // Test Reset
   always @(test_reset) begin
      if (test_reset) begin
	 init_state();
      end
   end
	 
   // Main behavior
   always @(lcde) begin
      if (!test_reset) begin
	 if (lcde && init_done) begin
	    lcde_rising_edge = $time;
	    t_pw_error = 0;
	    t_hold_error = 0;
	    glitch_error = 0;
	    
	    lcdrs_reg = lcdrs;
	    lcdrw_reg = lcdrw;
	    
	    data_valid_r = 0;
	    inst_valid_r = 0;
	    
	    
	    // Start a new cycle if the cycle type is different from
	    // the pending 4-bit cycle
	    
	    if ((lcdrs === LCDRS_INST && data_half)) begin
	       data_half = 0;
	       $display("%0t: WARNING: First 4-bit cycle was a data cycle, but second one is an instruction cycle. Further behavior/errors may be inaccurate.", $time);
	    end
	    if (lcdrs === LCDRS_DATA && inst_half) begin
	       inst_half = 0;
	       $display("%0t: WARNING: First 4-bit cycle was an instruction cycle, but second one is a data cycle. Further behavior/errors may be inaccurate.", $time);
	    end
	    if (lcdrw == LCDRW_READ)
	      $display("%0t: WARNING: Read operations not supported. Further behavior/errors may be inaccurate", $time);
	 end
	 else if (!lcde && init_done) begin
	    lcde_falling_edge = $time;
	    t_setup_error = 0;
	    t_4bit_error = 0;
	    t_c_error = 0;
	    
	    if (lcdrw == LCDRW_WRITE) begin
	       if((data_half || inst_half)) begin
		  if (!bad_cycle) begin
		     data_out = {lcddat_reg, lcddat};
		     inst_valid_r = inst_half;
		     data_valid_r = data_half;		     
		  end
		  data_half = 0;
		  inst_half = 0;
	       end
	       else begin
		  lcddat_reg = lcddat;
		  if (lcdrs == LCDRS_DATA)
		    data_half = 1;
		  else
		    inst_half = 1;
		  inst_valid_r = 0;
		  data_valid_r = 0;
	       end	       
	    end // if (lcdrw == LCDRW_WRITE)
	 end // if (!lcde && init_done)
      end // else: !if(test_reset)
   end // always @ (lcde)
   
   
      
   task init_state();
      begin
	 lcdrw_reg = 0;
	 lcdrs_reg = 0;
	 lcddat_reg = 0;
	 data_half = 0;
	 inst_half = 0;

	 data_out = 0;
	 data_valid_r = 0;
	 data_valid = 0;
	 inst_valid_r = 0;
	 inst_valid = 0;
	 
	 // These "reset" to the current simulation time so that
	 // test_reset doesn't cause things to be compared to time 0

	 lcdrs_changed = $time;
	 lcdrw_changed = $time;
	 lcde_falling_edge = $time;
	 lcddat_changed = $time;

	 t_setup_error = 0;
	 t_hold_error = 0;
	 t_pw_error = 0;
	 t_4bit_error = 0;
	 t_c_error = 0;
	 glitch_error = 0;
      end
   endtask // init_state

endmodule // bus_if