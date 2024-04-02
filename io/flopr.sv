/**
 * Flip-flop Register Module
 * @param d: input.
 * @param q: output of this module
 */
module flopr #(parameter WIDTH=8)
              (
                input  logic clk, reset,
                input  logic [WIDTH-1:0] d,
                output logic [WIDTH-1:0] q
              );
  /** YOUR CODE HERE */
  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;

endmodule