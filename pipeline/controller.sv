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
  logic bne;           // is current operation bne?
  logic[5:0] finalFunct;

  /** YOUR CODE HERE */
  itorfunc itor(
    op,
    funct,
    finalFunct
  );
  maindec md(
    op,
    memtoreg, memwrite,
    branch, alusrc,
    regdst, regwrite,
    jump,
    aluop
  );
  aludec ad(
    finalFunct,
    aluop, 
    alucontrol
  );
  assign bne = (op == 6'b000_101);
  assign pcsrc = branch & (zero ^ bne);
endmodule
