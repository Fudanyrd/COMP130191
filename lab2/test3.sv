/** 
 * This is used to test implementation of bne.
 * Test code is put in bne.asm.
 * 
 * NOTE that we do not need to write test for beq, because we can see
 * the correctness by simulating test.sv.
 * 
 * To run this code, have to change the content in memfile.dat into those 
 * machine code in bne.asm!
 */
module testbench2(
  /* void */
);
  logic clk;
  logic reset;

  logic[31:0] writedata, dataadr;
  logic memwrite;

  // instantiate device to be tested
  top dut(
    clk, reset,
    writedata,
    dataadr,
    memwrite
  );

  // initialize test
  initial
    begin
      reset <= 1;
      #22;
      reset <= 0;
    end
  // generate clock to sequence tests
  always 
    begin
      clk <= 1;
      #5;
      clk <= 0;
      #5;  
    end
  // check results
  always @(negedge clk)
    begin
      if (memwrite)
        begin
          if (writedata == 7) 
          begin
            $display("Simulation succeeded! Congrats!");
            $stop;
          end
        else 
          begin
            $display("Oops, simulation failed!");
            $stop;
          end
        end
    end
endmodule
