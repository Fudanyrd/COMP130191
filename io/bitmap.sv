/**
 * Bit map for each digit:
 * 0: 111_111_0
 * 1: 011_000_0
 * 2: 110_110_1
 * 3: 111_100_1
 * 4: 011_001_1
 * 5: 101_101_1
 * 6: 101_111_1
 * 7: 111_000_0
 * 8: 111_111_1
 * 9: 111_101_1
 */
module bitmap(
    input  logic[4:0] digit,
    output logic[6:0] map
);

    always_comb
    begin
      case (digit)
        5'd0: map <= 7'b111_111_0;
        5'd1: map <= 7'b011_000_0;
        5'd2: map <= 7'b110_110_1;
        5'd3: map <= 7'b111_100_1;
        5'd4: map <= 7'b011_001_1;
        5'd5: map <= 7'b101_101_1;
        5'd6: map <= 7'b101_111_1;
        5'd7: map <= 7'b111_000_0;
        5'd8: map <= 7'b111_111_1;
        5'd9: map <= 7'b111_101_1;
        5'd10: map <= 7'b111_110_1;  // a
        5'd11: map <= 7'b001_111_1;  // b
        5'd12: map <= 7'b000_110_1;  // c
        5'd13: map <= 7'b011_110_1;  // d
        5'd14: map <= 7'b110_111_1;  // e
        5'd15: map <= 7'b100_011_1;  // f
        // specify '=' character
        5'd16: map <= 7'b000_100_1;  // =
        default: map <= 7'b000_000_0;  // varnothing
      endcase
    end
endmodule