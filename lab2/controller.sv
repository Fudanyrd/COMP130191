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
  output logic[2:0] alucontrol,
  output logic[1:0] branchsrc
);
  logic[1:0] aluop;
  logic[5:0] func_backup;
  logic branch;

  /** YOUR CODE HERE */
  itorfunc itor (
    op,
    funct,
    func_backup
  );
  maindec md(
    op,
    memtoreg, memwrite,
    branch, alusrc,
    regdst, regwrite,
    jump,
    aluop,
    branchsrc
  );
  aludec ad(
    func_backup,
    aluop, 
    alucontrol
  );

  assign pcsrc = branch & zero;
endmodule
