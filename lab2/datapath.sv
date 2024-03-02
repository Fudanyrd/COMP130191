/**
 * Datapath Module
 */
module datapath(
  input  logic clk, reset,
  input  logic memtoreg, pcsrc,
  input  logic alusrc, regdst,
  input  logic regwrite, jump,
  input  logic[2:0] alucontrol,
  input  logic[1:0] branchsrc,
  output logic zero,
  output logic[31:0] pc,
  input  logic[31:0] instr,
  output logic[31:0] aluout, writedata,
  input  logic[31:0] readdata
);
  /** YOUR CODE HERE */
  logic[4:0]  writereg;   // which register to write to
  logic[31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  // signimmsh = signimm << 2;
  logic[31:0] signimm, signimmsh;
  logic[31:0] srca, srcb;
  logic[31:0] result;

  /*** PC LOGIC ***/
  flopr #(32) pcreg(
    clk, reset,
    pcnext,
    pc
  );
  adder        pcaddl(
    pc,
    32'b100,
    pcplus4  // = pc + 4.
  );
  sl2          immsh(
    signimm,
    signimmsh
  );
  adder        pcadd2(
    pcplus4,
    signimmsh,
    pcbranch
  );
  mux2 #(32)   pcbrmux(
    pcplus4,
    pcbranch,
    pcsrc,
    pcnextbr
  );
  mux2 #(32)    pcmux(
    pcnextbr,
    {pcplus4[31:28], instr[25:0], 2'b00},
    jump,
    pcnext
  );

  /*** REGISTER FILE LOGIC ***/
  regfile      rf(
    clk,
    regwrite,                      // write enabled or not
    instr[25:21], instr[20:16], writereg,  // rs, rt, rd
    result,          // write destination
    srca, writedata  // rd1, rd2
  );
  mux2 #(5)   wrmux(
    instr[20:16],
    instr[15:11],
    regdst,
    writereg
  );
  mux2 #(32)   resmux(
    aluout,
    readdata,
    memtoreg,
    result
  );
  signext      se(
    instr[15:0],
    signimm
  );

  /*** ALU LOGIC ***/
  mux2 #(32)   srcbmux(
    writedata,
    signimm,
    alusrc,
    srcb
  );
  alu          alu(
    srca,
    srcb,
    alucontrol,
    branchsrc,
    aluout,
    zero
  );
endmodule
