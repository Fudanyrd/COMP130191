/**
 * Controller Module
 */
module controller(
  input  logic[5:0] op, funct,
  input  logic zero,
  output logic memtoreg, memwrite,
  output logic pcsrc, alusrc,
  output logic regdst, regwrite,
  output logic jump,
  output logic branch,               // i.e. branchd, maybe used by Hazard Unit.
  output logic[2:0] alucontrol
);
  logic[1:0] aluop;
  // zero: a.k.a 'EqualD'

  /** YOUR CODE HERE */
  maindec md(
    op,
    memtoreg, memwrite,
    branch, alusrc,
    regdst, regwrite,
    jump,
    aluop
  );
  aludec ad(
    funct,
    aluop, 
    alucontrol
  );
  assign pcsrc = branch & zero;
endmodule
