/**
 * Datapath of the pipeline
 * 
 * @source for a working implementation, refer to the figure
 * 7-58 of textbook(and the meaning of identifiers).
 */
module datapath(
  // general purpose inputs
  input  logic clk, reset,
  /** Input & Output Of IMEM */
  input  logic[31:0] rdf,
  output logic[31:0] pcf,
  /** Input & Output Of DMEM */
  input  logic[31:0] rdm,         // probably used in 'lw'.
  output logic[31:0] aluoutm,
  output logic[31:0] writedatam,
  output logic memwritem,
  /** Input & Output Of Controller */
  input  logic jump,
  input  logic regwrited,
  input  logic memtoregd,
  input  logic memwrited,
  input  logic[2:0] alucontrold,
  input  logic alusrcd,
  input  logic regdstd,
  input  logic pcsrcd,             // pcsrcd = zero & branchd
  output logic[5:0] op,
  output logic[5:0] funct,
  output logic zero,               // i.e. equal d
  /** Input & Output Of Hazard Unit */
  input  logic stallf,
  input  logic stalld,
  input  logic forwardad,
  input  logic forwardbd,
  input  logic[1:0] forwardae,
  input  logic[1:0] forwardbe,
  input  logic flushe,
  output logic[4:0] rsd,
  output logic[4:0] rtd,
  output logic[4:0] rse,
  output logic[4:0] rte,
  output logic[4:0] writerege,
  output logic memtorege,
  output logic regwritee,
  output logic[4:0] writeregm,
  output logic memtoregm,
  output logic regwritem,
  output logic[4:0] writeregw,
  output logic regwritew
);
  // Fetch stage
  logic[31:0] readdataw, aluoutw;
  logic[31:0] resultw;
  logic[31:0] pcbranchd, pcplus4f;
  logic[31:0] pc1, pc2;
  logic[31:0] instrd;

  // Decoding stage
  logic[31:0] pcplus4d;
  logic[4:0] rdd;
  logic[31:0] rd1, rd2;
  logic[31:0] leftd, rightd;
  logic[15:0] instrd16;
  logic[31:0] signimmd, signimmdsh;
  logic memwritee;
  logic[2:0] alucontrole;
  logic alusrce;
  logic regdste;
  logic[31:0] lefte, righte;
  logic[4:0] rde;
  logic[31:0] signimme;

  // Execution stage
  logic[31:0] srcae, srcbe;
  logic[31:0] writedatae; 
  logic[31:0] aluoute;

  /*** Fetch Stage ***/
  Register #(71) fetchreg(
    clk, reset,
    1'b1,
    {
      regwritem,
      memtoregm,
      rdm,
      aluoutm,
      writeregm
    },
    {
      regwritew,
      memtoregw,
      readdataw,
      aluoutw,
      writeregw
    }
  );
  mux2 #(32) ResultW(
    aluoutw, readdataw,
    memtoregw,
    resultw
  );
  mux2 #(32) PCSel1(
    pcplus4f, pcbranchd,
    pcsrcd,
    pc1
  );
  mux2 #(32) PCSel2(
    pc1, {pcplus4f[31:28], instrd[25:0], 2'b0},
    jump,
    pc2
  );
  Register #(32) PC(
    clk, reset,
    ~stallf,
    pcf
  );
  adder PCPlus4(
    pcf, 32'b100,
    pcplus4f
  );
  // Link to IMEM

  /** Decoding Stage */
  signext SignImmD(
    instrd16,
    signimmd
  );
  Register #(64) InstrReg(
    clk, reset,
    ~stalld,
    {
      rdf,
      pcplus4f
    },
    {
      instrd,
      pcplus4d
    }
  );
  regfile RegFile(
    clk,
    regwritew,
    instrd[25:21], instrd[20:16], writeregw, /*a.k.a ra1, ra2, wd3*/
    resultw,
    rd1, rd2
  );
  mux2 #(32) LeftD(
    rd1, aluoutm,
    forwardad,
    leftd
  );
  mux2 #(32) RightD(
    rd2, aluoutm,
    forwardbd,
    rightd
  );
  adder PCBranchD(
    signimmdsh, pcplus4d,
    pcbranchd
  );
  Register #(119) DEReg(
    clk, reset | flushe,
    1'b1,
    {
      regwrited,
      memtoregd,
      memwrited,
      alucontrold,
      alusrcd,
      regdstd,
      leftd,
      rightd,
      rsd,
      rtd,
      rdd,
      signimmd
    },
    {
      regwritee,
      memtorege,
      memwritee,
      alucontrole,
      alusrce,
      regdste,
      lefte,
      righte,
      rse,
      rte,
      rde,
      signimme
    }
  );

  /*** Execution Stage ***/
  mux2 #(5) WriteRegE(
    rte, rde,
    regdste,
    writerege
  );
  mux3 #(32) SrcAE(
    lefte, resultw, aluoutm,
    forwardae,
    srcae
  );
  mux3 #(32) WriteDataE(
    righte, resultw, aluoutm,
    forwardbe,
    writedatae 
  );
  mux2 #(32) SrcBE(
    writedatae, signimme,
    alusrce,
    srcbe
  );  // link the ALU
  alu ALU(
    srcae, srcbe,
    alucontrole,
    aluoute
  );
  // pass to Memory Stage.
  Register #(72) EMReg(
    clk, reset,
    1'b1,
    {
      regwritee,
      memtorege,
      memwritee,
      aluoute,
      writedatae,
      writerege
    },
    {
      regwritem,
      memtoregm,
      memwritem,
      aluoutm,
      writedatam,
      writeregm
    }
  );

  always_comb
  begin
    op <= instrd[31:26];
    funct <= instrd[5:0];
    rsd <= instrd[25:21];
    rtd <= instrd[20:16];
    rdd <= instrd[15:11];
    zero <= (leftd == rightd);
    instrd16 <= instrd[15:0];
    signimmdsh <= {signimmd[29:0], 2'b00};
  end
endmodule
