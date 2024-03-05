module testbench(
  /* void */
);
  logic clk;
  logic reset;

  logic[31:0] writedata, dataadr;
  logic memwrite;
  logic[2:0] alucontrol;

  // instantiate device to be tested
  top dut(
    clk, reset,
    writedata,
    dataadr,
    memwrite,
    alucontrol
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
        if (dataadr == 84 & writedata == 7) 
        begin
          $display("Simulation succeeded! Congrats!");
          $stop;
        end
      else 
      if (dataadr == 84)
        begin
          $display("Good news: write to correct address! Bad one: write the wrong value");
          $stop;
        end
      if (dataadr != 80)
        begin
          $display("Oops, simulation failed!");
          $stop;
        end
      end
    end
endmodule
