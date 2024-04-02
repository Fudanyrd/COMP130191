/**
 * Data Memory Decoder
 *
 * In the positive edge of the clock, deal with dmem,
 * in the negative, deal with IO.
 */
module dmemDec(
    input  logic clk,
    input  logic writeEN,
    input  logic[7:0] addr, 
    input  logic[31:0] writeData,
    output logic[31:0] readData,
    input  logic IOclock,
    input  logic reset,
    input  logic btnL,
    input  logic btnR,
    input  logic[15:0] switch,
    output logic[7:0] an,
    output logic[6:0] a2g
):
  /** YOUR CODE HERE */
endmodule
