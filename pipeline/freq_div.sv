/**
 * Frequency divider
 */
module freq_div(
  input  logic CLK100MHZ,
  output logic CLK1KHZ     // output freq is 1000 HZ.
);
  logic[19:0] count;
  logic       clk_1k;

  initial begin
    count = 0;
    clk_1k = 1;
  end

  always_ff @(posedge CLK100MHZ)
  begin
    if (count == 20'd50_000) begin
      clk_1k <= ~clk_1k;
      count <= count + 1;
    end
    else begin
      if (count == 20'd99_999) begin
        count <= 20'b0;
        clk_1k <= ~clk_1k;
      end
      else begin
        count <= count + 1;
      end
    end
  end

  assign CLK1KHZ = clk_1k;
endmodule