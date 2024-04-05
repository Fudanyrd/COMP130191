/**
 * Data Memory Decoder
 *
 * In the positive edge of the clock, deal with dmem,
 * in the negative, deal with IO.
 */
module dmemDec(
    input  logic clk,
    input  logic writeEN,
    input  logic iord,             // newly added
    input  logic[31:0] pc,         // newly added
    // input  logic[7:0] addr, 
    input  logic[31:0] dataAdr, 
    input  logic[31:0] writeData,
    output logic[31:0] readData,
    input  logic reset,
    input  logic btnL,
    input  logic btnR,
    input  logic[15:0] switch,
    output logic[7:0] an,
    output logic[6:0] a2g,
    output logic dp
);
  /** YOUR CODE HERE */


  /**
   * NOTE:
   * switch[15:8] = left operand,
   * switch[7:0] = right operand
   */
  logic[7:0] addr;
  logic[31:0] readData1;
  logic[31:0] readData2;
  logic[11:0] led;

  Memory mem(
    .IorD(iord),
    .pc(pc),
    .addr(dataAdr),
    .clk(clk),
    .we(writeEN),
    .wd(writeData),
    .rd(readData1)             // output
  );

  mux2 #(32) mux(
    readData1, readData2,
    addr[7],
    readData             // output
  );

  IO io(
    (clk),
    (reset),
    (addr[7]),
    (writeEN & addr[7]),
    (addr[3:2]),
    (writeData[11:0]),
    (readData2),              // output
    (btnL),
    (btnR),
    (switch),
    (led)                          // output
  );

  mux7sig m7s(
    (clk),
    (reset),
    (switch),
    (led),
    (an),             // output
    (a2g),
    dp
  );

  always_comb
  begin
    addr <= dataAdr[7:0];
  end
endmodule
