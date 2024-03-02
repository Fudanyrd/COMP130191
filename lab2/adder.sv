/**
 * @brief compute the sum of two logics.
 * @param a: left operand.
 * @param b: right operand.
 */
module adder(
  input  logic[31:0] a, b,
  output logic[31:0] y
);
  /** YOUR CODE HERE */
  assign y = a + b;
endmodule