/**
 * Register File Module 
 * @author Fudanyrd
 * 
 * @param clk: the clock.
 * @param we3: whether write enabled.
 * @param ra: which register to read from.
 * @param wa: which register to write to.
 * @param wd: what to write to wa3.
 * @param rd: words load from ra1, ra2.
 *
 * Important note: for pipelined processor, write third port 
 * on **falling edge** of clk. (page 274[288] of textbook)
 */
module regfile(
  input  logic       clk,
  input  logic       we3,
  input  logic[4:0]  ra1, ra2, wa3,
  input  logic[31:0] wd3,
  output logic[31:0] rd1, rd2
);
  /** Create registers */ 
  logic[31:0] rf[31:0];

  /** YOUR CODE HERE */
  always_ff @(negedge clk)
    if (we3) rf[wa3] <= wd3;
  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule