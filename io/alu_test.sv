/**
 * Unit test of ALU Module
 * 
 * A potential pitfall: 
 * Run tests to show that MIPS uses big edian.
 * i.e.
 * higher bits  [0             ...                    31] lower bits
 * 1 = [0000 0000 0000 0000 0000 0000 0000 0001]
 */

module alu_test(/* void */);
  logic[31:0] left, right;
  logic[2:0]  alucontrol;
  logic[31:0] aluout;
  logic zero;

  alu alu(left, right, alucontrol, aluout, zero);
  
  initial begin
    /** ADD TEST */
    alucontrol = 3'b010;
    left = 32'd23;
    right = 32'd45;
    #10;
    assert (aluout == 32'd68) else $error("Failed on test 23+45");

    left = '1; // -1
    right = 32'd99;
    #10;
    assert (aluout == 32'd98) else $error("Failed on test 99+(-1)");
    // add more test cases HERE

    /** SUB TEST */
    alucontrol = 3'b110;
    left = 32'd44;
    right = 32'd45;
    #10;
    assert (aluout == '1) else $error("Failed on test 44-45");

    /** AND TEST */
    alucontrol = 3'b000;
    left = 32'd256;
    right = 32'd255;
    #10;
    assert (aluout == '0) else $error("Failed on test 256 & 255");

    /** OR TEST */
    alucontrol = 3'b001;
    left = 32'd257;
    right = 32'd255;
    #10;
    assert (aluout == 32'd511) else $error("Failed on test 257 | 255");

    /** SLT TEST */
    alucontrol = 3'b111;
    left = 32'd1;
    right = 32'd0;
    #10;
    assert (aluout == 32'b0) else $error("Failed on test 1 < 0");

    left = '1;
    right = '0;
    #10;
    // pitfall: -1 < 0, but -1 indeed looks larger than 0!
    assert (aluout == 32'b1) else $error("Failed on test -1 < 0");

    left = '0;
    right = '1;
    #10;
    assert (aluout == 32'b0) else $error("Failed on test 0 < -1");

    left = 32'b1111_1111_1111_1111_1111_1111_1100_0001;  // -63
    right= 32'b1111_1111_1111_1111_1111_1111_1000_0001;
    #10;
    assert (aluout == 32'b0) else $error("Failed on test -63 < -127");

    left = 32'd12;
    right = 32'd7;
    #10;
    assert (aluout == 32'b0) else $error("Failed on test 12 < 7");

    left = 32'd3;
    right = 32'd5;
    #10;
    assert (aluout == 32'b1) else $error("Failed on test 3 < 5");
  end
endmodule