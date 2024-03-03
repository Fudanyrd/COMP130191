/**
 * Top Module for multi-cycle MIPS Processor
 */
module top(
  input logic clk, reset,
  output logic[31:0] writedata, dataadr,
  output logic iord,
  output logic memwrite
);
  logic[31:0] pc, readdata;
  // logic iord;
  // processor!
  mips process(
    clk, reset,
    readdata,
    iord,
    memwrite,
    pc,
    dataadr,  // aluout
    writedata
  );
  // link to memory!
  Memory mem(
    iord,
    pc,
    dataadr,
    clk,
    memwrite,  // we
    writedata,
    readdata
  );
endmodule
