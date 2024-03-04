/**
 * Finite State Machine
 * 
 * Used by Hazard Unit.
 * It handles 5 states in total:
 * s0 is decode state; s1-s4 are stall state.
 */
module FSM(
  input  logic[2:0] cs,        // current state
  input  logic[31:0] cinstr,   // previous instruction(stored in register)
  input  logic[31:0] ninstr,   // next instruction(decide whether to stall)
  output logic[2:0] ns,        // code of next state
  output logic[31:0] cache,    // what instruction to be stored in cache?
  output logic stalld,         // control instruction register of datapath
  output logic stallf          // control pc register on datapath
);
  // dependency check.
  logic[5:0] opcode;
  logic isbranch;
  logic[4:0] dest;
  logic[4:0] rs, rt;
  logic stall;         // stall or not?
  
  DestReg getdest(
    cinstr,
    dest,
    isbranch
  );
  DependReg depd(
    ninstr,
    rs,
    rt
  );
  assign stall = isbranch | (dest != 5'b0 & (dest == rs | dest == rt));

  always_comb
  begin
    case (cs)
      /** Decoding State */
      3'b000: 
      begin
        // dependency check!
        ns <= (stall) ? 3'b001: 3'b000;
        cache <= (stall) ? cinstr : ninstr;
        stallf <= (stall) ? 0 : 1;
        stalld <= (stall) ? 0 : 1;
      end
      /** Stall States */
      3'b001: 
        begin 
          ns <= 3'b010;
          cache <= cinstr;
          stallf <= 0;
          stalld <= 0;
        end
      3'b010: 
        begin 
          ns <= 3'b011;
          cache <= cinstr;
          stallf <= 0;
          stalld <= 0;
        end
      3'b011: 
        begin 
          ns <= 3'b100;
          cache <= cinstr;
          stallf <= 0;
          stalld <= 0;
        end
      3'b100: 
        begin 
          ns <= 3'b000;
          cache <= cinstr;
          stallf <= 1;
          stalld <= 1;
        end
    endcase
  end
endmodule
