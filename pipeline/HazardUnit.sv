/**
 * Hazard Unit of MIPS Processor
 *
 * If hazard happens, this unit will just stall
 * for several cycles until hazard is solved.
 */
module HazardUnit(
  input  logic clk, reset,
  input  logic[31:0] instr,   // (ninstr)next instruction to run.
  output logic[31:0] instrd,  // instruction to be executed(may be nop)
  output logic stalld,
  output logic stallf
);
  /** YOUR CODE HERE */
  logic[2:0] cs;   // current state
  logic[2:0] ns;   // next state
  logic[31:0] cinstr;  // current instruction
  logic[31:0] cache;   // instruction to be cached.

  FSM fsm(
    cs,
    cinstr,
    instr,  // which is: ninstr
    ns,
    cache,
    stalld,
    stallf
  );

  Register #(3) sReg(  // state register
    clk, reset,
    1'b1,
    ns,
    cs
  );
  Register #(32) iReg( // instruction register
    clk, reset,
    1'b1,
    cache,
    cinstr
  );

  always_comb
  begin
    instrd <= (cs == 3'b000) ? instr : 32'h0000_0020;
  end
endmodule
