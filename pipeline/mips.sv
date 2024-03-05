/**
 * Pipelined MIPS Processor
 *
 * Implementation: Link controller, HazardUnit and Datapath.
 */
module mips(
  input  logic clk, reset,
  output logic[31:0] pc,
  input  logic[31:0] instr,
  output logic memwrite,
  output logic[31:0] aluout, writedata,
  input  logic[31:0] readdata,
  output logic[2:0] alucontrol  // for debugging
);
  /** YOUR CODE HERE **/
  logic jump;
  logic regwrited;
  logic memtoregd;
  logic memwrited;
  logic[2:0] alucontrold;
  logic alusrcd;
  logic regdstd;
  logic pcsrcd;
  logic[5:0] op, funct;
  logic zero;
  logic stallf, stalld;
  logic forwardad, forwardbd;
  logic[1:0] forwardae, forwardbe;
  logic flushe;
  logic[4:0] rsd, rtd;
  logic[4:0] rse, rte;
  logic[4:0] writerege, writeregm, writeregw;
  logic memtorege, regwritee;
  logic memtoregm, regwritem;
  logic regwritew;
  logic branchd;

  controller ctrl(
    op, funct,
    zero,
    memtoregd, memwrited,
    pcsrcd, alusrcd,
    regdstd, regwrited,
    jump,
    branchd,
    alucontrold
  );

  datapath dp(
  // general purpose inputs
    clk, reset,
  /** Input & Output Of IMEM HERE */
    instr,
    pc,
  /** Input & Output Of DMEM */
    readdata,           // a.k.a rdm
    aluout,             // a.k.a aluoutm
    writedata,          // a.k.a writedatam
    memwrite,           // a.k.a memwritem
  /** Input & Output Of Controller */
    jump,
    regwrited,
    memtoregd,
    memwrited,
    alucontrold,
    alusrcd,
    regdstd,
    pcsrcd,
    op,
    funct,
    zero,
  /** Input & Output Of Hazard Unit */
    stallf,
    stalld,
    forwardad,
    forwardbd,
    forwardae,
    forwardbe,
    flushe,
    rsd,
    rtd,
    rse,
    rte,
    writerege,
    memtorege,
    regwritee,
    writeregm,
    memtoregm,
    regwritem,
    writeregw,
    regwritew,
    alucontrol 
  );

  HazardUnit hu(
    jump,
    op,
    branchd,
    rsd,
    rtd,
    rse,
    rte,
    writerege,
    memtorege,
    regwritee,
    writeregm,
    memtoregm,
    regwritem,
    writeregw,
    regwritew,
    stallf,
    stalld,
    forwardad,
    forwardbd,
    flushe,
    forwardae,
    forwardbe
  );

endmodule
