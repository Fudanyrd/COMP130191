/**
 * Signed Less Than module
 * @param left: left operand
 * @param right: right operand
 * @return a single bit 1 if left < right (signed operation)
 */
module signedlessthan(
  input  logic[31:0] left,
  input  logic[31:0] right,
  output logic lessthan
);
  always_comb
  begin
    logic abslessthan = left < right;
    lessthan <= left[31] ? (right[31] ? abslessthan : 1)
                         : (right[31] ? 0 : abslessthan);
  end
endmodule
