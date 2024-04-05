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
 * =: 000_100_1
 */
module mux7sig(
  input  logic clk,
  input  logic reset,
  input  logic[15:0] switch,
  input  logic[11:0] led,
  output logic[7:0] an,
  output logic[6:0] a2g,
  output logic dp
);

  logic[7:0] curS;
  logic[7:0] nextS;
  logic[12:0] digit;
  logic[6:0] a2gFlipped;

  Register #(8) stateReg(
    clk, reset,
    1'b1,
    nextS,
    curS
  );
  ioFSM iofsm(
    curS,
    nextS
  );
  bitmap map(
    digit[3:0],
    a2gFlipped 
  );

  /** YOUR CODE HERE */
  always_ff @(posedge clk) begin
    dp <= 1'b1;   // do not activate dot point
    a2g <= ~a2gFlipped;
    if (reset) begin 
      // a2g <= 7'b0;
      an <= 8'b1111_1111;
    end
    else begin
      an <= (curS == 8'b0000_0000) ? 8'b1111_1110 : curS;
    end
  end

  always_comb begin
    case (curS)
      8'b1111_1110: digit <= (led % 12'd10);
      8'b1111_1101: digit <= ((led / 12'd10) % 12'd10);
      8'b1111_1011: digit <= (led / 12'd100);
      8'b1111_0111: digit <= 12'd10;
      8'b1110_1111: digit <= {4'b0, (switch[7:0] % 8'd10)};
      8'b1101_1111: digit <= {4'b0, (switch[7:0] / 8'd10)};
      8'b1011_1111: digit <= {4'b0, (switch[15:8] % 8'd10)};
      8'b0111_1111: digit <= {4'b0, (switch[15:8] / 8'd10)};
      default: digit <= 12'd11;
    endcase 
  end
endmodule