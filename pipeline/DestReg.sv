/**
 * Destination Register Module
 *
 * Can be used in FSM Module to parse cinstr.
 *
 * Given an instruction, tell the destination register
 * of it. Also tell if it is branch statement.
 */
module DestReg(
  input  logic[31:0] instr,
  output logic[4:0]  dest,
  output logic isbranch
);
  always_comb
  begin
    case (instr[31:26])
      // R-type
      6'b000_000: begin
        dest <= instr[15:11];
        isbranch <= 0;
      end
      // addi
      6'b001_000: begin 
        dest <= instr[20:16]; 
        isbranch <= 0;
      end
      // lw
      6'b100_011: begin
        dest <= instr[20:16];
        isbranch <= 0;
      end
      // sw: no destination!
      6'b101_011: begin
        dest <= '0;
        isbranch <= 0;
      end
      // j: no destination!
      6'b000_010: begin
        dest <= '0;
        isbranch <= 1;
      end
      // beq: no destination!
      6'b000_100: begin
        dest <= '0;
        isbranch <= 1;
      end
    endcase
  end
endmodule