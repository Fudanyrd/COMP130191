/**
 * 4-path multiplexer
 */
module mux4 #(parameter WIDTH=32)
(
  input  logic[WIDTH-1:0] d00,
  input  logic[WIDTH-1:0] d01,
  input  logic[WIDTH-1:0] d10,
  input  logic[WIDTH-1:0] d11,
  input  logic[1:0] src,        // selector
  output logic[WIDTH-1:0] s
);
  case (src)
    2'b00:  assign s = d00;
    2'b01:  assign s = d01;
    2'b10:  assign s = d10;
    2'b11:  assign s = d11;
  endcase
endmodule
