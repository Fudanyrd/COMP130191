/** 
 * Flip-Flop Register with write enabling port
 * @author Fudanyrd
 */
module Register #(parameter WIDTH = 32 /*may be 64*/)
(
  input  logic clk,             // clock signal
  input  logic reset,           // initialize to 0.
  input  logic we,              // write enabled, set to be 1 if not needed!
  input  logic[WIDTH-1:0] in,   // input
  output logic[WIDTH-1:0] out   // output
);
  /** YOUR CODE HERE */
  logic[WIDTH-1:0] dat;  // will need some way to retain previous signal
  // sychronous control
  always_ff @(posedge clk)
    if (reset) dat <= '0;
    else 
    if (we)  // if write enabled.
      begin
        dat <= in;
      end
  assign out = dat;
endmodule
