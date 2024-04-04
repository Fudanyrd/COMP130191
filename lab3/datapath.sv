/**
 * Datapath Module For Multi-cycle MIPS Processor
 *
 * Constructed from left to right based on figure 7-34
 * at page 248[262] on textbook.
 */
module datapath(
  input  logic clk, reset,
  input  logic[31:0] rd,        // output of memory file
  input  logic irwrite,         // IRWrite
  output logic[5:0] op,         // Opcode of operator
  output logic[5:0] funct,      // funct of R-type
  input  logic regdst,          // which field of instruction is destination?
  input  logic memtoreg,        // which result to write to register?
  input  logic regwrite,        // RegWrite: write to register file?
  output logic[31:0] writedata, // what to write to DMEM? (pass to Memory:wd)    
                                // used by memory! 
  input  logic alusrca,         // use register or pc as input?
  input  logic[1:0] alusrcb,    // use register or immediate as input?
  input  logic[2:0] alucontrol, // alu control signal
  input  logic branchsrc,       // 0: beq, 1: bne
  output logic zero,
  input  logic[1:0] pcsrc,      // use aluresult or aluout as pc value?
  input  logic pcen,            // enable pc write?
  output logic[31:0] aluout,    // new alu output
  output logic[31:0] pc         // new pc value
);
  /** YOUR CODE HERE */
  logic one = '1;  
  logic[31:0] instruction;
  logic[31:0] data;

  /** Register File related */
  logic[4:0] wa3;         // write to register wa3.
  logic[31:0] wd3;        // content to write to regfile.
  logic[31:0] rd1, rd2;   // output of register file.
  logic[31:0] a;

  /** Sign extender related */
  logic[15:0] imm16;
  logic[31:0] imm32;    // imm32 is the sign extended imm16.
  logic[31:0] imm32sh;  // imm32sh = imm32 << 2.

  /** ALU Related */
  logic[31:0] four = 32'b100;
  logic[31:0] srca;  // left operand
  logic[31:0] srcb;  // right operand
  logic[31:0] aluresult;

  /** PC Related */
  logic[31:0] pcdash;  // ie. PC' in the figure.
  logic[25:0] label;

  /** First: PC Control Logic! */
  mux4 #(32) PCSrc(
    aluresult, aluout, {pc[31:28], label[25:0], 2'b00}, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
    pcsrc,
    pcdash 
  );
  Register #(32) PCCache(
    clk, reset,
    pcen,
    pcdash,
    pc
  );

  /** Take data/instruction from memory, get op and funct. */
  Register #(32) Instr(  // instruction register
    clk,
    reset,
    irwrite,
    rd,
    instruction
  );
  Register #(32) Data(  // Data Register
    clk,
    reset,
    one,
    rd,
    data
  );

  /** Take instruction and data, visit register file */
  mux2 #(5) RegDst(
    instruction[20:16], instruction[15:11],
    regdst,
    wa3
  );
  mux2 #(32) WD3(
    aluout, data,
    memtoreg,
    wd3
  );
  regfile RegFile(
    clk,
    regwrite,
    instruction[25:21], instruction[20:16], wa3,
    wd3,
    rd1, rd2
  );
  Register #(64) RegCache(
    clk, reset,
    one,
    {rd1, rd2},
    {a, writedata}
  );

  /** Deal with immediates */
  signext SignExtendImm(
    imm16,
    imm32
  );
  sl2 ImmSh(
    imm32,
    imm32sh
  );

  /** Link ALU, send zero sigal to control */
  mux2 #(32) SrcA(
    pc, a,
    alusrca,
    srca
  );
  mux4 #(32) SrcB(
    writedata, four, imm32, imm32sh,
    alusrcb,
    srcb
  );
  alu ALU(
    srca, srcb,
    alucontrol,
    branchsrc,
    aluresult,
    zero
  );
  Register #(32) ALUCache(
    clk, reset,
    one,
    aluresult,
    aluout
  );

  always_comb
  begin
    // control signals
    op <= instruction[31:26];
    funct <= instruction[5:0];
    // immediates
    imm16 <= instruction[15:0];
    label <= instruction[25:0];
  end
endmodule
