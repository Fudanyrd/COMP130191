/**
 * Dependency Register Module
 * 
 * Can be used in FSM to parse ninstr.
 * 
 * Given an instruction, find its dependency 
 * register(can have 0, 1 or 2).
 * If not a dependency, return '0.
 */
module DependReg(
  input  logic[31:0] instr,
  output logic[4:0] rs,
  output logic[4:0] rt
);
  /** YOUR CODE HERE */
  always_comb
  begin
    case (instr[31:26])
      // R-type
      6'b000_000: begin
        rs <= instr[25:21];
        rt <= instr[20:16];
      end
      // addi
      6'b001_000: begin 
        rs <= instr[25:21];
        rt <= '0;
      end
      // lw
      6'b100_011: begin
        rs <= instr[25:21];
        rt <= '0;
      end
      // sw
      6'b101_011: begin
        rs <= instr[25:21];
        rt <= '0;
      end
      // j: no dependency register!
      6'b000_010: begin
        rs <= '0;
        rt <= '0;
      end
      // beq
      6'b000_100: begin
        rs <= instr[25:21];
        rt <= instr[20:16];
      end
    endcase
  end
endmodule