/**
 * Put everything so far together: MIPS Module!
 * Page 217[285] of textbook.
 */
module mips(
  input  logic clk, reset,
  output logic[31:0] pc,
  input  logic[31:0] instr,
  output logic memwrite,
  output logic[31:0] aluout, writedata,
  input  logic[31:0] readdata
);
  // meaning of these variables can be found on
  // page 238[252] of textbook, figure 7-14. 
  logic memtoreg;
  logic alusrc;
  logic regdst;
  logic regwrite;
  logic jump;
  logic pcsrc;
  logic zero;
  logic[2:0] alucontrol;

  // control logic
  controller c(
    instr[31:26], instr[5:0],
    zero,
    memtoreg, memwrite,
    pcsrc, alusrc,
    regdst, regwrite,
    jump,
    alucontrol
  );

  // datapath logic
  datapath dp(
    clk, reset, 
    memtoreg, pcsrc,
    alusrc, regdst,
    regwrite, jump,
    alucontrol,
    zero, 
    pc,
    instr,
    aluout, writedata,
    readdata
  );

endmodule
