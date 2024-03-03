/**
 * Arithmetic Logic Unit Decoder
 *
 * Refer to ALU_tt.csv and ALUop.csv for more details.
 */
module aludec(
  input  logic[5:0] funct,   // func field of instruction
  input  logic[1:0] aluop,   // aluop from main decoder.
  output logic[2:0] alucontrol
);
  always_comb
    case(aluop)
      // add (for lw, sw, addi) is merged into 'default' branch
      2'b00: alucontrol <= 3'b010;
      // sub (for beq)
      2'b01: alucontrol <= 3'b110;
      default:
        case(funct)
          // add
          6'b100_000: alucontrol <= 3'b010;
          // sub
          6'b100_010: alucontrol <= 3'b110;
          // and
          6'b100_100: alucontrol <= 3'b000;
          // or
          6'b100_101: alucontrol <= 3'b001;
          // slt
          6'b101_010: alucontrol <= 3'b111;
          // ???
          default:    alucontrol <= 3'bxxx;
        endcase
    endcase
endmodule