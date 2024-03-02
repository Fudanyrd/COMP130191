/**
 * Main Decoder Module
 * @source page 286[272] on textbook
 */
module maindec(
  input  logic[5:0] op,    // opticode
  output logic memtoreg, memwrite,
  output logic branch, alusrc,   
  output logic regdst, regwrite,
  output logic jump,
  output logic[1:0] aluop,
  output logic[1:0] branchsrc
);
  /** YOUR CODE HERE */
  logic[10:0] controls;
  // unpack the instruction.
  assign {
    regwrite,
    regdst,
    alusrc,    // 3
    branch,
    memwrite,
    memtoreg,  // 6
    jump,
    aluop,      // 8-9
    branchsrc
  } = controls;

  // set each field of control to what they should be.
  always_comb 
  begin
    case (op) 
      // R-type:
      6'b000000: controls <= 11'b110_000_010_10; // why?
      // lw
      6'b100011: controls <= 11'b101_001_000_10;
      // sw
      6'b101011: controls <= 11'b001_010_000_10;
      // beq
      6'b000100: controls <= 11'b000_100_001_00;
      // bne
      6'b000101: controls <= 11'b000_100_001_11;
      // addi
      6'b001000: controls <= 11'b101_000_000_10;
      // ori
      6'b001101: controls <= 11'b101_000_000_10;
      // andi
      6'b001100: controls <= 11'b101_000_000_10;
      // j
      6'b000010: controls <= 11'b000_000_100_10;
      // illegal opt
      default:   controls <= 11'bxxxxxxxxxxx;
    endcase
  end
endmodule
/************************************************
 *          IMPLEMENTATION DETAILS
 * The main decoder take Optcode[5:0] as input, 
 * based on this generate outputs:
 * MemtoReg, MemWrite, Branch, ALUSrc, RegDest, RegWrite.
 *
 * NOTE that only the following operations will be implemented:
 * R-type: add, sub, and, or, slt(set less than)
 * I-type: addi
 * S-type: sw, lw
 * SB-type: beq, j
 *
 * Note: instruction format in MIPS:
 * 1. R-type
 * [31:26|25:21|20:16|15:11|10:6 |5:0 ]
 * [ op  | rs  | rt  | rd  |shamt|func]
 * Note that 'shamt' will only be used in shifting operation.
 * An interesting observation: shifting 32 bits will always lead to 0!
 *
 * 2. I-type
 * [31:26|25:21|20:16|  15:0  ]
 * [ op  | rs  | rt  |  imm   ]
 *
 * 3. J-type
 * [31:26|    25:0     ]
 * [ op  |    addr     ]
 *
 * For the full instruction set of MIPS, go to 
 * Appendix B of textbook.
 ************************************************/
