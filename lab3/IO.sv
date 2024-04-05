module IO(
    input  logic clk,
    input  logic reset,
    /** linking to CPU */
    input  logic pRead,
    input  logic pWrite,
    input  logic[1:0] addr,
    input  logic[11:0] pWriteData,
    output logic[31:0] pReadData,
    /** linking to outer device(other than CPU and datapath) */
    input  logic buttonL,    // control LED
    input  logic buttonR,    // switch
    input  logic[15:0] switch,     // display on the screen
    output logic[11:0] led
);
    logic[1:0] status;
    logic[15:0] switch1;
    logic[11:0] led1;

    always_ff @(posedge clk)
    begin
      if (reset)
      begin
        status <= 2'b00;
        led1 <= 12'b00;
        switch1 <= 16'b00;
      end

      else begin
        // switch is ready for drawing inputs.
        if (buttonR) begin
          status[1] <= 1;
          switch1 <= switch;
        end
        // LED is ready, can output the result.
        if (buttonL) begin
          status[0] <= 1;
          led <= led1;
        end
        if (pWrite & (addr == 2'b01)) begin
            led1 <= pWriteData;
            status[0] <= 0;
        end
      end
    end

    always_comb begin
      if (pRead) begin
        case (addr)
          2'b11:  pReadData = {24'b0, switch1[15:8]};
          2'b10:  pReadData = {24'b0, switch1[7:0]};
          2'b00:  pReadData = {24'b0, 6'b0, status};
          default: pReadData = 32'b0;
        endcase
      end
      else begin
        pReadData = 32'b0;
      end
    end

endmodule