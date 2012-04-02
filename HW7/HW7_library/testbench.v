module testbench();

reg CCLK;
reg BTN0;
reg BTN1;
wire SPIMISO;
wire SW0;
wire [7:0] LED;
wire  SPISCK;
wire  SPIMOSI;
wire  SFCE;
wire SPISF;
wire FPGAIB;
wire AMPCS;
wire DACCS;
wire ADCON;
wire LCDE;
wire LCDRS;
wire LCDRW;
wire LCDDAT; 

integer i;

command CMD(
  .CCLK(CCLK),
  .BTN0(BTN0),
  .BTN1(BTN1),
  .SPIMISO(SPIMISO),
  .SW0(SW0),
  .LED(LED),
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
  BTN0 = 1'b1;
  @(negedge CCLK);
  @(negedge CCLK);
  BTN0 = 1'b0;
  
  for(i = 0; i<1000; i = i+1) begin
  @(negedge CCLK);
  end
  
end

endmodule