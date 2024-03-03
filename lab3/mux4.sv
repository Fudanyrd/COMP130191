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
  assign s = src[1] ? (src[0] ? d11 : d10) 
                    : (src[0] ? d01: d00);
endmodule
