module ioFSM(
    input  logic[7:0] curS,    // current state
    output logic[7:0] nextS    // next state
);
    always_comb
    begin
      case (curS)
        8'b1111_1110: nextS <= 8'b1111_1101;
        8'b1111_1101: nextS <= 8'b1111_1011;
        8'b1111_1011: nextS <= 8'b1111_0111;
        8'b1111_0111: nextS <= 8'b1110_1111;
        8'b1110_1111: nextS <= 8'b1101_1111;
        8'b1101_1111: nextS <= 8'b1011_1111;
        8'b1011_1111: nextS <= 8'b0111_1111;
        8'b0111_1111: nextS <= 8'b1111_1110;
        default: nextS <= 8'b1111_1110;
      endcase
    end
endmodule
