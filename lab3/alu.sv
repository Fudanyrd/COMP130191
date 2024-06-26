/**
 * Arithmetic Logic Unit
 * @author Fudanyrd
 *
 * HINT:
 * See ALU_tt.csv and ALUop.csv to make sense of the desired
 * behavior of ALU.
 */
module alu(
  input  logic[31:0] srca,
  input  logic[31:0] srcb,
  input  logic[2:0]  alucontrol,
  input  logic branchsrc,    // 0: beq, 1: bne
  output logic[31:0] aluout,
  output logic zero
);
  /** YOUR CODE HERE */
  logic lt;  // lessthan
  signedlessthan slt(
    srca,
    srcb,
    lt
  );

  always_comb 
  begin
    case (alucontrol)
      // add
      3'b010: aluout <= srca + srcb;
      // sub
      3'b110: aluout <= srca - srcb;
      // and
      3'b000: aluout <= srca & srcb;
      // or
      3'b001: aluout <= srca | srcb;
      // slt
      3'b111: aluout <= {31'b0, lt};
      default: aluout <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    endcase   
  zero <= (srca == srcb & (~branchsrc)) | (srca != srcb & branchsrc) ;
  end
  /** How to set the value of zero? */
  // first attempt:
  // assign zero = 1;
  /** PITFALL: think about what will happen to 'beq'! */
endmodule