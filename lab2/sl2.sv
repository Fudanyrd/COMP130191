/**
 * Shift Left by 2 Module
 */
module sl2(
  input  logic[31:0] a,
  output logic[31:0] y
);
  /** YOUR CODE HERE */
  assign y = {a[29:0], 2'b00};
endmodule