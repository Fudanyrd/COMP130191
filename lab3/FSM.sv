/**
 * Finite State Machine Module
 * 
 * All states and respective input and output is on page 254[268]
 * of the textbook.
 *
 * All irrelevant return value will be set to '0'.
 * This is based on the implementation on page 245[259]
 * of the textbook.
 */
module FSM(
  input  logic[3:0] cs,     // current state
  input  logic[5:0] op,     // opcode
  output logic[3:0] ns,     // next state?
  output logic pcwrite,     // PCwrite, write to PC?
  output logic[1:0] pcsrc,  // PC selector
  output logic iord,        // IOrD, Instruction or data?
  output logic memwrite,    // write to memory?
  output logic irwrite,     // write to instruction cache?
  output logic regdst,
  output logic memtoreg,
  output logic regwrite,
  output logic alusrca,
  output logic[1:0] alusrcb,
  output logic[1:0] aluop,   // pass it to alu decoder to get alucontrol.  
  output logic branch,
  output logic branchsrc     // 0: beq(state id=8) 1: bne(state id=12)
);
  always_comb
  begin
    case (cs)
      // State 0: Fetch
      4'd0: begin
        // only one next state
        ns <= 4'd1;
        // other outputs.
        pcwrite <= 1'b1;    // set
        pcsrc <= 2'b00;     // set
        iord <= 1'b0;       // set
        memwrite <= 1'b0;
        irwrite <= 1'b1;    // set
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;    // set
        alusrcb <= 2'b01;   // set
        aluop <= 2'b00;     // set
        branch <= 1'b0;
      end
      // State 1: Decode
      4'd1: begin
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;    // set
        alusrcb <= 2'b11;   // set
        aluop <= 2'b00;     // set
        branch <= 1'b0;
        branchsrc <= 1'b0;
        case (op)
          // lw
          6'b100011: ns <= 4'd2;
          // sw
          6'b101011: ns <= 4'd2;
          // R-type
          6'b000000: ns <= 4'd6;
          // beq
          6'b000100: ns <= 4'd8;
          // bne
          6'b000_101: ns <= 4'd12;
          // addi
          6'b001000: ns <= 4'd9;
          // andi
          6'b001100: ns <= 4'd13;
          // ori
          6'b001101: ns <= 4'd13;
          // j
          6'b000010: ns <= 4'd11;
          default: ns <= 4'd0;
        endcase
      end
      // State 2: MemAdr
      4'd2: begin
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;     // set
        alusrcb <= 2'b10;    // set
        aluop <= 2'b00;      // set
        branch <= 1'b0;
        branchsrc <= 1'b0;
        case (op)
          // lw
          6'b100011: ns <= 4'd3;
          // sw
          6'b101011: ns <= 4'd5;
          default: ns <= 4'd0;
        endcase
      end
      // State 3: MemRead
      4'd3: begin
        ns <= 4'd4;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b1;        // set
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 4: Mem Writeback
      4'd4: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;  
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;     // set
        memtoreg <= 1'b1;   // set
        regwrite <= 1'b1;   // set
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 5: MemWrite
      4'd5: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b1;       // set  
        memwrite <= 1'b1;   // set
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 6: Execution
      4'd6: begin 
        ns <= 4'd7;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0; 
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;    // set     
        alusrcb <= 2'b00;   // set    
        aluop <= 2'b10;     // set      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 7: ALU Writeback
      4'd7: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b1;     // set
        memtoreg <= 1'b0;   // set
        regwrite <= 1'b1;   // set
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 8: Branch equal!
      4'd8: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b01;    // set
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;    // set     
        alusrcb <= 2'b00;   // set    
        aluop <= 2'b01;     // set      
        branch <= 1'b1;     // set
        branchsrc <= 1'b0;
      end
      // State 12: Branch not equal!
      4'd12: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b01;    // set
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;    // set     
        alusrcb <= 2'b00;   // set    
        aluop <= 2'b01;     // set      
        branch <= 1'b1;     // set
        branchsrc <= 1'b1;  // set
      end
      // State 13: for andi and ori!
      4'd13: begin
        ns <= 4'd10;        // set, same as addi, write back.
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;     // set     
        alusrcb <= 2'b10;    // set
        aluop <= 2'b10;      // set
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 9: addi execution!
      4'd9: begin
        ns <= 4'd10;        // set
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b1;     // set     
        alusrcb <= 2'b10;    // set
        aluop <= 2'b00;      // set
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // State 10: addi write-back
      4'd10: begin
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;      // set
        memtoreg <= 1'b0;    // set
        regwrite <= 1'b1;    // set
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      4'd11: begin
        ns <= 4'd0;
        pcwrite <= 1'b1;     // set
        pcsrc <= 2'b10;      // set
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
      // ERROR: Unable to recognize state!
      default: begin
        // unset everything
        ns <= 4'd0;
        pcwrite <= 1'b0;
        pcsrc <= 2'b00;
        iord <= 1'b0;
        memwrite <= 1'b0;
        irwrite <= 1'b0;
        regdst <= 1'b0;
        memtoreg <= 1'b0;
        regwrite <= 1'b0;
        alusrca <= 1'b0;     
        alusrcb <= 2'b00;    
        aluop <= 2'b00;      
        branch <= 1'b0;
        branchsrc <= 1'b0;
      end
    endcase
  end
endmodule
