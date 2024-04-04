/**
 * Controller for multi-cycle MIPS Processor
 *
 * Provider of the control signal needed by datapath.
 */
module controller(
  /** input of controller */
  input  logic clk, reset,
  input  logic zero,       // from datapath
  input  logic[5:0] op,    // from datapath
  input  logic[5:0] funct, // from datapath
  /** output of controller, used by datapath */
  output logic irwrite,
  output logic regdst,
  output logic memtoreg,
  output logic regwrite,
  output logic alusrca,
  output logic[1:0] alusrcb,
  output logic[2:0] alucontrol,
  output logic[1:0] pcsrc,
  output logic pcen,
  /** output of controller, used by memory */
  output logic iord,
  output logic memwrite,
  output logic branchsrc    // 0: beq, 1: bne
);
  logic controlone = 1'b1;
  logic[3:0] ns;   // next state
  logic[3:0] cs;   // current state
  logic[1:0] aluop;
  logic pcwrite;
  logic branch;
  logic[5:0] finalFunct;

  itorfunc itor(
    op,
    funct,
    finalFunct
  );

  Register #(4) StateCache(
    clk, reset,
    controlone,
    ns, 
    cs
  );
  FSM machine(
    cs,
    op,
    ns,
    pcwrite,
    pcsrc,
    iord,
    memwrite,
    irwrite,
    regdst,
    memtoreg,
    regwrite,
    alusrca,
    alusrcb,
    aluop,
    branch,
    branchsrc
  );
  aludec decoder(
    finalFunct,
    aluop,
    alucontrol
  );

  always_comb
    begin
      pcen <= (pcwrite) | (branch & zero);
    end
endmodule