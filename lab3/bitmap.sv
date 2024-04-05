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
    input  logic[3:0] digit,
    output logic[6:0] map
);

    always_comb
    begin
      case (digit)
        4'd0: map <= 7'b111_111_0;
        4'd1: map <= 7'b011_000_0;
        4'd2: map <= 7'b110_110_1;
        4'd3: map <= 7'b111_100_1;
        4'd4: map <= 7'b011_001_1;
        4'd5: map <= 7'b101_101_1;
        4'd6: map <= 7'b101_111_1;
        4'd7: map <= 7'b111_000_0;
        4'd8: map <= 7'b111_111_1;
        4'd9: map <= 7'b111_101_1;
        // specify '=' character.
        4'd10: map <= 7'b000_100_1;
        default: map <= 7'b000_000_0;  // varnothing
      endcase
    end
endmodule