/**
 * Hazard Unit of MIPS Processor
 *
 * If hazard happens, this unit will just stall
 * for several cycles until hazard is solved.
 *
 * @source See figure 7-58 on textbook to get an 
 * implementation of pipeline hazard unit.
 */
module HazardUnit(
  /* input of hazard unit(fig 7-58, left to right) */
  input  logic jump,
  input  logic[5:0] op,
  input  logic branchd,
  input  logic[4:0] rsd,
  input  logic[4:0] rtd,
  input  logic[4:0] rse,
  input  logic[4:0] rte,
  input  logic[4:0] writerege,
  input  logic memtorege,
  input  logic regwritee,
  input  logic[4:0] writeregm,
  input  logic memtoregm,
  input  logic regwritem,
  input  logic[4:0] writeregw,
  input  logic regwritew,
  /* output of hazard unit(fig 7-58, left to right) */
  output logic stallf,            // 
  output logic stalld,            // 
  output logic forwardad,         //
  output logic forwardbd,         // 
  output logic flushe,            //
  output logic[1:0] forwardae,    // 
  output logic[1:0] forwardbe     // 
);
  /** YOUR CODE HERE */
  logic lwstall;
  logic branchstall;
  logic addi;

  /** ForwardAE, ForwardBE */
  always_comb
  begin
  if ((rse != 5'b0) & (rse == writeregm) & regwritem) assign forwardae = 2'b10;
  else if ((rse != 5'b0) & (rse == writeregw) & regwritew) assign forwardae = 2'b01;
  else assign forwardae = 2'b00;
  if ((rte != 5'b0) & (rte == writeregm) & regwritem) assign forwardbe = 2'b10;
  else if ((rte != 5'b0) & (rte == writeregw) & regwritew) assign forwardbe = 2'b01;
  else assign forwardbe = 2'b00;

  /** ForwardAD, ForwardBD */
  assign forwardad = (rsd != 5'd0) & (rsd == writeregm) & regwritem;
  assign forwardbd = (rtd != 5'd0) & (rtd == writeregm) & regwritem;

  /** stallF, stallD, FlushE */
  assign addi = op == 6'b001000;
  /** 
   * NOTE: 
   *
   * This is used to ensure that result of currect instruction does not
   * rely on previous 'lw' instruction. So we have to check data dependency
   * which is: rsd == rte OR rtd == rte.
   *
   * Since we want to add 'addi' operator to the pipeline, we have to consider 
   * if rtd depends on rte(i.e. if the source operand depends on 'lw' result). 
   * As for 'addi', the answer is no! So I made the following changes:
   */
  assign lwstall = ((rsd == rte) | (rtd == rte & ~addi)) & memtorege;
  //                                           ^^^^^^^^
  assign branchstall = branchd & regwritee & (writerege == rsd | (writerege == rtd)) 
                     | branchd & memtoregm & (writeregm == rsd | (writeregm == rtd));
  /**
   * Also note that if we want to add 'j' to pipeline, the new 'pc' value can be computed
   * at Decode stage. Thus do not need to stall(i.e. stallf = stalld = false), but we
   * still have to flush the pipeline(otherwise the rsd, rtd will just be fed forward and wreak havoc...)
   */
  assign stalld = lwstall | branchstall;
  assign stallf = stalld;
  assign flushe = stallf | jump; 
  //                     ^^^^^^^
  end
endmodule
