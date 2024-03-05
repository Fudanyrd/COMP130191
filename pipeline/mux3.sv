/**
 * Multiplexor
 * 
 * 3 possible outputs.
 */
module mux3 #(parameter WIDTH=32)
(
  input  logic[WIDTH-1:0] d00, d01, d10,
  input  logic[1:0] src,
  output logic[WIDTH-1:0] q
);
  always_comb
  begin
    case (src)
      2'b00: q <= d00;
      2'b01: q <= d01;
      2'b10: q <= d10;
      // control flow should not reach here.
      default: q <= 'x;
    endcase
  end
endmodule
