module d_ff(
  input wire data,
  input wire clock,
  input wire reset,
  output reg q
    );

always @(posedge clock or posedge reset)
if (reset) begin
  q <= 1'b0;
end else begin
  q <= data;
end

endmodule