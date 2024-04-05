module Top(
  input  logic CLK100MHZ,
  input  logic BTNC,
  input  logic BTNL,
  input  logic BTNR,
  input  logic[15:0] SW,
  output logic[7:0] AN,
  output logic[6:0] A2G,
  output logic DP
  // output logic[31:0] pc
);
  logic[31:0] pc;
  logic[31:0] instr;
  logic       CLK1KHZ;

  imem imem(
    (pc[7:2]),
    (instr)
  );

  freq_div divider(
    CLK100MHZ,
    CLK1KHZ
  );

  logic Write;
  logic[31:0] dataAdr;
  logic[31:0] writeData;
  logic[31:0] readData;

  mips mips(
    .clk(CLK1KHZ),
    .reset(BTNC),
    .pc(pc),                   // output
    .instr(instr),
    .memwrite(Write),
    .aluout(dataAdr),          // output
    .writedata(writeData),     // output
    .readdata(readData)
  );

  dmemDec ddc(
    .clk(CLK1KHZ),
    .writeEN(Write),
    .dataAdr(dataAdr),
    .writeData(writeData),
    .readData(readData),       // output
    .reset(BTNC),
    .btnL(BTNL),
    .btnR(BTNR),
    .switch(SW),
    .an(AN),                   // output
    .a2g(A2G),                 // output
    .dp(DP)                    // output
  );

endmodule
