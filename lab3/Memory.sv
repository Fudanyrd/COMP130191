/**
 * Memory Module
 * 
 * Challenge: Need to handle both data and instruction!
 *
 * For convenience, here I do not need a mutiplexer, but
 * take in two addresses and IorD(instruction or data) signal
 * from controller.
 */
module Memory(
  input  logic IorD,          // instruction or data(0-I, 1-D)?
  input  logic[31:0] pc,      // instruction address
  input  logic[31:0] addr,    // data address
  input  logic clk,
  input  logic we,            // is write enabled?     
  input  logic[31:0] wd,      // what to write to Data RAM?
  output logic[31:0] rd       // output of memory(depends on IorD)
);
  /** YOUR CODE HERE */
  logic[31:0] DataRAM[63:0];   // data memory file
  logic[31:0] InstrRAM[63:0];  // instruction memory
  // NOTE: InstrRAM should be read only!

  // initialize InstrRAM.
  initial
    // replace the filename here with the file for testing.
    $readmemh("memfile.dat", InstrRAM);

  assign rd = IorD ? DataRAM[addr[31:2]] : InstrRAM[pc];
  always_ff @(posedge clk)
    begin
      // if IorD is 0(instruction), definitely not write!
      if (IorD & we) DataRAM[addr[31:2]] <= wd;
    end
endmodule
