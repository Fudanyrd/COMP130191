/** 
 * This is used to test implementation of andi, ori,
 * Test code is put in andi_ori.asm.
 * 
 * To run this code, have to change the content in memfile.dat into those 
 * machine code in andi_ori.asm!
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
        if (dataadr == 16 & writedata == 7) 
        begin
          $display("Simulation succeeded! Congrats!");
          $stop;
        end
      else 
      if (dataadr == 16)
        begin
          $display("Good news: write to correct address; bad one: write the wrong value!");
          $stop;
        end
      if (dataadr != 16)
        begin
          $display("Oops, simulation failed!");
          $stop;
        end
      end
    end
endmodule
