/** 
 * Multi-Cycle MIPS Processor
 *
 * It is a link of ONLY controller and datapath, i.e.
 * memory file has not been added yet;
 * data needed by memory is providec here.
 */
module mips(
  input  logic clk, reset,
  input  logic[31:0] rd,
  output logic       iord,
  output logic       memwrite,
  output logic[31:0] pc,
  output logic[31:0] aluout,
  output logic[31:0] writedata
);
  logic zero;
  logic[5:0] op, funct;
  logic irwrite;
  logic regdst;
  logic memtoreg;
  logic regwrite;
  logic alusrca;
  logic[1:0] alusrcb;
  logic[2:0] alucontrol;
  logic[1:0] pcsrc;
  logic pcen;
  logic branchsrc;

  // linking controller, and list variables not found.
  controller ct( // from datapath
    clk, reset,
    zero,
    op,
    funct,       // used by datapath
    irwrite,
    regdst,
    memtoreg,
    regwrite,
    alusrca,
    alusrcb,
    alucontrol,
    pcsrc,
    pcen,         // used by memory
    iord,
    memwrite,
    branchsrc
  );

  // linking datapath:
  datapath dp(
    clk, reset,
    rd,
    irwrite,
    op,
    funct,
    regdst,
    memtoreg,
    regwrite,
    writedata,
    alusrca,
    alusrcb,
    alucontrol,
    branchsrc,
    zero,
    pcsrc,
    pcen,
    aluout,
    pc
  );
endmodule
