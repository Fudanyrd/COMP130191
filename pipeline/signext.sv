/**
 * Sign Extension Module
 */
module signext(
  input  logic[15:0] a,
  output logic[31:0] y
);
  /** YOUR CODE HERE */
  assign y = {{16{a[15]}}, a[15:0]};
endmodule
