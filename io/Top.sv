module Top(
  input  logic CLK100MHZ,
  input  logic BTNC,
  input  logic BTNL,
  input  logic BTNR,
  input  logic[15:0] SW,
  output logic[7:0] AN,
  output logic[6:0] A2G
):
  logic[31:0] pc;
  logic[31:0] instr;

  logic Write;
  logic[31:0] dataAdr;
  logic[31:0] writeData;
  logic[31:0] readData;

  MIPS mips(
    .clk(CLK100MHZ),
    .reset(BTNC),
    .pc(pc),                   // output
    .instr(instr),
    .memwrite(Write),
    .aluout(dataAdr),          // output
    .writedata(writeData),     // output
    .readData(readData)
  );

  dmemDec ddc(
    .clk(CLK100MHZ),
    .writeEN(Write),
    .addr(dataAdr[7:0]),
    .writeData(writeData),
    .readData(readData),       // output
    .IOclock(~CLK100MHZ),
    .reset(BTNC),
    .btnL(BTNL),
    .btnR(BTNR),
    .switch(SW),
    .an(AN),                   // output
    .a2g(A2G)                  // output
  );

endmodule
