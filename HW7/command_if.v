`default_nettype none
`timescale 1ns/1ns

// Command interface module.
// This module decodes and executes the behavior of the LCD commands, and
// generates update signals for the LCD GUI display.

// Unsupported commands will be decoded, both to ease expansion and to
// facilitate less-mysterious error messages.

// Data read/write "commands" are handled separately from "real"
// commands written to the command register. Data operations are
// decoded based on LCDRS and LCDRW in bus_if and don't really behave
// like commands even though they're in the table. Likewise, errors in
// these "commands" are handled there. The code here just takes care
// of updating the internal state on a write (reads are currently
// unsupported).

  
module command_if(input wire [7:0] data_in,
		  input wire inst_valid,
		  input wire data_valid,
		  output reg [7:0] char_out,
		  output reg row,
		  output reg [3:0] col,
		  output reg char_valid,
		  output wire display_on,
		  output reg clear_display,
		  // Following I/O is for test only
		  input  wire test_reset,
		  output wire invalid_cmd, // Invalid command received
		  output wire busy_cmd, // Command received while busy
		  output wire  init_done,  // 4-command init. seq. done
		  output reg  init_error, // 4-command init. seq. error
		  output reg  cmd_cd,  // Clear Display command seen
		  output reg  cmd_rch, // Return Cursor Home
		  output reg  cmd_ems, // Entry Mode Set
		  output reg  cmd_doo, // Display On/Off
		  output reg  cmd_cds, // Cursor/Display Shift
		  output reg  cmd_fs,  // Function Set
		  output reg  cmd_cgra,// Set CG RAM Address
		  output reg  cmd_ddra // Set DD RAM Address		  
		  );

   // Stop on errors by default
   parameter  STOP_ON_ERROR = 1;   

   // Useful constants
   localparam LINE1_ADDR = 7'h00;
   localparam LINE2_ADDR = 7'h40;
   localparam MAX_ADDR = LINE2_ADDR + 7'h1F;
   localparam CHAR_SPACE = 8'h20;


   // Busy time for various commands (in microseconds)
   localparam BUSY_RETURN_HOME = 1600;
   localparam BUSY_FUNCTION_SET = 40;
   localparam BUSY_ENTRY_MODE_SET = 40;
   localparam BUSY_DISPLAY_ON_OFF = 40;
   localparam BUSY_CLEAR_DISPLAY = 1640;
   localparam BUSY_SET_DDRAM_ADDR = 40;
   localparam BUSY_CD_SHIFT = 40;
   localparam BUSY_SET_CGRAM_ADDR = 40;

   
   // Configuration registers
   reg 			      cfg_id; // Address auto-increment/decrement
   reg 			      cfg_s;  // Shift display on DDRAM write
   reg 			      cfg_d;  // Display on/off
   reg 			      cfg_c;  // Cursor on/off
   reg 			      cfg_b;  // Cursor blink on/off

   // display_on is really just the D reg
   assign display_on = cfg_d;
   
   // State registers/RAM
   reg [6:0] 		     ddram_addr;
   reg [7:0] 		     ddram1 [0:39]; // Line 1
   reg [7:0] 		     ddram2 [0:39]; // Line 2
   reg			     busy; // Are we processing a command now?
   reg [63:0] 		     busy_time; // Time while busy after command
   reg 			     busy_cmd_r; // Did we get a command while busy?
   reg 			     invalid_cmd_r; // Did we get an invalid command?

   // Init. sequence state
   reg 			     fs_done;  // Did a Function Set
   reg 			     ems_done; // Did an Entry Mode Set
   reg 			     doo_done; // Did a Display On/Off
   reg 			     cd_done;  // Did a Clear Display

   assign init_done = fs_done && ems_done && doo_done && cd_done;

   
   // Make these separate regs for internal use independent of ports
   assign invalid_cmd = invalid_cmd_r;
   assign busy_cmd = busy_cmd_r;

   initial begin
      init_state();
      forever
	// Decrement the busy counter
	#1000 if (busy_time > 0)
	  busy_time = busy_time - 1;
   end

   // Update the busy and busy_cmd regs
   always @(busy_time) begin
      busy = busy_time > 0;
      if (busy_time === 0)
	busy_cmd_r = 0;
   end


   // Detect command-while-busy state and complain
   always @(posedge busy_cmd_r) begin
     $display("%0t: ERROR: command issued while previous command still busy (%0t remaining)", $time, busy_time*1000);
      stop_on_error();
   end
   

   // Process data writes
   always @(posedge data_valid) begin
      busy_cmd_r = busy;
      if (!test_reset && init_done && !busy) begin
	 // Decode the address and write DDRAM
	 if (ddram_addr < MAX_ADDR)
	    if (ddram_addr < LINE2_ADDR)
	      ddram1[ddram_addr] = data_in;
	    else
	      ddram2[ddram_addr - LINE2_ADDR] = data_in;

	 // Refresh the display if the visible area was written
	 if (ddram_addr < LINE2_ADDR) begin
	   if (ddram_addr < 16) begin
	     lcd_char(0, ddram_addr);
	     $display("%t: Writing a \"%s\" to line 0 column %d" , $time, char_out, ddram_addr);
	   end
	 end
	 else
	   if (ddram_addr - LINE2_ADDR < 16) begin
	     lcd_char(1, ddram_addr - LINE2_ADDR);
	     $display("%t: Writing a \"%s\" to line 1 column %d" , $time, char_out, ddram_addr - LINE2_ADDR);
	   end
		 
	 // Increment/decrement DDRAM address
	 if (cfg_id)
	   ddram_addr = ddram_addr + 1;
	 else
	   ddram_addr = ddram_addr - 1;
	   
	 

      end // if (!test_reset)
   end // always @ (posedge data_valid)


   // Decode and execute commands
   always @(posedge inst_valid) begin
      busy_cmd_r = busy;
      invalid_cmd_r = 0;
      reset_cmd_flags();

      if (!test_reset && !busy) begin
	 casex (data_in)
	   8'b0000_0001: do_clear_display();
	   8'b0000_001x: do_return_home();
	   8'b0000_01xx: do_entry_mode_set();
	   8'b0000_1xxx: do_display_on_off();
	   8'b0001_xxxx: do_cd_shift();
	   8'b0010_10xx: do_function_set();
	   8'b01xx_xxxx: do_set_cgram_addr();
	   8'b1xxx_xxxx: do_set_ddram_addr();
	   default: do_invalid_cmd();
	 endcase // casex (data_in)
      end
   end


   // Reset -- for testbench use only!
   always @(posedge test_reset)
     init_state();

   
   //
   // Command implementations
   //

   // Return Cursor Home
   task do_return_home();
      begin
	 busy_time = BUSY_RETURN_HOME;
	 cmd_rch = 1;
	 process_init_error();
	 ddram_addr = 0;
	 $display("%0t: Return Cursor Home command", $time);
      end
   endtask // do_return_home
   
	 

   // Function Set
   task do_function_set();
      begin
	 cmd_fs = 1;
	 $display("%0t: Function Set command", $time);
	 busy_time = BUSY_FUNCTION_SET;

	 if(!init_done && (ems_done || doo_done || cd_done))
	   process_init_error();
	 else
	   fs_done = 1;
      end
   endtask // do_function_set


   // Entry Mode Set
   task do_entry_mode_set();
      begin
	 cmd_ems = 1;
	 busy_time = BUSY_ENTRY_MODE_SET;
	 cfg_id = |(data_in & 8'b0000_0010);
	 cfg_s  = |(data_in & 8'b0000_0001);
	 $display("%0t: Entry Mode Set command: I/D=%0d, S=%0d",
		  $time, cfg_id, cfg_s);
	 if (cfg_s)
	   $display("WARNING: shift operation not supported");

	 if (!init_done && (!fs_done || doo_done || cd_done))
	   process_init_error();
	 else
	   ems_done = 1;
      end
   endtask // do_entry_mode_set


   // Display On/Off
   task do_display_on_off();
      begin
	 cmd_doo = 1;
	 busy_time = BUSY_DISPLAY_ON_OFF;
	 cfg_d = |(data_in & 8'b0000_0100);
	 cfg_c = |(data_in & 8'b0000_0010);
	 cfg_b = |(data_in & 8'b0000_0001);

	 $display("%0t: Display On/Off command: D=%0d, C=%0d, B=%0d",
		  $time, cfg_d, cfg_c, cfg_b);

	
	 if (!init_done && (!fs_done || !ems_done || cd_done))
	   process_init_error();
	 else if (!init_done && fs_done && ems_done && !cd_done
		  && cfg_d == 0)
	   begin
	      $display("%0t: Display On/Off command turned display off; needs to turn display on.", $time);
	      process_init_error();
	   end      
	 
	 else
	   doo_done = 1;
      end
   endtask // do_display_on_off


   // Clear Display
   task do_clear_display();
      begin
	 cmd_cd = 1;
	 busy_time = BUSY_CLEAR_DISPLAY;
	 $display("%0t: Clear Display command", $time);

	 if (!init_done && (!fs_done || !ems_done || !doo_done))
	   process_init_error();
	 else
	   cd_done = 1;
	 
	 clear_ddram();
	 ddram_addr = 0;
	 lcd_refresh();
	 cfg_d = 0;
       end
   endtask // do_clear_display


   // Set DD RAM Address
   task do_set_ddram_addr();
      begin
	 busy_time = BUSY_SET_DDRAM_ADDR;
	 cmd_ddra = 1;
	 process_init_error();
	 ddram_addr = data_in[6:0];
	 $display("%0t: Set DD RAM address to 'h%h", $time, ddram_addr);
      end
   endtask	 
   
   //
   // Unsupported commands
   //

   // Cursor/Display Shift
   task do_cd_shift();
      begin
	 busy_time = BUSY_CD_SHIFT;
	 cmd_cds = 1;
	 $display("%0t: Unsupported command Cursor/Display Shift", $time);
      end
   endtask
    
   // Set CG RAM Address
   task do_set_cgram_addr();
      begin
	 busy_time = BUSY_SET_CGRAM_ADDR;
	 cmd_cgra = 1;
	 process_init_error();
	 $display("%0t: Unsupported command Set CG RAM Address", $time);
      end
   endtask

   // Invalid command; logically, this means that the user issued a
   // Function Set command that is invalid for the S3ESK board.
   task do_invalid_cmd();
      begin
	 process_init_error();	 
	 $display("%0t: ERROR: Invalid command byte 'h%h",
		  $time, data_in);
	 invalid_cmd_r = 1;
      end
   endtask

   //
   // Misc. utility functions
   //
   
   task init_state();
      begin
	 char_out = CHAR_SPACE;
	 row = 0;
	 col = 0;
	 char_valid = 0;
	 
 	 cfg_id = 0; 
 	 cfg_s = 0;  
 	 cfg_d = 0;  
 	 cfg_c = 0;  
 	 cfg_b = 0;  

	 busy = 0;
	 busy_time = 0;
         invalid_cmd_r = 0;
	 busy_cmd_r = 0;
	 init_error = 0;
 	 ddram_addr = 0;

	 fs_done = 0;
	 ems_done = 0;
	 doo_done = 0;
	 cd_done = 0;
	 

	 reset_cmd_flags();
	 clear_ddram();
//	 lcd_refresh();
      end
   endtask // init_state

   // Reset the cmd_* flags
   task reset_cmd_flags();
      begin
	 cmd_cd = 0;
	 cmd_rch = 0; 
	 cmd_ems = 0;
	 cmd_doo = 0;
	 cmd_cds = 0;
	 cmd_fs = 0;
	 cmd_cgra = 0;
	 cmd_ddra = 0;
      end
   endtask // reset_cmd_flags
  

   // Clear DDRAM to contain just spaces
   task clear_ddram();
      integer i;
      begin
   	 for (i = 0; i < 'h40; i = i+1) begin
	    ddram1[i] = CHAR_SPACE;
 	    ddram2[i] = CHAR_SPACE;
	 end
      end
   endtask // clear_ddram

   // Refresh a character on the LCD
   task lcd_char(input reg row_in,
		 input reg [3:0] col_in);
      begin
	// $display("%t: Refreshing row %d col %d", $time, row_in, col_in);
	 
	 if (row_in == 0)
	   char_out = ddram1[col_in];
	 else
	   char_out = ddram2[col_in];
	 row = row_in;
	 col = col_in;
	 char_valid = 1;
	 #1;
	 char_valid = 0;
	 #1;
      end
   endtask // lcd_char

   //Refresh the entire LCD screen
   task lcd_refresh();
      integer col_i, row_i;      
      begin
	 for (row_i = 0; row_i < 2; row_i = row_i + 1)
	   for (col_i = 0; col_i < 16; col_i = col_i + 1) begin
	      lcd_char(row_i, col_i);	   
	   end
      end
   endtask // lcd_refresh
   

   // Select and print an init error message, and assert init_error
   task process_init_error();
      begin
	 if (!init_done) begin
	    
	    init_error = 1;
	    
	    if(!fs_done)
	      $display("%0t: ERROR: Command I/F init. error. Unexpected command; expecting a Function Set command.", $time);
	    
	    else if(!ems_done)
	      $display("%0t: ERROR: Command I/F init. error. Unexpected command; expecting an Entry Mode Set command.", $time);
	    
	    
	    else if(!doo_done)
	      $display("%0t: ERROR: Command I/F init. error. Unexpected command; expecting a Display On/Off command.", $time);
	    
	    
	    else if(!cd_done)
	      $display("%0t: ERROR: Command I/F init. error. Unexpected command; expecting a Clear Display command.", $time);

	    stop_on_error();	    
	 end // if (!init_done)
      end
   endtask // process_init_error

   task stop_on_error();
      begin
	 if (STOP_ON_ERROR) begin
	    #50;
	    $stop();
	 end	 
      end
   endtask
   
endmodule // command_if
