`timescale 1ns/1ns
module testbench();

reg CCLK;
reg BTN0;
reg BTN1;
wire SPIMISO;
wire SPISCK;
wire SPIMOSI;
wire SFCE;
wire SPISF;
wire FPGAIB;
wire AMPCS;
wire DACCS;
wire ADCON;
wire LCDE;
wire LCDRS;
wire LCDRW;
wire [3:0] LCDDAT; 

// gui use
wire [7:0]  char_out;
wire        row_out;
wire [3:0]  column_out;
wire        char_valid;

// counter variable
reg [63:0] i;

lcd_control LCD_CTRL(
  .lcddat(LCDDAT),
  .lcdrs(LCDRS),
  .lcdrw(LCDRW),
  .lcde(LCDE),
  .char_out(char_out),
  .row_out(row_out),
  .column_out(column_out),
  .char_valid(char_valid)
  );

command CMD(
  .CCLK(CCLK),
  .BTN0(BTN0),
  .BTN1(BTN1),
  .SPIMISO(SPIMISO),
  .SPISCK(SPISCK),
  .SPIMOSI(SPIMOSI),
  .SFCE(SFCE),
  .SPISF(SPISF),
  .FPGAIB(FPGAIB),
  .AMPCS(AMPCS),
  .DACCS(DACCS),
  .ADCON(ADCON),
  .LCDE(LCDE),
  .LCDRS(LCDRS),
  .LCDRW(LCDRW),
  .LCDDAT(LCDDAT)
);

always begin
  #10 CCLK = ~CCLK;
  end
  
initial begin
  CCLK = 1'b0;
  BTN0 = 1'b0;
  BTN1 = 1'b0;
  i = 1'b0;
  @(negedge CCLK);
  @(negedge CCLK);
  
  
  //reset
  BTN0 = 1'b1;
  @(negedge CCLK);
  @(negedge CCLK);
  BTN0 = 1'b0;
  for(i = 0; i<64'hcebb0; i = i+1) begin
  @(negedge CCLK);
  end
  
  ////hit the get_rdid button
  BTN1 = 1'b1;
  for(i = 0; i<64'h20; i = i+1) begin
  @(negedge CCLK);
  end
  BTN1 = 1'b0;
  for(i = 0; i<64'hcebb0; i = i+1) begin
  @(negedge CCLK);
  end
  
  
  //reset
  BTN0 = 1'b1;
  @(negedge CCLK);
  @(negedge CCLK);
  BTN0 = 1'b0;
  for(i = 0; i<64'h20; i = i+1) begin
  @(negedge CCLK);
  end
  
  //hit the get_rdid button
  BTN1 = 1'b1;
  for(i = 0; i<64'h20; i = i+1) begin
  @(negedge CCLK);
  end
  BTN1 = 1'b0;
  
  for(i = 0; i<64'hcebb0; i = i+1) begin
  @(negedge CCLK);
  end
end

endmodule