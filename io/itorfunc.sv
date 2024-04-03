/**
 * I to R funct Module
 * @param op: the opcode of an I-type operator.
 * @param funci: the input func.
 * @returns the R-type funct code of the operator, if invalid, return functi.
 * e.g. op is the code for ori, return the funct of or.
 */ 
module itorfunc(
  input  logic[5:0] op,
  input  logic[5:0] functi,
  output logic[5:0] funct
);
  /** YOUR CODE HERE */
  always_comb
    case (op)
      // addi, lw, sw should yield the same output: add!
      6'b001000: funct <= 6'b100_000;
      6'b100011: funct <= 6'b100_000;
      6'b101011: funct <= 6'b100_000;
      // ori
      6'b001101: funct <= 6'b100_101;
      // andi
      6'b001100: funct <= 6'b100_100;
      
      // unable to recognize I-type operator, return the original one...
      default: funct <= functi;
    endcase
endmodule
