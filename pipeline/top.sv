/**
 * Top Module of MIPS
 */
module top(
  input  logic clk, reset,
  output logic[31:0] writedata, dataadr,
  output logic memwrite,
  output logic[2:0] alucontrol  // for debug only
);
  logic[31:0] pc, instr, readdata;
  // instatiate processor and memories.
  mips mips(
    clk, reset,
    pc, 
    instr,
    memwrite,
    dataadr,   // which memory address to write to
    writedata,
    readdata,
    alucontrol
  );
  imem imem(pc[7:2], instr);
  dmem dmem(
    clk,
    memwrite,
    dataadr,
    writedata,
    readdata
  );
endmodule
