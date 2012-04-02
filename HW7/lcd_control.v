`timescale 1ns/1ns
module lcd_control(input wire [3:0] lcddat,
                   input wire lcdrs,
				   input wire lcdrw,
				   input wire lcde,
				   output wire [7:0] char_out,
				   output wire row_out,
				   output wire [3:0] column_out,
				   output wire char_valid
				   );

   reg 					       clk;
   wire 				       init_error;
   wire 				       init_done;
   reg [3:0] 				       unused;  
   
   wire [7:0] 				       data_out;
   wire 				       inst_valid;
   wire 				       data_valid;
   
   wire 				       cmd_fs;
   wire 				       cmd_cd;
   wire 				       cmd_rch;
   wire 				       cmd_ems;
   wire 				       cmd_doo;
   wire 				       cmd_cds;
   wire 				       cmd_cgra;
   wire 				       cmd_ddra;
 				       
   wire 				       cmd_init_error;
   wire 				       cmd_init_done;
   wire 				       cmd_display_on;
   wire 				       cmd_clear_display;
 				       
   wire 				       t_execution_error;
   wire 				       t_inst_valid_error;
   wire 				       t_wrong_data_error; 
   
   wire 				       t_setup_error;
   wire 				       t_hold_error;
   wire 				       t_pw_error;
   wire 				       t_4bit_error;
   wire 				       t_c_error;
   wire 				       glitch_error;
   
   wire 				       test_reset;
   
   command_if dut1(.char_out(char_out), .row(row_out), .data_in(data_out), .inst_valid(inst_valid), .data_valid(data_valid), 
		   .char_valid(char_valid), .col(column_out), .cmd_fs(cmd_fs), .test_reset(test_reset),
		   .busy_cmd(t_execution_error), .invalid_cmd(t_inst_valid_error),
		   .cmd_cd(cmd_cd), .cmd_rch(cmd_rch), .cmd_ems(cmd_ems), .cmd_doo(cmd_doo), .cmd_cds(cmd_cds),
		   .cmd_ddra(cmd_ddra), .cmd_cgra(cmd_cgra), 
		   .init_error(cmd_init_error), .init_done(cmd_init_done),
		   .clear_display(cmd_clear_display), .display_on(cmd_display_on));
   
   bus_if bus_if_1(.lcddat(lcddat), .lcde(lcde), .lcdrw(lcdrw), .lcdrs(lcdrs), .init_done(init_done), .test_reset(test_reset),
		   .data_out(data_out), .inst_valid(inst_valid), .data_valid(data_valid), .t_setup_error(t_setup_error), .t_hold_error(t_hold_error),
		   .t_pw_error(t_pw_error), .t_4bit_error(t_4bit_error), .t_c_error(t_c_error), .glitch_error(glitch_error));
   
   init_detector #(.STOP_ON_ERROR(0)) dut2  (.lcddat(lcddat), .lcde(lcde), .lcdrw(lcdrw),
					     .lcdrs(lcdrs), .init_error(init_error), .init_done(init_done),.test_reset(test_reset));
   
   
   initial begin
      clk=1'b0;
      forever 
	#1 clk=~clk;
   end
   
   assign test_reset = 0;
   
endmodule