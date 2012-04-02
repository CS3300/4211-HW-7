
module hex_to_ASCII();

function [7:0] hex_to_ASCII;
  input [7:0] hex;
  begin // if hex falls in the range of upper & lowercase alphabet chars,
    if((hex > 8'h40 && hex < 8'h5B)||(hex > 8'h60 && hex < 8'h7B)) begin
      hex_to_ASCII = (hex + 8'h40);
    end else begin  // else it's a number.
      hex_to_ASCII = (hex + 8'h30);
    end
  end
endfunction

endmodule