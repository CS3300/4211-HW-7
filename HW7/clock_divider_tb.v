module clock_divider_tb(
  input wire clk_in,
  input wire reset,
  output wire clk_out
);

reg [2:0] counter;

always@(posedge clk_in or posedge reset) begin
  if(reset)       counter <= 0;
  else counter <= counter+1;
end

assign clk_out = counter[2];

endmodule